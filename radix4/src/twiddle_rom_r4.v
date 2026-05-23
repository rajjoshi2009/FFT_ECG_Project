// =============================================
// twiddle_rom_r4.v
// Twiddle Factor ROM for Radix-4 FFT
// Only W1 W2 W3 stored - W0 and W4 are wires
// 16-bit Q1.15 Fixed Point
// FFT ECG Project - B.Tech Final Year
// =============================================

module twiddle_rom_r4 (
    input  wire [1:0]  addr,
    output reg  signed [15:0] w_real,
    output reg  signed [15:0] w_imag
);

    // Only 3 entries needed
    // W16^1 W16^2 W16^3
    // W16^0 = 1+j0  -> handled as wire
    // W16^4 = 0-j1  -> handled as wire (swap+negate)

    always @(*) begin
        case (addr)
            // W16^1 = 0.9239 - j0.3827
            2'd0 : begin w_real = 16'h7642; w_imag = 16'hCF04; end

            // W16^2 = 0.7071 - j0.7071
            2'd1 : begin w_real = 16'h5A82; w_imag = 16'hA57E; end

            // W16^3 = 0.3827 - j0.9239
            2'd2 : begin w_real = 16'h30FC; w_imag = 16'h89BE; end

            default : begin w_real = 16'h7FFF; w_imag = 16'h0000; end
        endcase
    end

endmodule