// =============================================
// fft16_r2.v
// Top Level - 16 Point Radix-2 DIT FFT
// 16-bit Q1.15 Fixed Point
// FFT ECG Project - B.Tech Final Year
// =============================================

module fft16_r2 (
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
    wire [1:0] stage;
    wire [2:0] twiddle_addr;
    wire       load_en;
    wire       compute_en;
    wire       clk_gate;

    // ---- Gated clock ----
    wire clk_gated;
    assign clk_gated = clk & clk_gate;

    // ---- Sample memory ----
    reg signed [15:0] mem_real [0:15];
    reg signed [15:0] mem_imag [0:15];

    // ---- Bit reversed address ----
    wire [3:0] br_addr;

    // ---- Twiddle factor ----
    wire signed [15:0] w_real;
    wire signed [15:0] w_imag;

    // ---- Butterfly outputs ----
    wire signed [15:0] p_real, p_imag;
    wire signed [15:0] q_real, q_imag;
    wire               bf_valid;

    // ---- Instantiate submodules ----
    control_fsm_r2 u_fsm (
        .clk         (clk),
        .rst_n       (rst_n),
        .valid_in    (valid_in),
        .sample_addr (sample_addr),
        .stage       (stage),
        .twiddle_addr(twiddle_addr),
        .load_en     (load_en),
        .compute_en  (compute_en),
        .valid_out   (valid_out),
        .clk_gate    (clk_gate)
    );

    bit_reversal_r2 u_br (
        .addr_in  (sample_addr),
        .addr_out (br_addr)
    );

    twiddle_rom_r2 u_rom (
        .addr   (twiddle_addr),
        .w_real (w_real),
        .w_imag (w_imag)
    );

    butterfly_r2 u_bf (
        .clk      (clk_gated),
        .rst_n    (rst_n),
        .valid_in (compute_en),
        .a_real   (mem_real[sample_addr]),
        .a_imag   (mem_imag[sample_addr]),
        .b_real   (mem_real[sample_addr + 1]),
        .b_imag   (mem_imag[sample_addr + 1]),
        .w_real   (w_real),
        .w_imag   (w_imag),
        .p_real   (p_real),
        .p_imag   (p_imag),
        .q_real   (q_real),
        .q_imag   (q_imag),
        .valid_out(bf_valid)
    );

    // ---- Load samples into memory ----
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
            mem_real[sample_addr]     <= p_real;
            mem_imag[sample_addr]     <= p_imag;
            mem_real[sample_addr + 1] <= q_real;
            mem_imag[sample_addr + 1] <= q_imag;
        end
    end

    // ---- Output ----
    genvar k;
    generate
        for (k = 0; k < 16; k = k + 1) begin : out_assign
            assign X_real[k] = mem_real[k];
            assign X_imag[k] = mem_imag[k];
        end
    endgenerate

endmodule