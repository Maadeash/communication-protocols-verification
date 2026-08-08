module spi_master(
  input clk,
  input rst,
  input start,
  input [7:0]data_in,
  input miso,
  output reg mosi,
  output reg sclk,
  output reg cs,
  output reg [7:0]data_out,
  output reg busy,
  output reg done
);
  localparam IDLE=2'b00,LOAD=2'b01,TRANSFER=2'b10,FINISH=2'b11;
  reg [1:0]state;
  reg [7:0]tx_shift;
  reg [7:0]rx_shift;
  reg [2:0]bit_cnt;
  reg [7:0]clk_div_cnt;
  reg sclk_rise_pulse;
  reg sclk_fall_pulse;

  always@(posedge clk or posedge rst) begin
    if(rst) begin
      clk_div_cnt<=8'd0;
      sclk<=1'b0;
      sclk_rise_pulse<=1'b0;
      sclk_fall_pulse<=1'b0;
    end
    else begin
      sclk_rise_pulse<=1'b0;
      sclk_fall_pulse<=1'b0;
      if(state==TRANSFER) begin
        if(clk_div_cnt==8'd3) begin
          clk_div_cnt<=8'd0;
          if(sclk==1'b0) begin
            sclk<=1'b1;
            sclk_rise_pulse<=1'b1;
          end
          else begin
            sclk<=1'b0;
            sclk_fall_pulse<=1'b1;
          end
        end
        else begin
          clk_div_cnt<=clk_div_cnt+1'b1;
        end
      end
      else begin
        clk_div_cnt<=8'd0;
        sclk<=1'b0;
      end
    end
  end

  always@(posedge clk or posedge rst) begin
    if(rst) begin
      state<=IDLE;
      mosi<=1'b0;
      cs<=1'b1;
      data_out<=8'h00;
      busy<=1'b0;
      done<=1'b0;
      tx_shift<=8'h00;
      rx_shift<=8'h00;
      bit_cnt<=3'd0;
    end
    else begin
      done<=1'b0;
      case(state)
        IDLE: begin
          cs<=1'b1;
          busy<=1'b0;
          mosi<=1'b0;
          if(start)
            state<=LOAD;
        end
        LOAD: begin
          cs<=1'b0;
          busy<=1'b1;
          tx_shift<=data_in;
          rx_shift<=8'h00;
          bit_cnt<=3'd7;
          mosi<=data_in[7];
          state<=TRANSFER;
        end
        TRANSFER: begin
          busy<=1'b1;
          if(sclk_fall_pulse)
            mosi<=tx_shift[bit_cnt];
          if(sclk_rise_pulse) begin
            rx_shift<={rx_shift[6:0],miso};
            if(bit_cnt==3'd0) begin
              data_out<={rx_shift[6:0],miso};
              state<=FINISH;
            end
            else begin
              bit_cnt<=bit_cnt-1'b1;
            end
          end
        end
        FINISH: begin
          cs<=1'b1;
          busy<=1'b0;
          done<=1'b1;
          state<=IDLE;
        end
        default: state<=IDLE;
      endcase
    end
  end
endmodule


