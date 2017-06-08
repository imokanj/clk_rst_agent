/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : The Clk agent is used to start/stop user specified clocks.
 */

class ClkAgent extends uvm_agent;
  `uvm_component_param_utils(ClkAgent)

  // Components
  uvm_sequencer #(ClkItem) sqcr;
  ClkDriver                drv;

  // Configurations
  ClkAgentCfg cfg;

  // Ports
  uvm_analysis_port #(ClkItem) aport;

  // Constructor
  function new(string name = "ClkAgent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Function/Task declarations
  extern virtual function void build_phase  (uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass: ClkAgent

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  function void ClkAgent::build_phase(uvm_phase phase);
    aport = new("aport", this);

    // get the Clk agent configuration
    if (!uvm_config_db #(ClkAgentCfg)::get(this, "", "clk_agent_cfg_db", cfg)) begin
      `uvm_fatal("CLK_AGT", "Couldn't get the Clk agent configuration")
    end

    // check if the virtual interface reference is populated
    if (cfg.vif == null) begin
      `uvm_fatal("CLK_AGT", "Virtual interface not found")
    end

    // create agent components
    sqcr       = uvm_sequencer #(ClkItem)::type_id::create("sequencer", this);
    drv        = ClkDriver               ::type_id::create(   "driver", this);
    drv.vif    = cfg.vif;
  endfunction: build_phase

  //----------------------------------------------------------------------------

  function void ClkAgent::connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(sqcr.seq_item_export);
  endfunction: connect_phase
  
