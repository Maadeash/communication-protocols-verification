class uart_coverage extends uvm_component;
  `uvm_component_utils(uart_coverage)
  uart_seq_item tr;
  covergroup uart_cg;
    DATA:coverpoint tr.data{
        bins LOW={[8'h00:8'h3F]};
        bins MID={[8'h40:8'hAF]};
        bins HIGH={[8'hB0:8'hFF]};
      }
    CORNERS:coverpoint tr.data{
        bins ZERO={8'h00};
        bins ALL_ONES={8'hFF};
        bins ALT_AA={8'hAA};
        bins ALT_55={8'h55};
      }
  endgroup
  function new(string name,uvm_component parent);
    super.new(name,parent);
    uart_cg=new();
  endfunction

  function void sample(uart_seq_item t);
    tr=t;
    uart_cg.sample();
    `uvm_info("COVERAGE",$sformatf("CURRENT=%0.2f%%",uart_cg.get_inst_coverage()),UVM_LOW)
    if(uart_cg.get_inst_coverage()>=99.99)
      `uvm_info("COVERAGE",">>> ALL BINS COVERED <<<",UVM_LOW)
  endfunction

  function real get_coverage();
    return uart_cg.get_coverage();
  endfunction

  function bit is_complete();
    return (uart_cg.get_coverage()>=99.99);
  endfunction
endclass
