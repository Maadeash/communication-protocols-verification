module uart_assertions(uart_if vif);
  property tx_idle_after_reset;
    @(posedge vif.clk) vif.rst|->##1(vif.tx===1'b1);
  endproperty
  assert property(tx_idle_after_reset)
    else $error("[ASSERT] TX not HIGH after reset at %0t",$time);

  property rx_empty_after_reset;
    @(posedge vif.clk) vif.rst|->##1(vif.rx_empty===1'b1);
  endproperty
  assert property(rx_empty_after_reset)
    else $error("[ASSERT] RX FIFO not empty after reset at %0t",$time);

  property tx_not_full_after_reset;
    @(posedge vif.clk) vif.rst|->##1(vif.tx_full===1'b0);
  endproperty
  assert property(tx_not_full_after_reset)
    else $error("[ASSERT] TX FIFO full after reset at %0t",$time);

  property tx_idle_when_no_write;
    @(posedge vif.clk)
    (!vif.wr)|->(vif.tx!==1'bx);
  endproperty
  assert property(tx_idle_when_no_write)
    else $error("[ASSERT] TX UNKNOWN");
endmodule
