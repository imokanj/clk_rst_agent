/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Clk agent base sequence. All other sequences are extended from
 *               this one.
 */

class ClkBaseSequence extends uvm_sequence #(ClkItem);
  `uvm_object_utils(ClkBaseSequence)

  // Variables
  ClkItem           it;
  static int        inst_cnt;
  rand op_type_t    op_type;

  rand clk_list_t   clk_name    [];
  rand logic        init        [];
  rand logic [31:0] period      [];
  rand logic [31:0] phase_shift [];

  // Constructor
  function new(string name = "ClkBaseSequence");
    super.new(name);
  endfunction: new

  extern virtual task body();

endclass: ClkBaseSequence

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  task ClkBaseSequence::body();
    inst_cnt++;
    it = ClkItem::type_id::create("spi_it");
  endtask: body
