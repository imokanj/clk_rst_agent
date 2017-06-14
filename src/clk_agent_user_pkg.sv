/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Agent user package. This file should be edited by the user
 *               to specify the user clocks and resets, and set their initial
 *               values.
 */

`ifndef _AGENT_CLK_RST_USER_PKG_
`define _AGENT_CLK_RST_USER_PKG_

package ClkAgentUserPkg;

  timeunit        1ns;
  timeprecision 100ps;

//==============================================================================
// User section
//==============================================================================

  // agent output pins list
  typedef enum {
    SYS_RST,
    SYS_RST_N    
  } rst_list_t;
  rst_list_t rst_list;
  
  typedef enum {
    SYS_CLK,
    CLK_25_MHz,
    CLK_50_MHz
  } clk_list_t;
  clk_list_t clk_list;

  // if your simulator does not support built-in functions in constant expressions
  // please manually count the number of resets and clocks and write it here, and
  // delete the *.num() calls,
  parameter R_WIDTH = 2; // rst_list.num();
  parameter C_WIDTH = 3; // clk_list.num();

  // set the initial values of the Rst output pins
  logic [R_WIDTH-1:0] rst_init = {
    1'b1, // SYS_RST
    1'b0  // SYS_RST_N
  };

  // set the initial values of the Clk output pins
  logic [C_WIDTH-1:0] clk_init = {
    1'b1, // SYS_CLK
    1'b0, // CLK_25_MHz
    1'b0  // CLK_50_MHz
  };

endpackage : ClkAgentUserPkg

`endif
