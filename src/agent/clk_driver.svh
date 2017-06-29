/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Agent driver. Used for generating user defined clocks.
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

  extern virtual function void setClkPol(input ClkItem it);
  extern virtual function void stopClk  (input ClkItem it);

  extern virtual task          driveInit();
  extern virtual task          setRstPol(input ClkItem it);
  extern virtual task          waitClk  (input ClkItem it);
  extern virtual task          startClk (input ClkItem it);
  extern virtual task          run_phase(uvm_phase phase);

endclass: ClkDriver

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  task ClkDriver::driveInit();
    vif.clk = clk_init;
    vif.rst = rst_init;
  endtask: driveInit

  //----------------------------------------------------------------------------

  task ClkDriver::setRstPol(input ClkItem it);
    logic [31:0] clk_name;

    foreach (it.rst_name[i]) begin
      fork
        begin
          // check if the specified clock process is running
          if (proc_start_clk[it.clk_name[i]] == null) begin
            `uvm_warning("CLK_RST_DRV", $sformatf({"\nChanging %s reset polarity ignored. ",
                         "Clock %s is not running."}, it.rst_name[i].name(), it.clk_name[i].name()))
          end else begin
            logic        rst_val;
            logic [31:0] rst_name;

            rst_val  = it.init[i];
            rst_name = it.rst_name[i];
            clk_name = it.clk_name[i];

            @(posedge vif.clk[clk_name]);
            #1step;
            vif.rst[rst_name] = rst_val;
          end
        end
      join_none

      // must use context switch because of fork-join_none
      #0;
    end

    // block
    if (it.is_blocking) begin
      foreach (it.clk_name[i]) begin
        fork
          begin
            if (proc_start_clk[it.clk_name[i]] != null) begin
              @(posedge vif.clk[it.clk_name[i]]);
            end
          end
        join
      end
    end
  endtask: setRstPol

  //----------------------------------------------------------------------------

  task ClkDriver::waitClk(input ClkItem it);
    if (proc_start_clk[it.clk_name[0]] != null) begin
      repeat(it.num) begin
        @(posedge vif.clk[it.clk_name[0]]);
      end
    end else begin
      `uvm_warning("CLK_RST_DRV", $sformatf("\nWaiting cycles on %s clock ignored. Clock is not running.", it.clk_name[0].name()))
    end
  endtask: waitClk

  //----------------------------------------------------------------------------

  function void ClkDriver::setClkPol(input ClkItem it);
    foreach (it.clk_name[i]) begin
      // check if an affected process is already running
      if (proc_start_clk[it.clk_name[i]] != null) begin
        `uvm_warning("CLK_RST_DRV", $sformatf("\nChanging %s clock polarity ignored. Clock is running.", it.clk_name[i].name()))
      end else begin
        vif.clk[it.clk_name[i]] = it.init[i];
      end
    end
  endfunction: setClkPol

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
          if (phase_shift) begin
            #phase_shift;
          end

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
      if (proc_start_clk[it.clk_name[i]] != null) begin
        proc_start_clk[it.clk_name[i]].kill();
        proc_start_clk[it.clk_name[i]] = null;
      end
    end
  endfunction: stopClk

  //----------------------------------------------------------------------------

  task ClkDriver::run_phase(uvm_phase phase);
    ClkItem it;


    proc_start_clk = new [C_WIDTH];
    driveInit();
    forever begin
      seq_item_port.get_next_item(it);

      case(it.op_type)
        RST_SET      : setRstPol(it);
        CLK_SET      : setClkPol(it);
        CLK_WAIT     : waitClk  (it);
        CLK_START    : startClk (it);
        CLK_STOP     : stopClk  (it);
        default      : `uvm_error("CLK_RST_DRV", "No such operation")
      endcase

      seq_item_port.item_done();
    end
  endtask: run_phase
