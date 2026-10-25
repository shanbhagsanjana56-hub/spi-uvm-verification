module spi_intf(input wr,clk,rst,ready,op_done,
                input [7:0] addr,din,
                output [7:0] dout,
                output reg cs,mosi,
                input miso,
                output reg done,err
               );
  
  
  reg [16:0] din_reg; //this is 17 bit because spi frame is 17 bit
  //first 8 bit addr, next 8 bit will be data and one bit will be op
  reg [7:0] dout_reg; //data received when read operation is done and it stores the output received from the miso
  
  integer count=0;
  
  typedef enum bit [3:0] {idle = 0, load = 1, check_op = 2, send_data = 3, read_data1 = 4, read_data2 = 5, error = 6, check_ready = 7,send_addr=8,read_data=9} state_type;
state_type state = idle; 
  
  always@(posedge clk)
    
    begin
      
      if(rst)
        begin
          state<=idle;
          count<=0;
          cs<=1'b1;  //to enable a memory we need to make chip select 0, hence we make it 1 here to disable it in this state
          mosi<=1'b0;
          err<=1'b0;
          done<=1'b0;
        end
      else
        begin
          case(state)
            idle:begin
              cs<=1'b1;
              mosi<=1'b0;
              state<=load;
              err<=1'b0;
              done<=1'b0;
            end
            
            load:begin
              din_reg<={din,addr,wr};
              state<=check_op;
            end
            
            check_op:begin
  `ifdef BUG_ADDR
    if(wr==1'b1 && addr<30)
  `else
    if(wr==1'b1 && addr<32)
  `endif
    begin
      cs<=1'b0;
      state<=send_data;
    end
  `ifdef BUG_ADDR
    else if(wr==1'b0 && addr<30)
  `else
    else if(wr==1'b0 && addr<32)
  `endif
    begin
      state<=send_addr;
      cs<=1'b0;
    end
  else
    begin
      state<=error;
      cs<=1'b1;
    end
end
            
            
            send_data: //in this state, i need to send both addr and the data to be sent in that addr
              begin
                if(count<=16)
                  begin
                    count<=count+1;
                    mosi<=din_reg[count];
                    state<=send_data;
                  end
                else
                  begin
                    cs<=1'b1;
                    mosi<=1'b0;
                    if(op_done)
                      begin
                        count<=0;
                        done<=1'b1;
                        state<=idle;
                      end
                    else
                      begin
                        state<=send_data;
                      end
                    
                  end
              end
            
            send_addr:begin
              if(count<=8)  //send lsb 9 bits, so this has adde and the op 
                begin
                  count<=count+1;
                  mosi<=din_reg[count];
                  state<=send_addr;
                end
              else
                begin
                  count<=0;
                  cs=1'b1;
                  state<=check_ready;
                end
            end
            
            check_ready:
              begin
                if(ready) 
                  state<=read_data;
                else
                  state<=check_ready;
              end
            
            read_data:begin
              if(count<=7)
                begin
                  count<=count+1;
                  dout_reg[count]<=miso;
                  state<=read_data;
                end
              else
                begin
                  count<=0;
                  done<=1'b1;
                  state<=idle;
                end
            end
            error:
              begin
                err<=1'b1;
                state<=idle;
                done<=1'b1;
              end
            
            default:begin
              state<=idle;
              count<=0;
            end
          endcase
        end
    end
  
  assign dout=dout_reg;
endmodule
              
            
                  
                    
            
            
              
            
            