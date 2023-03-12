module parity_check#(parameter data_size = 4'd8 , parameter EVEN = 1'b0 , parameter ODD = 1'b1)
  (
  input wire rst,clk,
  input wire par_type,par_check_en,sampled_bit,
  input wire [data_size-1:0] p_data,
  output reg par_check_err
  );

reg parity,xor1_out,xor2_out,xor3_out,xor4_out,xor5_out,xor6_out; 
 
 /* parity calculation */
 
 always@(*)begin
  if(par_check_en)begin
      xor1_out = p_data[0] ^ p_data[1]; 
      xor2_out = p_data[2] ^ xor1_out ; 
      xor3_out = p_data[3] ^ xor2_out ;
      xor4_out = p_data[4] ^ xor3_out ; 
      xor5_out = p_data[5] ^ xor4_out ;
      xor6_out = p_data[6] ^ xor5_out ; 
      parity   = p_data[7] ^ xor6_out ;
    end  
   else
      parity = 0;
end
    
always@(posedge clk or negedge rst)begin
  if(!rst)
    par_check_err <= 1'b0;
    
  else if(par_check_en)begin

      if(par_type == EVEN)begin
        if(parity == sampled_bit)
          par_check_err <= 1'b0;
        else
          par_check_err <= 1'b1;
       end 
      else if(par_type == ODD) begin
        if(~parity == sampled_bit)
          par_check_err <= 1'b0;
        else
          par_check_err <= 1'b1;
       end 
  end

end
endmodule



  
