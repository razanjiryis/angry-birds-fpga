module noiseController
	(
	input logic clk, // 50 MHz clock 
	input logic resetN, 
//	input logic switchN, // pedestrian switch to change the light 
	input  logic hit,
	input  logic smiley_hit,
	input  logic one_sec,
	
	output logic enable,
	output logic [3:0] notes	  //  output to the green lamp ' 
   );	
		


	enum logic [3:0] {IDLE_ST, N_A, N_B , N_C , N_D , N_E , N_F , N_G } SM_notes; // state machine
	
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
						collision <= 0;
						notes <= 0;
							if ( hit || smiley_hit)
									collision <= 1;
									
							if (collision)
								SM_notes <= N_A;
							else
								SM_notes <= IDLE_ST;
							
						
					

						end // IDLE_ST				
		
		//          ============		
						N_A: begin
		//          ============		
							
						collision <= 0;
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
						collision <= 0;
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
						collision <= 0;
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
						collision <= 0;
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
						  	
						collision <= 0;
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
					 	
						collision <= 0;
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
							collision <= 0;
						enable <= 1;
						notes <= 9;
						if (one_sec)
							SM_notes <= IDLE_ST;
						else
							SM_notes <= N_G;

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