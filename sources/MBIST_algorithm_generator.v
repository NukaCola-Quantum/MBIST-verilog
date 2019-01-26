`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: <-blank->
// Engineer: Yang Song
// 
// Create Date:    13:53:47 12/30/2013 
// Design Name:    MBIST_algorithm_generator
// Module Name:    MBIST_algorithm_generator 
// Project Name:   <-blank->
// Target Devices: [VirtexII-FG256]
// Tool versions:  ISE 10.1(x64) QuestaSim 10.x(x64)
// Description: 
// MBIST algorithms generation core is implemented by a 8 bits width FSM. It's
// simple to contain more algorithms and states by enlarge FSM width.
// Checkerboard and March 2 have existed. Please pay attension to keep the
// state machine clousre.
//
// Dependencies: None
//
// Revision:
// Revision 2.00 - Add March 2 algorithm 2/14/2014
// Revision 1.00 - Behavioral Simulation Pass for three UUTs. Only use Checkerboard.
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module MBIST_algorithm_generator (
	as_algsel, as_rst, as_en, as_clk, as_done, as_cap, as_check_ce, as_ADDRA, as_ADDRB, as_DIA, as_DIB, as_WEA, as_WEB
	);
	
	parameter as_ALGNUM = 1;												// Preset algorithm selection bus width, LSB is 0.
	parameter as_ADDRA_W = 1;												// Preset address width for port A, LSB is 0.
	parameter as_ADDRB_W = 1;												// Preset address width for port B, LSB is 0.
	parameter as_DA_W = 1;													// Preset data width for port A, LSB is 0.
	parameter as_DB_W = 1;													// Preset data width for port B, LSB is 0.
	
	input [as_ALGNUM:0] as_algsel;										// Algorithm selection bus, bit wise mapping, active high.
	input as_rst;																// AG asynchronous reset signal, active high.
	input as_en;																// AG enable signal, active high.
	input as_clk;																// BIST Clock
	output as_cap;																// Input data capture enable to comparator, active high.	
	output as_done;															// Done signal output
	output as_ADDRA;															// Address output to port A
	output as_ADDRB;															// Address output to port B
	output as_DIA;																// Data output to port A
	output as_DIB;																// Data output to port B
	output as_WEA;																// Write enable control for port A
	output as_WEB;																// Write enable control for port B
	output as_check_ce;														// Output data check enable for comparator, active high.
	
	reg as_WEA;
	reg as_WEB;
	reg [as_ADDRA_W:0] as_ADDRA;
	reg [as_ADDRB_W:0] as_ADDRB;
	reg [as_DA_W:0] as_DIA;
	reg [as_DB_W:0] as_DIB;
	reg [as_ALGNUM:0] algsel;
	reg as_state_go;
	reg [7:0] as_state;
	reg [1:0] alg_cnt;
	reg alg_done;
	reg as_done;
	reg as_cap;
	reg as_check_ce;
	reg alg_cap;
	reg alg_begin;
	reg [1:0] alg_march2_cnt;
	
	// AG asynchronous reset
	always @(as_rst) begin
		if (as_rst) begin
		assign as_ADDRA = 0;
		assign as_ADDRB = 0;
		assign as_DIA = 0;
		assign as_DIB = 0;
		assign as_WEA = 0;
		assign as_WEB = 0;
		assign algsel = 0;
		assign as_state_go = 0;
		assign as_state = 0;
		assign alg_cnt = 0;
		assign alg_done = 0;
		assign as_done = 0;
		assign as_cap = 0;
		assign as_check_ce = 0;
		assign alg_cap = 0;
		assign alg_begin = 0;
		assign alg_march2_cnt = 0;
		end
		else begin
		deassign as_ADDRA;
		deassign as_ADDRB;
		deassign as_DIA;
		deassign as_DIB;
		deassign as_WEA;
		deassign as_WEB;
		deassign algsel;
		deassign as_state_go;
		deassign as_state;
		deassign alg_cnt;
		deassign alg_done;
		deassign as_done;
		deassign as_cap;
		deassign as_check_ce;
		deassign alg_cap;
		deassign alg_begin;
		deassign alg_march2_cnt;
		end
	end
	
	// AG FSM control producer
	always @(posedge as_clk) begin
	if (as_en) begin	
		if (alg_cap) begin
			algsel <= as_algsel;
			alg_begin <= 1;
			end
		else begin
			if (alg_done) begin
				case (alg_cnt)
					2'b00: as_state <= 8'b0000_0000;				// Test algorithm 1 done
					2'b01: as_state <= 8'b0000_0101;				// Test algorithm 2 done
					2'b10: as_state <= 8'b0000_1100;				// Test algorithm 3 done
					2'b11: as_state <= 8'b0000_1111;				// Test algorithm 4 done
				endcase
				algsel <= algsel<<1;
			end		
			else if (as_state_go) begin
					  as_state <= as_state + 1;
				  end
		end		
	end	
	end
	
	// AG FSM Procedure, 8 bits width state machine
	always @(negedge as_clk) begin
		if (as_en) begin
		if (alg_begin) begin
			alg_cap <= 0;
			if (algsel[as_ALGNUM]) begin
				case (as_state)
					8'b0000_0000: begin: initial_checker_board								// Initial Checkerboard Algorithm
									  alg_done <= 0;
									  as_WEA <= 1;
									  as_ADDRA <= 0;
									  as_DIA <= 36'hAAAAAAAAA;
									  as_state_go <= 1;
									  as_check_ce <= 1;
									  as_cap <= 1;
									  end
					8'b0000_0001: begin: up_write_checker_board								// Checkerboard Step 1
									  if (~as_ADDRA) begin									  
									  as_state_go <= 0;									  
									  end
									  else begin
									  as_state_go <= 1;
									  as_WEA <= 0;
									  end									  
									  as_DIA <= ~as_DIA;
									  as_ADDRA <= as_ADDRA + 1'b1;
									  end
					8'b0000_0010: begin: up_read_checker_board								// Checkerboard Step 2
									  if (~as_ADDRA) begin
									  as_state_go <= 0;
									  as_DIA <= ~as_DIA;									  
									  end
									  else begin
									  as_WEA <= 1;
									  as_DIA <= 36'h555555555;
									  as_state_go <= 1;
									  end									  									  
									  as_ADDRA <= as_ADDRA + 1'b1;
									  end
					8'b0000_0011: begin: up_write_inverse_checker_board					// Checkerboard Step 3
									  if (~as_ADDRA) begin
									  as_state_go <= 0;								  
									  end
									  else begin
									  as_state_go <= 1;
									  as_WEA <= 0;
									  end
									  as_DIA <= ~as_DIA;
									  as_ADDRA <= as_ADDRA + 1'b1;
									  end
					8'b0000_0100: begin: up_read_inverse_checker_board						// Checkerboard Step 4
									  if (~as_ADDRA) begin
									  as_state_go <= 0;
									  as_DIA <= ~as_DIA;
									  as_ADDRA <= as_ADDRA + 1'b1;
									  end
									  else begin									  
									  alg_cnt <= alg_cnt + 1;
									  alg_done <= 1;
									  as_check_ce <= 0;
									  as_cap <= 0;
									  end
									  end
									  
					8'b0000_0101: begin: initial_march_2									// Initial March 2
									  alg_done <= 0;
									  as_WEA <= 1;
									  as_ADDRA <= 0;
									  as_DIA <= 36'h000000000;
									  as_state_go <= 1;
									  as_check_ce <= 1;
									  as_cap <= 1;
									  end
					8'b0000_0110: begin: march_2_step_1									// March 2 Step 1 up - Write 0
									  if (~as_ADDRA) begin									  
									  as_state_go <= 0;									  
									  end
									  else begin
									  as_state_go <= 1;
									  as_WEA <= 0;									  
									  alg_march2_cnt <= 2'b00;
									  end								  
									  as_ADDRA <= as_ADDRA + 1'b1;
									  end
					8'b0000_0111: begin: march_2_step_2									// March 2 Step 2 up - Read 0, Write 1, Read 1									  
									  if (~as_ADDRA) begin									  
											as_state_go <= 0;									  
											end
									  else if (alg_march2_cnt == 2'b10) begin
											as_state_go <= 1;									  
											end
									  case (alg_march2_cnt)
											2'b00: begin
														as_WEA <= 1;
														as_DIA <= 36'hfffffffff;
													 end
											2'b01: begin
														as_WEA <= 0;														
													 end
											2'b10: begin
														as_ADDRA <= as_ADDRA + 1'b1;
														if (~as_ADDRA) as_DIA <= 36'h000000000;
													 end
									  endcase
									  if (alg_march2_cnt == 2'b10)
									  alg_march2_cnt <= 0;
									  else
									  alg_march2_cnt <= alg_march2_cnt + 1'b1;
									  end
					8'b0000_1000: begin: march_2_step_3									// March 2 Step 3 up - Read 1, Write 0, Read 0
									  if (~as_ADDRA) begin									  
											as_state_go <= 0;									  
											end
									  else if (alg_march2_cnt == 2'b10) begin
											as_state_go <= 1;									  
											end
									  case (alg_march2_cnt)
											2'b00: begin
														as_WEA <= 1;
														as_DIA <= 36'h000000000;
													 end
											2'b01: begin
														as_WEA <= 0;														
													 end
											2'b10: begin
														if (~as_ADDRA) begin
															as_DIA <= 36'hfffffffff;
															as_ADDRA <= as_ADDRA + 1'b1;
														end
													 end
									  endcase
									  if (alg_march2_cnt == 2'b10)
									  alg_march2_cnt <= 0;
									  else
									  alg_march2_cnt <= alg_march2_cnt + 1'b1;
									  end
					8'b0000_1001: begin: march_2_step_4									// March 2 Step 4 down - Read 0, Write 1, Read 1
									  if (as_ADDRA) begin									  
											as_state_go <= 0;									  
											end
									  else if (alg_march2_cnt == 2'b10) begin
											as_state_go <= 1;									  
											end
									  case (alg_march2_cnt)
											2'b00: begin
														as_WEA <= 1;
														as_DIA <= 36'hfffffffff;
													 end
											2'b01: begin
														as_WEA <= 0;														
													 end
											2'b10: begin
														as_ADDRA <= as_ADDRA - 1'b1;
														if (as_ADDRA) as_DIA <= 36'h000000000;
													 end
									  endcase
									  if (alg_march2_cnt == 2'b10)
									  alg_march2_cnt <= 0;
									  else
									  alg_march2_cnt <= alg_march2_cnt + 1'b1;
									  end									  
					8'b0000_1010: begin: march_2_step_5									// March 2 Step 5 down - Read 1, Write 0, Read 0
									  if (as_ADDRA) begin									  
											as_state_go <= 0;									  
											end
									  else if (alg_march2_cnt == 2'b10) begin
											as_state_go <= 1;									  
											end
									  case (alg_march2_cnt)
											2'b00: begin
														as_WEA <= 1;
														as_DIA <= 36'h000000000;
													 end
											2'b01: begin
														as_WEA <= 0;														
													 end
											2'b10: begin
														as_ADDRA <= as_ADDRA - 1'b1;
														if (as_ADDRA) as_DIA <= 36'hfffffffff;
													 end
									  endcase
									  if (alg_march2_cnt == 2'b10)
									  alg_march2_cnt <= 0;
									  else
									  alg_march2_cnt <= alg_march2_cnt + 1'b1;
									  end									  
					8'b0000_1011: begin: march_2_step_6									// March 2 Step 6 down - Read 0
									  if (as_ADDRA) begin
									  as_state_go <= 0;									  
									  as_ADDRA <= as_ADDRA - 1'b1;
									  end
									  else begin									  
									  alg_cnt <= alg_cnt + 1;
									  alg_done <= 1;
									  as_check_ce <= 0;
									  as_cap <= 0;
									  end 
									  end
									  
					8'b0000_1100: begin: algorithm_2_step_2									// Algorithm 2 Step 2
									   
									  end
					8'b0000_1101: begin: algorithm_2_step_3									// Algorithm 2 Step 3
									   
									  end
					8'b0000_1110: begin: algorithm_2_step_4									// Algorithm 2 Step 4
									   
									  end
									  
					8'b0000_1111: begin: initial_algorithm_3									// Initial Algorithm 3
									   
									  end
					8'b0001_0000: begin: algorithm_3_step_1									// Algorithm 3 Step 1
									   
									  end
					8'b0001_0001: begin: algorithm_3_step_2									// Algorithm 3 Step 2
									  
									  end
					8'b0001_0010: begin: algorithm_3_step_3									// Algorithm 3 Step 3
									   
									  end
					8'b0001_0011: begin: algorithm_3_step_4									// Algorithm 3 Step 4
									   
									  end
				endcase
			end
			else begin
				  if (alg_cnt == 2'b11) begin
						as_done <= 1;
						end
				  else begin
						alg_cnt <= alg_cnt + 1;
						alg_done <= 1;
						end
			end
		end
		else begin
			  alg_cap <= 1;
		end
		end
	end
			
endmodule
