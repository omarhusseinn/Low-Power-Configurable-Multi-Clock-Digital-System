module SYS_RX_CTRL #(parameter DATA_WIDTH = 8 , parameter REG_ADDR = 4)
  (
    input wire clk,rst,
    input wire UART_RX_VALID,REG_READ_VALID,ALU_VALID,
    input wire [DATA_WIDTH-1 : 0] UART_RX_DATA,
    input wire [DATA_WIDTH-1 : 0] REG_READ_DATA,
    input wire [DATA_WIDTH*2-1 : 0] ALU_READ_DATA,
    
    output reg [DATA_WIDTH-1:0] reg_write_data,
    output reg alu_en,reg_write_en,reg_read_en,
    output reg clk_gate_en,clk_div_en,
    output reg [3:0]  alu_fun,
    output reg [REG_ADDR-1:0] reg_addr,
    
    output reg UART_TX_REG_SEND,UART_TX_ALU_SEND, // communicate between tx,rx controllers
    output reg [DATA_WIDTH*2-1 : 0] alu_data_tx, // communicate between tx,rx controllers
    output reg [DATA_WIDTH-1 : 0]   reg_data_tx // communicate between tx,rx controllers
    );
    
/*** COMMANDS ***/
localparam [7:0] REG_WRITE_CMD = 8'hAA,
                 REG_READ_CMD = 8'hBB,
                 ALU_OP_CMD = 8'hCC,
                 ALU_NO_OP_CMD = 8'hDD;

/*** STATES ***/
localparam [3:0] IDLE_S = 'd0,
                 REG_WR_ADDR_S = 'd1,
                 REG_WR_DATA_S = 'd2,
                 REG_RD_ADDR_S = 'd3,
                 REG_WAIT_S = 'd4,
                 ALU_OP_A_S = 'd5,
                 ALU_OP_B_S = 'd6,
                 ALU_FUN_S = 'd7,
                 ALU_WAIT_S = 'd8;
                 
/*** current,next state ***/
reg [3:0] cs,ns;

/**** STORING IN REGISTERS *****/
reg [DATA_WIDTH-1:0] REG_ADDR_STORE;
reg REG_ADDR_STORE_EN,REG_DATA_STORE_EN,ALU_DATA_STORE_EN;

/***** STORING REGISTER FILE ADDRESS ******/
always @(posedge clk or negedge rst)begin
  if(!rst)
    REG_ADDR_STORE <= 'd0;
  else if(REG_ADDR_STORE_EN)
     REG_ADDR_STORE <= UART_RX_DATA; 
end

/****** STORING REGISTER FILE DATA *******/
always @(posedge clk or negedge rst)begin
  if(!rst)
     reg_data_tx <= 'd0;
  else if(REG_DATA_STORE_EN)
     reg_data_tx <= REG_READ_DATA; 
end

/****** STORING ALU DATA ******/
always @(posedge clk or negedge rst)begin
  if(!rst)
    alu_data_tx <= 'd0;
  else if(ALU_DATA_STORE_EN)
   alu_data_tx <= ALU_READ_DATA; 
end




                 
/*** current state logic ***/
always@(posedge clk or negedge rst)begin
  if(!rst)
    cs <= IDLE_S;
  else
    cs <= ns;
end    

                 
/*** next state logic ***/
always @(*)begin
  case(cs)
  
    IDLE_S:begin
      if(UART_RX_VALID)begin
        if(UART_RX_DATA == REG_WRITE_CMD)
          ns = REG_WR_ADDR_S;
        else if(UART_RX_DATA == REG_READ_CMD)
          ns = REG_RD_ADDR_S ;
        else if(UART_RX_DATA == ALU_OP_CMD)
          ns = ALU_OP_A_S ;
        else if(UART_RX_DATA == ALU_NO_OP_CMD)
          ns = ALU_FUN_S ;
        else
          ns = IDLE_S;
      end    
         end
         
    REG_WR_ADDR_S:begin
        if(UART_RX_VALID)
          ns = REG_WR_DATA_S;
        else
          ns = REG_WR_ADDR_S;
         end
         
    REG_RD_ADDR_S:begin
         if(UART_RX_VALID)
          ns = REG_WAIT_S;
         else
          ns = REG_RD_ADDR_S;
         end
         
    REG_WR_DATA_S:begin
        if(UART_RX_VALID)
          ns = IDLE_S;
        else
          ns = REG_WR_DATA_S;
         end
        
    REG_WAIT_S:begin  // WAIT READING DATA FROM REG FILE
         if(REG_READ_VALID)
          ns = IDLE_S;
         else
          ns = REG_WAIT_S;
         end
         
    ALU_OP_A_S:begin
         if(UART_RX_VALID)
          ns = ALU_OP_B_S;
         else
          ns = ALU_OP_A_S;
         end 
         
    ALU_OP_B_S:begin
         if(UART_RX_VALID)
          ns = ALU_FUN_S;
         else
          ns = ALU_OP_B_S;
         end 
        
    ALU_FUN_S:begin
         if(UART_RX_VALID)
          ns = ALU_WAIT_S;
         else
          ns = ALU_FUN_S;
         end 
         
    ALU_WAIT_S:begin  // WAIT FOR CALCULATION 
         if(ALU_VALID)
          ns = IDLE_S;
         else
          ns = ALU_WAIT_S;
         end
         
     default : ns = IDLE_S;
  endcase     
