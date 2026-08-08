module spi_slave(
  input clk,
  input rst,
  input sclk,
  input mosi,
  input cs,
  input [7:0]data_in,
  input data_ready,
  output reg miso,
  output reg [7:0]data_out,
  output reg data_valid
);
  localparam IDLE=2'b00,TRANSFER=2'b01,COMPLETE=2'b10;
  reg [1:0]state;
  reg [7:0]tx_shift;
  reg [7:0]rx_shift;
  reg [2:0]bit_cnt;
  reg prev_sclk;
  reg prev_cs;
  wire sclk_posedge=(prev_sclk==1'b0)&&(sclk==1'b1);
  wire sclk_negedge=(prev_sclk==1'b1)&&(sclk==1'b0);
  wire cs_falling=(prev_cs==1'b1)&&(cs==1'b0);
  wire cs_rising=(prev_cs==1'b0)&&(cs==1'b1);

  always@(posedge clk or posedge rst) begin
    if(rst) begin
      state<=IDLE;
      prev_sclk<=1'b0;
      prev_cs<=1'b1;
      tx_shift<=8'h00;
      rx_shift<=8'h00;
      bit_cnt<=3'd7;
      miso<=1'b0;
      data_out<=8'h00;
      data_valid<=1'b0;
    end
    else begin
      prev_sclk<=sclk;
      prev_cs<=cs;
      data_valid<=1'b0;
      case(state)
        IDLE: begin
          bit_cnt<=3'd7;
          if(cs_falling) begin
            rx_shift<=8'h00;
            if(data_ready) begin
              tx_shift<={data_in[6:0],1'b0};
              miso<=data_in[7];
            end
            else begin
              tx_shift<=8'h00;
              miso<=1'b0;
            end
            state<=TRANSFER;
          end
        end
        TRANSFER: begin
          if(cs==1'b1) begin
            state<=COMPLETE;
          end
          else begin
            if(sclk_posedge) begin
              rx_shift<={rx_shift[6:0],mosi};
              if(bit_cnt==3'd0) begin
                data_out<={rx_shift[6:0],mosi};
                data_valid<=1'b1;
                state<=COMPLETE;
              end
              else begin
                bit_cnt<=bit_cnt-1'b1;
              end
            end
            if(sclk_negedge) begin
              miso<=tx_shift[7];
              tx_shift<={tx_shift[6:0],1'b0};
            end
          end
        end
        COMPLETE: begin
          if(cs_rising)
            state<=IDLE;
        end
        default: state<=IDLE;
      endcase
    end
  end
endmodule