`timescale 1ps/1ps

module tb_bist_adder6;
    reg clk;
    reg reset;
    wire [3:0] lfsr_state;
    wire [5:0] a;
    wire [5:0] b;
    wire [6:0] sum;
    wire [6:0] signature;
    wire [4:0] pattern_count;
    wire done;

    integer PERIOD_PS;
    integer cycles;
    reg [1024*8:1] sdf_file;

    localparam [6:0] GOLDEN_SIGNATURE = 7'h4d;

    bist_adder6 dut (
        .clk(clk),
        .reset(reset),
        .lfsr_state(lfsr_state),
        .a(a),
        .b(b),
        .sum(sum),
        .signature(signature),
        .pattern_count(pattern_count),
        .done(done)
    );

    initial begin
        if (!$value$plusargs("PERIOD_PS=%d", PERIOD_PS)) PERIOD_PS = 10000; // 100 MHz
        clk = 1'b0;
        forever #(PERIOD_PS/2) clk = ~clk;
    end

    initial begin
`ifdef GATE
        if (!$value$plusargs("SDF=%s", sdf_file)) sdf_file = "build/syn6/bist_adder6_syn.sdf";
        $display("Annotating SDF: %0s", sdf_file);
        $sdf_annotate("build/syn6/bist_adder6_syn.sdf", tb_bist_adder6.dut);
`endif
    end

    initial begin
`ifdef FSDB
        $fsdbDumpfile("waves/bist6_gate.fsdb");
        $fsdbDumpvars(0, tb_bist_adder6);
`else
        $dumpfile("waves/bist6.vcd");
        $dumpvars(0, tb_bist_adder6);
`endif
    end

    initial begin
        reset = 1'b1;
        cycles = 0;
        repeat (2) @(negedge clk);
        reset = 1'b0;

        while ((done !== 1'b1) && (cycles < 100)) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        @(negedge clk);
        $display("HW3_RESULT N=6 PERIOD_PS=%0d signature=0x%0h expected=0x%0h done=%0b cycles=%0d",
                 PERIOD_PS, signature, GOLDEN_SIGNATURE, done, cycles);

        if ((done !== 1'b1) || (^signature === 1'bx) || (signature !== GOLDEN_SIGNATURE)) begin
            $display("HW3_FAIL");
            $finish(1);
        end else begin
            $display("HW3_PASS");
            $finish(0);
        end
    end
endmodule
