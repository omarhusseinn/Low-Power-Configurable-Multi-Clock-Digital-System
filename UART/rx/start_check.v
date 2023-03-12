module start_check(
  input wire start_check_en,sampled_bit,
  input wire clk,rst,
  output reg start_check_err
  );
  
always@(posedge clk or negedge rst)begin
  if(!rst)
    start_check_err <= 1'b0;
  else if(start_check_en)begin
    if(sampled_bit == 1'b0)
      start_check_err <= 1'b0;
    else
      start_check_err <= 1'b1;
  end    
end      
endmodule  
