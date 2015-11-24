//==============================================================================
// Simon Module for Simon Project
//==============================================================================

`include "ButtonDebouncer.v"
`include "SimonControl.v"
`include "SimonDatapath.v"

module Simon(
	input        sysclk,
	input        pclk,
	input        rst,
	input        level,
	input  [3:0] pattern,

	output [3:0] pattern_leds,
	output [2:0] mode_leds
);

	// Declare local connections here
	// wire localconn1; ...
	wire valid;
	wire n_tc;
	wire of_out;
	wire last_it;
	wire p_correct;
	
	wire p_write;
	wire n_inc;
	wire i_clr;
	wire i_inc;
	wire of_set;
	wire psi_ld;
	wire reset;
	wire p_reflect;
	
	wire [2:0] mode_leds;

	//============================================
	// Button Debouncer Section
	//============================================

	//--------------------------------------------
	// IMPORTANT!!!! If simulating, use this line:
	//--------------------------------------------
	wire uclk = pclk;
	//--------------------------------------------
	// IMPORTANT!!!! If using FPGA, use this line:
	//--------------------------------------------
	//wire uclk;
	//ButtonDebouncer debouncer(
	//	.sysclk(sysclk),
	//	.noisy_btn(pclk),
	//	.clean_btn(uclk)
	//);

	//============================================
	// End Button Debouncer Section
	//============================================

	// Datapath -- Add port connections
	SimonDatapath dpath(
		.clk           (uclk),
		.level         (level),
		.pattern       (pattern),

		// ...
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
		
		.pattern_leds(pattern_leds)
		
	);

	// Control -- Add port connections
	SimonControl ctrl(
		.clk           (uclk),
		.rst           (rst),

		// ...
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

endmodule
