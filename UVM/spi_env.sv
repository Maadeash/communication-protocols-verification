// ============================================================================
// spi_env.sv
// Top-level verification environment: agent + scoreboard + coverage.
// The driver's completed-transaction stream fans out to both the
// scoreboard (checking) and the coverage collector (sampling) — replacing
// the original's `drv2scb.put(tr)` + direct `cov.sample(tr)` call inside
// the driver. The monitor's stream feeds the scoreboard's mon_export only,
// matching the original's mon2scb wiring.
// ============================================================================

class spi_env extends uvm_env;
  `uvm_component_utils(spi_env)

  spi_agent      agent;
  spi_scoreboard scb;
  spi_coverage   cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = spi_agent::type_id::create("agent", this);
    scb   = spi_scoreboard::type_id::create("scb", this);
    cov   = spi_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.drv_ap.connect(scb.drv_export);
    agent.drv_ap.connect(cov.analysis_export);
    agent.mon_ap.connect(scb.mon_export);
  endfunction
endclass
