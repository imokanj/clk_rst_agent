/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : Agent package. Contains :
 *                 - User specified clocks
 *                 - User specified initial clock signal values
 *                 - All needed files for building the clock and reset agent (except the interface)
 *                 - Convenience functions/tasks for clock and reset generation/stopping
 */

`ifndef _AGENT_CLK_RST_PKG_
`define _AGENT_CLK_RST_PKG_

package ClkAgentPkg;

  timeunit        1ns;
  timeprecision 100ps;

//==============================================================================
// System section
//==============================================================================

//******************************************************************************
// Constants, classes, types, etc.
//******************************************************************************

  typedef enum {
    RST_SET,
    CLK_WAIT,
    CLK_SET,
    CLK_START,
    CLK_STOP
  } op_type_t;

//******************************************************************************
// Imports
//******************************************************************************

  import uvm_pkg::*;
  import ClkAgentUserPkg::*; // user settings

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
  `include "sequences/rst_set_polarity_sequence.svh"
  `include "sequences/clk_wait_cycles_sequence.svh"

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
      `uvm_error("CLK_RST_PKG", "\nClk agent sequencer handle is NULL\n")
      return;
    end

    if (_clk_name.size() > C_WIDTH || _clk_name.size() < 1) begin
      `uvm_error("CLK_RST_PKG", {"\nOperation ignored.\nNumber of specified clocks ",
                             "is greater than number of actual clocks, or is less than one\n"})
      return;
    end

    if (_period.size() != _clk_name.size()) begin
      `uvm_error("CLK_RST_PKG", "\nNumber of specified clock periods differs from the number of clock sources.\n")
      return;
    end

    foreach (_period[i]) begin
      if (_period[i][0]) begin
        `uvm_warning("CLK_RST_PKG", $sformatf("\nPeriod for %s clock is not an even number\n", _clk_name[i].name()))
      end
    end

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
    })) `uvm_error("CLK_RST_PKG", "\nRandomization failed\n")

    if (_print_info) begin
      `uvm_info("CLK_RST_PKG", $sformatf({"\nStart Clock OP:\n",
                               "-------------------------------------------------\n",
                               "OP Type         : CLK_START\n",
                               "Clock Name(s)   : %s\n",
                               "Clock Num(s)    : %s\n",
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
    input  bit                _print_info    = 1'b1,
    input  uvm_sequencer_base _sqcr                ,
    input  clk_list_t         _clk_name   []
  );

    ClkStopSequence  _seq;

    if (_sqcr == null) begin
      `uvm_error("CLK_RST_PKG", "\nClk agent sequencer handle is NULL\n")
      return;
    end

    if (_clk_name.size() > C_WIDTH || _clk_name.size() < 1) begin
      `uvm_error("CLK_RST_PKG", {"\nOperation ignored.\nNumber of specified clocks ",
                             "is greater than number of actual clocks, or is less than one\n"})
      return;
    end

    _seq = ClkStopSequence::type_id::create("clk_stop_seq");

    if (!(_seq.randomize() with {
      clk_name.size()    == _clk_name.size();
      foreach(_clk_name[i])
        clk_name[i]      == _clk_name[i];
    })) `uvm_error("CLK_RST_PKG", "\nRandomization failed\n");

    if (_print_info) begin
      `uvm_info("CLK_RST_PKG", $sformatf({"\nStop Clock OP:\n",
                               "-------------------------------------------------\n",
                               "OP Type         : CLK_STOP\n",
                               "Clock Name(s)   : %s\n",
                               "Clock Num(s)    : %s\n"}
                               , printPinEnumO(_clk_name, 0), printPinEnumO(_clk_name, 1)
      ), UVM_LOW);
    end

    _seq.start(_sqcr);

  endtask : stopClk

  //----------------------------------------------------------------------------

  task automatic setClkPol(
    input  bit                _print_info    = 1'b1,
    input  uvm_sequencer_base _sqcr                ,
    input  clk_list_t         _clk_name   []       ,
    input  logic              _pol        [] = {}
  );

    ClkSetPolaritySequence  _seq;

    if (_sqcr == null) begin
      `uvm_error("CLK_RST_PKG", "\nClk agent sequencer handle is NULL\n")
      return;
    end

    if (_clk_name.size() > C_WIDTH || _clk_name.size() < 1) begin
      `uvm_error("CLK_RST_PKG", {"\nOperation ignored.\nNumber of specified clocks ",
                                 "is greater than number of actual clocks, or is less than one\n"})
      return;
    end

    _seq = ClkSetPolaritySequence::type_id::create("clk_set_pol_seq");

    // set default values for initial and phase delay parameters
    if (!_pol.size()) begin
      `uvm_warning("CLK_RST_PKG", "\nPolarity not specified. Default value of all zeros used.\n")
      _pol = new [_clk_name.size()];
      foreach (_pol[i]) begin
        _pol[i] = 1'b0;
      end
    end

    if (!(_seq.randomize() with {
      clk_name.size()    == _clk_name.size();
      foreach(_clk_name[i])
        clk_name[i]      == _clk_name[i];
      init.size()        == _pol.size();
      foreach(_pol[i])
        init[i]          == _pol[i];
    })) `uvm_error("CLK_RST_PKG", "\nRandomization failed\n")

    if (_print_info) begin
      `uvm_info("CLK_RST_PKG", $sformatf({"\nSet Clock Polatiy OP:\n",
                               "-------------------------------------------------\n",
                               "OP Type           : CLK_SET\n",
                               "Clock Name(s)     : %s\n",
                               "Clock Num(s)      : %s\n",
                               "Polarity value(s) : %s\n"}
                               , printPinEnumO(_clk_name, 0), printPinEnumO(_clk_name, 1), printPinVal(_pol)
      ), UVM_LOW)
    end

    _seq.start(_sqcr);

  endtask : setClkPol

  //----------------------------------------------------------------------------

  task automatic setRstPol(
    input  bit                _print_info     = 1'b1,
    input  uvm_sequencer_base _sqcr                 ,
    input  rst_list_t         _rst_name    []       ,
    input  clk_list_t         _clk_name    []       ,
    input  logic              _pol         [] = {}  ,
    input  logic              _is_blocking    = 1'b1
  );

    string                  _is_blocking_str;
    RstSetPolaritySequence  _seq;

    if (_sqcr == null) begin
      `uvm_error("CLK_RST_PKG", "\nClk agent sequencer handle is NULL\n")
      return;
    end

    if (_rst_name.size() > R_WIDTH || _rst_name.size() < 1) begin
      `uvm_error("CLK_RST_PKG", {"\nOperation ignored.\nNumber of specified resets ",
                                 "is greater than number of actual resets, or is less than one\n"})
      return;
    end

    if (_clk_name.size() > C_WIDTH || _rst_name.size() < 1 || (_clk_name.size() < C_WIDTH && _clk_name.size() != 1)) begin
      `uvm_error("CLK_RST_PKG", {"\nOperation ignored.\nValid number of specified clocks ",
                                 "is either one or an individual clock for all reset signals.\n",
                                 "When one clock is specified it will be used for all specified reset signals.\n"})
      return;
    end

    _seq = RstSetPolaritySequence::type_id::create("rst_set_pol_seq");

    // regulate clk array
    if (_clk_name.size() == 1) begin
      clk_list_t tmp;
      tmp = _clk_name[0];

      _clk_name = new [_rst_name.size()];
      foreach (_clk_name[i]) begin
        _clk_name[i] = tmp;
      end
    end

    // set default values for initial and phase delay parameters
    if (!_pol.size()) begin
      `uvm_warning("CLK_RST_PKG", "\nPolarity not specified. Default value of all zeros used.\n")
      _pol = new [_rst_name.size()];
      foreach (_pol[i]) begin
        _pol[i] = 1'b0;
      end
    end

    if (!(_seq.randomize() with {
      rst_name.size()    == _rst_name.size();
      foreach(_rst_name[i])
        rst_name[i]      == _rst_name[i];
      clk_name.size()    == _clk_name.size();
      foreach(_clk_name[i])
        clk_name[i]      == _clk_name[i];
      init.size()        == _pol.size();
      foreach(_pol[i])
        init[i]          == _pol[i];
      is_blocking     == _is_blocking;
    })) `uvm_error("CLK_RST_PKG", "\nRandomization failed\n")

    if (_print_info) begin
      _is_blocking_str = (_is_blocking != 1'b0) ? "TRUE" : "FALSE";

      `uvm_info("CLK_RST_PKG", $sformatf({"\nSet Reset Polatiy OP:\n",
                               "-------------------------------------------------\n",
                               "OP Type           : RST_SET\n",
                               "Reset Name(s)     : %p\n",
                               "Reset Num(s)      : %p\n",
                               "Polarity value(s) : %s\n",
                               "Clock Name(s)     : %s\n",
                               "Clock Num(s)      : %s\n",
                               "Blocking          : %s\n"}
                               , _rst_name, _rst_name, printPinVal(_pol)
                               , printPinEnumO(_clk_name, 0), printPinEnumO(_clk_name, 1)
                               , _is_blocking_str
      ), UVM_LOW)
    end

    _seq.start(_sqcr);

  endtask : setRstPol

  //----------------------------------------------------------------------------

  task automatic waitClkCycles(
    input  bit                _print_info = 1'b1,
    input  uvm_sequencer_base _sqcr             ,
    input  clk_list_t         _clk_name         ,
    input  bit [31:0]         _num        = 1
  );

    ClkWaitCyclesSequence  _seq;

    if (_sqcr == null) begin
      `uvm_error("CLK_RST_PKG", "\nClk agent sequencer handle is NULL\n")
      return;
    end

    _seq = ClkWaitCyclesSequence::type_id::create("clk_wait_cycles_seq");

    if (_num < 1) begin
      `uvm_warning("CLK_RST_PKG", "\nIncorrect number of cycles value specified. Value of 1 used.\n")
      _num = 1;
    end

    if (!(_seq.randomize() with {
      clk_name.size() == 1;
      clk_name[0]     == _clk_name;
      num             == _num;
    })) `uvm_error("CLK_RST_PKG", "\nRandomization failed\n")

    if (_print_info) begin
      `uvm_info("CLK_RST_PKG", $sformatf({"\nWait Clock Cycles OP:\n",
                               "-------------------------------------------------\n",
                               "OP Type       : CLK_WAIT\n",
                               "Clock Name    : %s\n",
                               "Clock Num     : %0d\n",
                               "Num. Cycle(s) : %0d\n"}
                               , _clk_name.name(), _clk_name, _num
      ), UVM_LOW)
    end

    _seq.start(_sqcr);

  endtask : waitClkCycles


endpackage : ClkAgentPkg

`endif
