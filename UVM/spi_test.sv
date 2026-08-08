// ============================================================================
// spi_test.sv
// Replaces the top testbench's `initial` block orchestration: build env,
// fire off the directed sequence (fire-and-forget, same as the original
// `fork gen.run(); ... join_none`), then hold for a fixed simulation-time
// budget (default 500,000ns, same as the original `#500_000;`) regardless
// of whether the sequence has already finished — the original testbench
// does not exit early even though the 13-item generator completes in a few
// microseconds. After the time budget, print the same report/coverage
// breakdown shape and end the test.
// ============================================================================

class spi_base_test extends uvm_test;
  `uvm_component_utils(spi_base_test)

  spi_env env;
  int     sim_time_ns   = 500_000;
  int     clk_period_ns = 10;   // must match spi_tb_top's `always #5 clk = ~clk;`

  function new(string name = "spi_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = spi_env::type_id::create("env", this);

    void'($value$plusargs("SPI_SIM_TIME_NS=%0d", sim_time_ns));
    void'($value$plusargs("SPI_CLK_PERIOD_NS=%0d", clk_period_ns));
    uvm_top.set_timeout((sim_time_ns + 100_000) * 1ns, 0);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  // Clock-edge-counted budget instead of an absolute `#` delay — avoids
  // depending on whatever timeunit/timeprecision happens to be active for
  // this package at compile time. See README.md -> "Debugging notes".
  task wait_time_budget();
    int clks;
    clks = sim_time_ns / clk_period_ns;
    if (clks <= 0) begin
      `uvm_warning("TEST", $sformatf("sim_time_ns=%0d / clk_period_ns=%0d gave clks=%0d — clamping to 1",
                   sim_time_ns, clk_period_ns, clks))
      clks = 1;
    end
    repeat (clks) @(posedge env.agent.drv.vif.clk);
  endtask

  task run_phase(uvm_phase phase);
    spi_main_sequence seq;

    phase.raise_objection(this, "Starting SPI test");

    seq = spi_main_sequence::type_id::create("seq");

    fork
      seq.start(env.agent.sqr);
    join_none

    wait_time_budget();

    env.scb.report();

    `uvm_info("TEST", "========================================", UVM_LOW)
    `uvm_info("TEST", $sformatf("FINAL FUNCTIONAL COVERAGE = %0.2f%%",
              env.cov.get_cov()), UVM_LOW)
    `uvm_info("TEST", "========================================", UVM_LOW)
    `uvm_info("TEST", $sformatf("MASTER_TX = %0.2f%%",
              env.cov.spi_cg.MASTER_TX.get_coverage()), UVM_LOW)
    `uvm_info("TEST", $sformatf("SLAVE_TX  = %0.2f%%",
              env.cov.spi_cg.SLAVE_TX.get_coverage()), UVM_LOW)
    `uvm_info("TEST", $sformatf("CORNERS   = %0.2f%%",
              env.cov.spi_cg.CORNERS.get_coverage()), UVM_LOW)
    `uvm_info("TEST", $sformatf("TX_CROSS  = %0.2f%%",
              env.cov.spi_cg.TX_CROSS.get_coverage()), UVM_LOW)
    `uvm_info("TEST", "Simulation complete", UVM_LOW)

    phase.drop_objection(this, "SPI test complete");
  endtask
endclass

// ----------------------------------------------------------------------------
// Convenience test that runs the random sequence after the directed one,
// e.g.: +UVM_TESTNAME=spi_random_test
// The directed-only default (spi_base_test) is unaffected.
// ----------------------------------------------------------------------------
class spi_random_test extends spi_base_test;
  `uvm_component_utils(spi_random_test)

  int num_random = 10;

  function new(string name = "spi_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'($value$plusargs("SPI_NUM_RANDOM=%0d", num_random));
  endfunction

  task run_phase(uvm_phase phase);
    spi_main_sequence   dir_seq;
    spi_random_sequence rnd_seq;

    phase.raise_objection(this, "Starting SPI random test");

    dir_seq = spi_main_sequence::type_id::create("dir_seq");
    rnd_seq = spi_random_sequence::type_id::create("rnd_seq");
    rnd_seq.num_random = num_random;

    fork
      begin
        dir_seq.start(env.agent.sqr);
        rnd_seq.start(env.agent.sqr);
      end
    join_none

    wait_time_budget();

    env.scb.report();
    `uvm_info("TEST", $sformatf("FINAL FUNCTIONAL COVERAGE = %0.2f%%",
              env.cov.get_cov()), UVM_LOW)

    phase.drop_objection(this, "SPI random test complete");
  endtask
endclass
