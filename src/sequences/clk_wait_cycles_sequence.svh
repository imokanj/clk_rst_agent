/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Agent wait cycles sequence. Used to wait for one or more clock
 *               cycles, on a specified user clock.
 */

class ClkWaitCyclesSequence extends RstSetPolaritySequence;
  `uvm_object_utils(ClkWaitCyclesSequence)

  // Constructor
  function new(string name = "ClkWaitCyclesSequence");
    super.new(name);
  endfunction: new

  // Function/Task declarations
  extern virtual task body();
  
  // Constraints
  constraint op_type_c {
    op_type == CLK_WAIT;
  }

endclass: ClkWaitCyclesSequence

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  task ClkWaitCyclesSequence::body();
    super.body(); // call clk start sequence
  endtask: body
