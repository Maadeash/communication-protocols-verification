module uart_tx #(parameter dbit=8,sb_tck=16)(
  input clk,rst,
  input [7:0]din,
  input tx_start,s_tck,
  output reg tx_done_tck,
  output tx
);
  localparam idle=2'd0,start=2'd1,data=2'd2,stop=2'd3;
  
  reg [1:0]state,next_state;
  reg [3:0]s,s_next;
  reg [2:0]n,n_next;
  reg [7:0]b,b_next;
  reg tx_reg,tx_next;
  
  always @(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          state<=idle;
          s<=0;
          n<=0;
          b<=0;
          tx_reg<=1'b1;
        end
      else
        begin
          state<=next_state;
          s<=s_next;
          n<=n_next;
          b<=b_next;
          tx_reg<=tx_next;
        end
    end
    
  always @(*)
    begin
      next_state=state;
      s_next=s;
      n_next=n;
      b_next=b;
      tx_next=tx_reg;
      tx_done_tck=1'b0;
      
      case(state)
        idle:
          begin
            tx_next=1'b1;
            if(tx_start)
              begin
                next_state=start;
                s_next=0;
                n_next=0;
                b_next=din;
              end
          end
          
        start:
          begin
            tx_next=1'b0;
            if(s_tck)
              begin
                if(s==4'd15)
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
            tx_next=b[0];
            if(s_tck)
              begin
                if(s==4'd15)
                  begin
                    s_next=0;
                    b_next=b>>1;
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
            tx_next=1'b1;
            if(s_tck)
              begin
                if(s==sb_tck-1)
                  begin
                    s_next=0;
                    next_state=idle;
                    tx_done_tck=1'b1;
                  end
                else
                  s_next=s+1'b1;
              end
          end
      endcase
    end
    
  assign tx=tx_reg;
endmodule
