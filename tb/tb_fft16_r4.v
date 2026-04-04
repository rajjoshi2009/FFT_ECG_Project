// =============================================
// tb_fft16_r4.v
// Testbench for Radix-4 FFT
// Same test vectors as Radix-2 testbench
// FFT ECG Project - B.Tech Final Year
// =============================================

`timescale 1ns/1ps

module tb_fft16_r4;

    // ---- Clock and reset ----
    reg clk;
    reg rst_n;

    always #5 clk = ~clk;  // 100 MHz

    // ---- DUT signals ----
    reg         valid_in;
    reg  signed [15:0] x_real;
    reg  signed [15:0] x_imag;
    wire signed [15:0] X_real [0:15];
    wire signed [15:0] X_imag [0:15];
    wire        valid_out;

    // ---- Test vectors ----
    reg [15:0] input_vec [0:15];
    reg [15:0] exp_real  [0:15];
    reg [15:0] exp_imag  [0:15];

    integer i, errors;

    // ---- Instantiate DUT ----
    fft16_r4 uut (
        .clk      (clk),
        .rst_n    (rst_n),
        .valid_in (valid_in),
        .x_real   (x_real),
        .x_imag   (x_imag),
        .X_real   (X_real),
        .X_imag   (X_imag),
        .valid_out(valid_out)
    );

    // ---- SAIF dump for power analysis ----
    initial begin
        $dumpfile("activity_r4.vcd");
        $dumpvars(0, tb_fft16_r4);
    end

    // ---- Main test ----
    initial begin
        // Load same vectors as R2 for fair comparison
        $readmemh("input_vectors.txt",  input_vec);
        $readmemh("expected_real.txt",  exp_real);
        $readmemh("expected_imag.txt",  exp_imag);

        // Initialise
        clk      = 0;
        rst_n    = 0;
        valid_in = 0;
        x_real   = 0;
        x_imag   = 0;
        errors   = 0;

        // Reset
        #20 rst_n = 1;
        #10;

        // Feed 16 input samples
        valid_in = 1;
        for (i = 0; i < 16; i = i + 1) begin
            x_real = input_vec[i];
            x_imag = 16'd0;
            @(posedge clk);
        end
        valid_in = 0;

        // Wait for output
        wait (valid_out == 1);
        #10;

        // Check outputs
        $display("=== FFT Radix-4 Output Check ===");
        for (i = 0; i < 16; i = i + 1) begin
            if (X_real[i] !== exp_real[i] || X_imag[i] !== exp_imag[i]) begin
                $display("MISMATCH bin %0d: got real=%h imag=%h  expected real=%h imag=%h",
                    i, X_real[i], X_imag[i], exp_real[i], exp_imag[i]);
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display("*** TESTBENCH PASSED - All 16 bins correct ***");
        else
            $display("*** TESTBENCH FAILED - %0d errors found ***", errors);

        $finish;
    end

endmodule