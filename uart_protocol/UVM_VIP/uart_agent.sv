class uart_agent extends uvm_agent;
  `uvm_component_utils(uart_agent)
  uart_sequencer sqr;
  uart_driver drv;
  uart_monitor mon;
  uvm_analysis_port #(uart_seq_item) drv_ap;
  uvm_analysis_port #(uart_seq_item) mon_ap;
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon=uart_monitor::type_id::create("mon",this);

    if(get_is_active()==UVM_ACTIVE) begin
      sqr=uart_sequencer::type_id::create("sqr",this);
      drv=uart_driver::type_id::create("drv",this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(get_is_active()==UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
    drv_ap=drv.drv_ap;
    mon_ap=mon.mon_ap;
  endfunction
endclass
