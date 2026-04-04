// =============================================
// butterfly_r4.v
// Radix-4 Butterfly Unit
// 16-bit Q1.15 Fixed Point
// 4 inputs -> 4 outputs
// 3 real multiplications only
// FFT ECG Project - B.Tech Final Year
// =============================================

module butterfly_r4 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,

    // 4 complex inputs
    input  wire signed [15:0] x0_real, x0_imag,
    input  wire signed [15:0] x1_real, x1_imag,
    input  wire signed [15:0] x2_real, x2_imag,
    input  wire signed [15:0] x3_real, x3_imag,

    // Twiddle factors W1 W2 W3
    input  wire signed [15:0] w1_real, w1_imag,
    input  wire signed [15:0] w2_real, w2_imag,
    input  wire signed [15:0] w3_real, w3_imag,

    // 4 complex outputs
    output reg  signed [15:0] y0_real, y0_imag,
    output reg  signed [15:0] y1_real, y1_imag,
    output reg  signed [15:0] y2_real, y2_imag,
    output reg  signed [15:0] y3_real, y3_imag,

    output reg         valid_out
);

    // ---- Complex multiply W1*x1 ----
    wire signed [31:0] w1x1_real_full, w1x1_imag_full;
    assign w1x1_real_full = (w1_real * x1_real) - (w1_imag * x1_imag);
    assign w1x1_imag_full = (w1_real * x1_imag) + (w1_imag * x1_real);
    wire signed [15:0] w1x1_real, w1x1_imag;
    assign w1x1_real = w1x1_real_full[30:15];
    assign w1x1_imag = w1x1_imag_full[30:15];

    // ---- Complex multiply W2*x2 ----
    wire signed [31:0] w2x2_real_full, w2x2_imag_full;
    assign w2x2_real_full = (w2_real * x2_real) - (w2_imag * x2_imag);
    assign w2x2_imag_full = (w2_real * x2_imag) + (w2_imag * x2_real);
    wire signed [15:0] w2x2_real, w2x2_imag;
    assign w2x2_real = w2x2_real_full[30:15];
    assign w2x2_imag = w2x2_imag_full[30:15];

    // ---- Complex multiply W3*x3 ----
    wire signed [31:0] w3x3_real_full, w3x3_imag_full;
    assign w3x3_real_full = (w3_real * x3_real) - (w3_imag * x3_imag);
    assign w3x3_imag_full = (w3_real * x3_imag) + (w3_imag * x3_real);
    wire signed [15:0] w3x3_real, w3x3_imag;
    assign w3x3_real = w3x3_real_full[30:15];
    assign w3x3_imag = w3x3_imag_full[30:15];

    // ---- Stage 1 additions ----
    // a = x0 + w2x2
    // b = x0 - w2x2
    // c = w1x1 + w3x3
    // d = w1x1 - w3x3  -> multiply by j = swap and negate real

    wire signed [15:0] a_real, a_imag;
    wire signed [15:0] b_real, b_imag;
    wire signed [15:0] c_real, c_imag;
    wire signed [15:0] d_real, d_imag;

    assign a_real = x0_real + w2x2_real;
    assign a_imag = x0_imag + w2x2_imag;

    assign b_real = x0_real - w2x2_real;
    assign b_imag = x0_imag - w2x2_imag;

    assign c_real = w1x1_real + w3x3_real;
    assign c_imag = w1x1_imag + w3x3_imag;

    // d = (w1x1 - w3x3) * (-j)
    // multiply by -j: real = imag, imag = -real
    wire signed [15:0] diff_real, diff_imag;
    assign diff_real = w1x1_real - w3x3_real;
    assign diff_imag = w1x1_imag - w3x3_imag;
    assign d_real =  diff_imag;
    assign d_imag = -diff_real;

    // ---- Final butterfly outputs ----
    // Y0 = a + c
    // Y1 = b + d
    // Y2 = a - c
    // Y3 = b - d

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y0_real <= 16'd0; y0_imag <= 16'd0;
            y1_real <= 16'd0; y1_imag <= 16'd0;
            y2_real <= 16'd0; y2_imag <= 16'd0;
            y3_real <= 16'd0; y3_imag <= 16'd0;
            valid_out <= 1'b0;
        end
        else if (valid_in) begin
            y0_real <= a_real + c_real;
            y0_imag <= a_imag + c_imag;

            y1_real <= b_real + d_real;
            y1_imag <= b_imag + d_imag;

            y2_real <= a_real - c_real;
            y2_imag <= a_imag - c_imag;

            y3_real <= b_real - d_real;
            y3_imag <= b_imag - d_imag;

            valid_out <= 1'b1;
        end
        else begin
            valid_out <= 1'b0;
        end
    end

endmodule