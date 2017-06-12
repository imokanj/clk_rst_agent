/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Clk agent interface signal definitions. Up to 32 different clock
 *               sources can be generated.
 */

interface ClkIf();

  timeunit        1ns;
  timeprecision 100ps;

//******************************************************************************
// Ports
//******************************************************************************

  logic [31:0] rst;
  logic [31:0] clk;

endinterface : ClkIf
