//===============================================================================
// Testbench Module for Simon Controller
//===============================================================================
`timescale 1ns/100ps

`include "SimonControl.v"

// Print an error message (MSG) if value ONE is not equal
// to value TWO.
`define ASSERT_EQ(ONE, TWO, MSG)               \
	begin                                      \
		if ((ONE) !== (TWO)) begin             \
			$display("\t\t[FAILURE]:%s", (MSG)); \
		end                                    \
	end #0

// Set the variable VAR to the value VALUE, printing a notification
// to the screen indicating the variable's update.
// The setting of the variable is preceeded and followed by
// a 1-timestep delay.
`define SET(VAR, VALUE) $display("\tSetting %s to %s...", "VAR", "VALUE"); #1; VAR = (VALUE); #1

// Cycle the clock up and then down, simulating
// a button press.
`define CLOCK $display("\tPressing uclk..."); #1; clk = 1; #1; clk = 0; #1

module SimonControlTest;

	// Local Vars
	reg clk = 0;
	reg rst = 0;
	// More vars here...
	reg valid = 0;
	reg n_tc = 0;
	reg of_out = 0;
	reg last_it = 0;
	reg p_correct = 0;
	
	wire p_write;
	wire n_inc;
	wire i_clr;
	wire i_inc;
	wire of_set;
	wire psi_ld;
	wire reset;
	wire p_reflect;
	
	wire [2:0] mode_leds;



	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// VCD Dump
	initial begin
		$dumpfile("SimonControlTest.vcd");
		$dumpvars;
	end

	// Simon Control Module
	SimonControl ctrl(
		.clk (clk),
		.rst (rst),

		// More ports here...
		.valid (valid),
		.n_tc (n_tc),
		.of_out (of_out),
		.last_it (last_it),
		.p_correct (p_correct),
		
		.p_write (p_write),
		.n_inc (n_inc),
		.i_clr (i_clr),
		.i_inc (i_inc),
		.of_set (of_set),
		.psi_ld (psi_ld),
		.reset (reset),
		.p_reflect (p_reflect),
		
		.mode_leds(mode_leds)

	);

	// Main Test Logic
	initial begin
		// Reset the game
		`SET(rst, 1);
		`CLOCK;
		`SET(rst, 0);

		// Your Test Logic Here
		// Check input defaults
		$display("Block 1");
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check valid = 1
		$display("Block 2");
		`SET(valid, 1);
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 1, "c");
		`ASSERT_EQ(n_inc, 1, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check valid and n_tc = 1
		$display("Block 3");
		`SET(n_tc, 1);
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 1, "c");
		`ASSERT_EQ(n_inc, 1, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 1, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check of_out = 1
		$display("Block 4");
		`SET(valid, 0);
		`SET(n_tc, 0);
		`SET(of_out, 1);
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 1, "g");
		`ASSERT_EQ(psi_ld, 1, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check all but reset
		$display("Block 5");
		`SET(valid, 1);
		`SET(n_tc, 1);
		`SET(of_out, 1);
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 1, "c");
		`ASSERT_EQ(n_inc, 1, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 1, "g");
		`ASSERT_EQ(psi_ld, 1, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check all w/ reset
		$display("Block 6");
		`SET(rst, 1);
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 0, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 1, "i");
		
		// check button press while not valid
		$display("Block 7");
		`SET(rst, 0);
		`SET(valid, 0);
		`SET(n_tc, 0);
		`SET(of_out, 0);
		`CLOCK;
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check button press while valid
		$display("Block 8");
		`SET(valid, 1);
		`CLOCK;
		`ASSERT_EQ(mode_leds, LED_MODE_PLAYBACK, "a");
		`ASSERT_EQ(p_reflect, 0, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 1, "e");
		`ASSERT_EQ(i_clr, 0, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check last_it = 1
		$display("Block 9");
		`SET(last_it, 1);
		`ASSERT_EQ(mode_leds, LED_MODE_PLAYBACK, "a");
		`ASSERT_EQ(p_reflect, 0, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check reset
		$display("Block 10");
		`SET(rst, 1);
		`ASSERT_EQ(mode_leds, LED_MODE_PLAYBACK, "a");
		`ASSERT_EQ(p_reflect, 0, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 0, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 1, "i");
		
		// check button press w/ last_it = 0
		$display("Block 11");
		`SET(rst, 0);
		`SET(last_it, 0);
		`CLOCK;
		`ASSERT_EQ(mode_leds, LED_MODE_PLAYBACK, "a");
		`ASSERT_EQ(p_reflect, 0, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 1, "e");
		`ASSERT_EQ(i_clr, 0, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check button press w/ last_it = 1
		$display("Block 12");
		`SET(last_it, 1);
		`CLOCK;
		`ASSERT_EQ(mode_leds, LED_MODE_REPEAT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check p_correct = 1
		$display("Block 13");
		`SET(p_correct, 1);
		`ASSERT_EQ(mode_leds, LED_MODE_REPEAT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 1, "e");
		`ASSERT_EQ(i_clr, 0, "f");
		`ASSERT_EQ(of_set, 0, "");
		`ASSERT_EQ(psi_ld, 0, "");
		`ASSERT_EQ(reset, 0, "");
		
		// check reset
		$display("Block 14");
		`SET(rst, 1);
		`ASSERT_EQ(mode_leds, LED_MODE_REPEAT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 0, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 1, "i");
		
		// check button press w/ last_it = 0 and p_correct = 1
		$display("Block 15");
		`SET(rst, 0);
		`SET(last_it, 0);
		`SET(p_correct, 1);
		`CLOCK;
		`ASSERT_EQ(mode_leds, LED_MODE_REPEAT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 1, "e");
		`ASSERT_EQ(i_clr, 0, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check button press w/ last_it = 1 and p_correct = 1
		$display("Block 16");
		`SET(last_it, 1);
		`CLOCK;
		`SET(valid, 0);
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// cycle back to repeat mode
		$display("Block 17");
		`SET(valid, 1);
		`CLOCK;
		`SET(last_it, 1);
		`CLOCK;
		`SET(p_correct, 0);
		`ASSERT_EQ(mode_leds, LED_MODE_REPEAT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check button press w/ p_correct = 0
		$display("Block 18");
		`CLOCK;
		`SET(last_it, 0);
		`ASSERT_EQ(mode_leds, LED_MODE_DONE, "a");
		`ASSERT_EQ(p_reflect, 0, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 1, "e");
		`ASSERT_EQ(i_clr, 0, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check last_it = 1
		$display("Block 18.5");
		`SET(last_it, 1);
		`ASSERT_EQ(mode_leds, LED_MODE_DONE, "a");
		`ASSERT_EQ(p_reflect, 0, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		
		// check reset
		$display("Block 19");
		`SET(rst, 1);
		`ASSERT_EQ(mode_leds, LED_MODE_DONE, "a");
		`ASSERT_EQ(p_reflect, 0, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 0, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 1, "i");
		
		// button press
		$display("Block 20");
		`CLOCK;
		`SET(rst, 0);
		`SET(valid, 0);
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "a");
		`ASSERT_EQ(p_reflect, 1, "b");
		`ASSERT_EQ(p_write, 0, "c");
		`ASSERT_EQ(n_inc, 0, "d");
		`ASSERT_EQ(i_inc, 0, "e");
		`ASSERT_EQ(i_clr, 1, "f");
		`ASSERT_EQ(of_set, 0, "g");
		`ASSERT_EQ(psi_ld, 0, "h");
		`ASSERT_EQ(reset, 0, "i");
		$finish;
	end

endmodule
