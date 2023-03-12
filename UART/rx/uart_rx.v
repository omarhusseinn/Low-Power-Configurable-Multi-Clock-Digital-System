module uart_rx(
  input wire rx_in,
  input wire clk,
  input wire rst,
  input wire par_en,
  input wire par_type,
  input wire [4:0] prescale,
  output wire data_valid,
  output wire [7:0] p_data
  );

/*** internal wires ***/  
wire start_check_err;
wire stop_check_err;
wire par_check_err;

wire enable;
wire data_sample_en;
wire start_check_en;
wire stop_check_en;
wire par_check_en;
wire deser_en;

wire sampled_bit;
 
wire [5:0] edge_cnt;
wire [3:0] bit_cnt;


/*** data sample block ***/
data_sampling i0(
  .clk(clk),
  .rst(rst),
  .rx_in(rx_in),
  .data_sample_en(data_sample_en),
  .prescale(prescale),
  .edge_cnt(edge_cnt),
  .sampled_bit(sampled_bit)
);
/*** rx controller block ***/
controller_fsm i1(
  .clk(clk),
  .rst(rst),
  .rx_in(rx_in),
  .par_check_err(par_check_err),
  .start_check_err(start_check_err),
  .stop_check_err(stop_check_err),
  .edge_cnt(edge_cnt),
  .bit_cnt(bit_cnt),
  .enable(enable),
  .data_sample_en(data_sample_en),
  .par_check_en(par_check_en),
  .start_check_en(start_check_en),
  .stop_check_en(stop_check_en),
  .data_valid(data_valid),
  .deser_en(deser_en),
  .par_en(par_en)
  );
/*** start check block ***/
start_check i2(
  .start_check_en(start_check_en),
  .sampled_bit(sampled_bit),
  .clk(clk),
  .rst(rst),
  .start_check_err(start_check_err)
  );
/*** parity check block ***/
parity_check i3(
  .par_check_en(par_check_en),
  .sampled_bit(sampled_bit),
  .clk(clk),
  .rst(rst),
  .par_check_err(par_check_err),
  .p_data(p_data),
  .par_type(par_type)
  );
/*** stop check block ***/
stop_check i4(
  .stop_check_en(stop_check_en),
  .sampled_bit(sampled_bit),
  .clk(clk),
  .rst(rst),
  .stop_check_err(stop_check_err)
  );
/*** deserializer block ***/
deserializer i5(
  .clk(clk),
  .rst(rst),
  .sampled_bit(sampled_bit),
  .deser_en(deser_en),
  .p_data(p_data),
  .edge_cnt(edge_cnt)
  );
/*** edge_bit_cnt block ***/
edge_bit_cnt i6(
  .enable(enable),
  .clk(clk),
  .rst(rst),
  .prescale(prescale),
  .edge_cnt(edge_cnt),
  .bit_cnt(bit_cnt)
  );
endmodule