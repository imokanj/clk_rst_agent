/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Agent wait cycles sequence. Used to wait for one or more clock
 *               cycles, on a specified user clock.
 */

class ClkWaitCyclesSequence extends ClkBaseSequence;
  `uvm_object_utils(ClkWaitCyclesSequence)

  // Variables
  rand bit [31:0] num;

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
    super.body(); // create the transaction item

    start_item(it);
    if (!it.randomize() with {
      op_type            == local::op_type;
      clk_name.size()    == local::clk_name.size();
      foreach(local::clk_name[i])
        clk_name[i]      == local::clk_name[i];
      num                == local::num;
    }) `uvm_error("CLK_WAIT_SQNC", "\nRandomization failed\n")
    finish_item(it);
  endtask: body
