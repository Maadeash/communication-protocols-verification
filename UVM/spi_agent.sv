// ============================================================================
// spi_agent.sv
// Standard active agent: sequencer + driver + monitor.
// ============================================================================

class spi_agent extends uvm_agent;
  `uvm_component_utils(spi_agent)

  spi_sequencer sqr;
  spi_driver    drv;
  spi_monitor   mon;

  uvm_analysis_port #(spi_seq_item) drv_ap;
  uvm_analysis_port #(spi_seq_item) mon_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = spi_monitor::type_id::create("mon", this);

    if (get_is_active() == UVM_ACTIVE) begin
      sqr = spi_sequencer::type_id::create("sqr", this);
      drv = spi_driver::type_id::create("drv", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
    drv_ap = drv.drv_ap;
    mon_ap = mon.mon_ap;
  endfunction
endclass
