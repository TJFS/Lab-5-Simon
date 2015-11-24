//===============================================================================
// Testbench Module for Simon Datapath
//===============================================================================
`timescale 1ns/100ps

`include "SimonDatapath.v"

// Print an error message (MSG) if value ONE is not equal
// to value TWO.
`define ASSERT_EQ(ONE, TWO, MSG)               \
    begin                                      \
        if ((ONE) !== (TWO)) begin             \
            $display("\t[FAILURE]:%s", (MSG)); \
        end                                    \
    end #0

// Set the variable VAR to the value VALUE, printing a notification
// to the screen indicating the variable's update.
// The setting of the variable is preceeded and followed by
// a 1-timestep delay.
`define SET(VAR, VALUE) $display("Setting %s to %s...", "VAR", "VALUE"); #1; VAR = (VALUE); #1

// Cycle the clock up and then down, simulating
// a button press.
`define CLOCK $display("Pressing uclk..."); #1; clk = 1; #1; clk = 0; #1

module SimonDatapathTest;

    // Local Vars
    reg clk = 0;
    reg level = 0;
    reg [3:0] pattern = 4'b0000;

    reg of_set = 0;
    reg reset = 0;
    reg p_write = 0;
    reg psi_ld = 0;
    reg n_inc = 0;
    reg i_inc = 0;
    reg i_clr = 0;
    reg p_reflect = 0;

    wire valid;
    wire of_out;
    wire n_tc;
    wire last_it;
    wire [3:0] pattern_leds;
    wire p_correct;

    // LED Light Parameters
    localparam LED_MODE_INPUT    = 3'b001;
    localparam LED_MODE_PLAYBACK = 3'b010;
    localparam LED_MODE_REPEAT   = 3'b100;
    localparam LED_MODE_DONE     = 3'b111;

    // VCD Dump
    integer idx;
    initial begin
        $dumpfile("SimonDatapathTest.vcd");
        $dumpvars;
        for (idx = 0; idx < 64; idx = idx + 1) begin
            $dumpvars(0, dpath.mem.mem[idx]);
        end
    end

    // Simon Control Module
    SimonDatapath dpath(
        .clk     (clk),
        .level   (level),
        .pattern (pattern),

        .of_set  (of_set),
        .reset   (reset),
        .p_write (p_write),
        .psi_ld  (psi_ld),
        .n_inc   (n_inc),
        .i_inc   (i_inc),
        .i_clr   (i_clr),
        .p_reflect (p_reflect),

        .valid   (valid),
        .of_out  (of_out),
        .n_tc    (n_tc),
        .last_it (last_it),
        .p_correct (p_correct),

        .pattern_leds (pattern_leds)
    );

    // Main Test Logic
    initial begin
        // Reset and set level
        $display("**Reset and set level");
        `SET(reset, 1);
        `SET(i_clr, 1);
        `SET(level, 0);
        `CLOCK;
        `ASSERT_EQ(of_out, 0, "of_out should be 0");
        `SET(reset, 0);
        `SET(i_clr, 0);

        // Check p_reflect and valid for level = 0
        $display("**Check p_reflect and valid for level = 0");
        `SET(pattern, 4'b0100);
        `SET(p_reflect, 1);
        `CLOCK;
        `ASSERT_EQ(pattern_leds, 4'b0100, "pattern_leds should be 0100");
        `ASSERT_EQ(valid, 1, "valid should be 1");

        `SET(pattern, 4'b1010);
        `CLOCK;
        `ASSERT_EQ(pattern_leds, 4'b1010, "pattern_leds should be 1010");
        `ASSERT_EQ(valid, 0, "valid should be 0");

        `SET(p_reflect, 0);
        `SET(pattern, 4'b1111);
        `CLOCK;
        `ASSERT_EQ(pattern_leds, 4'b0000, "pattern_leds should be 0000");

            // make sure that setting level = 1 without reset doesn't change valid
        $display("**make sure that setting level = 1 without reset doesn't change valid");
        `SET(level, 1);
        `CLOCK;
        `ASSERT_EQ(valid, 0, "valid should be 0");
        `SET(level, 0);

            // check level = 1
        $display("**check level = 1");
        `SET(reset, 1);
        `SET(level, 1);
        `SET(pattern, 4'b1010);
        `CLOCK;
        `ASSERT_EQ(valid, 1, "valid should be 1");
        `SET(pattern, 4'b1111);
        `CLOCK;
        `ASSERT_EQ(valid, 1, "valid should be 1");
        `SET(pattern, 4'b0100);
        `CLOCK;
        `ASSERT_EQ(valid, 1, "valid should be 1");
        `SET(pattern, 4'b0000);
        `CLOCK;
        `ASSERT_EQ(valid, 1, "valid should be 1");
        `SET(reset, 1);
        `SET(level, 0);
        `CLOCK;
        `SET(reset, 0);

        // Check of_set, n_tc and last_it
        $display("**Check of_set, n_tc and last_it");
        `SET(of_set, 1);
        `SET(i_clr, 1);
        `CLOCK;
        `ASSERT_EQ(of_out, 1, "of_out should be 1");
        `SET(of_set, 0);
        `SET(i_clr, 0);

        `SET(n_inc, 1);
        `SET(i_inc, 1);
        repeat (63) begin
            `CLOCK;
        end
        `ASSERT_EQ(n_tc, 1, "n_tc should be 1");
        `ASSERT_EQ(last_it, 1, "last_it should be 1");

        `CLOCK;
        `ASSERT_EQ(n_tc, 0, "n_tc should be 0");
        `ASSERT_EQ(last_it, 0, "last_it should be 0");
        `SET(n_inc, 0);
        `SET(i_inc, 0);
        `SET(reset, 1);
        `CLOCK;
        `SET(reset, 0);

        // Check writing to and reading from reg, and check p_correct
        $display("**Check writing to reg");
        `SET(pattern, 4'b0001);
        `SET(p_write, 1);
        `SET(p_reflect, 0);
        `CLOCK;
        `ASSERT_EQ(pattern_leds, 4'b0001, "pattern_leds should be 0001");
        `ASSERT_EQ(p_correct, 1, "p_correct should be 1");
        `SET(p_write, 0);

        `SET(n_inc, 1);
        `CLOCK;
        `SET(n_inc, 0);
        `SET(pattern, 4'b0010);
        `SET(p_write, 1);
        `CLOCK;
        `ASSERT_EQ(pattern_leds, 4'b0001, "pattern_leds should be 0001");
        `ASSERT_EQ(p_correct, 0, "p_correct should be 0");

        `SET(p_write, 0);
        `SET(i_inc, 1);
        `CLOCK;
        `SET(i_inc, 0);
        `ASSERT_EQ(pattern_leds, 4'b0010, "pattern_leds should be 0010");
        `ASSERT_EQ(p_correct, 1, "p_correct should be 1");

        // Check last_it for when it hasn't overflowed
        $display("**Check last_it for when it hasn't overflowed");
        `SET(i_clr, 1);
        `SET(reset, 1);
        `CLOCK;
        `SET(reset, 0);
        `SET(i_clr, 0);

        `SET(n_inc, 1);
        `CLOCK; `CLOCK; `CLOCK;
        `SET(n_inc, 0);
        `SET(i_inc, 1);
        `CLOCK;
        `ASSERT_EQ(last_it, 0, "last_it should be 0");
        `CLOCK;
        `ASSERT_EQ(last_it, 1, "last_it should be 1");
        `SET(i_inc, 0);

        // Check various last_it and psi stuff
        $display("**Check various last_it and psi stuff");
        `SET(i_clr, 1);
        `SET(reset, 1);
        `CLOCK;
        `SET(reset, 0);
        `SET(i_clr, 0);

            // no overflow
        $display("**No overflow:");
        `SET(n_inc, 1);
        `SET(p_write, 1);
        `SET(pattern, 4'b0000);
        `CLOCK;
        `SET(pattern, 4'b0001);
        `CLOCK;
        `SET(pattern, 4'b0010);
        `CLOCK;
        `SET(pattern, 4'b0011);
        `CLOCK;
        `SET(n_inc, 0);
        `SET(p_write, 0);
        `SET(i_inc, 1);
        `SET(p_reflect, 0);
        `ASSERT_EQ(pattern_leds, 4'b0000, "pattern_leds should be 0000");
        `ASSERT_EQ(last_it, 0, "last_it should be 0");
        `CLOCK;
        `ASSERT_EQ(pattern_leds, 4'b0001, "pattern_leds should be 0001");
        `ASSERT_EQ(last_it, 0, "last_it should be 0");
        `CLOCK;
        `ASSERT_EQ(pattern_leds, 4'b0010, "pattern_leds should be 0010");
        `ASSERT_EQ(last_it, 0, "last_it should be 0");
        `CLOCK;
        `ASSERT_EQ(pattern_leds, 4'b0011, "pattern_leds should be 0011");
        `ASSERT_EQ(last_it, 1, "last_it should be 1");
        `CLOCK;
        `SET(i_inc, 0);
        `SET(i_clr, 1);
        `SET(of_set, 1);
        `CLOCK;
        `SET(i_clr, 0);
        `SET(of_set, 0);

            // overflow
        $display("**Overflow:");
        `SET(n_inc, 1);
        `SET(p_write, 1);
        `SET(pattern, 4'b0000);
        `CLOCK;
        `SET(pattern, 4'b0001);
        `SET(psi_ld, 1);
        `CLOCK;
        `SET(psi_ld, 0);
        `SET(pattern, 4'b0010);
        `CLOCK;
        `SET(pattern, 4'b0011);
        `CLOCK;
        `SET(n_inc, 0);
        `SET(p_write, 0);
        `SET(i_inc, 1);
        `SET(p_reflect, 0);
        `ASSERT_EQ(pattern_leds, 4'b0010, "pattern_leds should be 0010");
        `ASSERT_EQ(last_it, 0, "last_it should be 0");
        `CLOCK;
        `ASSERT_EQ(pattern_leds, 4'b0011, "pattern_leds should be 0011");
        `ASSERT_EQ(last_it, 0, "last_it should be 0");
        `CLOCK;
        `ASSERT_EQ(pattern_leds, 4'b0000, "pattern_leds should be 0000");
        `ASSERT_EQ(last_it, 0, "last_it should be 0");
        `CLOCK;
        `ASSERT_EQ(pattern_leds, 4'b0000, "pattern_leds should be 0000");
        `ASSERT_EQ(last_it, 0, "last_it should be 0");
        `CLOCK;
        `SET(i_inc, 0);
        `SET(i_clr, 1);
        `SET(reset, 1);
        `SET(of_set, 0);
        `CLOCK;
        `SET(i_clr, 0);
        `SET(reset, 0);

        $finish;
    end

endmodule
