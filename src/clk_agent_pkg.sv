/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Clk agent package. Contains :
 *                 - User specified clocks
 *                 - User specified initial clock signal values
 *                 - All needed files for building the Clk agent (except the Clk interface)
 *                 - Convenience functions/tasks for clock generation/stopping
 */

`ifndef _AGENT_CLK_PKG_
`define _AGENT_CLK_PKG_

package ClkAgentPkg;

  timeunit        1ns;
  timeprecision 100ps;

//==============================================================================
// User section
//==============================================================================

  // agent output pins list
  typedef enum {
    CLK_25_MHz,
    CLK_50_MHz    
  } clk_list_t;
  clk_list_t clk_list;

  // if your simulator does not support built-in functions in constant expressions
  // please manually count the number of clocks and write it here, and delete the 
  // *.num() calls
  parameter WIDTH = 2; // clk_list.num();

  // set the initial values of the Clk output pins
  logic [WIDTH-1:0] clk_init = {
    1'b0, // CLK_25_MHz
    1'b0  // CLK_50_MHz
  };

//==============================================================================
// System section
//==============================================================================

  typedef enum {
    CLK_SET,
    CLK_START,
    CLK_STOP
  } op_type_t;

//******************************************************************************
// Imports
//******************************************************************************

  import uvm_pkg::*;

