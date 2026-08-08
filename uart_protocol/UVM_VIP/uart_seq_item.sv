class uart_seq_item extends uvm_sequence_item;
  rand bit [7:0]data;
  constraint c_balanced{data dist {[8'h00:8'h3F]:/33,[8'h40:8'hAF]:/34,[8'hB0:8'hFF]:/33};}
  `uvm_object_utils_begin(uart_seq_item)
    `uvm_field_int(data,UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="uart_seq_item");
    super.new(name);
  endfunction

  function void display(string tag);
    `uvm_info(tag,$sformatf("DATA=0x%02h",data),UVM_LOW)
  endfunction

  function string convert2string();
    return $sformatf("data=0x%02h",data);
  endfunction
endclass
