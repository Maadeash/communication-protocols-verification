// ============================================================================
// spi_coverage.sv
// Replaces the original `spi_coverage` class. Identical covergroup: same
// MASTER_TX/SLAVE_TX bins (LOW/MID/HIGH), CORNERS bins
// (ZERO/ALL_ONE/ALT_AA/ALT_55), and TX_CROSS cross. Implemented as a
// uvm_subscriber connected to the driver's analysis port, so sample() fires
// on every completed transaction exactly as the original driver's
// `cov.sample(tr)` call did (same point in time: after rx capture).
// ============================================================================

class spi_coverage extends uvm_subscriber #(spi_seq_item);
  `uvm_component_utils(spi_coverage)

  spi_seq_item tr;

  covergroup spi_cg;

    MASTER_TX: coverpoint tr.master_tx {
      bins LOW={[8'h00:8'h3F]};
      bins MID={[8'h40:8'hAF]};
      bins HIGH={[8'hB0:8'hFF]};
    }

    SLAVE_TX: coverpoint tr.slave_tx {
      bins LOW={[8'h00:8'h3F]};
      bins MID={[8'h40:8'hAF]};
      bins HIGH={[8'hB0:8'hFF]};
    }

    CORNERS: coverpoint tr.master_tx {
      bins ZERO={8'h00};
      bins ALL_ONE={8'hFF};
      bins ALT_AA={8'hAA};
      bins ALT_55={8'h55};
    }

    TX_CROSS: cross MASTER_TX,SLAVE_TX;

  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    spi_cg = new();
  endfunction

  virtual function void write(spi_seq_item t);
    tr = t;
    spi_cg.sample();

    `uvm_info("COVERAGE", $sformatf("CURRENT=%0.2f%%", spi_cg.get_inst_coverage()), UVM_LOW)
  endfunction

  function real get_cov();
    return spi_cg.get_coverage();
  endfunction
endclass
