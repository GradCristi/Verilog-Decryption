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

module demux #(
		parameter MST_DWIDTH = 32,
		parameter SYS_DWIDTH = 8
	)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Input interface
		input [MST_DWIDTH -1  : 0]	 data_i,
		input 						 	 valid_i,
		
		//output interfaces
		output reg [SYS_DWIDTH - 1 : 0] 	data0_o,
		output reg     						valid0_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data1_o,
		output reg     						valid1_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data2_o,
		output reg     						valid2_o
    );
	
// what we have to do is receive data in blocks of 4 when the clock master is up, and 
//then we must send it to the decypering block that the select pin has indicated 
	reg[MST_DWIDTH -1  : 0]	 aux;				//auxiliar pentru retinerea celor 4 litere
	reg intrare;
	reg iesire;
	reg[7:0] state;


	initial begin				//initializare variabile
		intrare=1;
		iesire=0;
		state=0;
		valid0_o<=0;
		valid1_o<=0;
		valid2_o<=0;
		data0_o<=0;
		data1_o<=0;
		data2_o<=0;
	end
	always @(posedge clk_sys) begin			//dupa ceasul sistemului
		case(state)
			0: begin							//starea 0
				if(valid_i==1) begin
					if(intrare==1)begin			//daca trebuie sa primesc informatii
						state<=1;				//trec la starea 1, nu vreau sa fac nimic in 0
					end
				end
				if(iesire==1) begin				//daca vrem sa scriem
					if(select==0) begin			//in functie de ce avem pe select
						data0_o<=aux[8*2 +: 8];		//scriem la adresa respectiva
						valid0_o<=1;			//punem output valid pe 1
						state<=1;				//trecem la starea urmatoare
					end
					else
					if(select==1) begin
						data1_o<=aux[8*2 +: 8];
						valid1_o<=1;
						state<=1;
					end
					else
					if(select==2) begin
						data2_o<=aux[8*2 +: 8];
						valid2_o<=1;
						state<=1;
					end
				end
			end

			1: begin
				if(valid_i==1) begin				//din nou, la aceasta etapa nu vreau sa fac nimic
					if(intrare==1)begin
						state<=2;					//trec la urmatoarea
					end
				end
				if(iesire==1) begin					//same as last time
					if(select==0) begin
						data0_o<=aux[8*1 +: 8];
						valid0_o<=1;
						state<=2;
					end
					else
					if(select==1) begin
						data1_o<=aux[8*1 +: 8];
						valid1_o<=1;
						state<=2;
					end
					else
					if(select==2) begin
						data2_o<=aux[8*1 +: 8];
						valid2_o<=1;
						state<=2;
					end
				end	
			end

			2: begin
				if(valid_i==1) begin
					if(intrare==1)begin
						aux<=data_i;				//scriu datele in auxiliar
						state<=3;					//trimitem in starea 3
						intrare<=0;					//pregatesc pentru modulul de scriere
						iesire<=1;					//pe care il voi activa pe cc urm
					end
				end
				if(iesire==1) begin
						
					if(select==0) begin
						data0_o<=aux[8*0 +: 8];
						valid0_o<=1;
						state<=3;
						if(valid_i==0) begin			//trebuie sa tin cont daca mai urmeaza
							intrare<=1;					//date pe valid in sau nu
							iesire<=0;
						end
						else
						if(valid_i==1) begin		//daca da, continui acest proces, daca nu
							intrare<=0;				//ma intorc la situatia in care voiam sa scriu
							iesire<=1;		
							aux<=data_i;			//pe ciclul de ceas urmator
						end
					end
					else
					if(select==1) begin
						data1_o<=aux[8*0 +: 8];
						valid1_o<=1;
						state<=3;
						if(valid_i==0) begin
							intrare<=1;
							iesire<=0;
						end
						else
						if(valid_i==1) begin
							intrare<=0;
							iesire<=1;
							aux<=data_i;
						end
					end
					else
					if(select==2) begin
						data2_o<=aux[8*0 +: 8];
						valid2_o<=1;
						state<=3;
						if(valid_i==0) begin
							intrare<=1;
							iesire<=0;
						end
						else
						if(valid_i==1) begin
							intrare<=0;
							iesire<=1;
							aux<=data_i;
						end
					end
				end		
			end

			3:begin
				
					if(intrare==1)begin
						state<=0;					//trec in starea 0
						valid0_o<=0;				//resetez semnalele
						data0_o<=0;					//aceasta etapa e tranzitionara
						valid1_o<=0;				// le trec pe 0 pentru ca inainte
						data1_o<=0;					//transmiteam aceeasi informatie 
						valid2_o<=0;				//pana la urm decriptare(makes sense)
						data2_o<=0;
					end
				if(iesire==1) begin
					if(select==0) begin
						data0_o<=aux[8*3 +: 8];		
						valid0_o<=1;				
						state<=0;				
					end
					else
					if(select==1) begin
						data1_o<=aux[8*3 +: 8];		
						valid1_o<=1;				
						state<=0;				
					end
					else
					if(select==2) begin
						data2_o<=aux[8*3 +: 8];		
						valid2_o<=1;				
						state<=0;			
					end
				end	

			end
		endcase



	end

endmodule