// ============================================================================
// spi_driver.sv
// Replaces the original `spi_driver` class. Same signal sequencing
// (drive data + data_ready, pulse start for one cycle, poll `done`), same
// rx capture from master_data_out/slave_data_out. Broadcasts the completed
// transaction (tx values + captured rx values) on a single analysis port —
// this feeds both the scoreboard (was `drv2scb`) and the coverage collector
// (was the driver calling `cov.sample(tr)` directly).
//
// Uses two virtual interface handles:
//   - `vif`     : unrestricted `virtual spi_if`, used only to drive/read
//                 `rst` directly and to wait on `clk`, since neither DRV nor
//                 MON modport exposes `rst` as writable (see spi_if.sv).
//   - `drv_vif` : `virtual spi_if.DRV`, used for all clocking-block driven
//                 traffic, exactly like the original `vif.drv_cb.*` access.
// ============================================================================

class spi_driver extends uvm_driver #(spi_seq_item);
  `uvm_component_utils(spi_driver)

  virtual spi_if     vif;
  virtual spi_if.DRV drv_vif;
  uvm_analysis_port #(spi_seq_item) drv_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    drv_ap = new("drv_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Unrestricted virtual interface not set via uvm_config_db")
    if (!uvm_config_db#(virtual spi_if.DRV)::get(this, "", "drv_vif", drv_vif))
      `uvm_fatal("DRV", "Virtual interface (DRV modport) not set via uvm_config_db")
  endfunction

  // Same reset sequencing as the original initial block.
  task reset_dut();
    vif.rst            = 1'b1;
    vif.start           = 1'b0;
    vif.master_data_in  = 8'h00;
    vif.slave_data_in   = 8'h00;
    vif.data_ready       = 1'b0;

    repeat (5) @(posedge vif.clk);
    vif.rst = 1'b0;

    `uvm_info("DRV", "Reset released - starting test", UVM_LOW)
  endtask

  task run_phase(uvm_phase phase);
    spi_seq_item req;

    reset_dut();

    forever begin
      seq_item_port.get_next_item(req);

      @(drv_vif.drv_cb);
      drv_vif.drv_cb.master_data_in <= req.master_tx;
      drv_vif.drv_cb.slave_data_in  <= req.slave_tx;
      drv_vif.drv_cb.data_ready     <= 1'b1;
      drv_vif.drv_cb.start          <= 1'b0;
      @(drv_vif.drv_cb);
      drv_vif.drv_cb.start          <= 1'b1;
      @(drv_vif.drv_cb);
      drv_vif.drv_cb.start          <= 1'b0;

      begin : wait_done
        automatic bit found = 0;

        while (!found) begin
          @(drv_vif.drv_cb);
          if (drv_vif.drv_cb.done)
            found = 1;
        end
      end

      req.master_rx = drv_vif.drv_cb.master_data_out;
      req.slave_rx  = drv_vif.drv_cb.slave_data_out;

      drv_ap.write(req);

      `uvm_info("DRIVER", $sformatf("MSTR_TX=%0h SLV_TX=%0h MSTR_RX=%0h SLV_RX=%0h",
                req.master_tx, req.slave_tx, req.master_rx, req.slave_rx), UVM_LOW)

      seq_item_port.item_done();
    end
  endtask
endclass
