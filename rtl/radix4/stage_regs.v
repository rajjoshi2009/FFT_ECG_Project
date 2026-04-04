// =============================================
// stage_regs.v
// Pipeline Register between Stage 1 and Stage 2
// Radix-4 FFT
// 16-bit Q1.15 Fixed Point
// FFT ECG Project - B.Tech Final Year
// =============================================

module stage_regs (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,

    input  wire signed [15:0] din_real  [0:15],
    input  wire signed [15:0] din_imag  [0:15],

    output reg  signed [15:0] dout_real [0:15],
    output reg  signed [15:0] dout_imag [0:15]
);

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 16; i = i + 1) begin
                dout_real[i] <= 16'd0;
                dout_imag[i] <= 16'd0;
            end
        end
        else if (en) begin
            for (i = 0; i < 16; i = i + 1) begin
                dout_real[i] <= din_real[i];
                dout_imag[i] <= din_imag[i];
            end
        end
    end

endmodule