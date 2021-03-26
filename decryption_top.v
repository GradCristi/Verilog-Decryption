`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:12:00 11/23/2020 
// Design Name: 
// Module Name:    demux 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module decryption_top#(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16,
			parameter MST_DWIDTH = 32,
			parameter SYS_DWIDTH = 8
		)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		// Input interface
		input [MST_DWIDTH -1 : 0] data_i,
		input 						  valid_i,
		output reg busy,
		
		//output interface
		output [SYS_DWIDTH - 1 : 0] data_o,
		output						 valid_o,
		
		// Register access interface
		input[addr_witdth - 1:0] addr,
		input read,
		input write,
		input [reg_width - 1 : 0] wdata,
		output[reg_width - 1 : 0] rdata,
		output done,
		output error
		
    );
	
		wire[15:0] select;
		wire[15:0] caesar_key;
		wire[15:0] scytale_key;
		wire[15:0] zigzag_key;
		wire[7:0] data0_o_dmx;
		wire valid0_o_dmx;
		wire[7:0] data1_o_dmx;
		wire valid1_o_dmx;
		wire[7:0] data2_o_dmx;
		wire valid2_o_dmx;
		wire[7:0] data_o_caesar;
		wire valid_o_caesar;
		wire[7:0] data_o_scytale;
		wire valid_o_scytale;
		wire[7:0] data_o_zigzag;
		wire valid_o_zigzag;
		wire busy_caesar;
		wire busy_scytale;
		wire busy_zigzag;

	//instantiem toate modulele cu variabilele lor.  iese in evidenta: semnalul busy este semnal de iesire prentru 3 module diferite 

	
	decryption_regfile regi(clk_sys, rst_n, addr, read, write, wdata, rdata, done, error, select, caesar_key, scytale_key, zigzag_key);
	demux dmux(clk_sys, clk_mst, rst_n, select[1:0], data_i, valid_i, data0_o_dmx, valid0_o_dmx, data1_o_dmx, valid1_o_dmx, data2_o_dmx, valid2_o_dmx);
	caesar_decryption caesar(clk_sys, rst_n, data0_o_dmx, valid0_o_dmx, caesar_key, busy_caesar, data_o_caesar, valid_o_caesar);
	scytale_decryption scy(clk_sys, rst_n, data1_o_dmx, valid1_o_dmx, scytale_key[15:8], scytale_key[7:0], data_o_scytale, valid_o_scytale, busy_scytale);
	zigzag_decryption zig(clk_sys, rst_n, data2_o_dmx, valid2_o_dmx, zigzag_key[7:0], busy_zigzag, data_o_zigzag, valid_o_zigzag);
	mux mx(clk_sys, rst_n, select[1:0], data_o, valid_o, data_o_caesar, valid_o_caesar, data_o_scytale, valid_o_scytale, data_o_zigzag, valid_o_zigzag);


	always @(posedge clk_sys) begin
		if(busy_caesar==1 || busy_scytale==1 || busy_zigzag==1)
			busy<=1;
		else busy<=0;
	end

	

endmodule
