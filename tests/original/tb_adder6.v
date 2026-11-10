`timescale 1ns/1ps

module tb_adder6_only;

    reg  [5:0] a;
    reg  [5:0] b;
    wire [6:0] sum;

    // Pure 6-bit unsigned adder only
    ripple_adder #(.N(6)) dut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    task apply_test;
        input [5:0] ta;
        input [5:0] tb;
        input [6:0] expected;
        begin
            a = ta;
            b = tb;
            #10;

            if (sum === expected)
                $display("PASS: a=%b b=%b sum=%b expected=%b", a, b, sum, expected);
            else
                $display("FAIL: a=%b b=%b sum=%b expected=%b", a, b, sum, expected);
        end
    endtask

    initial begin
`ifdef FSDB
        $fsdbDumpfile("waves/adder6_only.fsdb");
        $fsdbDumpvars(0, tb_adder6_only);
`else
        $dumpfile("waves/adder6_only.vcd");
        $dumpvars(0, tb_adder6_only);
`endif
    end

    initial begin
        a = 6'b000000;
        b = 6'b000000;

        #10;

        // Test 1: zero + zero
        apply_test(6'b000000, 6'b000000, 7'b0000000);  // 0 + 0 = 0

        // Test 2: no carry
        apply_test(6'b000011, 6'b000100, 7'b0000111);  // 3 + 4 = 7

        // Test 3: simple carry
        apply_test(6'b001111, 6'b000001, 7'b0010000);  // 15 + 1 = 16

        // Test 4: long carry propagation
        apply_test(6'b111111, 6'b000001, 7'b1000000);  // 63 + 1 = 64

        // Test 5: maximum + maximum
        apply_test(6'b111111, 6'b111111, 7'b1111110);  // 63 + 63 = 126

        // Test 6: random middle value
        apply_test(6'b101010, 6'b010101, 7'b0111111);  // 42 + 21 = 63

        // Test 7: another random value
        apply_test(6'b100000, 6'b011111, 7'b0111111);  // 32 + 31 = 63

        #20;
        $finish;
    end

endmodule