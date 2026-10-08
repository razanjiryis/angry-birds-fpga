
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_smiley,
			input	logic	drawing_request_boarders,

//---------------------#1-add input drawing request of box/number
		
			input	logic	drawing_request_number,
		

//---------------------#1-end input drawing request of box/number
//-----------------------------------------------------------------------------------------------------------------------------------------------=----------------------------
//-----------------------------------------Added for correct smiley hits and retry--------------------------------------------------------------------------------------------
			
			input logic box_hit,
			input logic wall_hit,
			input logic bird_died,
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------Added for game ended---------------------------------------------------------------------------------------------------------------
			input logic game_won,
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------



//---------------------#2-add  drawing request of hart

		//	input	logic	drawing_request_hart,

//---------------------#2-end drawing request of hart		

			
			output logic collision, // active in case of collision between two objects
			
			output logic SingleHitPulse, // critical code, generating A single pulse in a frame
		
			output logic smiley_collision, 
			output logic bird_reset, 
			output logic level_ended,
			output logic lost
			
			

//---------------------#3-add collision  smiley and hart   -------------------------------------


		//	output logic collision_Smiley_Hart // active in case of collision between Smiley and hart


//---------------------#3-end collision  smiley and hart	--------------------------------------




			


);

// drawing_request_smiley   -->  smiley
// drawing_request_boarders -->  brackets
// drawing_request_number   -->  number/box 

//assign collision = (drawing_request_smiley && drawing_request_boarders);// any collision --> comment after updating with #4 or #5 

//---------------------#4-update  collision  conditions - add collision between smiley and box/pig   ----------------------------

assign collision = ( (drawing_request_smiley && drawing_request_boarders) || (drawing_request_smiley && drawing_request_number) );

assign smiley_collision = (( collision && box_hit ) ||  ( collision && wall_hit ));


//---------------------#4-end update  collision  conditions	 - add collision between smiley and number	-------------------------

//--------------------------------######----Add bird resetting after dying----######----------------------------------------------
assign bird_reset = bird_died ;
//--------------------------------------------------------------------------------------------------------------------------------

//--------------------------------######----Add matrix resetting after level ends----######---------------------------------------
assign level_ended = game_won ;
//--------------------------------------------------------------------------------------------------------------------------------
					
						

//---------------------#5-update  collision  sconditions - add collision between smiley and hart  ---------------------------------

//assign collision = <collision_before> +( drawing_request_smiley && drawing_request_hart ); 
	


//---------------------#5-end update  collision  conditions	- add collision between smiley and hart	-----------------------------
	



//-------------------------- #6-add colision between Smiley and hart-----------------

//assign collision_Smiley_Hart = ( drawing_request_smiley && drawing_request_hart ) ;


//---------------------------#6-end colision betweenand Smiley and hart-----------------







logic flag ; // a semaphore to set the output only once per frame regardless of number of collisions 
logic collision_smiley_number; // collision between Smiley and number - is not output

assign collision_smiley_number = (drawing_request_smiley && drawing_request_number);

int counter ;
//logic lost_D ;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ;
		counter <= 0 ;
				
	end 
	else begin 
	
	//-------------------------Added to end the game------------------------------------
			
			
			if(bird_died)
				counter <= counter + 1 ;
				
			
	//----------------------------------------------------------------------------------
	
//-------------------------- #7-add colision between Smiley and number-----------------



//-------------------------- #7-end colision between Smiley and number-----------------	
		
			SingleHitPulse <= 1'b0 ; // default
			if(startOfFrame) 
				flag <= 1'b0 ; // reset for next time 
				
			//	---#7 - change the condition below to collision between Smiley and number ---------

			if ( collision_smiley_number  && (flag == 1'b0)) begin 
				flag	<= 1'b1; // to enter only once 
				SingleHitPulse <= 1'b1 ; 
			end
			

 
	end 
	
	
end

assign lost = (counter >= 3) ? 1'b1 : 1'b0 ;

endmodule
