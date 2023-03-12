module fsm (
  input wire clk,rstn,
  input wire data_valid,par_en,ser_done,
  output reg busy,ser_en,
  output reg [1:0] mux_sel
  );
 reg [2:0] current_state,next_state;
 
parameter IDLE = 3'd0;
parameter START_BIT = 3'd1; 
parameter DATA = 3'd2;
parameter PARITY = 3'd3;
parameter STOP = 3'd4;

/*current_state logic */
always@(posedge clk or negedge rstn)begin
  if(!rstn)
    current_state <= IDLE;
  else
    current_state <= next_state;
end  
    
 /*next state logic */
always@(*)begin
  case(current_state)
    IDLE:begin
          if(data_valid)
            next_state = START_BIT;
          else
            next_state = IDLE;
          end

    START_BIT:next_state = DATA;
    DATA:begin
         if(par_en == 1'b1 && ser_done == 1'b1)
            next_state = PARITY;
          else if (par_en == 1'b0 && ser_done == 1'b1)
            next_state = STOP;
          else
            next_state = DATA;
          end  
    PARITY: next_state = STOP;
    STOP: next_state = IDLE;
    default : next_state = IDLE;
  endcase
end

/* moore output logic */
always@(*)begin
    mux_sel = 2'd0;
    busy = 1'b0;
    ser_en = 1'b0;
    
  case(current_state)
    IDLE:begin
	      busy = 1'b0;
	      mux_sel = 2'd1;
	  end
    START_BIT:begin
              ser_en = 1'b1;
              mux_sel = 2'd0;
              busy = 1'b1;
              end
    DATA:begin
               ser_en = 1'b1;
               mux_sel = 2'd2;
               busy = 1'b1;
          end
    PARITY:begin
              mux_sel = 2'd3;
              busy = 1'b1;
           end
    STOP:begin
              mux_sel = 2'd1;
              busy = 1'b1;
          end   

endcase
end
endmodule
