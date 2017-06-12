/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Agent sequence item.
 */

class ClkItem extends uvm_sequence_item;

  // Variables
  rand op_type_t  op_type;
  rand logic      is_blocking; // used only for RST_SET

  rand rst_list_t rst_name    [];
  rand clk_list_t clk_name    [];
  rand logic      init        [];
  rand time       period      [];
  rand time       phase_shift [];

  // Constructor
  function new(string name = "ClkItem");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(ClkItem)
    `uvm_field_enum      ( op_type_t,  op_type, UVM_DEFAULT | UVM_NOPACK)
    `uvm_field_int       (         is_blocking, UVM_DEFAULT | UVM_NOPACK)
    `uvm_field_array_enum(rst_list_t, rst_name, UVM_DEFAULT | UVM_NOPACK)
    `uvm_field_array_enum(clk_list_t, clk_name, UVM_DEFAULT | UVM_NOPACK)
    `uvm_field_array_int (                init, UVM_DEFAULT | UVM_NOPACK)
    `uvm_field_array_int (              period, UVM_DEFAULT | UVM_NOPACK | UVM_TIME)
    `uvm_field_array_int (         phase_shift, UVM_DEFAULT | UVM_NOPACK | UVM_TIME)
  `uvm_object_utils_end

endclass: ClkItem
