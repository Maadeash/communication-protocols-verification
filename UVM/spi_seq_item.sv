class spi_seq_item extends uvm_sequence_item;
  rand bit [7:0]master_tx;
  rand bit [7:0]slave_tx;
  bit [7:0]master_rx;
  bit [7:0]slave_rx;

  `uvm_object_utils_begin(spi_seq_item)
    `uvm_field_int(master_tx,UVM_ALL_ON)
    `uvm_field_int(slave_tx,UVM_ALL_ON)
    `uvm_field_int(master_rx,UVM_ALL_ON|UVM_NOCOMPARE)
    `uvm_field_int(slave_rx,UVM_ALL_ON|UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name="spi_seq_item");
    super.new(name);
  endfunction

  function void display(string tag);
    `uvm_info(tag,$sformatf("MSTR_TX=%0h SLV_TX=%0h MSTR_RX=%0h SLV_RX=%0h",master_tx,slave_tx,master_rx,slave_rx),UVM_LOW)
  endfunction

  function string convert2string();
    return $sformatf("master_tx=0x%02h slave_tx=0x%02h master_rx=0x%02h slave_rx=0x%02h",master_tx,slave_tx,master_rx,slave_rx);
  endfunction
endclass
