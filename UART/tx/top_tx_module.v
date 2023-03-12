module top_tx_module #(parameter data_size = 8)
(
  input wire [data_size-1:0] p_data,
  input wire clk,rstn,
  input wire data_valid,par_en,par_type,
  output wire busy,tx_out

);


/*** internal wires ***/
wire ser_done,ser_en,par_bit,start_bit,stop_bit,ser_data;
wire [1:0] mux_sel;


/*** blocks instantiation **/
serializer u0 (
  .clk(clk),
  .rstn(rstn),
  .ser_en(ser_en),
  .ser_done(ser_done),
  .ser_data(ser_data),
  .p_data(p_data)
);


fsm u1 (
  .clk(clk),
  .rstn(rstn),
  .data_valid(data_valid),
  .ser_done(ser_done),
  .ser_en(ser_en),
  .busy(busy),
  .mux_sel(mux_sel),
  .par_en(par_en)
  );
  
parity_check_tx u2 (
  .clk(clk),
  .rstn(rstn),
  .data_valid(data_valid),
  .par_type(par_type),
  .p_data(p_data),
  .par_bit(par_bit)
  );

mux4x1 u3(
  .mux_sel(mux_sel),
  .ser_data(ser_data),
  .start_bit(start_bit),
  .stop_bit(stop_bit),
  .par_bit(par_bit),
  .tx_out(tx_out)
);

endmodule