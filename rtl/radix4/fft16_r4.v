// =============================================
// fft16_r4.v
// Top Level - 16 Point Radix-4 DIT FFT
// 16-bit Q1.15 Fixed Point
// 2 stages - ultra low power iterative
// FFT ECG Project - B.Tech Final Year
// =============================================

module fft16_r4 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,

    input  wire signed [15:0] x_real,
    input  wire signed [15:0] x_imag,

    output wire signed [15:0] X_real [0:15],
    output wire signed [15:0] X_imag [0:15],

    output wire        valid_out
);

    // ---- Internal signals ----
    wire [3:0] sample_addr;
    wire [1:0] twiddle_addr;
    wire [1:0] bf_sel;
    wire       load_en;
    wire       stage1_en;
    wire       stage2_en;
    wire       reg_en;
    wire       clk_gate;

    // ---- Gated clock for ultra low power ----
    wire clk_gated;
    assign clk_gated = clk & clk_gate;

    // ---- Memory ----
    reg signed [15:0] mem_real [0:15];
    reg signed [15:0] mem_imag [0:15];

    // ---- Stage register ----
    wire signed [15:0] sreg_real [0:15];
    wire signed [15:0] sreg_imag [0:15];

    // ---- Bit reversed address ----
    wire [3:0] br_addr;

    // ---- Twiddle factors ----
    wire signed [15:0] w_real, w_imag;

    // ---- Butterfly outputs ----
    wire signed [15:0] y0_real, y0_imag;
    wire signed [15:0] y1_real, y1_imag;
    wire signed [15:0] y2_real, y2_imag;
    wire signed [15:0] y3_real, y3_imag;
    wire               bf_valid;

    // ---- Butterfly input selection ----
    wire signed [15:0] bx0_real, bx0_imag;
    wire signed [15:0] bx1_real, bx1_imag;
    wire signed [15:0] bx2_real, bx2_imag;
    wire signed [15:0] bx3_real, bx3_imag;

    // Select 4 inputs based on butterfly group
    assign bx0_real = mem_real[{bf_sel, 2'b00}];
    assign bx0_imag = mem_imag[{bf_sel, 2'b00}];
    assign bx1_real = mem_real[{bf_sel, 2'b01}];
    assign bx1_imag = mem_imag[{bf_sel, 2'b01}];
    assign bx2_real = mem_real[{bf_sel, 2'b10}];
    assign bx2_imag = mem_imag[{bf_sel, 2'b10}];
    assign bx3_real = mem_real[{bf_sel, 2'b11}];
    assign bx3_imag = mem_imag[{bf_sel, 2'b11}];

    // ---- Twiddle W2 and W3 derived ----
    wire signed [15:0] w2_real, w2_imag;
    wire signed [15:0] w3_real, w3_imag;

    // W2 from ROM addr+1, W3 from ROM addr+2
    // For simplicity use ROM with offset
    wire signed [15:0] rom_w1_real, rom_w1_imag;
    wire signed [15:0] rom_w2_real, rom_w2_imag;
    wire signed [15:0] rom_w3_real, rom_w3_imag;

    // ---- Instantiate submodules ----
    control_fsm_r4 u_fsm (
        .clk         (clk),
        .rst_n       (rst_n),
        .valid_in    (valid_in),
        .sample_addr (sample_addr),
        .twiddle_addr(twiddle_addr),
        .bf_sel      (bf_sel),
        .load_en     (load_en),
        .stage1_en   (stage1_en),
        .stage2_en   (stage2_en),
        .reg_en      (reg_en),
        .valid_out   (valid_out),
        .clk_gate    (clk_gate)
    );

    bit_reversal_r4 u_br (
        .addr_in  (sample_addr),
        .addr_out (br_addr)
    );

    twiddle_rom_r4 u_rom1 (
        .addr   (2'd0),
        .w_real (rom_w1_real),
        .w_imag (rom_w1_imag)
    );

    twiddle_rom_r4 u_rom2 (
        .addr   (2'd1),
        .w_real (rom_w2_real),
        .w_imag (rom_w2_imag)
    );

    twiddle_rom_r4 u_rom3 (
        .addr   (2'd2),
        .w_real (rom_w3_real),
        .w_imag (rom_w3_imag)
    );

    butterfly_r4 u_bf (
        .clk      (clk_gated),
        .rst_n    (rst_n),
        .valid_in (stage1_en | stage2_en),
        .x0_real  (bx0_real), .x0_imag (bx0_imag),
        .x1_real  (bx1_real), .x1_imag (bx1_imag),
        .x2_real  (bx2_real), .x2_imag (bx2_imag),
        .x3_real  (bx3_real), .x3_imag (bx3_imag),
        .w1_real  (rom_w1_real), .w1_imag (rom_w1_imag),
        .w2_real  (rom_w2_real), .w2_imag (rom_w2_imag),
        .w3_real  (rom_w3_real), .w3_imag (rom_w3_imag),
        .y0_real  (y0_real), .y0_imag (y0_imag),
        .y1_real  (y1_real), .y1_imag (y1_imag),
        .y2_real  (y2_real), .y2_imag (y2_imag),
        .y3_real  (y3_real), .y3_imag (y3_imag),
        .valid_out(bf_valid)
    );

    stage_regs u_sreg (
        .clk      (clk),
        .rst_n    (rst_n),
        .en       (reg_en),
        .din_real (mem_real),
        .din_imag (mem_imag),
        .dout_real(sreg_real),
        .dout_imag(sreg_imag)
    );

    // ---- Memory control ----
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 16; i = i + 1) begin
                mem_real[i] <= 16'd0;
                mem_imag[i] <= 16'd0;
            end
        end
        else if (load_en) begin
            mem_real[br_addr] <= x_real;
            mem_imag[br_addr] <= x_imag;
        end
        else if (bf_valid) begin
            mem_real[{bf_sel, 2'b00}] <= y0_real;
            mem_imag[{bf_sel, 2'b00}] <= y0_imag;
            mem_real[{bf_sel, 2'b01}] <= y1_real;
            mem_imag[{bf_sel, 2'b01}] <= y1_imag;
            mem_real[{bf_sel, 2'b10}] <= y2_real;
            mem_imag[{bf_sel, 2'b10}] <= y2_imag;
            mem_real[{bf_sel, 2'b11}] <= y3_real;
            mem_imag[{bf_sel, 2'b11}] <= y3_imag;
        end
    end

    // ---- Output assignments ----
    genvar k;
    generate
        for (k = 0; k < 16; k = k + 1) begin : out_assign
            assign X_real[k] = mem_real[k];
            assign X_imag[k] = mem_imag[k];
        end
    endgenerate

endmodule