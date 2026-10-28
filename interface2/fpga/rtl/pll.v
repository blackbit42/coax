// Generated PLL module for iCE40UP5K using SB_PLL40_2_PAD
// Equivalent to the original SB_PLL40_CORE with:
//   DIVR=0, DIVF=16, DIVQ=3, FILTER_RANGE=3
// Input: 40 MHz (25ns period), Output: ~85 MHz

`default_nettype none

module pll (
    input  wire clk_in,      // 40 MHz input clock
    output wire clk_out      // ~85 MHz output clock
);

    SB_PLL40_2_PAD #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),
        .DIVF(7'b0010000),
        .DIVQ(3'b011),
        .FILTER_RANGE(3'b011)
    ) pll_inst (
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .REFERENCECLK(clk_in),
        .PLLOUTCORE(clk_out),
        .PLLOUTGLOBAL()
    );

endmodule