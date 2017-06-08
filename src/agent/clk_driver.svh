/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Clk agent driver. Used for generating user defined clocks.
 */

class ClkDriver extends uvm_driver #(ClkItem);
  `uvm_component_utils(ClkDriver)

  // Components
  virtual ClkIf vif;
  
  // Variables
  protected process proc_start_clk []; // each process corresponds to one clock

  // Methods
  function new(string name = "ClkDriver", uvm_component parent);
    super.new(name, parent);
  endfunction

  extern virtual task          driveInit();
  extern virtual task          startClk (input ClkItem it);
  extern virtual function void setClk   (input ClkItem it);
  extern virtual function void stopClk  (input ClkItem it);
  extern virtual task          run_phase(uvm_phase phase);

endclass: ClkDriver

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  task ClkDriver::driveInit();
    vif.clk = clk_init;
  endtask: driveInit

  //----------------------------------------------------------------------------

  function void ClkDriver::setClk(input ClkItem it);
    // implement
  endfunction: setClk

  //----------------------------------------------------------------------------

  task ClkDriver::startClk(input ClkItem it);
    foreach (it.clk_name[i]) begin
      // check if an affected process is already running
      if (proc_start_clk[i] != null) begin
        proc_start_clk[i].kill();
      end
      
      fork
        begin
          logic        init_clk_val;
          logic [31:0] clk_name;
          logic [31:0] phase_shift;
          logic [31:0] half_period;
          
          init_clk_val = it.init[i];
          clk_name     = it.clk_name[i];
          phase_shift  = it.phase_shift[i];
          half_period  = it.period[i]/2;
          
          // start clock generation
          #phase_shift;
          vif.clk[clk_name]        = init_clk_val;
          proc_start_clk[clk_name] = process::self();
          forever begin
            vif.clk[clk_name]      = #half_period ~vif.clk[clk_name];
          end
        end
      join_none
      
      // must use context switch because of fork-join_none
      #0;
    end
  endtask: startClk
  
  //----------------------------------------------------------------------------

  function void ClkDriver::stopClk(input ClkItem it);
    foreach (it.clk_name[i]) begin
      // check if an affected process is already running
      if (proc_start_clk[i] != null) begin
        proc_start_clk[i].kill();
      end
    end    
  endfunction: stopClk

  //----------------------------------------------------------------------------

  task ClkDriver::run_phase(uvm_phase phase);
    ClkItem it;


    proc_start_clk = new [WIDTH];
    driveInit();
    forever begin
      seq_item_port.get_next_item(it);

      case(it.op_type)
        CLK_SET      : setClk  (it);
        CLK_START    : startClk(it);
        CLK_STOP     : stopClk (it);
        default      : `uvm_error("Clk_DRV", "No such operation")
      endcase

      seq_item_port.item_done();
    end
  endtask: run_phase
