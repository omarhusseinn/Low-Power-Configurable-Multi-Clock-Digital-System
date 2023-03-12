module data_sampling(
  input wire clk,rst,
  input wire rx_in,data_sample_en,
  input wire [4:0] prescale,
  input wire [5:0] edge_cnt,
  output reg sampled_bit
  );
  

/*** for 3 edges used in oversampling ***/
reg[4:0]  edge_cnt_1;
reg[4:0]  edge_cnt_2;
reg[4:0]  edge_cnt_3;

/*** 3 sampled bits from oversampling ***/
reg sampled_bit_1,sampled_bit_2,sampled_bit_3;

always@(*)begin
  edge_cnt_1 =  (prescale/6'd2)-6'd2;
  edge_cnt_2 =  (prescale/6'd2)-6'd1;
  edge_cnt_3 =  (prescale/6'd2);
end

always@(posedge clk or negedge rst)begin
   if(!rst)begin
	sampled_bit_1 <= 1'b0;
	sampled_bit_2 <= 1'b0;
	sampled_bit_3 <= 1'b0;
	end
   else if(data_sample_en)begin
      if(edge_cnt == edge_cnt_1)
      sampled_bit_1 <= rx_in;
      else if(edge_cnt == edge_cnt_2)
      sampled_bit_2 <= rx_in;
      else if(edge_cnt == edge_cnt_3)
      sampled_bit_3 <= rx_in;
     end

end

/*** checking sampled bits ***/
always@(posedge clk or negedge rst)begin
  if(!rst)
    sampled_bit <= 1'b0;
   else begin		
	
  if(sampled_bit_1 == sampled_bit_2 && sampled_bit_1 != sampled_bit_3)
    sampled_bit <= sampled_bit_1;
  else if(sampled_bit_1 == sampled_bit_3 && sampled_bit_1 != sampled_bit_2)
    sampled_bit <= sampled_bit_1;
  else if(sampled_bit_2 == sampled_bit_3 && sampled_bit_2 != sampled_bit_1)
    sampled_bit <= sampled_bit_2;
  else if(sampled_bit_1 == sampled_bit_3 && sampled_bit_1 == sampled_bit_2)
    sampled_bit <= sampled_bit_1;
end
end
endmodule
   
      
    
