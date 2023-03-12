module controller_fsm(
  input wire clk,rst,
  input wire rx_in,par_check_err,start_check_err,stop_check_err,par_en,
  input wire [5:0] edge_cnt,
  input wire [3:0] bit_cnt,
  output reg enable,data_sample_en,par_check_en,start_check_en,stop_check_en,data_valid,deser_en
  );
 
 
/*** encoding parameters ***/
parameter IDLE = 3'd0;
parameter START_BIT = 3'd1; 
parameter DATA = 3'd2;
parameter PARITY = 3'd3;
parameter STOP = 3'd4;
parameter ERR_CHECK = 3'd5;
parameter DATA_VALID = 3'd6;

/*** current,next state parameters ***/
reg [2:0] next_state,current_state;

  
  
/*** current state logic ***/
always@(posedge clk or negedge rst)begin
    if(!rst)
      current_state <= IDLE;
    else
      current_state <= next_state;
end      
 

/*** next state logic ***/

always@(*)begin

  case(current_state)
    IDLE:begin
          if(!rx_in)
            next_state = START_BIT;           
          else
            next_state = IDLE;
          end
          
    START_BIT:begin
       if(bit_cnt == 4'd0 && edge_cnt == 6'd7) begin
        if(!start_check_err)
          next_state = DATA;
        else
         next_state = IDLE;
        end
        
        else
          next_state = START_BIT;
        end
        
    DATA:begin
         if(bit_cnt == 4'd8 && edge_cnt == 6'd7)begin
            if(par_en)
               next_state = PARITY; 
            else
               next_state = STOP;
          end
          else
            next_state = DATA;
          end  
    PARITY:begin
            if(bit_cnt == 4'd9 && edge_cnt == 6'd7)
                next_state = STOP;
            else
                next_state = PARITY;
            end
            
    STOP: begin
          if(par_en)begin
             if(bit_cnt == 4'd10 && edge_cnt == 6'd7)
                  next_state = ERR_CHECK;
              else
                   next_state = STOP;
          end         
          else begin         
             if(bit_cnt == 4'd9 && edge_cnt == 6'd7)
                  next_state = ERR_CHECK;
              else
                   next_state = STOP;                   
          end
          end

    ERR_CHECK :begin
                if(par_check_err == 1'b0 && stop_check_err == 1'b0)
                    next_state = DATA_VALID;
                else
                    next_state = IDLE;
               end
    DATA_VALID : next_state = IDLE;
                    
    default : next_state = IDLE;
  endcase
end




/* moore & mealy output logic */
always@(*)begin
        data_sample_en = 1'b0;
        enable = 1'b0;
        start_check_en = 1'b0;
        par_check_en = 1'b0;
        stop_check_en = 1'b0;
        deser_en = 1'b0;
        data_valid = 1'b0;
        
  case(current_state)         
    IDLE:begin
      if(!rx_in)begin
        data_sample_en = 1'b1;
        enable = 1'b1;
        start_check_en = 1'b1;
      end

      else
        data_sample_en = 1'b0;
        enable = 1'b0;
        start_check_en = 1'b0;
        par_check_en = 1'b0;
        stop_check_en = 1'b0;
        deser_en = 1'b0;
        data_valid = 1'b0;
	  end
    START_BIT:begin
        data_sample_en = 1'b1;
        enable = 1'b1;
        if(bit_cnt == 4'd0 && edge_cnt == 6'd7)  
          start_check_en = 1'b1;
        else
         start_check_en = 1'b0;
        end
        
             
    DATA:begin
        data_sample_en = 1'b1;
        enable = 1'b1;
        if(bit_cnt == 4'd8 && edge_cnt == 6'd7)
             deser_en = 1'b0;
        else
              deser_en = 1'b1;
          end

    PARITY:begin
        data_sample_en = 1'b1;
        enable = 1'b1;
         if(bit_cnt == 4'd9 && edge_cnt == 6'd7)
            par_check_en = 1'b1;
         else
            par_check_en = 1'b0;        
           end
           
    STOP:begin
        data_sample_en = 1'b1;
        enable = 1'b1;
          if(par_en)begin
             if(bit_cnt == 4'd10 && edge_cnt == 6'd7)
                  stop_check_en = 1'b1;
              else
                   stop_check_en = 1'b0;
          end         
          else begin         
             if(bit_cnt == 4'd9 && edge_cnt == 6'd7)
                  stop_check_en = 1'b1;
              else
                   stop_check_en = 1'b0;                   
          end
          end
          
    ERR_CHECK :begin
        data_sample_en = 1'b1;
    end
    
    DATA_VALID :begin
        data_valid = 1'b1;
    end

endcase
end
endmodule
