module uart_rx #(parameter dbit=8,sb_tck=16)(
  input clk,rst,
  input rx,s_tck,
  output reg rx_done_tck,
  output [7:0]dout
);
  localparam idle=2'd0,start=2'd1,data=2'd2,stop=2'd3;
  
  reg [1:0]state,next_state;
  reg [3:0]s,s_next;
  reg [2:0]n,n_next;
  reg [7:0]b,b_next;
  
  always @(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          state<=idle;
          s<=0;
          n<=0;
          b<=0;
        end
      else
        begin
          state<=next_state;
          s<=s_next;
          n<=n_next;
          b<=b_next;
        end
    end
    
  always @(*)
    begin
      next_state=state;
      s_next=s;
      n_next=n;
      b_next=b;
      rx_done_tck=1'b0;
      
      case(state)
        idle:
          begin
            if(~rx)
              begin
                next_state=start;
                s_next=0;
              end
          end
          
        start:
          begin
            if(s_tck)
              begin
                if(s==4'd7)
                  begin
                    next_state=data;
                    s_next=0;
                    n_next=0;
                  end
                else
                  s_next=s+1'b1;
              end
          end
          
        data:
          begin
            if(s_tck)
              begin
                if(s==4'd15)
                  begin
                    s_next=0;
                    b_next={rx,b[7:1]};
                    if(n==(dbit-1))
                      next_state=stop;
                    else
                      n_next=n+1'b1;
                  end
                else
                  s_next=s+1'b1;
              end
          end
          
        stop:
          begin
            if(s_tck)
              begin
                if(s==sb_tck-1)
                  begin
                    s_next=0;
                    next_state=idle;
                    rx_done_tck=1'b1;
                  end
                else
                  s_next=s+1'b1;
              end
          end
      endcase
    end
    
  assign dout=b;
endmodule
