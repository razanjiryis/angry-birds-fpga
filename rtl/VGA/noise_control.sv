

module noise_control
	(
	input  logic clk, // 50 MHz clock 
	input  logic resetN, 
	input  logic bird_collision,
	input	 logic collision_in,
	input  logic bird_died,
	input	 logic bird_died_2,
	input  logic win,
	input  logic lose,
	input  logic one_sec,
	
	output logic enable,
	output logic [3:0] notes	  //  output to the green lamp ' 
   );	
		


	enum logic [4:0] {IDLE_ST, N_A, N_B , N_C , N_D , N_E , N_F , N_G , N_H , N_I} SM_notes; // state machine
	
logic collision;
	
always_ff @(posedge clk or negedge resetN) // State machine logic //
   begin
	   
   if ( !resetN ) begin // Asynchronic reset, initialize the state machine 
		SM_notes <= IDLE_ST;
//collision <= 0;
		
	end // asynch
	else begin 				   // Synchronic logic of the state machine; once every clock 
		
		
		
		case ( SM_notes )
				
						//Note: the implementation of the red Yellow state is already given you as an example

		//          ============		
						IDLE_ST: begin
		//          ============		 
						
						enable <= 0;
						notes <= 0;

							if (bird_collision)
								SM_notes <= N_A;
							else if (collision_in)
								SM_notes <= N_C;
							else if(bird_died)
								SM_notes <= N_D;
							else if(bird_died_2)
								SM_notes <= N_E;
							else if(win)
								SM_notes <= N_F;
							else if(win)
								SM_notes <= N_I;
							
							else
								SM_notes <= IDLE_ST;
							
						
					

						end // IDLE_ST				
		
		//          ============		
						N_A: begin
		//          ============		
							
						enable <= 1;
						notes <= 0;
						if (one_sec)
							SM_notes <= N_B;
						else
							SM_notes <= N_A;
					
						
							
						end // N_A
						
		//          ============		
						N_B: begin
		//          ============		
						enable <= 1;
						notes <= 3;
						if (one_sec)
							SM_notes <= N_C;
						else
							SM_notes <= N_B;
					 

						end // N_B

						
		//          ============		
						N_C: begin
		//          ============		
						enable <= 1;
						notes <= 0;
						if (one_sec)
							SM_notes <= N_D;
						else
							SM_notes <= N_C;
					 

						end // s_green
						
		
		//          ============		
						N_D: begin
		//          ============		 
						enable <= 1;
						notes <= 4;
						if (one_sec)
							SM_notes <= IDLE_ST;
						else
							SM_notes <= N_D;
					 

						end // N_D

		//          ============		
						N_E: begin
		//          ============		 
						  	
						enable <= 1;
						notes <= 12;
						if (one_sec)
							SM_notes <= IDLE_ST;
						else
							SM_notes <= N_E;
					 

						end // N_E

		//          ============		
						N_F: begin
		//          ============		 
					 	
						enable <= 1;
						notes <= 10;
						if (one_sec)
							SM_notes <= IDLE_ST;
						else
							SM_notes <= N_F;
					 

						end // N_F		
		
		//          ============		
						N_G: begin
		//          ============		 
						enable <= 1;
						notes <= 9;
						if (one_sec)
							SM_notes <= N_H;
						else
							SM_notes <= N_G;

						end // N_G		
						
		//          ============		
						N_H: begin
		//          ============		 
						enable <= 1;
						notes <= 11;
						if (one_sec)
							SM_notes <= N_I;
						else
							SM_notes <= N_H;

						end // N_G		
						
						
		//          ============		
						N_I: begin
		//          ============		 
						enable <= 1;
						notes <= 7;
						if (one_sec)
							SM_notes <= IDLE_ST;
						else
							SM_notes <= N_I;

						end // N_G		
		
		
		
		
		//  		  =========		
					  default : begin   
		//          =======			
								SM_notes <= IDLE_ST;  //next state 
						end // default
		  		
	endcase
	end // if reset 
	
	 
		
			

end // always_ff state machine ///////////////////////////////

			 
						 
endmodule 