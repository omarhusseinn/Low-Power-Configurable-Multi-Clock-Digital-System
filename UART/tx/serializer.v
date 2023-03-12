module serializer #(parameter data_size = 4'd8)
(
  input clk,rstn,
  input ser_en,
  input [data_size-1:0] p_data,
  output reg ser_done,
  output reg ser_data
);

reg [data_size-1 : 0] data_stored;

/** set counter to know when serializer finish **/
reg [3:0] cnt;

/** put parallel data in a register **/
always@(*)begin
     data_stored[0] = p_data[0];
     data_stored[1] = p_data[1];
     data_stored[2] = p_data[2];
     data_stored[3] = p_data[3];
     data_stored[4] = p_data[4];
     data_stored[5] = p_data[5];
     data_stored[6] = p_data[6];
     data_stored[7] = p_data[7];
end

always@(posedge clk or negedge rstn)begin
  if(!rstn)
    data_stored = 0;
  else if(ser_en == 1'b1 && cnt < 4'd8) begin
    ser_data <= data_stored[0];
    data_stored[0] <= data_stored [1] ;
    data_stored[1] <= data_stored [2] ;
    data_stored[2] <= data_stored [3] ;
    data_stored[3] <= data_stored [4] ;
    data_stored[4] <= data_stored [5] ;
    data_stored[5] <= data_stored [6] ;
    data_stored[6] <= data_stored [7] ;
    data_stored[7] <= 1'b0;
end
end

/** counter increment **/
always @(posedge clk or negedge rstn)begin
  if(!rstn)
    cnt <= 4'd0;
  else if(ser_en)begin
    cnt <= cnt + 4'd1;
    if(cnt == 4'd7)
      ser_done <= 1'b1;  
    else if(cnt == 4'd8)begin
      cnt <= 4'd0;
      ser_done <= 1'b0;
      end
  end
      
end
endmodule