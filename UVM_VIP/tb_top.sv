// ============================================================================
// tb_top.sv
// Top-level simulation module. Compile last (after i2c_if.sv, the rtl/
// files, i2c_assertions.sv and i2c_pkg.sv).
// ============================================================================
`include "uvm_macros.svh"
import uvm_pkg::*;
import i2c_pkg::*;

module tb_top;

  bit clk;
  always #10 clk = ~clk;

  i2c_if vif(clk);

  master dut_master(
    .clk      (clk),
    .rst      (vif.rst),
    .w_data   (vif.w_data),
    .addr     (vif.addr),
    .rw       (vif.rw),
    .enable   (vif.enable),
    .dout     (vif.dout),
    .i2c_sda  (vif.sda),
    .i2c_scl  (vif.scl)
  );

  slave dut_slave(
    .sda(vif.sda),
    .scl(vif.scl)
  );

  i2c_assertions i_assert(vif);

  initial begin
    $dumpfile("i2c_uvm.vcd");
    $dumpvars(0,tb_top);
  end

  // reset sequencing — matches the original TB's repeat(20)@(posedge clk)
  initial begin
    vif.rst    = 1'b1;
    vif.enable = 1'b0;
    vif.addr   = 7'd0;
    vif.rw     = 1'b0;
    vif.w_data = 8'd0;
    repeat(20) @(posedge clk);
    vif.rst = 1'b0;
  end

  initial begin
    uvm_config_db#(virtual i2c_if.DRV)::set(null,"*","vif",vif);
    uvm_config_db#(virtual i2c_if.MON)::set(null,"*","vif",vif);
    run_test();
  end

endmodule : tb_top
