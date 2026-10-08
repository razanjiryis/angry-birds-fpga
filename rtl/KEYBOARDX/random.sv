// (c) Technion IIT, Department of Electrical Engineering 2021 
module random 	
 ( 
	input	logic  clk,
	input	logic  resetN, 
	input	logic	 rise,
	output logic unsigned [SIZE_BITS-1:0] dout	
  ) ;

// Generating a random number by latching a fast counter with the rising edge of an input ( e.g. key pressed )
  
parameter SIZE_BITS = 8;
parameter unsigned MIN_VAL = 0;  //set the min and max values 
parameter unsigned MAX_VAL = 255;

	logic unsigned  [SIZE_BITS-1:0] counter = 0/* synthesis keep = 1 */;
	logic rise_d = 0 /* synthesis keep = 1 */;
	
	
always_ff @(posedge clk) begin

			counter <= counter+1;
			if ( counter >= MAX_VAL ) // the +1 is done on the next clock 
				counter <=  MIN_VAL ; // set min and max mvalues 
			rise_d <= rise;
			if (rise && !rise_d) // rising edge 
				dout <= counter;
	
	end
 
endmodule

