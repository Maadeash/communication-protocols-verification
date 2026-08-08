// ============================================================================
// spi_assertions.sv
// SVA checker bound against spi_if. Logic identical to the original module.
// ============================================================================

module spi_assertions(spi_if vif);

  property p_cs_reset;
    @(posedge vif.clk)
    vif.rst |-> (vif.cs==1'b1);
  endproperty

  assert property(p_cs_reset)
    else $error("[ASSERT] CS NOT HIGH DURING RESET");

  property p_done_reset;
    @(posedge vif.clk)
    vif.rst |-> (vif.done==1'b0);
  endproperty

  assert property(p_done_reset)
    else $error("[ASSERT] DONE ACTIVE DURING RESET");

  property p_sclk_when_cs_low;
    @(posedge vif.clk)
    (vif.cs==1'b1) |-> (vif.sclk==1'b0);
  endproperty

  assert property(p_sclk_when_cs_low)
    else $error("[ASSERT] SCLK TOGGLED WHILE CS HIGH");

  property p_done_cs_high;
    @(posedge vif.clk)
    vif.done |-> (vif.cs==1'b1);
  endproperty

  assert property(p_done_cs_high)
    else $error("[ASSERT] CS NOT HIGH WHEN DONE");

endmodule
