// =============================================
// butterfly_r2.v
// Radix-2 Butterfly Unit
// 16-bit Q1.15 Fixed Point
// FFT ECG Project - B.Tech Final Year
// =============================================

module butterfly_r2 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,

    // Input A (complex)
    input  wire signed [15:0] a_real,
    input  wire signed [15:0] a_imag,

    // Input B (complex)
    input  wire signed [15:0] b_real,
    input  wire signed [15:0] b_imag,

    // Twiddle factor W (complex, Q1.15)
    input  wire signed [15:0] w_real,
    input  wire signed [15:0] w_imag,

    // Output P = A + W*B (complex)
    output reg  signed [15:0] p_real,
    output reg  signed [15:0] p_imag,

    // Output Q = A - W*B (complex)
    output reg  signed [15:0] q_real,
    output reg  signed [15:0] q_imag,

    output reg         valid_out
);

    // ---- Complex multiply W * B ----
    // (w_real + j*w_imag) * (b_real + j*b_imag)
    // = (w_real*b_real - w_imag*b_imag) 
    //   + j(w_real*b_imag + w_imag*b_real)

    wire signed [31:0] wb_real_full;
    wire signed [31:0] wb_imag_full;

    assign wb_real_full = (w_real * b_real) - (w_imag * b_imag);
    assign wb_imag_full = (w_real * b_imag) + (w_imag * b_real);

    // Scale back from Q2.30 to Q1.15
    // by taking bits [30:15]
    wire signed [15:0] wb_real;
    wire signed [15:0] wb_imag;

    assign wb_real = wb_real_full[30:15];
    assign wb_imag = wb_imag_full[30:15];

    // ---- Butterfly outputs ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_real    <= 16'd0;
            p_imag    <= 16'd0;
            q_real    <= 16'd0;
            q_imag    <= 16'd0;
            valid_out <= 1'b0;
        end
        else if (valid_in) begin
            // P = A + WB
            p_real <= a_real + wb_real;
            p_imag <= a_imag + wb_imag;

            // Q = A - WB
            q_real <= a_real - wb_real;
            q_imag <= a_imag - wb_imag;

            valid_out <= 1'b1;
        end
        else begin
            valid_out <= 1'b0;
        end
    end

endmodule