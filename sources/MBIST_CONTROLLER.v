`timescale 1ns / 1ps
/*
//////////////////////////////////////////////////////////////////////////////////
//   Copyright 2013 - 2019 Yang Song
//   E-mail: googotohell@gmail.com
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
*/
//////////////////////////////////////////////////////////////////////////////////
// Company: <-blank->
// Engineer: Yang Song
// 
// Create Date:    13:53:47 12/30/2013 
// Design Name:    FW-MBIST
// Module Name:    MBIST_CONTROLLER 
// Project Name:   <-blank->
// Target Devices: [VirtexII-FG256]
// Tool versions:  ISE 10.1(x64) QuestaSim 10.x(x64)
// Description: 
// A controller implements memory BIST. Control process base on a 4 bits width FSM.
// This module also includes some sub-functional modules. For instance 
// Algorithm Generator Block, MBIST Diagnostics Block, TAP interface Block and more.
// Feel free to modify the FSM or to extend varietal sub-modules to meet the demand
// of project.
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

module MBIST_controller (
   test_h, rst_l, bist_clk, fail_h, alg_end, tst_done, tst_capture, tst_check_ce, tst_ADDRA, tst_ADDRB, tst_DIA, tst_DIB, 
	tst_WEA, tst_WEB, tst_ENA, tst_ENB, tst_RRSA, tst_RRSB, tst_algsel, inter_fail, inter_done
   );
	
	parameter ALGNUM = 3;												// Preset algorithm selection bus size, LSB is 0.
	parameter ADDRA_W = 8;												// Preset address width for port A, LSB is 0.
	parameter ADDRB_W = 8;												// Preset address width for port B, LSB is 0.
	parameter DA_W = 35;													// Preset data width for port A, LSB is 0.
	parameter DB_W = 35;													// Preset data width for port B, LSB is 0.
	parameter ENUM = 3;													// Preset UUT enable control bus, LSB is 1.
	
	input test_h;															// Test start-up enable signal, active high.
	input rst_l;															// Controller asynchronous reset signal, active low.
	input bist_clk;														// BIST Clock
	input [ALGNUM:0] tst_algsel;										// Algorithm selection bus, bit wise mapping, active high.
	input [ENUM:1] inter_fail;											// Fail ID bus, input from all of UUT's comparators.
	input [ENUM:1] inter_done;											// Done ID bus, input from all of UUT's comparators.
	output fail_h;															// Fail signal output
	output alg_end;														// Algorithm end signal output
	output tst_done;														// Done signal output
	output tst_WEA;														// Write enable control for port A
	output tst_WEB;														// Write enable control for port B
	output tst_ENA;														// Chip-sel enable control for port A
	output tst_ENB;														// Chip-sel enable control for port B
	output tst_RRSA;														// Reset control for port A
	output tst_RRSB;														// Reset control for port B
	output tst_capture;													// Input data capture enable to comparator, active high.
	output tst_check_ce;													// Output data check enable to comparator, active high.
	output [ADDRA_W:0] tst_ADDRA;										// Address output to port A
	output [ADDRB_W:0] tst_ADDRB;										// Address output to port B
	output [DA_W:0] tst_DIA;											// Data output to port A
	output [DB_W:0] tst_DIB;											// Data output to port B	
	
	wor fail_h;
	wand tst_done;
	reg state_go;
	reg [ENUM:1] tst_ENA;
	reg [ENUM:1] tst_ENB;
	reg alg_rst_h;
	reg tst_RRSA;
	reg tst_RRSB;
	reg [3:0] t_state;
	reg [2:0] rst_cnt;
	reg i_next;
	reg i_over;
	reg i_lock;
	reg i_first;
	reg alg_start;
	reg [ENUM:1] en_shift;
	
	genvar k;
	generate
	for (k=0;k<ENUM;k=k+1) begin: FAIL_DONE 
	assign fail_h = inter_fail[k+1];
	assign tst_done = inter_done[k+1];
	end
	endgenerate
	
	// Install testing algorithm core
	MBIST_algorithm_generator #(.as_ALGNUM(ALGNUM), .as_ADDRA_W(ADDRA_W), .as_ADDRB_W(ADDRB_W), .as_DA_W(DA_W), .as_DB_W(DB_W))
		BRAM_ALG (
			.as_algsel(tst_algsel),
			.as_rst(alg_rst_h),
			.as_en(alg_start),
			.as_clk(bist_clk),
			.as_done(alg_end),
			.as_ADDRA(tst_ADDRA),
			.as_ADDRB(tst_ADDRB),
			.as_DIA(tst_DIA),
			.as_DIB(tst_DIB),
			.as_WEA(tst_WEA),
			.as_WEB(tst_WEB),
			.as_cap(tst_capture),
			.as_check_ce(tst_check_ce)
			);	
	
	// Controller asynchronous reset
	always @(rst_l) begin
		if (~rst_l) begin
		assign rst_cnt = 0;
		assign t_state = 0;
		assign state_go = 0;
		assign alg_start = 0;
		assign alg_rst_h = 1;
		assign tst_RRSA = 1;
		assign tst_RRSB = 1;		
		assign tst_ENA = 0;
		assign tst_ENB = 0;		
		assign i_next = 0;
		assign i_over = 0;
		assign i_lock = 0;
		assign i_first = 0;
		assign en_shift = 1;
		end
		else begin		
		deassign rst_cnt;
		deassign t_state;
		deassign alg_start;
		deassign state_go;		
		deassign alg_rst_h;
		deassign tst_RRSA;
		deassign tst_RRSB;
		deassign tst_ENA;
		deassign tst_ENB;	
		deassign i_next;
		deassign i_over;
		deassign i_lock;
		deassign i_first;
		deassign en_shift;
		end
	end
	
	// MBIST_C(MBIST Controller) FSM control producer
	always @(negedge bist_clk) begin			
		if (test_h) begin
			if (tst_ENA[ENUM]) begin
				i_lock <= 1;
				end
			else begin
				i_lock <= i_lock;
				end
			if (rst_cnt[2]||i_next) begin
				t_state <= 4'b0001;
				rst_cnt <= 0;
				end		
			else if (i_next == 0&&tst_done == 1) begin
						t_state <= 4'b1111;
						end
				  else if (state_go) begin
							 t_state <= t_state + 1;
							 end
						 else if (i_first) begin
								rst_cnt <= rst_cnt + 1'b1;
								end
		end
	end
	
	// MBIST_C FSM Procedure, 4 bits width state machine 
	always @(posedge bist_clk) begin
		if (test_h) begin
			case (t_state)
				4'b0000: begin: s_RESET							// MBIST_C reset state
							tst_RRSA <= 1;
							tst_RRSB <= 1;
							alg_rst_h <= 1;
							tst_ENA <= 0;
							tst_ENB <= 0;
							en_shift = 1;
							i_over <= 0;
							i_first <= 1;							
							end
							
				4'b0001: begin: s_START							// MBIST_C start-up state
							tst_RRSA <= 0;
							tst_RRSB <= 0;
							alg_rst_h <= 0;																				
							state_go <= 1;
							i_next <= 0;
							end
							
				4'b0010: begin: s_ALGBEGIN						// MBIST_C algorithm start-up state
							i_first <= 0;
							tst_ENA <= en_shift;	
							alg_start <= 1;							
							end
							
				4'b0011: begin: s_WAIT							// MBIST_C algorithm running state
							if (alg_end) begin
							state_go <= 1;
							alg_rst_h <= 1;
							alg_start <= 0;
							tst_ENA <= 0;
							end
							else begin
							state_go <= 0;
							end
							end
							
				4'b0100: begin: s_ALGEND						// MBIST_C algorithm run over state														
							en_shift = en_shift<<1;
							end
							
				4'b0101: begin: s_NEXT							// MBIST_C access the next UUT state
							if (i_lock) begin								
								i_next <= 0;
								end
							else begin								
								i_next <= 1;
								end							
							state_go <= 0;
							end
							
				4'b1000: begin: s_FAIL							// MBIST_C reserve state for diagnostic test
				
							end
							
				4'b1111: begin: s_OVER							// MBIST_C test over state
							tst_RRSA <= 0;
							tst_RRSB <= 0;
							alg_rst_h <= 0;							
							tst_ENA <= 0;
							tst_ENB <= 0;							
							i_over <= 1;
							end
							
				default: begin: s_BACK							// MBIST_C reserve state for recover from error state 
				
							end							
			endcase
		end		
	end
endmodule
