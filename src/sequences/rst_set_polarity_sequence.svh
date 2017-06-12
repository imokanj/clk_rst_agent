/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Agent set reset polarity sequence. Used to set one or more
 *               user defined resets to a specified value.
 */

class RstSetPolaritySequence extends ClkBaseSequence;
  `uvm_object_utils(RstSetPolaritySequence)
  
  // Variables
  rand logic      is_blocking;

  // Constructor
  function new(string name = "RstSetPolaritySequence");
    super.new(name);
  endfunction: new

  // Function/Task declarations
  extern virtual task body();
  
  // Constraints
  constraint op_type_c {
    op_type == RST_SET;
  }

endclass: RstSetPolaritySequence

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  task RstSetPolaritySequence::body();
    super.body(); // create the transaction item

    start_item(it);
    if (!it.randomize() with {
      op_type            == local::op_type;
      rst_name.size()    == local::rst_name.size();
      foreach(local::rst_name[i])
        rst_name[i]      == local::rst_name[i];
      clk_name.size()    == local::clk_name.size();
      foreach(local::clk_name[i])
        clk_name[i]      == local::clk_name[i];
      init.size()        == local::init.size();
      foreach(local::init[i])
        init[i]          == local::init[i];
      is_blocking        == local::is_blocking;
    }) `uvm_error("RST_SET_SQNC", "\nRandomization failed\n");
    finish_item(it);
  endtask: body
