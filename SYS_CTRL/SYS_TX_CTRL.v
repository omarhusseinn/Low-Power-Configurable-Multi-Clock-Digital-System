module SYS_TX_CTRL #(parameter DATA_WIDTH = 8)
(
  input wire clk,rst,
  input wire UART_TX_Busy,
  
  input wire UART_TX_REG_SEND,UART_TX_ALU_SEND, // communicate between tx,rx controllers
  input wire [DATA_WIDTH*2-1 : 0] alu_data_tx, // communicate between tx,rx controllers
  input wire [DATA_WIDTH-1 : 0]   reg_data_tx, // communicate between tx,rx controllers
  
  output reg [DATA_WIDTH-1 : 0]   data_out_tx,
  output reg data_valid_tx
);

reg [2:0] cs,ns;
localparam [2:0]  IDLE = 'd0,
                  REG_DATA_SEND ='d1,
                  ALU_DATA_SEND_FIRST = 'd2,
                  TX_BUSY = 'd3,
                  ALU_DATA_SEND_SECOND = 'd4;
              
              
always @ (posedge clk or negedge rst)
 begin
  if(!rst)
    cs <= IDLE ;
  else
    cs <= ns ;
 end 

always @(*)begin

  case(cs)
  
    IDLE : begin
                  if(UART_TX_REG_SEND)
                    ns = REG_DATA_SEND;
                  else if(UART_TX_ALU_SEND)
                     ns = ALU_DATA_SEND_FIRST;
                  else
                     ns = IDLE;
           end
           
    REG_DATA_SEND : begin
                    if(UART_TX_Busy)
                      ns = IDLE;
                    else
                      ns = REG_DATA_SEND;
                    end
                     
   ALU_DATA_SEND_FIRST : begin
                    if(UART_TX_Busy)
                      ns = TX_BUSY;
                    else
                      ns = ALU_DATA_SEND_FIRST;
                    end
   TX_BUSY :  begin
                    if(UART_TX_Busy)
                      ns = TX_BUSY;
                    else
                      ns = ALU_DATA_SEND_SECOND;
                    end
                    
   ALU_DATA_SEND_SECOND : begin
                    if(UART_TX_Busy)
                      ns = IDLE;
                    else
                      ns = ALU_DATA_SEND_SECOND;
                    end
                    
   default : ns = IDLE;
   
  endcase
end
   
                    
                    
always @(*)begin

  case(cs)
  
    IDLE : begin
              data_out_tx = 'd0;
              data_valid_tx = 'd0;
           end
           
    REG_DATA_SEND : begin
              data_out_tx = reg_data_tx;
              data_valid_tx = 'd1;               
                    end
                     
   ALU_DATA_SEND_FIRST : begin
              data_out_tx = alu_data_tx[DATA_WIDTH-1 : 0];
              data_valid_tx = 'd1;
                    end
   TX_BUSY :  begin
              data_out_tx = 'd0;
              data_valid_tx = 'd0;                    
                    end
                    
   ALU_DATA_SEND_SECOND : begin
              data_out_tx = 'd0;
              data_valid_tx = 'd1;
                    end
                    
   default : begin 
              data_out_tx = alu_data_tx[DATA_WIDTH*2-1 : DATA_WIDTH];
              data_valid_tx = 'd0;
             end
  endcase
end                  
endmodule                    