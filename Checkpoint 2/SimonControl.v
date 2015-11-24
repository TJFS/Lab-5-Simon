//==============================================================================
// Control Module for Simon Project
//==============================================================================

module SimonControl(
	// External Inputs
	input        clk,           // Clock
	input        rst,           // Reset

	// Datapath Inputs
	// input     localin1,
	input valid,
	input n_tc,
	input of_out,
	input last_it,
	input p_correct,

	// Datapath Control Outputs
	// output    control1,
	output reg p_write,
	output reg n_inc,
	output reg i_clr,
	output reg i_inc,
	output reg of_set,
	output reg psi_ld,
	output reg reset,
	output reg p_reflect,

	// External Outputs
	// output [2:0] mode_leds
	output reg [2:0] mode_leds
);

	// Declare Local Vars Here
	// reg [X:0] state;
	// reg [X:0] next_state;
	reg [1:0] state;
	reg [1:0] next_state;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// Declare State Names Here
	//localparam STATE_ONE = 2'd0;
	localparam STATE_INPUT = 2'd0;
	localparam STATE_PLAYBACK = 2'd1;
	localparam STATE_REPEAT = 2'd2;
	localparam STATE_DONE = 2'd3;

	// Output Combinational Logic
	always @( * ) begin
		// Set defaults
		// signal_one = 0; ...
		p_write = 0;
		n_inc = 0;
		i_clr = 0;
		i_inc = 0;
		of_set = 0;
		psi_ld = 0;
		reset = rst;
		p_reflect = 1;
		mode_leds = 0;


		// Write your output logic here
		case (state)
			STATE_INPUT: begin
				mode_leds = LED_MODE_INPUT;
				p_reflect = 1;
				if (~rst) begin
					p_write = valid;
					n_inc = valid;
					i_clr = 1;
					of_set = of_out | (valid & n_tc);
					psi_ld = of_out;
				end
			end
			STATE_PLAYBACK: begin
				mode_leds = LED_MODE_PLAYBACK;
				p_reflect = 0;
				if (~rst) begin
					i_clr = last_it;
					i_inc = ~last_it;
				end
			end
			STATE_REPEAT: begin
				mode_leds = LED_MODE_REPEAT;
				p_reflect = 1;
				if (~rst) begin
					i_clr = ~p_correct;
					i_inc = p_correct;
				end
			end
			STATE_DONE: begin
				mode_leds = LED_MODE_DONE;
				p_reflect = 0;
				if (~rst) begin
					i_clr = last_it;
					i_inc = ~last_it;
				end
			end
		endcase
		
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Write your Next State Logic Here
		// next_state = ???
		next_state = state;
		
		case (state)
			STATE_INPUT: begin
				if (valid) begin
					next_state = STATE_PLAYBACK;
				end
			end
			STATE_PLAYBACK: begin
				if (last_it) begin
					next_state = STATE_REPEAT;
				end
			end
			STATE_REPEAT: begin
				if (~p_correct) begin
					next_state = STATE_DONE;
				end
				else if (last_it & p_correct) begin
					next_state = STATE_INPUT;
				end
			end
		endcase
		
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			// Update state to reset state
			// state <= STATE_ONE;
			state <= STATE_INPUT;
		end
		else begin
			// Update state to next state
			// state <= next_state;
			state <= next_state;
		end
	end

endmodule
