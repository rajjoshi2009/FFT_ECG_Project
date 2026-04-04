// =============================================
// pipeline_regs_r2.v
// Pipeline Registers between FFT stages
// 16-bit Q1.15 Fixed Point
// FFT ECG Project - B.Tech Final Year
// =============================================

module pipeline_regs_r2 #(
    parameter WIDTH = 16,
    parameter DEPTH = 16
)(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    en,
    input  wire signed [WIDTH-1:0] data_real_in [0:DEPTH-1],
    input  wire signed [WIDTH-1:0] data_imag_in [0:DEPTH-1],
    output reg  signed [WIDTH-1:0] data_real_out [0:DEPTH-1],
    output reg  signed [WIDTH-1:0] data_imag_out [0:DEPTH-1]
);

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                data_real_out[i] <= {WIDTH{1'b0}};
                data_imag_out[i] <= {WIDTH{1'b0}};
            end
        end
        else if (en) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                data_real_out[i] <= data_real_in[i];
                data_imag_out[i] <= data_imag_in[i];
            end
        end
    end

endmodule