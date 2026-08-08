module uart_tb_top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import uart_pkg::*;
  logic clk=0;
  always #5 clk=~clk;

  uart_if vif(.clk(clk));
  top #(.dbit(8),.sb_tck(16),.n(10),.m(5),.fifo_addbit(2)) 
  dut(.clk(clk),.rst(vif.rst),.w_data(vif.w_data),.rd(vif.rd),.wr(vif.wr),.rx(vif.rx),.tx(vif.tx),.tx_full(vif.tx_full),.rx_empty(vif.rx_empty),.r_data(vif.r_data));

  assign vif.rx=vif.tx;
  uart_assertions ua(vif);
  initial begin
    uvm_config_db#(virtual uart_if.DRV)::set(null,"uvm_test_top.env.agent.drv","vif",vif);
    uvm_config_db#(virtual uart_if.MON)::set(null,"uvm_test_top.env.agent.mon","vif",vif);
    run_test();
  end

  initial begin
    $dumpfile("uart_sim.vcd");
    $dumpvars(0,uart_tb_top);
  end
endmodule