//******************************************************************************
// Includes
//******************************************************************************

  `include "uvm_macros.svh"

  // sequences
  `include "sequences/clk_item.svh"
  `include "sequences/clk_base_sequence.svh"
  `include "sequences/clk_start_sequence.svh"
  `include "sequences/clk_stop_sequence.svh"
  `include "sequences/clk_set_polarity_sequence.svh"

  // components
  `include "agent/clk_agent_cfg.svh"
  `include "agent/clk_driver.svh"
  `include "agent/clk_agent.svh"

//******************************************************************************
// Functions/Tasks
//******************************************************************************
  
  function automatic string printPinEnumO(clk_list_t a [], bit is_val);
    parameter DIGITS = "9876543210";
    string    str    = "";
    int       tmp;

    tmp = a.size();
    foreach(a[i]) begin
      if (!is_val) begin
        if (i != tmp-1) begin
          str = {str, a[i].name(), ", "};
        end else begin
          str = {str, a[i].name()};
        end
      end else begin
        if (i != tmp-1) begin
          str = {str, DIGITS[a[i]*8+:8], ", "};
        end else begin
          str = {str, DIGITS[a[i]*8+:8]};
        end
      end
    end
    return str;
  endfunction : printPinEnumO
  
  //----------------------------------------------------------------------------
  
  function automatic string printPinVal(logic v []);
    string    str = "";
    string    val;
    int       tmp;

    tmp = v.size();
    foreach(v[i]) begin
      val = (v[i] === 1'bX) ? "X" :
            (v[i] === 1'bZ) ? "Z" :
            (v[i] === 1'b1) ? "1" : "0";
      if (i != tmp-1) begin
        str = {str, "1'b", val, ", "};
      end else begin
        str = {str, "1'b", val};
      end
    end
    return str;
  endfunction : printPinVal
  
  //----------------------------------------------------------------------------
  
    function automatic string printPinVal2(logic [31:0] v []);
    string    str = "";
    string    val;
    int       tmp;

    tmp = v.size();
    foreach(v[i]) begin
      val = (&v[i] === 1'bX) ? "X" :
            (&v[i] === 1'bZ) ? "Z" :
            (&v[i] === 1'b1) ? "1" : "0";
      if (i != tmp-1) begin
        str = {str, "1'b", val, ", "};
      end else begin
        str = {str, "1'b", val};
      end
    end
    return str;
  endfunction : printPinVal2
  
  //----------------------------------------------------------------------------

  task automatic startClk(
    input  bit                _print_info     = 1'b1,
    input  uvm_sequencer_base _sqcr                 ,
    input  clk_list_t         _clk_name    []       ,
    input  logic              _init        [] = {}  ,      
    input  time               _period      []       ,
    input  time               _phase_shift [] = {}
  );

    ClkStartSequence  _seq;
    
    if (_sqcr == null) begin
      `uvm_error("CLK_PKG", "\nClk agent sequencer handle is NULL\n")
      return;
    end

    if (_clk_name.size() > WIDTH || _clk_name.size() < 1) begin
      `uvm_error("CLK_PKG", {"\nOperation ignored.\nNumber of specified clocks ",
                             "is greater than number of actual clocks, or is less than one\n"})
      return;
    end
    
    if (_period.size() != _clk_name.size()) begin
      `uvm_error("CLK_PKG", "\nNumber of specified clock periods differs from the number of clock sources.\n")
      return;
    end
    
    //foreach (_period[i]) begin
      //if (_period[i][0]) begin
        //`uvm_warning("CLK_PKG", $sformatf("\nPeriod for %s clock is not an even number\n", _clk_name[i].name()))
      //end
    //end
    
    _seq = ClkStartSequence::type_id::create("clk_start_seq");
    
    // set default values for initial and phase delay parameters
    if (!_init.size()) begin
      _init = new [_clk_name.size()];
      foreach (_init[i]) begin
        _init[i] = 1'b0;
      end
    end
    
    if (!_phase_shift.size()) begin
      _phase_shift = new [_clk_name.size()];
      foreach (_phase_shift[i]) begin
        _phase_shift[i] = 1'b0;
      end
    end

    if (!(_seq.randomize() with {
      clk_name.size()    == _clk_name.size();
      foreach(_clk_name[i])
        clk_name[i]      == _clk_name[i];
      init.size()        == _init.size();
      foreach(_init[i])
        init[i]          == _init[i];
      period.size()      == _period.size();
      foreach(_period[i])
        period[i]        == _period[i];
      phase_shift.size() == _phase_shift.size();
      foreach(_phase_shift[i])
        phase_shift[i]   == _phase_shift[i];
    })) `uvm_error("CLK_PKG", "\nRandomization failed\n")

    if (_print_info) begin
      `uvm_info("CLK_PKG", $sformatf({"\nClk Start OP:\n",
                               "-------------------------------------------------\n",
                               "OP Type         : CLK_START\n",
                               "Pin Name(s)     : %s\n",
                               "Pin Num(s)      : %s\n",
                               "Init. Value(s)  : %s\n",
                               "Clock Period(s) : %p\n",
                               "Phase Delay(s)  : %p\n"}
                               , printPinEnumO(_clk_name, 0), printPinEnumO(_clk_name, 1)
                               , printPinVal(_init), _period, _phase_shift
      ), UVM_LOW)
    end

    _seq.start(_sqcr);

  endtask : startClk

  //----------------------------------------------------------------------------

  task automatic stopClk(
    input  bit                _print_info     = 1'b1,
    input  uvm_sequencer_base _sqcr                 ,
    input  clk_list_t         _clk_name    []
  );

    ClkStopSequence  _seq;
    
    if (_sqcr == null) begin
      `uvm_error("CLK_PKG", "\nClk agent sequencer handle is NULL\n")
      return;
    end

    if (_clk_name.size() > WIDTH || _clk_name.size() < 1) begin
      `uvm_error("CLK_PKG", {"\nOperation ignored.\nNumber of specified clocks ",
                             "is greater than number of actual clocks, or is less than one\n"})
      return;
    end
    
    _seq = ClkStopSequence::type_id::create("clk_stop_seq");

    if (!(_seq.randomize() with {
      clk_name.size()    == _clk_name.size();
      foreach(_clk_name[i])
        clk_name[i]      == _clk_name[i];
    })) `uvm_error("CLK_PKG", "\nRandomization failed\n");

    if (_print_info) begin
      `uvm_info("CLK_PKG", $sformatf({"\nClk Stop OP:\n",
                               "-------------------------------------------------\n",
                               "OP Type         : CLK_STOP\n",
                               "Pin Name(s)     : %s\n",
                               "Pin Num(s)      : %s\n"}
                               , printPinEnumO(_clk_name, 0), printPinEnumO(_clk_name, 1)
      ), UVM_LOW);
    end

    _seq.start(_sqcr);

  endtask : stopClk

  //----------------------------------------------------------------------------

  task automatic setClkPol(
    input  bit                _print_info     = 1'b1,
    input  uvm_sequencer_base _sqcr                 ,
    input  clk_list_t         _clk_name    []       ,
    input  logic              _init        [] = {}
  );

    ClkSetPolaritySequence  _seq;
    
    if (_sqcr == null) begin
      `uvm_error("CLK_PKG", "\nClk agent sequencer handle is NULL\n")
      return;
    end

    if (_clk_name.size() > WIDTH || _clk_name.size() < 1) begin
      `uvm_error("CLK_PKG", {"\nOperation ignored.\nNumber of specified clocks ",
                             "is greater than number of actual clocks, or is less than one\n"})
      return;
    end
        
    _seq = ClkSetPolaritySequence::type_id::create("clk_set_pol_seq");
    
    // set default values for initial and phase delay parameters
    if (!_init.size()) begin
      _init = new [_clk_name.size()];
      foreach (_init[i]) begin
        _init[i] = 1'b0;
      end
    end

    if (!(_seq.randomize() with {
      clk_name.size()    == _clk_name.size();
      foreach(_clk_name[i])
        clk_name[i]      == _clk_name[i];
      init.size()        == _init.size();
      foreach(_init[i])
        init[i]          == _init[i];
    })) `uvm_error("CLK_PKG", "\nRandomization failed\n")

    if (_print_info) begin
      `uvm_info("CLK_PKG", $sformatf({"\nClk Set Polatiy OP:\n",
                               "-------------------------------------------------\n",
                               "OP Type           : CLK_START\n",
                               "Pin Name(s)       : %s\n",
                               "Pin Num(s)        : %s\n",
                               "Polarity value(s) : %s\n"}
                               , printPinEnumO(_clk_name, 0), printPinEnumO(_clk_name, 1), printPinVal(_init)
      ), UVM_LOW)
    end

    _seq.start(_sqcr);

  endtask : setClkPol

endpackage : ClkAgentPkg

`endif