end
          
                  
/*** output logic ***/
always @(*)begin
reg_write_en = 'd0;
reg_addr = 'd0;
reg_write_data = 'd0;
reg_read_en = 'd0;
clk_gate_en = 'd0;
clk_div_en = 'd1;
alu_en = 'd0;
alu_fun = 'd0;

UART_TX_REG_SEND = 'd0;
UART_TX_ALU_SEND = 'd0;

REG_DATA_STORE_EN = 'd0;
REG_ADDR_STORE_EN = 'd0;
ALU_DATA_STORE_EN = 'd0;

  case(cs)
  
    IDLE_S:begin
         end
         
    REG_WR_ADDR_S:begin
         if(UART_RX_VALID)
           REG_ADDR_STORE_EN = 'd1;
         else
           REG_ADDR_STORE_EN = 'd0;
         end
         
    REG_RD_ADDR_S:begin
         if(UART_RX_VALID)
           REG_ADDR_STORE_EN = 'd1;
         else
           REG_ADDR_STORE_EN = 'd0;
         end
         
         
    REG_WR_DATA_S:begin
          if(UART_RX_VALID)begin
            reg_write_en = 'd1;
            reg_addr = REG_ADDR_STORE;
            reg_write_data = UART_RX_DATA;
            end
          else begin
            reg_write_en = 'd0;
            reg_addr = REG_ADDR_STORE;
            reg_write_data = UART_RX_DATA;
         end
         end
         
    REG_WAIT_S:begin
            reg_read_en = 'd1;
            reg_addr = REG_ADDR_STORE;
            if(REG_READ_VALID)begin
              UART_TX_REG_SEND = 'd1;
              REG_DATA_STORE_EN ='d1;
              end
            else begin
              UART_TX_REG_SEND = 'd0;
              REG_DATA_STORE_EN ='d0;              
            end  
         end
    ALU_OP_A_S:begin
            if(UART_RX_VALID)begin
              reg_write_en = 'd1;
              reg_addr = 'd0;
              reg_write_data = UART_RX_DATA;
            end
            else begin
              reg_write_en = 'd0;
              reg_addr = 'd0;
              reg_write_data = UART_RX_DATA;
         end       
         end
         
    ALU_OP_B_S:begin
            if(UART_RX_VALID)begin
              reg_write_en = 'd1;
              reg_addr = 'd1;
              reg_write_data = UART_RX_DATA;
            end
            else begin
              reg_write_en = 'd0;
              reg_addr = 'd1;
              reg_write_data = UART_RX_DATA;
         end       
         end
         
    ALU_FUN_S:begin
            clk_gate_en = 'd1;
            if(UART_RX_VALID)begin
              alu_en = 'd1;
              alu_fun = UART_RX_DATA;
            end
            else begin
              alu_en = 'd0;
              alu_fun = UART_RX_DATA;
            end  
         end
         
    ALU_WAIT_S:begin
            clk_gate_en = 'd1;
            if(ALU_VALID)begin
              ALU_DATA_STORE_EN = 'd1;
              UART_TX_ALU_SEND = 'd1;
            end
            else begin
              ALU_DATA_STORE_EN = 'd0;
              UART_TX_ALU_SEND = 'd0;
            end  
         end    

     default : begin
reg_write_en = 'd0;
reg_addr = 'd0;
reg_write_data = 'd0;
reg_read_en = 'd0;
clk_gate_en = 'd0;
clk_div_en = 'd1;
alu_en = 'd0;
alu_fun = 'd0;

UART_TX_REG_SEND = 'd0;
UART_TX_ALU_SEND = 'd0;

REG_DATA_STORE_EN = 'd0;
REG_ADDR_STORE_EN = 'd0;
ALU_DATA_STORE_EN = 'd0;     
      end
     
  endcase     
end
endmodule            
    