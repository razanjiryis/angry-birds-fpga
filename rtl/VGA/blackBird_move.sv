module	blackBird_move	(	
 
					input	 logic clk,
					input	 logic resetN,
					input	 logic startOfFrame,      //short pulse every start of frame 30Hz 
					// input	 logic enable_sof,    // if want to stop the smiley move
					input	 logic Y_direction_key,   //move Y Up  ---------------------------------------------------change name-------------------------------------- 
					input	 logic boom_key,      //toggle X   ---------------------------------------------------change name--------------------------------------
					input  logic collision,         //collision if smiley hits an object
					input  logic [3:0] HitEdgeCode, //one bit per edge
				
					
					//----------------Added for moving with the plane------
					input int X_InitialBirdSpeed,
					input logic signed [10:0] X_InitialPlacement,
					input logic signed [10:0] Y_InitialPlacement,
					//-----------------------------------------------------
					
					//----------------Added for resetting when bird dies-------------
					input logic bird_reset,
					//---------------------------------------------------------------

					output logic signed 	[10:0] topLeftX, // output the top left corner 
					output logic signed	[10:0] topLeftY,  // can be negative , if the object is partliy outside 
					output logic dropped,
					output logic bird_died,
					output logic boom
					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_Y_SPEED = 0;
parameter int Y_ACCEL = -10;

const int MAX_Y_SPEED = 500;
const int	FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions


// movement limits 
const int   OBJECT_WIDTH_X = 32;
const int   OBJECT_HIGHT_Y = 32;
const int	SafetyMargin   =	2;

const int	x_FRAME_LEFT	=	(- SafetyMargin - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int	x_FRAME_RIGHT	=	(639 + SafetyMargin + OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int	y_FRAME_TOP		=	(SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int	y_FRAME_BOTTOM	=	(479 + SafetyMargin + OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER; //- OBJECT_HIGHT_Y


enum  logic [2:0] {IDLE_ST,         	// initial state
						 MOVE_ST, 				// moving no colision 
						 START_OF_FRAME_ST, 	          // startOfFrame activity-after all data collected 
						 POSITION_CHANGE_ST, // position interpolate 
						 POSITION_LIMITS_ST  // check if inside the frame  
						}  SM_Motion ;

int Xspeed  ; // speed   

int Yspeed  ;

int Xposition ; //position  

int Yposition ; 


logic boom_key_D ;
 

logic [15:0] hit_reg = 16'b00000;  // register to collect all the collisions in the frame. |corner|left|top|right|bottom|

 //---------
 
//------------------------------Added--------------------------------//
parameter int X_ACCEL = 5 ;
logic dropped_flag ;
logic bird_died_D ;
logic boom_D ;
int counter ;
//-------------------------------------------------------------------//
 
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if (resetN == 1'b0) begin 
		SM_Motion <= IDLE_ST ; 
		Xspeed <= X_InitialBirdSpeed   ; 
		Yspeed <= 0  ; 
		Xposition <= X_InitialPlacement*FIXED_POINT_MULTIPLIER  ; 
		Yposition <= (Y_InitialPlacement+FIXED_POINT_MULTIPLIER)*FIXED_POINT_MULTIPLIER   ; 
		boom_key_D <= 0 ;
		dropped_flag <= 0;
		hit_reg <= 16'b0 ;
		bird_died_D <= 1'b0 ;
		boom_D <= 1'b0 ;
		counter <= 0 ;
		
	
	end 	
	
	else begin
		if (bird_reset == 1'b1)begin
			SM_Motion <= IDLE_ST ; 
			Xspeed <= X_InitialBirdSpeed   ; 
			Yspeed <= 0  ; 
			Xposition <= X_InitialPlacement*FIXED_POINT_MULTIPLIER  ; 
			Yposition <= (Y_InitialPlacement+FIXED_POINT_MULTIPLIER)*FIXED_POINT_MULTIPLIER   ; 
			boom_key_D <= 0 ;
			dropped_flag <= 0;
			hit_reg <= 16'b0 ;
			bird_died_D <= 1'b0 ;
			boom_D <= 1'b0 ;
			counter <= 0 ;
			
		end
	
		boom_key_D <= boom_key ;  //shift register to detect edge
		if (X_InitialPlacement > 0 && X_InitialPlacement < 450)begin
			if(Y_direction_key)
				dropped_flag <= 1'b1;
		end

	
		case(SM_Motion)
		
		//------------
			IDLE_ST: begin
		//------------
		
				Xspeed  <= X_InitialBirdSpeed ; 
				Yspeed  <= INITIAL_Y_SPEED  ; 
				Xposition <= X_InitialPlacement*FIXED_POINT_MULTIPLIER; 
				Yposition <= (Y_InitialPlacement+FIXED_POINT_MULTIPLIER)*FIXED_POINT_MULTIPLIER; 

				// if (startOfFrame && enable_sof)   if want to stop the smiley move
				if (startOfFrame && dropped_flag) 
					SM_Motion <= MOVE_ST ;
 	
			end
	
		//------------
			MOVE_ST:  begin     // moving no colision 
		//------------
		// keys direction change 
				if (Y_direction_key && (Yspeed == 0 ) )begin//  while moving down
					if(X_InitialPlacement > 0 && X_InitialPlacement < 450 )
						Yspeed <= -Y_ACCEL;// drop the bird ; 
				end
				if (boom_key & !boom_key_D) //rizing edge 
					boom_D <= 1'b1 ; // initiate "special" ability 
	
       // collcting collisions 	
				if (collision) begin
					hit_reg[HitEdgeCode]<=1'b1;
					

				end
				

				if (startOfFrame )
					SM_Motion <= START_OF_FRAME_ST ; 
					
					
				
		end 
		
		//------------
			START_OF_FRAME_ST:  begin      //check if any colisin was detected 
		//------------
				
	
//		  {32'hC4444446,     
//			32'h8C444462,    
//			32'h88c44622,    
//			32'h888C6222,    
//			32'h88893222,    
//			32'h88911322,    
//			32'h89111132,    
//			32'h91111113};
			
			case (hit_reg)
				
				16'h0000:  // no collision in the frame 
					begin
							
							Yspeed <= Yspeed ;
							Xspeed <= Xspeed ;
							
					end
				//   CH       6H		3H         9H
				16'h1000:	// one of the four corners 	

				  begin
							
							Yspeed <= -(Yspeed/2) ;
							Xspeed <= -(Xspeed/2) ;
							Xposition <= Xposition + 30 ; 
							Yposition <= Yposition + 30 ;
							
					end
					16'h0040:	// one of the four corners 	

				  begin
							
							Yspeed <= -(Yspeed/2) ;
							Xspeed <= -(Xspeed/2) ;
							Xposition <= Xposition - 30 ; 
							Yposition <= Yposition + 30 ;
							
					end
					16'h0008:	// one of the four corners 	

				  begin
							
							Yspeed <= -(Yspeed/2) ;
							Xspeed <= -(Xspeed/2) ;
							Xposition <= Xposition - 30 ; 
							Yposition <= Yposition - 30 ;
							
					end
					16'h0200:	// one of the four corners 	

				  begin
							
							Yspeed <= -(Yspeed/2) ;
							Xspeed <= -(Xspeed/2) ;
							Xposition <= Xposition + 30 ; 
							Yposition <= Yposition - 30 ;
							
					end
			//   8H   ; (CH & 8H) ; (8H & 9H) ; (cH & 9H) ;(cH & 9H & 8H)   
				16'h0100,16'h1100,16'h0300,16'h1200,16'h1300:  // left side 
				  begin
							
							if (Xspeed < 0)
								Xspeed <= -(Xspeed/2) ;
								Xposition <= Xposition + 20 ; 
							
				  end
				//  4H     (CH & 4H)  (4H & 6H) (CH & 6H)  (CH & 4H & 6H)
				16'h0010,16'h1010,16'h0050, 16'h1040 , 16'h1050 : //  top side 
				  begin 
	
							if (Yspeed < 0)
								Yspeed <= -((Yspeed-1)/2) ;
								Yposition <= Yposition + 20 ;
							
				  end
				//   2H  (2H & 6H) (2H & 3H) (6H & 3H )  (6H & 2H &3H )
				16'h0004,16'h0044,16'h000C, 16'h0048 , 16'h004C: // right side 
				 begin
							
							if (Xspeed > 0)
								Xspeed <= -(Xspeed/2) ;
								Xposition <= Xposition - 20 ;
							
			    end
				//   1H  (1H & 9H) (1H & 3H) (3H & 9H ) (3H & 1H & 9H )
				16'h0002,16'h0202,16'h000A, ,16'h0028 ,16'h002A: // bottom side 
				  begin
							
							if (Yspeed > 0)
								Yspeed <= -((Yspeed+1)/2) ;
								Yposition <= Yposition - 20 ;
							
				  end
				  
				 //complex corner
				 default: 
				  begin
							
							Yspeed <= -(Yspeed/2) ;
							Xspeed <= -(Xspeed/2) ;
							
					end				 

			endcase
					
				hit_reg <= 16'h0000;  //clear for next time 
								
				SM_Motion <= POSITION_CHANGE_ST ; 
			end 

		//------------------------
			POSITION_CHANGE_ST : begin  // position interpolate 
		//------------------------
		
		
				if(boom_D) begin
					counter <= counter + 1 ;
					
					if(counter == 20)begin
						Yposition <= y_FRAME_BOTTOM + 32 ;
					end
					
					else begin
					Xposition <= Xposition ; 
					Yposition <= Yposition ;
					end
					
				end
	
				else begin
					Xposition <= Xposition + Xspeed ; 
					Yposition <= Yposition + Yspeed ;
			 
					// accelerate 
				
					if (!dropped_flag)begin
						if (Y_direction_key && Yspeed < MAX_Y_SPEED ) //  limit the speed while going down 
							Yspeed <= Yspeed - Y_ACCEL ; // deAccelerate : slow the speed down every clock tick
					end 
					
					else begin
						if (Yspeed < MAX_Y_SPEED ) //  limit the speed while going down 
							Yspeed <= Yspeed - Y_ACCEL ; // deAccelerate : slow the speed down every clock tick
					end
				
		
//					if ((Yspeed < MAX_Y_speed)&&(Yspeed >0 ))	
//						Yspeed <= Yspeed - Y_ACCEL ; // deAccelerate : slow the speed down every clock tick 
//		
//					else if ((Yspeed > (-MAX_Y_speed))&&(Yspeed < 0 ))
//						Yspeed <= Yspeed + Y_ACCEL ; // deAccelerate : slow the speed down every clock tick
				end
				
					
				SM_Motion <= POSITION_LIMITS_ST ; 
			end
		
		//------------------------
			POSITION_LIMITS_ST : begin  //check if still inside the frame 
		//------------------------
		if (Xposition < x_FRAME_LEFT)begin 
						Xposition <= x_FRAME_LEFT ; 
						bird_died_D <= 1'b1 ;
		end
		if ((Xposition > x_FRAME_RIGHT) & !dropped_flag )begin
						Xposition <= x_FRAME_LEFT ;
						bird_died_D <= 1'b1 ;
		end
		if ((Xposition > x_FRAME_RIGHT) & dropped_flag )begin
						Xposition <= x_FRAME_RIGHT ;
						bird_died_D <= 1'b1 ;
		end
		if (Yposition < y_FRAME_TOP)begin
						Yposition <= y_FRAME_TOP ;
						bird_died_D <= 1'b1 ;
		end
		if (Yposition > y_FRAME_BOTTOM)begin 
						Yposition <= y_FRAME_BOTTOM ; 
						bird_died_D <= 1'b1 ;
		end

				SM_Motion <= MOVE_ST ; 
			
			end
		
		endcase  // case 

		
	end 

end // end fsm_sync


//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX = Xposition / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = Yposition / FIXED_POINT_MULTIPLIER ; 
assign   dropped = dropped_flag ; // return if the bird is dropped
assign 	bird_died = bird_died_D;
assign	boom = boom_D ;
	

endmodule	
//---------------
 
