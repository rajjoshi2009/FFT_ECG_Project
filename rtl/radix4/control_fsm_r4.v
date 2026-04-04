// =============================================
// control_fsm_r4.v
// Control FSM for Radix-4 FFT
// States: IDLE->LOAD->STAGE1->STAGE2->OUTPUT
// Clock gating on IDLE for ultra low power
// FFT ECG Project - B.Tech Final Year
// =============================================

module control_fsm_r4 (
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,

    output reg [3:0] sample_addr,
    output reg [1:0] twiddle_addr,
    output reg [1:0] bf_sel,
    output reg       load_en,
    output reg       stage1_en,
    output reg       stage2_en,
    output reg       reg_en,
    output reg       valid_out,
    output reg       clk_gate
);

    // States
    localparam IDLE   = 3'd0;
    localparam LOAD   = 3'd1;
    localparam STAGE1 = 3'd2;
    localparam STAGE2 = 3'd3;
    localparam OUTPUT = 3'd4;

    reg [2:0] state;
    reg [4:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            count        <= 5'd0;
            sample_addr  <= 4'd0;
            twiddle_addr <= 2'd0;
            bf_sel       <= 2'd0;
            load_en      <= 1'b0;
            stage1_en    <= 1'b0;
            stage2_en    <= 1'b0;
            reg_en       <= 1'b0;
            valid_out    <= 1'b0;
            clk_gate     <= 1'b0;
        end
        else begin
            case (state)

                IDLE: begin
                    // Clock gated here - ultra low power
                    clk_gate  <= 1'b0;
                    load_en   <= 1'b0;
                    stage1_en <= 1'b0;
                    stage2_en <= 1'b0;
                    valid_out <= 1'b0;
                    count     <= 5'd0;
                    if (valid_in) begin
                        state    <= LOAD;
                        clk_gate <= 1'b1;
                    end
                end

                LOAD: begin
                    load_en     <= 1'b1;
                    stage1_en   <= 1'b0;
                    sample_addr <= count[3:0];
                    count       <= count + 1;
                    if (count == 5'd15) begin
                        state <= STAGE1;
                        count <= 5'd0;
                    end
                end

                STAGE1: begin
                    load_en      <= 1'b0;
                    stage1_en    <= 1'b1;
                    stage2_en    <= 1'b0;
                    twiddle_addr <= count[1:0];
                    bf_sel       <= count[1:0];
                    count        <= count + 1;
                    if (count == 5'd3) begin
                        state  <= STAGE2;
                        count  <= 5'd0;
                        reg_en <= 1'b1;
                    end
                end

                STAGE2: begin
                    stage1_en    <= 1'b0;
                    stage2_en    <= 1'b1;
                    reg_en       <= 1'b0;
                    twiddle_addr <= count[1:0];
                    bf_sel       <= count[1:0];
                    count        <= count + 1;
                    if (count == 5'd3) begin
                        state <= OUTPUT;
                        count <= 5'd0;
                    end
                end

                OUTPUT: begin
                    stage2_en <= 1'b0;
                    valid_out <= 1'b1;
                    count     <= count + 1;
                    if (count == 5'd15) begin
                        state    <= IDLE;
                        clk_gate <= 1'b0;
                        count    <= 5'd0;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule