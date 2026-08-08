interface uart_if(input logic clk);
  logic rst;
  logic [7:0]w_data;
  logic wr;
  logic rd;
  wire tx;
  wire rx;
  wire tx_full;
  wire rx_empty;
  wire [7:0]r_data;

  clocking drv_cb @(posedge clk);
    default input #1 output #1;
    output w_data;
    output wr;
    output rd;
    input tx_full;
    input rx_empty;
    input r_data;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1;
    input w_data;
    input wr;
    input rd;
    input tx;
    input rx;
    input tx_full;
    input rx_empty;
    input r_data;
  endclocking

  modport DRV(clocking drv_cb,input clk,ref rst);
  modport MON(clocking mon_cb,input clk,input rst);
endinterface
