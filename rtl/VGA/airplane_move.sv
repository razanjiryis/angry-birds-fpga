module	airplane_move	(	
 
					input	 logic clk,
					input	 logic resetN,
					input	 logic startOfFrame,      //short pulse every start of frame 30Hz 
					// input	 logic enable_sof,    // if want to stop the smiley move
					input	 logic Y_up_key,   //move Y Up
					input	 logic Y_down_key,   //move Y Down
					input	 logic X_accelerate_key,      //accelerate in X
					input  logic X_deaccelerate_key,         //deaccelerate in X
					input  logic [3:0] HitEdgeCode, //one bit per edge

					output logic signed 	[10:0] topLeftX, // output the top left corner 
					output logic signed	[10:0] topLeftY,  // can be negative , if the object is partliy outside 
					output int X_AirplaneSpeed
					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 0;
parameter int INITIAL_Y = 20;
parameter int INITIAL_X_SPEED = 100;



const int MAX_X_SPEED = 400;
const int	FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions


// movement limits 
const int   OBJECT_WIDTH_X = 128;
const int   OBJECT_HIGHT_Y = 128;
const int	SafetyMargin   =	2;

const int	x_FRAME_LEFT	=	(- SafetyMargin - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int	x_FRAME_RIGHT	=	(639 - SafetyMargin)* FIXED_POINT_MULTIPLIER; 
const int	y_FRAME_TOP		=	(SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int	y_FRAME_BOTTOM	=	(239 -SafetyMargin - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER; //- OBJECT_HIGHT_Y


enum  logic [2:0] {IDLE_ST,         	// initial state
						 MOVE_ST, 				// moving no colision 
						 POSITION_CHANGE_ST, // position interpolate 
						 POSITION_LIMITS_ST  // check if inside the frame  
						}  SM_Motion ;

int Xspeed  ; // speed    
int Xposition ; //position   
int Yposition ;  

logic accelerate_x_key_D ;
logic deaccelerate_x_key_D ;

 

logic [15:0] hit_reg = 16'b00000;  // register to collect all the collisions in the frame. |corner|left|top|right|bottom|

 //---------
 
//------------------------------Added--------------------------------//
parameter int X_ACCEL = 15;
parameter int Y_MOVE_UP = 50;
parameter int Y_MOVE_DOWN = -50;

//-------------------------------------------------------------------//
 
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if (resetN == 1'b0) begin 
		SM_Motion <= IDLE_ST ; 
		Xspeed <= 0   ; 
		Xposition <= 0  ; 
		Yposition <= 0   ; 
		accelerate_x_key_D <= 0 ;
		hit_reg <= 16'b0 ;	
	
	end 	
	
	else begin
	
		accelerate_x_key_D <= X_accelerate_key ;  //shift register to detect edge
		deaccelerate_x_key_D <=  X_deaccelerate_key ;
	
		case(SM_Motion)
		
		//------------
			IDLE_ST: begin
		//------------
		
				Xspeed  <= INITIAL_X_SPEED ; 
				Xposition <= INITIAL_X*FIXED_POINT_MULTIPLIER; 
				Yposition <= INITIAL_Y*FIXED_POINT_MULTIPLIER; 

				// if (startOfFrame && enable_sof)   if want to stop the smiley move
				if (startOfFrame) 
					SM_Motion <= MOVE_ST ;
 	
			end
	
		//------------
			MOVE_ST:  begin     // moving no colision 
		//------------
		// X acceleration 
				if (X_accelerate_key & !accelerate_x_key_D) //rizing edge 
					if(Xspeed + X_ACCEL < MAX_X_SPEED)
						Xspeed <= Xspeed + X_ACCEL ; // accelerate in X direction 
					else
						Xspeed <=MAX_X_SPEED ;
						
	   // X deacceleration 
				else if (X_deaccelerate_key & !deaccelerate_x_key_D) //rizing edge 
					if(Xspeed - X_ACCEL > INITIAL_X_SPEED)
						Xspeed <= Xspeed - X_ACCEL ; // accelerate in X direction 
					else
						Xspeed <= INITIAL_X_SPEED ;
						
       // collcting collisions 	
				/*if (collision) begin
					hit_reg[HitEdgeCode]<=1'b1;

				end*/
				

				if (startOfFrame )
					SM_Motion <= POSITION_CHANGE_ST ; 
					
					
				
		end 

		//------------------------
			POSITION_CHANGE_ST : begin  // position interpolate 
		//------------------------
	
				Xposition <= Xposition + Xspeed ; 
				if (Y_up_key)begin //positive edge 
					Yposition <= Yposition + Y_MOVE_DOWN ; // move the plane towards the sky
				end	
				else if (Y_down_key)begin //positive edge
				   Yposition <= Yposition + Y_MOVE_UP ; // move the plane towards the ground
				end
				else begin
					Yposition <= Yposition ;
				end
			 
				// accelerate 
				
				/*if (!dropped_flag)begin
					if (Y_direction_key && Yspeed < MAX_Y_SPEED ) //  limit the speed while going down 
						Yspeed <= Yspeed - Y_ACCEL ; // deAccelerate : slow the speed down every clock tick
				end 
				
				else begin
					if (Yspeed < MAX_Y_SPEED ) //  limit the speed while going down 
						Yspeed <= Yspeed - Y_ACCEL ; // deAccelerate : slow the speed down every clock tick
				end*/
				
	
//				if ((Yspeed < MAX_Y_speed)&&(Yspeed >0 ))	
//					Yspeed <= Yspeed - Y_ACCEL ; // deAccelerate : slow the speed down every clock tick 
//	
//				else if ((Yspeed > (-MAX_Y_speed))&&(Yspeed < 0 ))
//					Yspeed <= Yspeed + Y_ACCEL ; // deAccelerate : slow the speed down every clock tick
					
				SM_Motion <= POSITION_LIMITS_ST ; 
			end
		
		//------------------------
			POSITION_LIMITS_ST : begin  //check if still inside the frame 
		//------------------------
		if (Xposition < x_FRAME_LEFT) 
						Xposition <= x_FRAME_LEFT ; 
		if (Xposition > x_FRAME_RIGHT) // cyclic movement
						Xposition <= x_FRAME_LEFT ; 
		if (Yposition < y_FRAME_TOP) 
						Yposition <= y_FRAME_TOP ; 
		if (Yposition > y_FRAME_BOTTOM) 
						Yposition <= y_FRAME_BOTTOM ; 

				SM_Motion <= MOVE_ST ; 
			
			end
		
		endcase  // case 

		
	end 

end // end fsm_sync


//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX = Xposition / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = Yposition / FIXED_POINT_MULTIPLIER ;    
assign   X_AirplaneSpeed = Xspeed ; // to give it to the bird for initial X speed
	

endmodule	