class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)
  virtual uart_if.MON vif;
  uvm_analysis_port #(uart_seq_item) mon_ap;

  function new(string name,uvm_component parent);
    super.new(name,parent);
    mon_ap=new("mon_ap",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual uart_if.MON)::get(this,"","vif",vif))
      `uvm_fatal("MON","Virtual interface (MON modport) not set via uvm_config_db")
  endfunction

  task run_phase(uvm_phase phase);
    uart_seq_item tr;
    forever begin
      @(vif.mon_cb iff (vif.mon_cb.rd===1'b1));
      tr=uart_seq_item::type_id::create("tr");
      tr.data=vif.mon_cb.r_data;
      mon_ap.write(tr);
      `uvm_info("MON",$sformatf("CAPTURED 0x%02h",tr.data),UVM_LOW)
      @(vif.mon_cb);
    end
  endtask
endclass
