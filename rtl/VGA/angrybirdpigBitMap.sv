 //-------------------------------
 
module	angrybirdpigBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output   logic	[3:0] HitEdgeCode //one bit per edge 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  // 2^5 = 32 


localparam  int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 3; // -2; how many pixel bits are in every collision pixel
localparam  int OBJECT_WIDTH_X_DIVIDER =  OBJECT_NUMBER_OF_X_BITS - 3; // -2

// generating a pig bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 

logic [0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] [7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h2e,8'h2e,8'h2e,8'h2e,8'h20,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h2e,8'h2e,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'h2e,8'h2e,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'h20,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf6,8'h99,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'h2e,8'h2e,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'hff,8'hff,8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h20,8'h20,8'h20,8'h20,8'h20,8'h2e,8'h2e,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'h20,8'hf6,8'hf6,8'h00,8'hf6,8'h34,8'h34,8'h34,8'hf6,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h2e,8'h2e,8'h2e,8'h73,8'h73,8'h73,8'h73,8'h2e,8'h2e,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h34,8'hf6,8'hf6,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h20,8'h20,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'h2e,8'h2e,8'h2e,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'h73,8'h20,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf6,8'hf6,8'h20,8'h73,8'h73,8'h73,8'h73,8'h00,8'h2c,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'h20,8'h20,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'h30,8'h30,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hb6,8'hf6,8'hf6,8'hf6,8'h30,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h98,8'h98,8'h98,8'h98,8'h98,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h30,8'h30,8'h30,8'hf6,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'h74,8'h74,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h98,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'h98,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hff,8'hff},
	{8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h74,8'hf6,8'hf6,8'h98,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'h98,8'hf6,8'h78,8'hf6,8'hf6,8'hf6,8'h74,8'hf6,8'h00,8'hff},
	{8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h74,8'hf6,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'h98,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h74,8'h00,8'hff},
	{8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h98,8'hf9,8'hf9,8'h2c,8'h2c,8'h2c,8'hf9,8'hf9,8'hf9,8'hbc,8'hf9,8'hf9,8'hbc,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'hff},
	{8'hff,8'h00,8'hf6,8'hf6,8'hfe,8'h00,8'h00,8'hfe,8'hfe,8'hfe,8'hfe,8'h98,8'hf9,8'hf9,8'h2c,8'h2c,8'h2c,8'hf9,8'hf9,8'h2c,8'h2c,8'h2c,8'hf9,8'hf9,8'hf6,8'h00,8'hfe,8'hfe,8'hfe,8'hfe,8'h70,8'hff},
	{8'hff,8'h00,8'hf6,8'hf6,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h98,8'hf9,8'hf9,8'h2c,8'h2c,8'h2c,8'hf9,8'hf9,8'h2c,8'h2c,8'h2c,8'hf9,8'hf9,8'h00,8'h00,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'hff},
	{8'hff,8'h00,8'hf6,8'hf6,8'h74,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h74,8'h98,8'hf9,8'hf9,8'hf9,8'h2c,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'h98,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'hff},
	{8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'hfe,8'hfe,8'hfe,8'hfe,8'h74,8'hf6,8'hf6,8'h98,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'h98,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h74,8'h00,8'hff},
	{8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h74,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h98,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'h98,8'h9c,8'hf6,8'hf6,8'h74,8'hde,8'h74,8'hf6,8'hf6,8'h24,8'hff},
	{8'hff,8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h74,8'h74,8'hf6,8'h78,8'h98,8'h98,8'h98,8'h98,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h74,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'h24,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h74,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h30,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'hf6,8'hf6,8'hf6,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};
//each picture row and column divided to 8 sections 


logic [0:7] [0:7] [3:0] hit_colors = 
		  {32'hC4444446,     
			32'h8C444462,    
			32'h88C44622,    
			32'h888C6222,    
			32'h88893222,    
			32'h88911322,    
			32'h89111132,    
			32'h91111113};
 

 
 
// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		HitEdgeCode <= 4'h0;

	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		HitEdgeCode <= 4'h0;

		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket 
			RGBout <= object_colors[offsetY][offsetX];
			HitEdgeCode <= hit_colors[offsetY >> OBJECT_HEIGHT_Y_DIVIDER][offsetX >> OBJECT_WIDTH_X_DIVIDER];	//get hitting edge code from the colors table  
			
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = ((RGBout != TRANSPARENT_ENCODING)) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap

endmodule