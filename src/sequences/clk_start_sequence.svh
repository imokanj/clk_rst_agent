/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Clk agent start sequence. Used to start generation of one or
 *               more user defined clocks.
 */

class ClkStartSequence extends ClkBaseSequence;
  `uvm_object_utils(ClkStartSequence)

  // Constructor
  function new(string name = "ClkStartSequence");
    super.new(name);
  endfunction: new

  // Function/Task declarations
  extern virtual task body();
  
  // Constraints
  constraint op_type_c {
    op_type == CLK_START;
  }

endclass: ClkStartSequence

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  task ClkStartSequence::body();
    super.body(); // create the transaction item

    start_item(it);
    if (!it.randomize() with {
      op_type            == local::op_type;
      clk_name.size()    == local::clk_name.size();
      foreach(local::clk_name[i])
        clk_name[i]      == local::clk_name[i];
      init.size()        == local::init.size();
      foreach(local::init[i])
        init[i]          == local::init[i];
      period.size()      == local::period.size();
      foreach(local::period[i])
        period[i]        == local::period[i];
      phase_shift.size() == local::phase_shift.size();
      foreach(local::phase_shift[i])
        phase_shift[i]   == local::phase_shift[i];
    }) `uvm_error("Clk_SET_SQNC", "\nRandomization failed\n");
    finish_item(it);
  endtask: body
