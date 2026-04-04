// =============================================
// bit_reversal_r2.v
// Bit Reversal Unit for Radix-2 FFT
// N=16, 4-bit index reversed
// FFT ECG Project - B.Tech Final Year
// =============================================

module bit_reversal_r2 (
    input  wire [3:0] addr_in,
    output reg  [3:0] addr_out
);

    // Bit reverse 4-bit index
    // Example: 0001 (1) -> 1000 (8)
    // Full table for N=16

    always @(*) begin
        case (addr_in)
            4'd0  : addr_out = 4'd0;   // 0000 -> 0000
            4'd1  : addr_out = 4'd8;   // 0001 -> 1000
            4'd2  : addr_out = 4'd4;   // 0010 -> 0100
            4'd3  : addr_out = 4'd12;  // 0011 -> 1100
            4'd4  : addr_out = 4'd2;   // 0100 -> 0010
            4'd5  : addr_out = 4'd10;  // 0101 -> 1010
            4'd6  : addr_out = 4'd6;   // 0110 -> 0110
            4'd7  : addr_out = 4'd14;  // 0111 -> 1110
            4'd8  : addr_out = 4'd1;   // 1000 -> 0001
            4'd9  : addr_out = 4'd9;   // 1001 -> 1001
            4'd10 : addr_out = 4'd5;   // 1010 -> 0101
            4'd11 : addr_out = 4'd13;  // 1011 -> 1101
            4'd12 : addr_out = 4'd3;   // 1100 -> 0011
            4'd13 : addr_out = 4'd11;  // 1101 -> 1011
            4'd14 : addr_out = 4'd7;   // 1110 -> 0111
            4'd15 : addr_out = 4'd15;  // 1111 -> 1111
            default: addr_out = 4'd0;
        endcase
    end

endmodule