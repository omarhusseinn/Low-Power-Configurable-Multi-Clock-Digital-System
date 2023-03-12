module SYS_CTRL_TOP#(parameter DATA_WIDTH = 8 , parameter REG_ADDR = 4)
(
    input wire clk,rst,
    input wire UART_RX_VALID,REG_READ_VALID,ALU_VALID,
    input wire [DATA_WIDTH-1 : 0] UART_RX_DATA,
    input wire [DATA_WIDTH-1 : 0] REG_READ_DATA,
    input wire [DATA_WIDTH*2-1 : 0] ALU_READ_DATA,
    input wire UART_TX_Busy,
    
    output wire [DATA_WIDTH-1:0] reg_write_data,
    output wire alu_en,reg_write_en,reg_read_en,
    output wire clk_gate_en,clk_div_en,
    output wire [3:0]  alu_fun,
    output wire [REG_ADDR-1:0] reg_addr,
    output wire [DATA_WIDTH-1 : 0] data_out_tx,
    output wire data_valid_tx
);

wire UART_TX_REG_SEND,UART_TX_ALU_SEND; // communicate between tx,rx controllers
wire [DATA_WIDTH*2-1 : 0] alu_data_tx; // communicate between tx,rx controllers
wire [DATA_WIDTH-1 : 0]   reg_data_tx; // communicate between tx,rx controllers    


/*** BLOCK INSTANTIATION ***/
SYS_TX_CTRL SYS_TX_CTRL_T0( 
  .clk(clk),
  .rst(rst),
  .UART_TX_Busy(UART_TX_Busy),
  .UART_TX_REG_SEND(UART_TX_REG_SEND),
  .UART_TX_ALU_SEND(UART_TX_ALU_SEND),
  .alu_data_tx(alu_data_tx),
  .reg_data_tx(reg_data_tx),
  .data_out_tx(data_out_tx),
  .data_valid_tx(data_valid_tx)
);

SYS_RX_CTRL SYS_RX_CTRL_T1(
    .clk(clk),
    .rst(rst),
    .UART_RX_VALID(UART_RX_VALID),
    .REG_READ_VALID(REG_READ_VALID),
    .ALU_VALID(ALU_VALID),
    .UART_RX_DATA(UART_RX_DATA),
    .REG_READ_DATA(REG_READ_DATA),
    .ALU_READ_DATA(ALU_READ_DATA),
    .reg_write_data(reg_write_data),
    .alu_en(alu_en),
    .reg_write_en(reg_write_en),
    .reg_read_en(reg_read_en),
    .clk_gate_en(clk_gate_en),
    .clk_div_en(clk_div_en),
    .alu_fun(alu_fun),
    .reg_addr(reg_addr),
    .UART_TX_REG_SEND(UART_TX_REG_SEND),
    .UART_TX_ALU_SEND(UART_TX_ALU_SEND),
    .alu_data_tx(alu_data_tx),
    .reg_data_tx(reg_data_tx)  
);    
endmodule