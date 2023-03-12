module deserializer(
  input wire clk,rst,
  input wire sampled_bit,deser_en,
  input wire [5:0] edge_cnt,
  output reg [7:0] p_data
  );


always@(posedge clk or negedge rst)begin
 if(!rst)
   p_data <= 8'd0;
  

  else if(deser_en)begin
    if(edge_cnt == 5'd6)begin
      p_data <= {sampled_bit,p_data[7:1]};
    end
   end 
end    

endmodule    
