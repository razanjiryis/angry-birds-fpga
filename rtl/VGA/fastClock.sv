 module fastClock      	
	(
   // Input, Output Ports
	input  logic clk, 
	input  logic resetN, 
	
	
	output logic fast_clock
   );
	
	int oneSecCount ;
	int sec ;		 // gets either one seccond or Turbo top value


	
//       ----------------------------------------------	counter limit setting
	localparam oneSecVal_REAL = 32'd50; // for DE10 board un-comment this line 
	//localparam oneSecVal_SIM = 32'd20; // for quartus simulation un-comment this line 
	localparam oneSecVal= oneSecVal_REAL ; //select what to use 
//       ----------------------------------------------	
	
	assign  sec = oneSecVal/1000;  // it is legal to devide by 10, as it is done by the complier not by logic (actual transistors) 


	
   always_ff @( posedge clk or negedge resetN )
   begin
	
		// asynchronous reset
		if ( !resetN ) begin
			fast_clock <= 1'b0;
			oneSecCount <= 32'd0;
		end // if reset
		
		// executed once every clock 	
		else begin
			if (oneSecCount >= sec) begin
				fast_clock <= 1'b1;
				oneSecCount <= 0;
			end
			else begin
				oneSecCount <= oneSecCount + 1;
				fast_clock		<= 1'b0;
			end
		end // else clk
		
	end // always
	
endmodule