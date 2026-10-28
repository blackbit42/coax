// PLL module using SB_PLL40_CORE (same primitive as original IceCube2 design)
// Equivalent to the original SB_PLL40_CORE with:
//   DIVR=0, DIVF=16, DIVQ=3, FILTER_RANGE=3
// Input: 40 MHz (25ns period), Output: ~85 MHz

`default_nettype none

/* verilator lint_off PINCONNECTEMPTY */
module pll (
    input  wire clk_in,      // 40 MHz input clock
    output wire clk_out      // ~85 MHz output clock
);

    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),
        .DIVF(7'b0010000),
        .DIVQ(3'b011),
        .FILTER_RANGE(3'b011),
        .PLLOUT_SELECT("GENCLK")
    ) pll_inst (
        .REFERENCECLK(clk_in),
        .PLLOUTCORE(clk_out),
        .PLLOUTGLOBAL(),
        .EXTFEEDBACK(1'b0),
        .DYNAMICDELAY(8'b0),
        .LOCK(),
        .BYPASS(1'b0),
        .RESETB(1'b1),
        .LATCHINPUTVALUE(1'b0),
        .SDO(),
        .SDI(1'b0),
        .SCLK(1'b0)
    );

endmodule
/* verilator lint_on PINCONNECTEMPTY */
