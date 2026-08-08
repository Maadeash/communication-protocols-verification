package i2c_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class i2c_txn extends uvm_sequence_item;
    rand bit [6:0]addr;
    rand bit rw;
    rand bit [7:0]data;
    bit [7:0]read_data;

    constraint c_addr { addr==7'b0101010; }

    `uvm_object_utils_begin(i2c_txn)
      `uvm_field_int(addr,UVM_ALL_ON)
      `uvm_field_int(rw,UVM_ALL_ON)
      `uvm_field_int(data,UVM_ALL_ON)
      `uvm_field_int(read_data,UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="i2c_txn");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf("ADDR=%0h RW=%0b DATA=%0h READ=%0h",addr,rw,data,read_data);
    endfunction
  endclass:i2c_txn

  class i2c_sequencer extends uvm_sequencer#(i2c_txn);
    `uvm_component_utils(i2c_sequencer)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction
  endclass:i2c_sequencer

  class i2c_base_seq extends uvm_sequence#(i2c_txn);
    `uvm_object_utils(i2c_base_seq)
    function new(string name="i2c_base_seq");
      super.new(name);
    endfunction
  endclass:i2c_base_seq

  class i2c_write_read_seq extends i2c_base_seq;
    `uvm_object_utils(i2c_write_read_seq)
    rand int unsigned reps=5;

    function new(string name="i2c_write_read_seq");
      super.new(name);
    endfunction

    task body();
      i2c_txn tr;
      repeat(reps) begin
        tr=i2c_txn::type_id::create("tr_wr");
        start_item(tr);
        if(!tr.randomize() with {rw==1'b0;})
          `uvm_error("SEQ","randomize failed (write)")
        finish_item(tr);
        tr=i2c_txn::type_id::create("tr_rd");
        start_item(tr);
        if(!tr.randomize() with {rw==1'b1;})
          `uvm_error("SEQ","randomize failed (read)")
        finish_item(tr);
      end
    endtask
  endclass:i2c_write_read_seq

  class i2c_corner_seq extends i2c_base_seq;
    `uvm_object_utils(i2c_corner_seq)
    static bit [7:0]corner_vals[4]='{8'h00,8'hFF,8'h55,8'hAA};

    function new(string name="i2c_corner_seq");
      super.new(name);
    endfunction

    task body();
      i2c_txn tr;
      foreach(corner_vals[i]) begin
        tr=i2c_txn::type_id::create("tr_wr");
        start_item(tr);
        if(!tr.randomize() with {rw==1'b0; data==corner_vals[i];})
          `uvm_error("SEQ","randomize failed (corner write)")
        finish_item(tr);

        tr=i2c_txn::type_id::create("tr_rd");
        start_item(tr);
        if(!tr.randomize() with {rw==1'b1;})
          `uvm_error("SEQ","randomize failed (corner read)")
        finish_item(tr);
      end
    endtask
  endclass:i2c_corner_seq

  class i2c_driver extends uvm_driver#(i2c_txn);
    `uvm_component_utils(i2c_driver)
    virtual i2c_if.DRV vif;

    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual i2c_if.DRV)::get(this,"","vif",vif))
        `uvm_fatal("NOVIF","virtual interface not set for i2c_driver")
    endfunction

    task run_phase(uvm_phase phase);
      i2c_txn tr;
      vif.drv_cb.enable<=1'b0;
      vif.drv_cb.addr<='0;
      vif.drv_cb.rw<=1'b0;
      vif.drv_cb.w_data<='0;
      if(vif.rst) @(negedge vif.rst);
      @(vif.drv_cb);
      forever begin
        seq_item_port.get_next_item(tr);
        drive(tr);
        seq_item_port.item_done();
      end
    endtask

    task drive(i2c_txn tr);
      vif.drv_cb.addr<=tr.addr;
      vif.drv_cb.rw<=tr.rw;
      vif.drv_cb.w_data<=tr.data;
      vif.drv_cb.enable<=1'b1;
      repeat(5) @(vif.drv_cb);
      vif.drv_cb.enable<=1'b0;
      repeat(150) @(vif.drv_cb);
      if(tr.rw) begin
        tr.read_data=vif.drv_cb.dout;
        `uvm_info("DRIVER",$sformatf("READ CAPTURED dout=%0h",tr.read_data),UVM_HIGH)
      end
      `uvm_info("DRIVER",tr.convert2string(),UVM_HIGH)
    endtask
  endclass:i2c_driver

  class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)
    virtual i2c_if.MON vif;
    uvm_analysis_port#(i2c_txn) ap;

    function new(string name,uvm_component parent);
      super.new(name,parent);
      ap=new("ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual i2c_if.MON)::get(this,"","vif",vif))
        `uvm_fatal("NOVIF","virtual interface not set for i2c_monitor")
    endfunction

    task run_phase(uvm_phase phase);
      i2c_txn tr;
      forever begin
        @(vif.mon_cb);
        if(vif.mon_cb.enable) begin
          tr=i2c_txn::type_id::create("tr");
          tr.addr=vif.mon_cb.addr;
          tr.rw=vif.mon_cb.rw;
          tr.data=vif.mon_cb.w_data;
          @(negedge vif.mon_cb.enable);
          repeat(150) @(vif.mon_cb);
          if(tr.rw)
            tr.read_data=vif.mon_cb.dout;
          else
            tr.read_data=8'h00;
          ap.write(tr);
          `uvm_info("MONITOR",tr.convert2string(),UVM_HIGH)
        end
      end
    endtask
  endclass:i2c_monitor

  class i2c_agent extends uvm_agent;
    `uvm_component_utils(i2c_agent)
    i2c_sequencer sqr;
    i2c_driver drv;
    i2c_monitor mon;
    uvm_analysis_port#(i2c_txn) ap;

    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      void'(uvm_config_db#(uvm_active_passive_enum)::get(this,"","is_active",is_active));
      mon=i2c_monitor::type_id::create("mon",this);
      if(is_active==UVM_ACTIVE) begin
        sqr=i2c_sequencer::type_id::create("sqr",this);
        drv=i2c_driver::type_id::create("drv",this);
      end
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      ap=mon.ap;
      if(is_active==UVM_ACTIVE)
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass:i2c_agent

  class i2c_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(i2c_scoreboard)
    uvm_analysis_imp#(i2c_txn,i2c_scoreboard) imp;

    bit [7:0]last_write;
    bit have_write;
    int unsigned pass_cnt,fail_cnt,skip_cnt;

    function new(string name,uvm_component parent);
      super.new(name,parent);
      imp=new("imp",this);
    endfunction

    function void write(i2c_txn tr);
      if(tr.rw==1'b0) begin
        last_write=tr.data;
        have_write=1'b1;
        `uvm_info("SCOREBOARD",$sformatf("WRITE STORED=%0h",last_write),UVM_LOW)
      end
      else begin
        if(!have_write) begin
          skip_cnt++;
          `uvm_info("SCOREBOARD","SKIP - no prior write",UVM_LOW)
        end
        else if(last_write==tr.read_data) begin
          pass_cnt++;
          `uvm_info("SCOREBOARD",$sformatf("PASS EXP=%0h ACT=%0h",last_write,tr.read_data),UVM_LOW)
        end
        else begin
          fail_cnt++;
          `uvm_error("SCOREBOARD",$sformatf("FAIL EXP=%0h ACT=%0h",last_write,tr.read_data))
        end
      end
    endfunction

    function void report_phase(uvm_phase phase);
      `uvm_info("SCOREBOARD",$sformatf("PASS=%0d FAIL=%0d SKIP=%0d",pass_cnt,fail_cnt,skip_cnt),UVM_NONE)
    endfunction
  endclass:i2c_scoreboard

  class i2c_cov_subscriber extends uvm_subscriber#(i2c_txn);
    `uvm_component_utils(i2c_cov_subscriber)
    i2c_txn tr;

    covergroup cg;
      option.per_instance=1;
      ADDR:coverpoint tr.addr{ bins VALID={7'b0101010}; }
      RW:coverpoint tr.rw{ bins WRITE={0}; bins READ={1}; }
      DATA:coverpoint tr.data{
        bins ZERO={8'h00};
        bins FF={8'hFF};
        bins A5={8'h55};
        bins F_A={8'hAA};
        bins LOW={[8'h01:8'h3F]};
        bins MID={[8'h40:8'hAF]};
        bins HIGH={[8'hB0:8'hFE]};
      }
      ADDR_RW:cross ADDR,RW;
    endgroup

    function new(string name,uvm_component parent);
      super.new(name,parent);
      cg=new();
    endfunction

    function void write(i2c_txn t);
      tr=t;
      cg.sample();
      `uvm_info("COVERAGE",$sformatf("CURRENT=%0.2f%%",cg.get_coverage()),UVM_HIGH)
    endfunction

    function void report_phase(uvm_phase phase);
      `uvm_info("COVERAGE",$sformatf("FINAL FUNCTIONAL COVERAGE=%0.2f%%",cg.get_coverage()),UVM_NONE)
    endfunction
  endclass:i2c_cov_subscriber

  class i2c_env extends uvm_env;
    `uvm_component_utils(i2c_env)
    i2c_agent agt;
    i2c_scoreboard scb;
    i2c_cov_subscriber cov;

    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agt=i2c_agent::type_id::create("agt",this);
      scb=i2c_scoreboard::type_id::create("scb",this);
      cov=i2c_cov_subscriber::type_id::create("cov",this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agt.ap.connect(scb.imp);
      agt.ap.connect(cov.analysis_export);
    endfunction
  endclass:i2c_env

  class i2c_base_test extends uvm_test;
    `uvm_component_utils(i2c_base_test)
    i2c_env env;

    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env=i2c_env::type_id::create("env",this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      uvm_top.print_topology();
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
      uvm_top.set_timeout(300us,0);
    endfunction
  endclass:i2c_base_test

  class i2c_random_test extends i2c_base_test;
    `uvm_component_utils(i2c_random_test)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
      i2c_write_read_seq seq;
      phase.raise_objection(this);
      seq=i2c_write_read_seq::type_id::create("seq");
      seq.reps=34;
      seq.start(env.agt.sqr);
      #120000;
      phase.drop_objection(this);
    endtask
  endclass:i2c_random_test

  class i2c_corner_test extends i2c_base_test;
    `uvm_component_utils(i2c_corner_test)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
      i2c_corner_seq seq;
      phase.raise_objection(this);
      seq=i2c_corner_seq::type_id::create("seq");
      seq.start(env.agt.sqr);
      #20000;
      phase.drop_objection(this);
    endtask
  endclass:i2c_corner_test

  class i2c_full_test extends i2c_base_test;
    `uvm_component_utils(i2c_full_test)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
      i2c_write_read_seq wr_seq;
      i2c_corner_seq cn_seq;
      phase.raise_objection(this);
      wr_seq=i2c_write_read_seq::type_id::create("wr_seq");
      wr_seq.reps=30;
      wr_seq.start(env.agt.sqr);
      cn_seq=i2c_corner_seq::type_id::create("cn_seq");
      cn_seq.start(env.agt.sqr);
      #20000;
      phase.drop_objection(this);
    endtask
  endclass:i2c_full_test
endpackage:i2c_pkg
