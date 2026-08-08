module spi_tb_top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import spi_pkg::*;

  logic clk=0;
  always #5 clk=~clk;
  spi_if vif(clk);

  spi_master master_inst(
    .clk(clk),
    .rst(vif.rst),
    .start(vif.start),
    .data_in(vif.master_data_in),
    .miso(vif.miso),
    .mosi(vif.mosi),
    .sclk(vif.sclk),
    .cs(vif.cs),
    .data_out(vif.master_data_out),
    .busy(vif.busy),
    .done(vif.done)
  );

  spi_slave slave_inst(
    .clk(clk),
    .rst(vif.rst),
    .sclk(vif.sclk),
    .mosi(vif.mosi),
    .cs(vif.cs),
    .data_in(vif.slave_data_in),
    .data_ready(vif.data_ready),
    .miso(vif.miso),
    .data_out(vif.slave_data_out),
    .data_valid(vif.data_valid)
  );

  spi_assertions sa(vif);
  initial begin
    uvm_config_db#(virtual spi_if)::set(null,"uvm_test_top.env.agent.drv","vif",vif);
    uvm_config_db#(virtual spi_if.DRV)::set(null,"uvm_test_top.env.agent.drv","drv_vif",vif);
    uvm_config_db#(virtual spi_if.MON)::set(null,"uvm_test_top.env.agent.mon","vif",vif);
    run_test();
  end

  initial begin
    $dumpfile("spi.vcd");
    $dumpvars(0,spi_tb_top);
  end
endmodule
