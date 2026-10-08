// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	redBirdBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					
					//-----------Added for showing only when dropped----
					input logic bird_is_dropped,
					//--------------------------------------------------
					
					//-----------Added for "changing to angry face" when bird is about to collide----------
					input logic turn_to_angry,
					//-------------------------------------------------------------------------------------

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

//-----------------------------------------------------
logic dropped_D ;
//-----------------------------------------------------

// generating a smiley bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 

logic [0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] [7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'he0,8'he0,8'he0,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hda,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h60,8'h00,8'h60,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'hff},
	{8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00,8'h00,8'ha0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h80,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hfe,8'hfe,8'hfe,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfe,8'hfe,8'he0,8'he0,8'hff},
	{8'hff,8'hff,8'h24,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'he0,8'he0,8'he0,8'hc0,8'hfe,8'hfe,8'hfe,8'h00,8'h00,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'hfe,8'hc0,8'he0,8'hff},
	{8'hff,8'hff,8'h00,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'hc0,8'he0,8'hc0,8'hc0,8'hfe,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'hfe,8'hc0,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'hc0,8'he0,8'hc0,8'hc0,8'h00,8'hfe,8'hfe,8'hfe,8'h00,8'hf8,8'hf8,8'h00,8'hfe,8'hfe,8'hfe,8'hc0,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'he0,8'he0,8'hc0,8'hc0,8'he0,8'hc0,8'hc0,8'hc0,8'h00,8'h00,8'h6c,8'hf8,8'hf8,8'hf8,8'hf8,8'hd0,8'h00,8'hc0,8'hc0,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'hc0,8'hc0,8'hc0,8'he0,8'hc0,8'hc0,8'he0,8'hc0,8'hc0,8'hc0,8'hc0,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hc0,8'hc0,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hed,8'h00,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'he0,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hb1,8'h00,8'h00,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'h60,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'he0,8'he0,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'he0,8'he0,8'he0,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'hf4,8'hf4,8'hf4,8'hf4,8'h00,8'he0,8'he0,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hc0,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'hf4,8'h8c,8'hfe,8'hfe,8'he0,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'hfe,8'h00,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'h00,8'hda,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hda,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'h00,8'h00,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};
	
	//--------------------------------The angry face---------------------
	logic[0:31][0:31][7:0] object_colors_2 = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h60,8'he0,8'h80,8'hff,8'he4,8'he0,8'he0,8'hc0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he0,8'he0,8'he0,8'h80,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he4,8'he0,8'he0,8'he0,8'h60,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd6,8'he4,8'he0,8'he0,8'he0,8'he4,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h80,8'h80,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h20,8'h20,8'h20,8'hb6,8'hff,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'h84,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h20,8'he0,8'h60,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h20,8'h20,8'h20,8'he0,8'h60,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'h20,8'h20,8'h20,8'h20,8'h80,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h20,8'h20,8'h20,8'he0,8'he0,8'h80,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h20,8'h20,8'hff,8'hff,8'h20,8'h20,8'hff,8'ha0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'ha0,8'h20,8'h20,8'h20,8'he0,8'he0,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'he0,8'he4,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'hc0,8'hc0,8'he0,8'he0,8'he0,8'h60,8'hfe,8'hfe,8'hfe,8'h20,8'h20,8'he0,8'he0,8'he0,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h20,8'h20,8'h20,8'h20,8'h60,8'he4,8'he0,8'he0,8'he0,8'hc0,8'hc0,8'he0,8'hc0,8'hc0,8'hc0,8'he0,8'he0,8'he0,8'hc0,8'hc0,8'hfe,8'hfe,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h60,8'he4,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'hc0,8'hc0,8'he0,8'he0,8'hc0,8'hc0,8'hc0,8'hc0,8'hfe,8'hfe,8'h20,8'h20,8'h20,8'h20,8'h20,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'hc0,8'hc0,8'hc0,8'h20,8'hfe,8'hfe,8'hfe,8'he0,8'h20,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'h60,8'h64,8'hfe,8'hfe,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h80,8'he4,8'he4,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hfa,8'hfe,8'he0,8'h64,8'hf4,8'hf8,8'hf8,8'hf8,8'hfa,8'hfe,8'hfe,8'hfe,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h60,8'he4,8'he4,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hfe,8'hfe,8'hfe,8'h84,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf8,8'hf8,8'hf8,8'hc0,8'hc0,8'hc0,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h80,8'he4,8'he4,8'he0,8'he0,8'he0,8'he0,8'hfe,8'hfe,8'hfe,8'hf4,8'h84,8'h20,8'h20,8'h20,8'h20,8'h80,8'h64,8'hf4,8'hf4,8'hf8,8'hf8,8'hac,8'hc0,8'h60,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h60,8'he4,8'he4,8'he4,8'he0,8'hfe,8'hfe,8'hfe,8'hb1,8'hac,8'h80,8'h20,8'h20,8'h20,8'h20,8'h84,8'h64,8'hfe,8'hfe,8'h84,8'hf4,8'hf8,8'hf8,8'hc0,8'he0,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he0,8'hfe,8'hfe,8'hfe,8'h84,8'h80,8'h80,8'h80,8'h80,8'h20,8'h80,8'hcc,8'hf0,8'hf0,8'hf0,8'hf0,8'hd5,8'hfe,8'hf4,8'hf8,8'he0,8'he0,8'hc0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h80,8'he4,8'hfa,8'hfa,8'hfe,8'hfe,8'hf4,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h84,8'hfe,8'h80,8'hc4,8'h80,8'hfe,8'hfe,8'hfe,8'h64,8'h84,8'he0,8'h80,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h80,8'hfa,8'hfa,8'hfa,8'hfa,8'hfe,8'hfe,8'hf4,8'hf8,8'h80,8'h80,8'h80,8'hf8,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'he0,8'he0,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h80,8'hfa,8'hfa,8'hfa,8'hfa,8'hfe,8'hb1,8'hf4,8'hf4,8'hf4,8'hf8,8'h64,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'he0,8'h80,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h80,8'h80,8'hfa,8'hfa,8'hfa,8'hfa,8'hfe,8'hfe,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf8,8'h80,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h60,8'he0,8'he0,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h80,8'h80,8'h80,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfe,8'hfe,8'hfe,8'h64,8'h84,8'h84,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h60,8'he0,8'he0,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'h80,8'h80,8'hfa,8'h60,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'he0,8'h80,8'he0,8'he0,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'h80,8'hfa,8'h60,8'hfa,8'h60,8'h60,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'h60,8'h84,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'h60,8'hfa,8'h60,8'h60,8'hfa,8'hfa,8'h60,8'h80,8'h80,8'h80,8'h80,8'h80,8'hfa,8'h60,8'h00,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'h60,8'hfa,8'hfa,8'h60,8'h80,8'h80,8'h80,8'h80,8'h80,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};

//////////--------------------------------------------------------------------------------------------------------------=
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  

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
		dropped_D <= 1'b0;

	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		HitEdgeCode <= 4'h0;
		dropped_D <= bird_is_dropped;

		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket 
			RGBout <= (turn_to_angry) ? object_colors_2[offsetY][offsetX] : object_colors[offsetY][offsetX] ;
			HitEdgeCode <= hit_colors[offsetY >> OBJECT_HEIGHT_Y_DIVIDER][offsetX >> OBJECT_WIDTH_X_DIVIDER];	//get hitting edge code from the colors table  
			
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = ((RGBout != TRANSPARENT_ENCODING) & dropped_D) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap

endmodule