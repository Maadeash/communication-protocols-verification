// ============================================================================
// spi_pkg.sv
// UVM VIP package for the SPI master/slave DUT. Include order follows class
// dependency: item -> sequences -> sequencer -> driver/monitor -> agent ->
// coverage/scoreboard -> env -> tests.
//
// No `timescale directive here on purpose: VCS's default (Verilog-2001)
// ITSFM check requires ALL modules/packages in a compilation to either have
// a `timescale or none — mixing is an error. Since the RTL files
// (spi_rtl.sv) and spi_if.sv/spi_assertions.sv have no `timescale, this
// package must not have one either. Timing is instead pinned uniformly for
// the whole compilation via `-timescale=1ns/1ps` on the vcs command line
// (see Makefile / README). This also covers the `#100;` pacing delays in
// spi_sequences.sv, which had the same exposure. The test/sequence timeout
// code additionally avoids raw `#<int>` delays via clock-edge waits (see
// spi_test.sv), so it does not depend on this either way.
// ============================================================================

package spi_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "spi_seq_item.sv"
  `include "spi_sequences.sv"
  `include "spi_sequencer.sv"
  `include "spi_driver.sv"
  `include "spi_monitor.sv"
  `include "spi_agent.sv"
  `include "spi_coverage.sv"
  `include "spi_scoreboard.sv"
  `include "spi_env.sv"
  `include "spi_test.sv"

endpackage
