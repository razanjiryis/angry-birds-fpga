
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // smiley 
					input		logic	smileyDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] smileyRGB, 
					     

		  // for the plane
					input		logic airplaneDrawingRequest,
					input 	logic [7:0] airplaneRGB,
		  
		  ////////////////////////
		  // background 
					input    logic boxDrawingRequest,
					input		logic	[7:0] boxRGB,  
					
					input		logic	[7:0] backGroundRGB, 
					input		logic	BGDrawingRequest, 
					
					input		logic	[7:0] RGB_MIF, 
					
			
		  //for winning the game
					input		logic winnerDR,
					input 	logic [7:0] winnerRGB,
					input		logic level_ended,
			
		  //for losing the game
					input		logic gameOverDR,
					input 	logic [7:0] gameOverRGB,
					input		logic lost,
					
		  //for the hearts
					input		logic heartsDR,
					input 	logic [7:0] heartsRGB,

			  
				   output	logic	[7:0] RGBOut
);


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
	
		if(winnerDR == 1'b1 && level_ended == 1'b1)
				RGBOut <= winnerRGB ;
				
		else if(lost == 1'b1)
				RGBOut <= gameOverRGB ;
	
		
		else begin
		
		
			if (smileyDrawingRequest == 1'b1 )   
				RGBOut <= smileyRGB;  //first priority 

//--------------------------------------------------------------------------------------------		

 		   else if (airplaneDrawingRequest == 1'b1)
			  RGBOut <= airplaneRGB;
			  
			else if (heartsDR == 1'b1)
				RGBOut <= heartsRGB ;
				
		   else if (boxDrawingRequest == 1'b1)
				RGBOut <= boxRGB;
				
		   else if (BGDrawingRequest == 1'b1)
				RGBOut <= backGroundRGB ;
		   else RGBOut <= RGB_MIF ;// last priority 
		end

	end ; 
end

endmodule


