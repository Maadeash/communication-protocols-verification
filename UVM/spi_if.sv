// ============================================================================
// spi_if.sv
// DUT-facing interface. Same clocking blocks/modports as the original VIP.
//
// NOTE: both DRV and MON modports declare `rst` as plain `input rst` (not
// `ref`, unlike the UART interface this VIP suite also contains). That means
// `rst` cannot be driven through either modport-typed handle. The UVM driver
// therefore also obtains an *unrestricted* `virtual spi_if` handle (see
// uart_driver.sv's UART counterpart for contrast, and spi_driver.sv here)
// purely to assert/deassert reset, exactly like the original testbench did
// by writing `vif.rst` directly instead of through drv_cb.
// ============================================================================

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
