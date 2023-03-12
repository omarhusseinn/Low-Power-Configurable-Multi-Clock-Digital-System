module parity_check_tx#(parameter data_size = 4'd8 , parameter EVEN = 1'b0 , parameter ODD = 1'b1)
  (
    input clk,rstn,
    input par_type,data_valid,
    input [data_size-1:0] p_data,
    output reg par_bit
   );
   
reg parity,xor1_out,xor2_out,xor3_out,xor4_out,xor5_out,xor6_out;
reg [7:0] data_input; 
 
 
 /*** load data input in the register data_input ***/
 always@(posedge clk)begin
  if(!rstn)
    data_input = 8'd0;
  else if(data_valid)
    data_input = p_data;
 end
 
 
 
 /* parity calculation */
 always@(*)begin
      xor1_out = p_data[0] ^ p_data[1]; 
      xor2_out = p_data[2] ^ xor1_out ; 
      xor3_out = p_data[3] ^ xor2_out ;
      xor4_out = p_data[4] ^ xor3_out ; 
      xor5_out = p_data[5] ^ xor4_out ;
      xor6_out = p_data[6] ^ xor5_out ; 
      parity   = p_data[7] ^ xor6_out ;
end


/* check whether parity type is even or odd */
always@(*)begin
  if(par_type == EVEN)
    par_bit <= parity;
  else
    par_bit <= ~parity;
end
endmodule