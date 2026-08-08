interface spi_if(input logic clk);
  logic rst;
  logic start;
  logic [7:0]master_data_in;
  logic [7:0]slave_data_in;
  logic data_ready;
  wire [7:0]master_data_out;
  wire [7:0]slave_data_out;
  wire mosi,miso,sclk,cs;
  wire busy,done,data_valid;

  clocking drv_cb @(posedge clk);
    output start;
    output master_data_in;
    output slave_data_in;
    output data_ready;
    input master_data_out;
    input slave_data_out;
    input busy;
    input done;
    input data_valid;
  endclocking

  clocking mon_cb @(posedge clk);
    input start;
    input master_data_in;
    input slave_data_in;
    input data_ready;
    input master_data_out;
    input slave_data_out;
    input mosi;
    input miso;
    input sclk;
    input cs;
    input busy;
    input done;
    input data_valid;
  endclocking

  modport DRV(clocking drv_cb,input clk,input rst);
  modport MON(clocking mon_cb,input clk,input rst);
endinterface
