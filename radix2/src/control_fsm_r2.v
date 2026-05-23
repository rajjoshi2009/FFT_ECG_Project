// =============================================
// control_fsm_r2.v
// Control FSM for Radix-2 FFT
// FFT ECG Project - B.Tech Final Year
// =============================================

module control_fsm_r2 (
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,

    output reg [3:0] sample_addr,
    output reg [1:0] stage,
    output reg [2:0] twiddle_addr,
    output reg       load_en,
    output reg       compute_en,
    output reg       valid_out,
    output reg       clk_gate
);

    // States
    localparam IDLE    = 2'd0;
    localparam LOAD    = 2'd1;
    localparam COMPUTE = 2'd2;
    localparam OUTPUT  = 2'd3;

    reg [1:0] state;
    reg [4:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            count        <= 5'd0;
            sample_addr  <= 4'd0;
            stage        <= 2'd0;
            twiddle_addr <= 3'd0;
            load_en      <= 1'b0;
            compute_en   <= 1'b0;
            valid_out    <= 1'b0;
            clk_gate     <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    load_en    <= 1'b0;
                    compute_en <= 1'b0;
                    valid_out  <= 1'b0;
                    clk_gate   <= 1'b0;  // clock gated in IDLE
                    count      <= 5'd0;
                    if (valid_in) begin
                        state    <= LOAD;
                        clk_gate <= 1'b1;
                    end
                end

                LOAD: begin
                    load_en     <= 1'b1;
                    compute_en  <= 1'b0;
                    sample_addr <= count[3:0];
                    count       <= count + 1;
                    if (count == 5'd15) begin
                        state <= COMPUTE;
                        count <= 5'd0;
                        stage <= 2'd0;
                    end
                end

                COMPUTE: begin
                    load_en    <= 1'b0;
                    compute_en <= 1'b1;
                    twiddle_addr <= count[2:0];
                    count <= count + 1;
                    if (count == 5'd7) begin
                        count <= 5'd0;
                        stage <= stage + 1;
                        if (stage == 2'd3) begin
                            state <= OUTPUT;
                        end
                    end
                end

                OUTPUT: begin
                    compute_en <= 1'b0;
                    valid_out  <= 1'b1;
                    count      <= count + 1;
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