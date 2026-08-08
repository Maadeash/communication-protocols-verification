module fifo #(parameter d=8,w=4)(
  input clk,rst,
  input [d-1:0]w_data,
  input wr,rd,
  output full,empty,
  output [d-1:0]r_data
);
  reg [d-1:0]array_mem[0:(2**w)-1];
  reg [w-1:0]wr_ptr,rd_ptr;
  reg [w:0]count;
  
  assign full=(count==(2**w));
  assign empty=(count==0);
  assign r_data=array_mem[rd_ptr];
  
  wire do_wr=wr&~full;
  wire do_rd=rd&~empty;
  
  always @(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          wr_ptr<=0;
          rd_ptr<=0;
          count<=0;
        end
      else
        begin
          if(do_wr)
            begin
              array_mem[wr_ptr]<=w_data;
              wr_ptr<=wr_ptr+1'b1;
            end
            
          if(do_rd)
            rd_ptr<=rd_ptr+1'b1;
            
          case({do_wr,do_rd})
            2'b10:count<=count+1'b1;
            2'b01:count<=count-1'b1;
            default:count<=count;
          endcase
        end
    end
endmodule
