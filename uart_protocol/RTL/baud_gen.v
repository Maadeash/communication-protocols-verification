module baudgen #(parameter n=1,m=1)(
  input clk,rst,
  output [n-1:0]q,
  output max_tck
);
  reg [n-1:0]r_reg;
  
  assign q=r_reg;
  assign max_tck=(r_reg==(m-1))?1'b1:1'b0;
  
  always @(posedge clk or posedge rst)
    begin
      if(rst)
        r_reg<=0;
      else if(r_reg==(m-1))
        r_reg<=0;
      else
        r_reg<=r_reg+1'b1;
    end
endmodule
