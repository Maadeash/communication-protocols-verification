`timescale 1ns/1ps
interface i2c_if(input logic clk);
  logic rst;
  logic [7:0] w_data;
  logic [6:0] addr;
  logic rw;
  logic enable;
  logic [7:0] dout;
  wire sda;
  wire scl;

  clocking drv_cb @(posedge clk);
    output w_data;
    output addr;
    output rw;
    output enable;
    input dout;
  endclocking

  clocking mon_cb @(posedge clk);
    input w_data;
    input addr;
    input rw;
    input enable;
    input dout;
    input sda;
    input scl;
  endclocking

  modport DRV(clocking drv_cb,input clk,input rst);
  modport MON(clocking mon_cb,input clk,input rst);
endinterface

class i2c_transaction;
  rand bit [6:0] addr;
  rand bit rw;
  rand bit [7:0] data;
  bit [7:0] read_data;
  constraint addr_c {addr==7'b0101010;}
  function void display(string tag);
    $display("[%s] ADDR=%0h RW=%0b DATA=%0h READ=%0h",
              tag,addr,rw,data,read_data);
  endfunction
endclass

class i2c_generator;
  mailbox #(i2c_transaction) gen2drv;
  function new(mailbox #(i2c_transaction) gen2drv);
    this.gen2drv=gen2drv;
  endfunction

  task run();
    i2c_transaction tr;
    repeat(5) begin
      tr=new();
      assert(tr.randomize() with {rw==0;});
      tr.display("GEN_WRITE");
      gen2drv.put(tr);
      #100;
      tr=new();
      assert(tr.randomize() with {rw==1;});
      tr.display("GEN_READ");
      gen2drv.put(tr);
      #100;
    end
  endtask
endclass

class i2c_coverage;
  i2c_transaction tr;
  covergroup i2c_cg;
    ADDR: coverpoint tr.addr {bins VALID={7'b0101010};}
    RW: coverpoint tr.rw {bins WRITE={0}; bins READ={1};}
    DATA: coverpoint tr.data {
      bins LOW={[8'h00:8'h3F]};
      bins MID={[8'h40:8'hAF]};
      bins HIGH={[8'hB0:8'hFF]};
    }
    ADDR_RW: cross ADDR,RW;
  endgroup

  function new();
    i2c_cg=new();
  endfunction

  task sample(i2c_transaction t);
    tr=t;
    i2c_cg.sample();
    $display("[COVERAGE] CURRENT=%0.2f%%",
              i2c_cg.get_inst_coverage());
  endtask

  function real get_cov();
    return i2c_cg.get_inst_coverage();
  endfunction
endclass

typedef class i2c_coverage;

class i2c_driver;
  virtual i2c_if.DRV vif;
  mailbox #(i2c_transaction) gen2drv;
  mailbox #(i2c_transaction) drv2scb;
  i2c_coverage cov;
  function new(
    virtual i2c_if.DRV vif,
    mailbox #(i2c_transaction) gen2drv,
    mailbox #(i2c_transaction) drv2scb,
    i2c_coverage cov
  );
    this.vif=vif;
    this.gen2drv=gen2drv;
    this.drv2scb=drv2scb;
    this.cov=cov;
  endfunction

  task drive(i2c_transaction tr);
    vif.drv_cb.addr<=tr.addr;
    vif.drv_cb.rw<=tr.rw;
    vif.drv_cb.w_data<=tr.data;
    vif.drv_cb.enable<=1'b1;
    repeat(5) @(posedge vif.clk);
    vif.drv_cb.enable<=1'b0;
    repeat(150) @(posedge vif.clk);
  endtask

  task run();
    i2c_transaction tr;
    forever begin
      gen2drv.get(tr);
      drive(tr);
      cov.sample(tr);
      if(tr.rw==1'b1) begin
        tr.read_data=vif.drv_cb.dout;
        $display("[DRIVER] READ CAPTURED dout=%0h",tr.read_data);
      end
      drv2scb.put(tr);
      $display("[DRIVER] ADDR=%0h RW=%0b DATA=%0h read_data=%0h",
                tr.addr,tr.rw,tr.data,tr.read_data);
    end
  endtask
endclass

class i2c_monitor;
  virtual i2c_if.MON vif;
  mailbox #(i2c_transaction) mon2scb;
  function new(
    virtual i2c_if.MON vif,
    mailbox #(i2c_transaction) mon2scb
  );
    this.vif=vif;
    this.mon2scb=mon2scb;
  endfunction

  task run();
    i2c_transaction tr;
    forever begin
      @(posedge vif.clk);
      if(vif.mon_cb.enable) begin
        tr=new();
        tr.addr=vif.mon_cb.addr;
        tr.rw=vif.mon_cb.rw;
        tr.data=vif.mon_cb.w_data;
        @(negedge vif.mon_cb.enable);
        repeat(150) @(posedge vif.clk);
        if(tr.rw==1'b1)
          tr.read_data=vif.mon_cb.dout;
        else
          tr.read_data=8'h00;
        mon2scb.put(tr);
        $display("[MONITOR] ADDR=%0h RW=%0b DATA=%0h READ=%0h",
                  tr.addr,tr.rw,tr.data,tr.read_data);
      end
    end
  endtask
endclass

class i2c_scoreboard;
  mailbox #(i2c_transaction) drv2scb;
  mailbox #(i2c_transaction) mon2scb;
  function new(
    mailbox #(i2c_transaction) drv2scb,
    mailbox #(i2c_transaction) mon2scb
  );
    this.drv2scb=drv2scb;
    this.mon2scb=mon2scb;
  endfunction

  task run();
    i2c_transaction dtr,mtr;
    bit [7:0] last_write;
    bit have_write=0;
    fork
      forever begin
        mon2scb.get(mtr);
      end

      forever begin
        drv2scb.get(dtr);
        if(dtr.rw==1'b0) begin
          last_write=dtr.data;
          have_write=1;
          $display("[SCOREBOARD] WRITE STORED=%0h",last_write);
        end
        else begin
          if(!have_write)
            $display("[SCOREBOARD] SKIP — no prior write");
          else if(last_write==dtr.read_data)
            $display("[SCOREBOARD] PASS EXP=%0h ACT=%0h",
                      last_write,dtr.read_data);
          else
            $display("[SCOREBOARD] FAIL EXP=%0h ACT=%0h",
                      last_write,dtr.read_data);
        end
      end
    join
  endtask
endclass

module i2c_assertions(i2c_if vif);
  property p_enable_reset;
    @(posedge vif.clk)
    vif.rst |-> (vif.enable==0);
  endproperty

  assert property(p_enable_reset)
    else $error("ENABLE ACTIVE DURING RESET");

  property p_start_condition;
    @(negedge vif.sda)
    vif.scl==1;
  endproperty

  assert property(p_start_condition)
    else $error("START CONDITION FAILED");
endmodule

module tb_i2c_vip;
  logic clk;
  always #10 clk=~clk;
  i2c_if vif(clk);

  master dut1(
    .clk(clk),
    .rst(vif.rst),
    .w_data(vif.w_data),
    .addr(vif.addr),
    .rw(vif.rw),
    .enable(vif.enable),
    .dout(vif.dout),
    .i2c_sda(vif.sda),
    .i2c_scl(vif.scl)
  );

  slave dut2(
    .sda(vif.sda),
    .scl(vif.scl)
  );

  i2c_assertions a1(vif);

  mailbox #(i2c_transaction) gen2drv,drv2scb,mon2scb;

  i2c_generator gen;
  i2c_driver drv;
  i2c_monitor mon;
  i2c_scoreboard scb;
  i2c_coverage cov;

  initial begin
    clk=0;
    gen2drv=new();
    drv2scb=new();
    mon2scb=new();
    cov=new();
    gen=new(gen2drv);
    drv=new(vif,gen2drv,drv2scb,cov);
    mon=new(vif,mon2scb);
    scb=new(drv2scb,mon2scb);

    vif.rst=1;
    vif.enable=0;
    vif.addr=0;
    vif.rw=0;
    vif.w_data=0;

    repeat(20) @(posedge clk);
    vif.rst=0;

    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_none

    #500_000;
    $display("========================================");
    $display("[TB] FINAL FUNCTIONAL COVERAGE = %0.2f%%",cov.get_cov());
    $display("========================================");
    $display("[TB] Simulation complete");
    $display("ADDR  = %0.2f%%",cov.i2c_cg.ADDR.get_coverage());
    $display("RW    = %0.2f%%",cov.i2c_cg.RW.get_coverage());
    $display("DATA  = %0.2f%%",cov.i2c_cg.DATA.get_coverage());
    $display("CROSS = %0.2f%%",cov.i2c_cg.ADDR_RW.get_coverage());
    $finish;
  end
endmodule
