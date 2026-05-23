// =============================================
// stage_regs.v
// Pipeline Register between Stage 1 and Stage 2
// Radix-4 FFT - Flattened Port Version
// 16-bit Q1.15 Fixed Point
// FFT ECG Project - B.Tech Final Year
// =============================================

module stage_regs (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,

    // Flattened 256-bit input buses
    input  wire signed [255:0] din_real,
    input  wire signed [255:0] din_imag,

    // Flattened 256-bit output buses
    output reg  signed [255:0] dout_real,
    output reg  signed [255:0] dout_imag
);

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dout_real <= 256'd0;
            dout_imag <= 256'd0;
        end
        else if (en) begin
            for (i = 0; i < 16; i = i + 1) begin
                dout_real[(i*16)+15 : i*16] <= din_real[(i*16)+15 : i*16];
                dout_imag[(i*16)+15 : i*16] <= din_imag[(i*16)+15 : i*16];
            end
        end
    end

endmodule
