//==============================================================================
// Datapath for Simon Project
//==============================================================================

`include "Memory.v"

module SimonDatapath(
    // External Inputs
    input        clk,           // Clock
    input        level,         // Switch for setting level
    input  [3:0] pattern,       // Switches for creating pattern

    // Datapath Control Signals
    input        of_set,
    input        reset,
    input        p_write,
    input        psi_ld,
    input        n_inc,
    input        i_inc,
    input        i_clr,
    input        p_reflect,

    // Datapath Outputs to Control
    output reg   valid,
    output reg   of_out,
    output reg   n_tc,
    output reg   last_it,
    output reg   p_correct,

    // External Outputs
    output reg [3:0] pattern_leds   // LED outputs for pattern
);

    // Declare Local Vars Here
    reg [5:0]    psi;
    reg [5:0]    n;
    reg [5:0]    i;
    reg          lvl;
    reg          of;
    wire [5:0]   k;
    wire [3:0]   read_pattern;

    //----------------------------------------------------------------------
    // Internal Logic -- Manipulate Registers, ALU's, Memories Local to
    // the Datapath
    //----------------------------------------------------------------------

    assign k = psi + i + 1;

    always @(posedge clk) begin
        // reset
        if (reset) begin
            lvl <= level;
            of <= 1'b0;
            psi <= 6'b111111;
            n <= 1'b0;
        end
        // of_set
        else begin
            if (of_set) begin
                of <= 1'b1;
            end
            // psi_ld
            if (psi_ld) begin
                psi <= n;
            end
            // n_inc
            if (n_inc) begin
                n <= n + 1;
            end
            // i_clr
            if (i_clr) begin
                i <= 6'b000000;
            end
            // i_inc
            else if (i_inc) begin
                i <= i + 1;
            end
        end
    end

    // 64-entry 4-bit memory (from Memory.v) -- Fill in Ports!
    Memory mem(
        .clk     (clk),
        .rst     (reset),
        .r_addr  (k),
        .w_addr  (n),
        .w_data  (pattern),
        .w_en    (p_write),
        .r_data  (read_pattern)
    );

    //----------------------------------------------------------------------
    // Output Logic -- Set Datapath Outputs
    //----------------------------------------------------------------------

    always @( * ) begin
        // Output Logic Here
        if (~lvl) begin
            valid <= (pattern[0] + pattern[1] + pattern[2] + pattern[3]) == 1;
        end
        else begin
            valid <= 1'b1;
        end

        if (of) begin
            last_it <= (i == 6'b111111);
        end
        else begin
            last_it <= (i == (n - 1));
        end

        if (p_reflect) begin
            pattern_leds <= pattern;
        end
        else begin
            pattern_leds <= read_pattern;
        end

        of_out <= of;
        n_tc <= (n == 6'b111111);
        p_correct <= (pattern == read_pattern);
    end

endmodule
