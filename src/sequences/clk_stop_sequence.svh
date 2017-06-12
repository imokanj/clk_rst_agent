/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Agent stop sequence. Used to stop generation of one or more
 *               running user defined clocks.
 */

class ClkStopSequence extends ClkBaseSequence;
  `uvm_object_utils(ClkStopSequence)

  // Constructor
  function new(string name = "ClkStopSequence");
    super.new(name);
  endfunction: new

  // Function/Task declarations
  extern virtual task body();
  
  // Constraints
  constraint op_type_c {
    op_type == CLK_STOP;
  }

endclass: ClkStopSequence

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  task ClkStopSequence::body();
    super.body(); // create the transaction item

    start_item(it);
    if (!it.randomize() with {
      op_type            == local::op_type;
      clk_name.size()    == local::clk_name.size();
      foreach(local::clk_name[i])
        clk_name[i]      == local::clk_name[i];
    }) `uvm_error("CLK_STOP_SQNC", "\nRandomization failed\n");
    finish_item(it);
  endtask: body
