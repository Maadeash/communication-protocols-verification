// ============================================================================
// uart_scoreboard.sv
// Replaces the original `uart_scoreboard` class. Same logic: an expected
// queue fed by the driver's "just wrote" transactions, checked against the
// monitor's captured transactions in arrival order. Same pass/fail counters,
// same report() format, and the same `coverage_done` event fired once
// coverage hits 100%. Two analysis imps replace the two mailboxes
// (`drv2scb`, `mon2scb`).
// ============================================================================

`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)

class uart_scoreboard extends uvm_component;
  `uvm_component_utils(uart_scoreboard)

  uvm_analysis_imp_drv #(uart_seq_item, uart_scoreboard) drv_export;
  uvm_analysis_imp_mon #(uart_seq_item, uart_scoreboard) mon_export;

  uart_coverage cov;   // handle set by the env, mirrors original constructor arg

  bit [7:0] exp_q[$];
  int       pass_cnt, fail_cnt;
  event     coverage_done;
  bit       coverage_done_fired;   // guards against re-announcing 100% every transaction

  function new(string name, uvm_component parent);
    super.new(name, parent);
    drv_export           = new("drv_export", this);
    mon_export           = new("mon_export", this);
    pass_cnt             = 0;
    fail_cnt             = 0;
    coverage_done_fired  = 0;
  endfunction

  // Called on every item the driver just wrote (was drv2scb.put in original)
  function void write_drv(uart_seq_item tr);
    exp_q.push_back(tr.data);
    `uvm_info("SCB", $sformatf("EXPECT 0x%02h  (queue depth=%0d)",
              tr.data, exp_q.size()), UVM_LOW)
  endfunction

  // Called on every item the monitor captured (was mon2scb.put in original)
  function void write_mon(uart_seq_item tr);
    bit [7:0] exp;

    if (exp_q.size() > 0) begin
      exp = exp_q.pop_front();
      if (exp === tr.data) begin
        `uvm_info("SCB", $sformatf("PASS  EXP=0x%02h  ACT=0x%02h", exp, tr.data), UVM_LOW)
        pass_cnt++;
        if (cov != null) begin
          cov.sample(tr);
          if (cov.is_complete() && !coverage_done_fired) begin
            coverage_done_fired = 1;
            `uvm_info("SCB", ">>> 100% FUNCTIONAL COVERAGE REACHED <<<", UVM_LOW)
            ->coverage_done;
          end
        end
      end else begin
        `uvm_error("SCB", $sformatf("FAIL  EXP=0x%02h  ACT=0x%02h", exp, tr.data))
        fail_cnt++;
      end
    end else begin
      `uvm_error("SCB", $sformatf("FAIL  UNEXPECTED ACT=0x%02h", tr.data))
      fail_cnt++;
    end
  endfunction

  function void report();
    real cov_pct;
    cov_pct = (cov != null) ? cov.get_coverage() : 0.0;
    `uvm_info("SCB", "============================================", UVM_LOW)
    `uvm_info("SCB", $sformatf(" SCOREBOARD: PASS=%0d  FAIL=%0d", pass_cnt, fail_cnt), UVM_LOW)
    `uvm_info("SCB", $sformatf(" FUNCTIONAL COVERAGE OVERALL: %.2f%%", cov_pct), UVM_LOW)
    if (cov_pct >= 99.99)
      `uvm_info("SCB", " COVERAGE STATUS: COMPLETE (all bins hit)", UVM_LOW)
    else
      `uvm_info("SCB", " COVERAGE STATUS: INCOMPLETE - increase num_random or transactions", UVM_LOW)
    `uvm_info("SCB", "============================================", UVM_LOW)
  endfunction

  function void report_phase(uvm_phase phase);
    report();
  endfunction
endclass
