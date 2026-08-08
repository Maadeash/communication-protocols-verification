// ============================================================================
// spi_scoreboard.sv
// Replaces the original `spi_scoreboard` class. Two analysis imps replace
// the two mailboxes (`drv2scb`, `mon2scb`).
//
// IMPORTANT — faithfully preserved behavior: in the original code, the
// mon2scb branch of scb.run() only did `mon2scb.get(mtr);` and never
// compared mtr against anything — all checking happened on the drv2scb
// branch, comparing each transaction's own master_rx/slave_rx (captured
// directly off the DUT by the driver) against the *other* side's expected
// tx byte:
//   MASTER_RX check: did the master receive what the slave was sending?
//   SLAVE_RX  check: did the slave receive what the master was sending?
// That already exercises both directions of the link, which is what
// "verify both master and slave sides" means here. This conversion keeps
// that exact check set. write_mon() is implemented (so the monitor's
// stream is still consumed and logged, matching original behavior) but
// intentionally does not add new pass/fail checks, to avoid silently
// changing the original scoreboard's PASS/FAIL semantics. If you want an
// independent passive cross-check (monitor-observed data vs.
// driver-observed data for the same transfer), that's a natural extension
// point inside write_mon() below.
// ============================================================================

`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)

class spi_scoreboard extends uvm_component;
  `uvm_component_utils(spi_scoreboard)

  uvm_analysis_imp_drv #(spi_seq_item, spi_scoreboard) drv_export;
  uvm_analysis_imp_mon #(spi_seq_item, spi_scoreboard) mon_export;

  int pass_cnt;
  int fail_cnt;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    drv_export = new("drv_export", this);
    mon_export = new("mon_export", this);
    pass_cnt   = 0;
    fail_cnt   = 0;
  endfunction

  function void do_check(string label, bit [7:0] exp, bit [7:0] act);
    if (exp == act) begin
      `uvm_info("SCOREBOARD", $sformatf("PASS %-12s EXP=%0h ACT=%0h", label, exp, act), UVM_LOW)
      pass_cnt++;
    end else begin
      `uvm_error("SCOREBOARD", $sformatf("FAIL %-12s EXP=%0h ACT=%0h", label, exp, act))
      fail_cnt++;
    end
  endfunction

  // Called on every item the driver completed (was drv2scb.put in original)
  function void write_drv(spi_seq_item dtr);
    do_check("MASTER_RX:", dtr.slave_tx,  dtr.master_rx);
    do_check("SLAVE_RX: ", dtr.master_tx, dtr.slave_rx);
  endfunction

  // Called on every item the monitor captured (was mon2scb.put in original)
  function void write_mon(spi_seq_item mtr);
    `uvm_info("SCOREBOARD", $sformatf("MON OBSERVED MSTR_TX=%0h SLV_TX=%0h MSTR_RX=%0h SLV_RX=%0h",
              mtr.master_tx, mtr.slave_tx, mtr.master_rx, mtr.slave_rx), UVM_HIGH)
  endfunction

  function void report();
    `uvm_info("SCOREBOARD", $sformatf("TOTAL PASS=%0d  FAIL=%0d", pass_cnt, fail_cnt), UVM_LOW)
  endfunction

  function void report_phase(uvm_phase phase);
    report();
  endfunction
endclass
