class uart_env extends uvm_env;
  `uvm_component_utils(uart_env)
  uart_agent agent;
  uart_scoreboard scb;
  uart_coverage cov;

  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent=uart_agent::type_id::create("agent",this);
    scb=uart_scoreboard::type_id::create("scb",this);
    cov=uart_coverage::type_id::create("cov",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.drv_ap.connect(scb.drv_export);
    agent.mon_ap.connect(scb.mon_export);
    scb.cov=cov;
  endfunction
endclass
