// Black box declaration for iCE40 SB_PLL40_CORE primitive
// This allows verilator to lint designs using this primitive without needing the full cell library

`default_nettype none

/* verilator lint_off MODDUP */
/* verilator lint_off DECLFILENAME */
/* verilator lint_off UNUSEDPARAM */
/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */

module SB_PLL40_CORE #(
    parameter FEEDBACK_PATH = "SIMPLE",
    parameter DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED",
    parameter DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED",
    parameter SHIFTREG_DIV_MODE = 1'b0,
    parameter FDA_FEEDBACK = 4'b0000,
    parameter FDA_RELATIVE = 4'b0000,
    parameter PLLOUT_SELECT = "GENCLK",
    parameter DIVR = 4'b0000,
    parameter DIVF = 7'b0000000,
    parameter DIVQ = 3'b000,
    parameter FILTER_RANGE = 3'b000,
    parameter ENABLE_ICEGATE = 1'b0
)(
    input  REFERENCECLK,
    output PLLOUTCORE,
    output PLLOUTGLOBAL,
    input  EXTFEEDBACK,
    input  [7:0] DYNAMICDELAY,
    output LOCK,
    input  BYPASS,
    input  RESETB,
    input  LATCHINPUTVALUE,
    output SDO,
    input  SDI,
    input  SCLK
);
    // Black box - no implementation needed for linting
endmodule

/* verilator lint_on MODDUP */
/* verilator lint_on DECLFILENAME */
/* verilator lint_on UNUSEDPARAM */
/* verilator lint_on UNUSEDSIGNAL */
