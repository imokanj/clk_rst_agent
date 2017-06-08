/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Clk agent sequence item.
 */

class ClkItem extends uvm_sequence_item;

  // Variables
  rand op_type_t    op_type;

  rand clk_list_t   clk_name    [];
  rand logic        init        [];
  rand logic [31:0] period      [];
  rand logic [31:0] phase_shift [];

  // Constructor
  function new(string name = "ClkItem");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(ClkItem)
    `uvm_field_enum      ( op_type_t,  op_type, UVM_DEFAULT | UVM_NOPACK)
    `uvm_field_array_enum(clk_list_t, clk_name, UVM_DEFAULT | UVM_NOPACK)
    `uvm_field_array_int (                init, UVM_DEFAULT | UVM_NOPACK)
    `uvm_field_array_int (              period, UVM_DEFAULT | UVM_NOPACK)
    `uvm_field_array_int (         phase_shift, UVM_DEFAULT | UVM_NOPACK)
  `uvm_object_utils_end

endclass: ClkItem
