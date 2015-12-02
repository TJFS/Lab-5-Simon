//===============================================================================
// Testbench Module for Simon
//===============================================================================
`timescale 1ns/100ps

`include "Simon.v"

`define ASSERT_EQ(ONE, TWO, MSG)               \
    begin                                      \
        if ((ONE) !== (TWO)) begin             \
            $display("\t[FAILURE]:%s", (MSG)); \
            errors = errors + 1;               \
        end                                    \
    end #0

`define SET(VAR, VALUE) $display("Setting %s to %s...", "VAR", "VALUE"); #1; VAR = (VALUE); #1

`define CLOCK $display("Pressing uclk..."); #1; clk = 1; #1; clk = 0; #1

`define SHOW_MODE(MODE) $display("\nEntering Mode: %s\n-----------------------------------", MODE)

`define ADD_TO_SEQUENCE                                                 \
    begin                                                               \
        `SET(pattern, pat[currentIndex]);                               \
        `CLOCK;                                                         \
        for (i = 0; i <= loopIndex; i = i + 1) begin                    \
            $display("1_%d", i);                                        \
            `ASSERT_EQ(mode_leds, 2, "a");                              \
            if (~of) begin                                              \
                `ASSERT_EQ(pattern_leds, pat[i], "b");                  \
            end                                                         \
            else begin                                                  \
                `ASSERT_EQ(pattern_leds, pat[i+currentIndex-63], "b");  \
            end                                                         \
            `CLOCK;                                                     \
        end                                                             \
        for (i = 0; i <= loopIndex; i = i + 1) begin                    \
            $display("2_%d", i);                                        \
            `ASSERT_EQ(mode_leds, 4, "a");                              \
            if (~of) begin                                              \
                `SET(pattern, pat[i]);                                  \
            end                                                         \
            else begin                                                  \
                `SET(pattern, pat[i+currentIndex-63]);                  \
            end                                                         \
            `CLOCK;                                                     \
        end                                                             \
        `ASSERT_EQ(mode_leds, 1, "c");                                  \
        currentIndex = currentIndex + 1;                                \
    end #0                                                              


module SimonTest;

    // Loop
    integer i = 0;
    integer k = 0;
    integer currentIndex = 0;
    wire [20:0] loopIndex = (currentIndex < 64 ? currentIndex : 63);
    wire of = (currentIndex < 64 ? 0 : 1);
    reg [3:0] pat [127:0];
    integer j = 0;
    integer ii = 0;
    
    initial begin
        for (j = 0; j < 128; j = j + 1) begin
            if (j < 64) begin
                pat[j] = j%16;
            end 
            else begin
                pat[j] = (127-j)%16;
            end
        end
        
        for (j = 0; j < 128; j = j + 1) begin
            $display("%d %d", j, pat[j]);
        end
    end

    // Local Vars
    reg clk = 0;
    reg sysclk = 0;
    reg rst = 0;
    reg level = 0;
    reg [3:0] pattern = 4'd0;
    wire [2:0] mode_leds;
    wire [3:0] pattern_leds;

    // Error Counts
    reg [7:0] errors = 0;

    // LED Light Parameters
    localparam LED_MODE_INPUT    = 3'b001;
    localparam LED_MODE_PLAYBACK = 3'b010;
    localparam LED_MODE_REPEAT   = 3'b100;
    localparam LED_MODE_DONE     = 3'b111;
    
    // VCD Dump
    integer idx;
    initial begin
        $dumpfile("SimonTest.vcd");
        $dumpvars;
        for (idx = 0; idx < 64; idx = idx + 1) begin
            $dumpvars(0, simon.dpath.mem.mem[idx]);
        end
    end

    // Simon Module
    Simon simon(
        .sysclk       (sysclk),
        .pclk         (clk),
        .rst          (rst),
        .level        (level),
        .pattern      (pattern),

        .pattern_leds (pattern_leds),
        .mode_leds    (mode_leds)
    );

    // Main Test Logic
    initial begin
        // Reset the game
        `SHOW_MODE("Unknown");
        `SET(rst, 1);
        `CLOCK;

        //-----------------------------------------------
        // Input Mode
        // ----------------------------------------------
        `SHOW_MODE("Input");
        `SET(rst, 0);

        // Write your test cases here!
        `SET(level, 1);
        `SET(rst, 1);
        `CLOCK;
        `SHOW_MODE("Input");
        `SET(rst, 0);
        
        for (ii = 0; ii < 128; ii = ii + 1) begin
            `ADD_TO_SEQUENCE;
            if (ii % 16 == 3) begin // Ensure that toggling the level switch at arbitrary points doesn't do anything
                `SET(level, ~level);
            end
            if (ii == 20) begin // Test against asynchronous reset
                `SET(rst, 1);
                #5;
                `SET(rst, 0);
            end
        end
        
        // Test wrong input at the end
        `ASSERT_EQ(mode_leds, LED_MODE_INPUT, "Should be input mode");
        `SET(pattern, 1);
        `CLOCK;
        for (ii = 0; ii < 64; ii = ii + 1) begin
            `ASSERT_EQ(mode_leds, LED_MODE_PLAYBACK, "Should be playback mode");
            `CLOCK;
        end
        `ASSERT_EQ(mode_leds, LED_MODE_REPEAT, "Should be repeat mode");
        `SET(pattern, 3);
        `CLOCK;
        `ASSERT_EQ(mode_leds, LED_MODE_DONE, "Should be done mode");

        $display("\nTESTS COMPLETED (%d FAILURES)", errors);
        $finish;
    end

endmodule
