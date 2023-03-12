module stop_check(
  input wire stop_check_en,sampled_bit,
  input wire clk,rst,
  output reg stop_check_err
  );
  
always@(posedge clk or negedge rst)begin
  if(!rst)
    stop_check_err <= 1'b0;
  else if(stop_check_en)begin
    if(sampled_bit == 1'b1)
      stop_check_err <= 1'b0;
    else
      stop_check_err <= 1'b1;
  end    
end      
endmodule  
