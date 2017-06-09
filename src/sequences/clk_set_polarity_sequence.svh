/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Clk agent set polarity sequence. Used to set one or more IDLING
 *               user defined clocks to a specified value.
 */

class ClkSetPolaritySequence extends ClkStartSequence;
  `uvm_object_utils(ClkSetPolaritySequence)

  // Constructor
  function new(string name = "ClkSetPolaritySequence");
    super.new(name);
  endfunction: new

  // Function/Task declarations
  extern virtual task body();
  
  // Constraints
  constraint op_type_c {
    op_type == CLK_SET;
  }

endclass: ClkSetPolaritySequence

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  task ClkSetPolaritySequence::body();
    super.body(); // call clk start sequence
  endtask: body
