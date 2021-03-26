`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:17:08 11/23/2020 
// Design Name: 
// Module Name:    ceasar_decryption 
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
module caesar_decryption #(
				parameter D_WIDTH = 8,					//latimea datelor
				parameter KEY_WIDTH = 16				//latimea cheii
			)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
         output reg busy,
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o
    );
	
	reg[7:0] aux;
	
	always@(*) begin
	aux=data_i-key;
	busy=0;
	end

	always@(posedge clk) begin
		if( valid_i==1) begin
			data_o<=aux;
			valid_o<=1;
		end
		else valid_o<=0;
	end

endmodule
