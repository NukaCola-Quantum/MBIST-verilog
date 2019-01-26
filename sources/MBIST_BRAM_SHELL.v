`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: <-blank->
// Engineer: Yang Song
// 
// Create Date:		10:21:31 01/03/2014 
// Design Name:		MBIST_BRAM_SHELL
// Module Name:		MBIST_BRAM_SHELL
// Project Name: 	<-blank->
// Target Devices:	[VirtexII-FG256]
// Tool versions:  ISE 10.1(x64) QuestaSim 10.x(x64)
// Description: 
// A shell for FW-MBIST, it assembles BIST conroller and comparators. Also could
// include UUTs( e.g. BRAMs on FPGA) or not, it's up to demand. Use writing first
// for write mode of BRAM. Auto-run memory testing algorithms on sort.
// 
// Dependencies: MBIST_CONTROLLER.v, MBIST_comparator_WF.v
//
// Revision:
// Revision 1.00 - Behavioral Simulation Pass for three UUTs. Only use Checkerboard. 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module MBIST_BRAM_SHELL (RESET_L, TEST_H, TCLK, ALG_SEL, FAIL, DONE);
	
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
		
	wire [UUTN:1] c_fail;
	wire [UUTN:1] c_done;
	wire [ADA:0] c_addra;
	wire [DAA:0] c_dia;
	wire [DAA:0] c_doa [UUTN:1];
	wire c_wea;
	wire [UUTN:1] c_ena;
	wire c_rrsa;
	wire c_alg_end;
	wire c_capture;
	wire c_check;
	wire c_check_ce;
	
	// Install BIST controller
	MBIST_controller #(
		.ALGNUM(ASNET),
		.ADDRA_W(ADA),
		.ADDRB_W(ADB),
		.DA_W(DAA),
		.DB_W(DAB),
		.ENUM(UUTN))
	CONTROLLER (
		.test_h(TEST_H),
		.rst_l(RESET_L),
		.bist_clk(TCLK),
		.tst_algsel(ALG_SEL),
		.inter_fail(c_fail),
		.inter_done(c_done),
		.fail_h(FAIL),
		.alg_end(c_alg_end),
		.tst_done(DONE),
		.tst_capture(c_capture),
		.tst_check_ce(c_check_ce),
		.tst_WEA(c_wea),
		.tst_WEB(),
		.tst_ENA(c_ena),
		.tst_ENB(),
		.tst_RRSA(c_rrsa),
		.tst_RRSB(),
		.tst_ADDRA(c_addra),
		.tst_ADDRB(),
		.tst_DIA(c_dia),
		.tst_DIB()
	);
	
	// Install a clockgating for comparator's check-clk. It also coould be replaced by DCM or more complicate function.
	// BUFGCE: Global Clock Buffer with Clock Enable (active high)
    //         Virtex-II/II-Pro/4/5, Spartan-3/3E/3A
    // Xilinx HDL Language Template, version 10.1.2

   BUFGCE BUFGCE_inst (
      .O(c_check),   // Clock buffer output
      .CE(c_check_ce), // Clock enable input
      .I(TCLK)    // Clock buffer input
   );

   // End of BUFGCE_inst instantiation	
	
	// Generate UUT blocks and corresponding comparators.
	genvar i;
	generate
	
	for (i=1;i<=UUTN;i=i+1) begin: BRAM_COMP
	
   // RAMB16_S36: Virtex-II/II-Pro, Spartan-3/3E 512 x 32 + 4 Parity bits Single-Port RAM
   // Xilinx HDL Language Template, version 10.1.2

   RAMB16_S36 #(
      .INIT(36'h000000000),  // Initial values of RAM registers
      .SRVAL(36'h000000000), // Output values upon SSR assertion
      .WRITE_MODE("WRITE_FIRST"), // WRITE_FIRST, READ_FIRST or NO_CHANGE

      // The following INIT_xx declarations specify the initial contents of the RAM
      // Address 0 to 127
      .INIT_00(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_01(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_02(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_03(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_04(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_05(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_06(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_07(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_08(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_09(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_0A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_0B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_0C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_0D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_0E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_0F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      // Address 128 to 255
      .INIT_10(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_11(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_12(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_13(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_14(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_15(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_16(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_17(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_18(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_19(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_1A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_1B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_1C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_1D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_1E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_1F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      // Address 256 to 383
      .INIT_20(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_21(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_22(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_23(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_24(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_25(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_26(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_27(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_28(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_29(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_2A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_2B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_2C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_2D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_2E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_2F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      // Address 384 to 511
      .INIT_30(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_31(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_32(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_33(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_34(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_35(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_36(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_37(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_38(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_39(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_3A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_3B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_3C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_3D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_3E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
      .INIT_3F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),

      // The next set of INITP_xx are for the parity bits
      // Address 0 to 127
      .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
      // Address 128 to 255
      .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
      // Address 256 to 383
      .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
      // Address 384 to 511
      .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000)
   ) RAMB16_S36_inst (
      .DO(c_doa[i][31:0]),      // 32-bit Data Output
      .DOP(c_doa[i][35:32]),    // 4-bit parity Output
      .ADDR(c_addra),  // 9-bit Address Input
      .CLK(TCLK),    // Clock
      .DI(c_dia[31:0]),      // 32-bit Data Input
      .DIP(c_dia[35:32]),    // 4-bit parity Input
      .EN(c_ena[i]),      // RAM Enable Input
      .SSR(c_rrsa),    // Synchronous Set/Reset Input
      .WE(c_wea)       // Write Enable Input
   );

   // End of RAMB16_S36_inst instantiation
	
	MBIST_comparator_write_first #(.DW(DAA))
		COMPARATOR (
			.reset(c_rrsa),
			.comp_en(c_ena[i]),
			.comp_clk(TCLK), 
			.check(c_check), 
			.capture(c_capture), 
			.comp_alg_end(c_alg_end), 
			.data_in(c_dia), 
			.data_out(c_doa[i]), 
			.fail(c_fail[i]), 
			.done(c_done[i])
	);
	
	end
	endgenerate

endmodule