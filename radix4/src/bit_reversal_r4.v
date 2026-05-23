// =============================================
// bit_reversal_r4.v
// Radix-4 Digit Reversal Network (16-point)
// Pure combinational - Zero latency, zero area
// FFT ECG Project - B.Tech Final Year
// =============================================

module bit_reversal_r4 (
    input  wire [3:0] addr_in,
    output wire [3:0] addr_out
);

    // In Radix-4, we reverse the 2-bit digits (base-4 positions).
    // For a 4-bit address space:
    // Upper digit [3:2] moves to Lower digit [1:0]
    // Lower digit [1:0] moves to Upper digit [3:2]
    
    assign addr_out = {addr_in[1:0], addr_in[3:2]};

endmodule
