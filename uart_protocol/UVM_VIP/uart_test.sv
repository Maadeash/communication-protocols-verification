class uart_base_test extends uvm_test;
  `uvm_component_utils(uart_base_test)
  uart_env env;
  int num_random=6;
  int sim_time_ns=500_000;
  int clk_period_ns=10;
  int min_pass_count=0;
  function new(string name="uart_base_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=uart_env::type_id::create("env",this);
    void'($value$plusargs("UART_NUM_RANDOM=%0d",num_random));
    void'($value$plusargs("UART_SIM_TIME_NS=%0d",sim_time_ns));
    void'($value$plusargs("UART_CLK_PERIOD_NS=%0d",clk_period_ns));
    void'($value$plusargs("UART_MIN_PASS_COUNT=%0d",min_pass_count));
    uvm_top.set_timeout((sim_time_ns+100_000)*1ns,0);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    uart_main_sequence seq;
    int timeout_clks;
    phase.raise_objection(this,"Starting UART test");
    timeout_clks=sim_time_ns/clk_period_ns;
    if(timeout_clks<=0) begin
      `uvm_warning("TEST",$sformatf("sim_time_ns=%0d / clk_period_ns=%0d gave timeout_clks=%0d — clamping to 1",sim_time_ns,clk_period_ns,timeout_clks))
      timeout_clks=1;
    end
    seq=uart_main_sequence::type_id::create("seq");
    seq.num_random=num_random;
    fork
      seq.start(env.agent.sqr);
    join_none
    fork
      begin:coverage_race
        @(env.scb.coverage_done);
        if(min_pass_count>0) begin
          while(env.scb.pass_cnt<min_pass_count)
            @(posedge env.agent.drv.vif.clk);
        end
        repeat(50) @(posedge env.agent.drv.vif.clk);
        `uvm_info("TEST",$sformatf("Coverage complete, pass_cnt=%0d - ending test early",env.scb.pass_cnt),UVM_LOW)
      end
      begin:timeout_race
        repeat(timeout_clks) @(posedge env.agent.drv.vif.clk);
        `uvm_info("TEST",$sformatf("FINAL FUNCTIONAL COVERAGE = %0.2f%%",env.cov.get_coverage()),UVM_LOW)
        `uvm_info("TEST",$sformatf("DATA = %0.2f%%",env.cov.uart_cg.DATA.get_coverage()),UVM_LOW)
        `uvm_info("TEST",$sformatf("CORNERS = %0.2f%%",env.cov.uart_cg.CORNERS.get_coverage()),UVM_LOW)
        `uvm_info("TEST","Timeout reached",UVM_LOW)
      end
    join_any
    disable fork;
    phase.drop_objection(this,"UART test complete");
  endtask
endclass

class uart_random_test extends uart_base_test;
  `uvm_component_utils(uart_random_test)
  function new(string name="uart_random_test",uvm_component parent=null);
    super.new(name,parent);
    num_random=100;
    min_pass_count=35;
  endfunction
endclass
