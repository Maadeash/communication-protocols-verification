module top #(parameter dbit=8,sb_tck=16,n=10,m=5,fifo_addbit=2)(
  input clk,rst,
  input [7:0]w_data,
  input rd,wr,rx,
  output tx,tx_full,rx_empty,
  output [7:0]r_data
);
  wire max_tck,tx_empty,rx_full;
  wire tx_done_tck,rx_done_tck;
  wire [7:0]tx_fifo_out,rx_data_out;
  wire [n-1:0]q;
  
  baudgen #(.n(n),.m(m)) bg(.clk(clk),.rst(rst),.q(q),.max_tck(max_tck));
  
  fifo #(.d(dbit),.w(fifo_addbit)) f_tx(.clk(clk),.rst(rst),.w_data(w_data),.wr(wr),.rd(tx_done_tck),.full(tx_full),.empty(tx_empty),.r_data(tx_fifo_out));
  
  uart_tx #(.dbit(dbit),.sb_tck(sb_tck)) utx(.clk(clk),.rst(rst),.din(tx_fifo_out),.tx_start(~tx_empty),.s_tck(max_tck),.tx_done_tck(tx_done_tck),.tx(tx));
  
  uart_rx #(.dbit(dbit),.sb_tck(sb_tck)) urx(.clk(clk),.rst(rst),.rx(rx),.s_tck(max_tck),.rx_done_tck(rx_done_tck),.dout(rx_data_out));
  
  fifo #(.d(dbit),.w(fifo_addbit)) f_rx(.clk(clk),.rst(rst),.w_data(rx_data_out),.wr(rx_done_tck),.rd(rd),.full(rx_full),.empty(rx_empty),.r_data(r_data));
endmodule
