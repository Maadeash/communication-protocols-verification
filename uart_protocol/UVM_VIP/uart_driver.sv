class uart_driver extends uvm_driver #(uart_seq_item);
  `uvm_component_utils(uart_driver)
  virtual uart_if.DRV vif;
  uvm_analysis_port #(uart_seq_item) drv_ap;

  function new(string name,uvm_component parent);
    super.new(name,parent);
    drv_ap=new("drv_ap",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual uart_if.DRV)::get(this,"","vif",vif))
      `uvm_fatal("DRV","Virtual interface (DRV modport) not set via uvm_config_db")
  endfunction

  task reset_dut();
    vif.rst=1'b1;
    vif.drv_cb.wr<=1'b0;
    vif.drv_cb.rd<=1'b0;
    vif.drv_cb.w_data<=8'h00;
    repeat(20) @(posedge vif.clk);
    vif.rst=1'b0;
    @(posedge vif.clk);
    `uvm_info("DRV","Reset released — starting test",UVM_LOW)
  endtask

  task write_byte(input bit [7:0]data);
    @(vif.drv_cb);
    while(vif.drv_cb.tx_full)
    @(vif.drv_cb);
    @(vif.drv_cb);
    vif.drv_cb.w_data<=data;
    vif.drv_cb.wr<=1'b1;
    @(vif.drv_cb);
    vif.drv_cb.wr<=1'b0;
    vif.drv_cb.w_data<=8'h00;
  endtask

  task read_byte();
    @(vif.drv_cb);
    while(vif.drv_cb.rx_empty)
      @(vif.drv_cb);
    @(vif.drv_cb);
    vif.drv_cb.rd<=1'b1;
    @(vif.drv_cb);
    vif.drv_cb.rd<=1'b0;
  endtask

  task run_phase(uvm_phase phase);
    uart_seq_item req;
    reset_dut();
    forever begin
      seq_item_port.get_next_item(req);
      write_byte(req.data);
      `uvm_info("DRV",$sformatf("WROTE 0x%02h",req.data),UVM_LOW)
      drv_ap.write(req);
      read_byte();
      seq_item_port.item_done();
    end
  endtask
endclass
