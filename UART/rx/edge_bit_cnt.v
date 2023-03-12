module edge_bit_cnt #(parameter FRAME_SIZE = 11)
 (
  input wire enable,
  input wire clk,rst,
  input wire [4:0] prescale, // prescale value = 4,8,16,32
  output reg [5:0] edge_cnt, // counting posegde of clk
  output reg [3:0] bit_cnt //counting number of bits of frame
  );

  
always @(posedge clk or negedge rst)begin

  if(!rst)begin
    edge_cnt <= 6'd0;
    bit_cnt <= 4'd0;
  end  

  else if(enable)begin
    edge_cnt <= edge_cnt + 6'd1;
    if(edge_cnt == prescale-5'd1)begin
      edge_cnt <= 6'd0;
      bit_cnt <= bit_cnt +4'd1;
    end
    end
    
  else begin
      edge_cnt <= 6'd0;
      bit_cnt <= 4'd0;
  end  
  
end
endmodule  
