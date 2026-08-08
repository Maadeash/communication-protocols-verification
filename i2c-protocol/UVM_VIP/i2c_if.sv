interface i2c_if(input logic clk);
  logic rst;
  logic [7:0]w_data;
  logic [6:0]addr;
  logic rw;
  logic enable;
  logic [7:0]dout;
  wire sda;
  wire scl;

  clocking drv_cb @(posedge clk);
    output w_data;
    output addr;
    output rw;
    output enable;
    input dout;
  endclocking

  clocking mon_cb @(posedge clk);
    input w_data;
    input addr;
    input rw;
    input enable;
    input dout;
    input sda;
    input scl;
  endclocking

  modport DRV(clocking drv_cb,input clk,input rst);
  modport MON(clocking mon_cb,input clk,input rst);
endinterface : i2c_if
