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
// Create Date:    15:54:30 01/14/2014 
// Design Name:    FW-MBIST
// Module Name:    MBIST_BRAM_TOP 
// Project Name:   <-blank->
// Target Devices: [VirtexII-FG256]
// Tool versions:  ISE 10.1(x64) QuestaSim 10.x(x64)
// Description: 
// The top-level of FW-MBIST
//
// Dependencies: None
//
// Revision:
// Revision 1.00 - Behavioral Simulation Pass and APR Complete 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module MBIST_BRAM_TOP (RESET_L, TEST_H, TCLK, ALG_SEL, FAIL, DONE);

	parameter SHN = 4;
	parameter ASNET = 3;												// Preset algorithm selection bus width, LSB is 0.
	parameter UUTN = 10;												// Preset UUT number, LSB is 1.
	parameter ADA = 8;												// Preset address width for port A, LSB is 0.
	parameter ADB = 8;												// Preset address width for port B, LSB is 0.
	parameter DAA = 35;												// Preset data width for port A, LSB is 0.
	parameter DAB = 35;												// Preset data width for port B, LSB is 0.
	
	input RESET_L;														// Global asynchronous reset signal, active low.
	input TEST_H;														// Test start-up enable signal, active high.
	input TCLK;															// BIST Clock
	input [ASNET:0] ALG_SEL;										// Algorithm selection bus, bit wise mapping, active high.
	output FAIL;														// Test fail identifier, active high.
	output DONE;														// Test done identifier, active high.

	wire [SHN:1] top_fail;
	wire [SHN:1] top_done;
	
	assign FAIL = |top_fail;
	assign DONE = &top_done;
	
	genvar k;
	generate
		
		for (k=1;k<=SHN;k=k+1) begin: SHELL
			MBIST_BRAM_SHELL #(
				.ASNET(ASNET),
				.UUTN(UUTN),
				.ADA(ADA),
				.ADB(ADB),
				.DAA(DAA),
				.DAB(DAB))
			MBLOCK (
				.RESET_L(RESET_L),
				.TEST_H(TEST_H),
				.TCLK(TCLK),
				.ALG_SEL(ALG_SEL),
				.FAIL(top_fail[k]),
				.DONE(top_done[k])
			);
		end	
		
	endgenerate	
	
endmodule
