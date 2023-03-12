module mux4x1(
  input wire ser_data,start_bit,stop_bit,par_bit,
  input wire [1:0] mux_sel,
  output reg tx_out
  );
  
assign start_bit = 1'b0;
assign stop_bit = 1'b1;


always@(*)begin
  case(mux_sel)
    2'b00: tx_out = start_bit;
    2'b01: tx_out = stop_bit;
    2'b10: tx_out = ser_data; 
    2'b11: tx_out = par_bit;
 endcase
 end
 endmodule
    