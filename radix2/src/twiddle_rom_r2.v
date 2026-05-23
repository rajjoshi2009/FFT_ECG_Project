// =============================================
// twiddle_rom_r2.v
// Twiddle Factor ROM for Radix-2 FFT
// 16-bit Q1.15 Fixed Point
// W16^0 to W16^7 stored
// FFT ECG Project - B.Tech Final Year
// =============================================

module twiddle_rom_r2 (
    input  wire [2:0]  addr,      // 0 to 7
    output reg  signed [15:0] w_real,
    output reg  signed [15:0] w_imag
);

    // W16^k = cos(2*pi*k/16) - j*sin(2*pi*k/16)
    // All values in Q1.15 format
    // Q1.15 = value * 32768

    always @(*) begin
        case (addr)
            // W16^0 = 1 + j*0
            3'd0 : begin w_real = 16'h7FFF; w_imag = 16'h0000; end

            // W16^1 = 0.9239 - j*0.3827
            3'd1 : begin w_real = 16'h7642; w_imag = 16'hCF04; end

            // W16^2 = 0.7071 - j*0.7071
            3'd2 : begin w_real = 16'h5A82; w_imag = 16'hA57E; end

            // W16^3 = 0.3827 - j*0.9239
            3'd3 : begin w_real = 16'h30FC; w_imag = 16'h89BE; end

            // W16^4 = 0 - j*1
            3'd4 : begin w_real = 16'h0000; w_imag = 16'h8001; end

            // W16^5 = -0.3827 - j*0.9239
            3'd5 : begin w_real = 16'hCF04; w_imag = 16'h89BE; end

            // W16^6 = -0.7071 - j*0.7071
            3'd6 : begin w_real = 16'hA57E; w_imag = 16'hA57E; end

            // W16^7 = -0.9239 - j*0.3827
            3'd7 : begin w_real = 16'h89BE; w_imag = 16'hCF04; end

            default : begin w_real = 16'h0000; w_imag = 16'h0000; end
        endcase
    end

endmodule