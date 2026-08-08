`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)

class spi_scoreboard extends uvm_component;
  `uvm_component_utils(spi_scoreboard)
  uvm_analysis_imp_drv #(spi_seq_item,spi_scoreboard) drv_export;
  uvm_analysis_imp_mon #(spi_seq_item,spi_scoreboard) mon_export;
  int pass_cnt;
  int fail_cnt;
  function new(string name,uvm_component parent);
    super.new(name,parent);
    drv_export=new("drv_export",this);
    mon_export=new("mon_export",this);
    pass_cnt=0;
    fail_cnt=0;
  endfunction

  function void do_check(string label,bit [7:0]exp,bit [7:0]act);
    if(exp==act) begin
      `uvm_info("SCOREBOARD",$sformatf("PASS %-12s EXP=%0h ACT=%0h",label,exp,act),UVM_LOW)
      pass_cnt++;
    end
    else begin
      `uvm_error("SCOREBOARD",$sformatf("FAIL %-12s EXP=%0h ACT=%0h",label,exp,act))
      fail_cnt++;
    end
  endfunction

  function void write_drv(spi_seq_item dtr);
    do_check("MASTER_RX:",dtr.slave_tx,dtr.master_rx);
    do_check("SLAVE_RX: ",dtr.master_tx,dtr.slave_rx);
  endfunction

  function void write_mon(spi_seq_item mtr);
    `uvm_info("SCOREBOARD",$sformatf("MON OBSERVED MSTR_TX=%0h SLV_TX=%0h MSTR_RX=%0h SLV_RX=%0h",mtr.master_tx,mtr.slave_tx,mtr.master_rx,mtr.slave_rx),UVM_HIGH)
  endfunction

  function void report();
    `uvm_info("SCOREBOARD",$sformatf("TOTAL PASS=%0d  FAIL=%0d",pass_cnt,fail_cnt),UVM_LOW)
  endfunction

  function void report_phase(uvm_phase phase);
    report();
  endfunction
endclass
