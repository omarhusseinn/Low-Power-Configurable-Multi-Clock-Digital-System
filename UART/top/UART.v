
module UART # ( parameter DATA_WIDTH = 8 , PRESCALE_WIDTH = 5 )

(
 input   wire                          RST,
 input   wire                          TX_CLK,
 input   wire                          RX_CLK,
 input   wire                          RX_IN_S,
 output  wire   [DATA_WIDTH-1:0]       RX_OUT_P, 
 output  wire                          RX_OUT_V,
 input   wire   [DATA_WIDTH-1:0]       TX_IN_P, 
 input   wire                          TX_IN_V, 
 output  wire                          TX_OUT_S,
 output  wire                          TX_OUT_V,  
 input   wire   [PRESCALE_WIDTH-1:0]   Prescale,
 input   wire                          parity_enable,
 input   wire                          parity_type
);


top_tx_module  U0_UART_TX (
.clk(TX_CLK),
.rstn(RST),
.p_data(TX_IN_P),
.data_valid(TX_IN_V),
.par_en(parity_enable),
.par_type(parity_type), 
.tx_out(TX_OUT_S),
.busy(TX_OUT_V)
);
 
 
uart_rx U0_UART_RX (
.clk(RX_CLK),
.rst(RST),
.rx_in(RX_IN_S),
.prescale(Prescale),
.par_en(parity_enable),
.par_type(parity_type),
.p_data(RX_OUT_P), 
.data_valid(RX_OUT_V)
);
 
endmodule
 
