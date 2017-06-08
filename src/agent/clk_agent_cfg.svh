/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Clk agent configuration class. An object of this class should
 *               be put in the configuration database so that the Clk agent can
 *               get the user configuration.
 */

class ClkAgentCfg extends uvm_object;
  `uvm_object_utils(ClkAgentCfg)

  // Variables
  virtual ClkIf           vif;

  // Constructor
  function new(string name = "ClkAgentCfg");
    super.new(name);
  endfunction

endclass: ClkAgentCfg
