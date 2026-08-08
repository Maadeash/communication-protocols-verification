// ============================================================================
// i2c_assertions.sv
// Protocol sanity checks, kept as plain SVA outside the UVM class hierarchy
// so they run continuously against the bus regardless of which sequence is
// active. Instantiated directly in tb_top.sv against the same vif.
// ============================================================================
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
