`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:53:30 11/26/2020 
// Design Name: 
// Module Name:    mux 
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
module mux #(
		parameter D_WIDTH = 8
	)(
		// Clock and reset interface
		input clk,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Output interface
		output reg[D_WIDTH - 1 : 0] data_o,
		output reg					valid_o,
				
		//input interfaces
		input [D_WIDTH - 1 : 0] 	data0_i,
		input   					valid0_i,
		
		input [D_WIDTH - 1 : 0] 	data1_i,
		input   					valid1_i,
		
		input [D_WIDTH - 1 : 0] 	data2_i,
		input     					valid2_i
    );

	//planul este ca in functie de ce select este activ, daca semnalul de valid in este prezent
	//noi sa transmitem acel semnal catre exterior
	
	always@(posedge clk) begin					//pe frontul crescator 
		case(select)
			0: begin							//cazul 0
				if(valid0_i==1) begin			//daca inputul este activ
					data_o<=data0_i;			//outputul ia valoarea intrarii 1
					valid_o<=1;					//iesirea este valida
				end
				else valid_o<=0;				//altfel iesirea nu este valida
			end
		
			1: begin							//select 1, scytale
				if(valid1_i==1) begin
					data_o<=data1_i;
					valid_o<=1;
				end
				else valid_o<=0;
			end
			
			2: begin							//select 2, zigzag
				if(valid2_i==1) begin
					data_o<=data2_i;
					valid_o<=1;
				end
				else valid_o<=0;
			end
		endcase
	end

endmodule
