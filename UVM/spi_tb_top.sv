// ============================================================================
// spi_tb_top.sv
// Top-level module. Replaces the original `tb_spi_vip` module body up to
// (but not including) the class-based components, which now live in the
// UVM env started via run_test(). DUT instantiation and the assertion bind
// are unchanged.
//
// No `timescale directive here on purpose — see spi_pkg.sv for why (VCS's
// ITSFM check rejects mixing timescale/no-timescale files in one
// compilation, and the RTL files have none). Pass `-timescale=1ns/1ps` on
// the vcs command line instead.
// ============================================================================

module spi_tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import spi_pkg::*;

  logic clk = 0;
  always #5 clk = ~clk;

  spi_if vif(clk);

  spi_master master_inst(
    .clk      (clk),
    .rst      (vif.rst),
    .start    (vif.start),
    .data_in  (vif.master_data_in),
    .miso     (vif.miso),
    .mosi     (vif.mosi),
    .sclk     (vif.sclk),
    .cs       (vif.cs),
    .data_out (vif.master_data_out),
    .busy     (vif.busy),
    .done     (vif.done)
  );

  spi_slave slave_inst(
    .clk        (clk),
    .rst        (vif.rst),
    .sclk       (vif.sclk),
    .mosi       (vif.mosi),
    .cs         (vif.cs),
    .data_in    (vif.slave_data_in),
    .data_ready (vif.data_ready),
    .miso       (vif.miso),
    .data_out   (vif.slave_data_out),
    .data_valid (vif.data_valid)
  );

  spi_assertions sa(vif);

  initial begin
    // Unrestricted handle: driver uses this only to drive `rst` directly,
    // since neither modport exposes it as writable.
    uvm_config_db#(virtual spi_if)::set(null, "uvm_test_top.env.agent.drv", "vif", vif);
    uvm_config_db#(virtual spi_if.DRV)::set(null, "uvm_test_top.env.agent.drv", "drv_vif", vif);
    uvm_config_db#(virtual spi_if.MON)::set(null, "uvm_test_top.env.agent.mon", "vif", vif);
    run_test();
  end

  initial begin
    $dumpfile("spi.vcd");
    $dumpvars(0, spi_tb_top);
  end

endmodule
