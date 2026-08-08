// ============================================================================
// spi_monitor.sv
// Replaces the original `spi_monitor` class. Same trigger condition
// (polls `done` every clock via the MON modport's clocking block) and same
// captured fields. Broadcasts on an analysis port — this is passively
// observed data; per the original scoreboard, it is received but not
// actively compared (see spi_scoreboard.sv for the note on why that's
// preserved as-is).
// ============================================================================

class spi_monitor extends uvm_monitor;
  `uvm_component_utils(spi_monitor)

  virtual spi_if.MON vif;
  uvm_analysis_port #(spi_seq_item) mon_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual spi_if.MON)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Virtual interface (MON modport) not set via uvm_config_db")
  endfunction

  task run_phase(uvm_phase phase);
    spi_seq_item tr;

    forever begin
      begin : mon_wait
        automatic bit found = 0;

        while (!found) begin
          @(vif.mon_cb);
          if (vif.mon_cb.done)
            found = 1;
        end
      end

      tr           = spi_seq_item::type_id::create("tr");
      tr.master_tx = vif.mon_cb.master_data_in;
      tr.slave_tx  = vif.mon_cb.slave_data_in;
      tr.master_rx = vif.mon_cb.master_data_out;
      tr.slave_rx  = vif.mon_cb.slave_data_out;
      mon_ap.write(tr);

      `uvm_info("MONITOR", $sformatf("MSTR_TX=%0h SLV_TX=%0h MSTR_RX=%0h SLV_RX=%0h",
                tr.master_tx, tr.slave_tx, tr.master_rx, tr.slave_rx), UVM_LOW)
    end
  endtask
endclass
