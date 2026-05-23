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
    
    // Flattened 1D vector ports (16 * 16 = 256 bits wide)
    input  wire signed [(WIDTH*DEPTH)-1:0] data_real_in,
    input  wire signed [(WIDTH*DEPTH)-1:0] data_imag_in,
    output reg  signed [(WIDTH*DEPTH)-1:0] data_real_out,
    output reg  signed [(WIDTH*DEPTH)-1:0] data_imag_out
);

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_real_out <= {(WIDTH*DEPTH){1'b0}};
            data_imag_out <= {(WIDTH*DEPTH){1'b0}};
        end
        else if (en) begin
            // Loop slices the flat input vectors directly into the flat output vectors
            for (i = 0; i < DEPTH; i = i + 1) begin
                data_real_out[i*WIDTH +: WIDTH] <= data_real_in[i*WIDTH +: WIDTH];
                data_imag_out[i*WIDTH +: WIDTH] <= data_imag_in[i*WIDTH +: WIDTH];
            end
        end
    end

endmodule
