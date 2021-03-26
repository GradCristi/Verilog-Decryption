`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:13:49 11/23/2020 
// Design Name: 
// Module Name:    decryption_regfile 
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

// nu am reusit de nicio culoare sa fac indentarile comentariilor sa fie pe acelasi loc si in Xilinx si in Notepad. 
//daca le pun frumos in Notepad se decaleaza pentru xilinx, si invers... :(

module decryption_regfile #(
			parameter addr_witdth = 8,            							//dimensiunea in biti a adresei
			parameter reg_width 	 = 16								//dimensiunea in biti a registrului	
		)(
			// Clock and reset interface
			input clk, 										//semnalul de ceas
			input rst_n,										//semnalul de reset negat, deci este activ pe 0;
			
			// Register access interface
			input[addr_witdth - 1:0] addr,								//adresa pe 8 biti [7:0]
			input read,										//semnal de read( cum ar veni oe)
			input write,										//semnal de write( we)
			input [reg_width -1 : 0] wdata,								//datele pentru scriere in registru
			output reg [reg_width -1 : 0] rdata,							//datele pentru citire din registru
			output reg done,									//semnalul de terminare
			output reg error,									//flagul de eorare
				
			// Output wires
			output reg[reg_width - 1 : 0] select,							//bitii de select( e pe 16 biti dar se citesc doar [1:0]
			output reg[reg_width - 1 : 0] caesar_key,						//cheia de decriptare cezar
			output reg[reg_width - 1 : 0] scytale_key,						//cheia de decriptare scytale
			output reg[reg_width - 1 : 0] zigzag_key						//cheia de decriptare zigzag
    );



	always @(posedge clk) begin	
	
	
		if(addr==8'h0 || addr==8'h10 || addr==8'h12 || addr==8'h14) begin                    
			error<=0;										//s-a efectuat o operatie la o adresa permisa
		end
		else error<=1;											//operatia incercata nu s-a efectuat la o adresa permisa

		
		if(rst_n) begin											//daca reset este inactiv

			case(addr)
			
			
				8'h0: begin 									//adresa select_register
				
					select[1:0]<= write ? wdata[1:0] : select[1:0];     			//daca write este activ, scriem wdata( doar primii 2 biti pentru ca restul nu conteaza), altfel ramane selectul de dinainte
					rdata<= read ? select : 0;						//daca read este activ, atunci citim semnalul select, altfel ramane pe 0
					
				end
				
				
				8'h10: begin									//adresa caesar_key
				
					caesar_key<= write ? wdata: caesar_key;					//daca write e activ, scriem datele in el, altfel ramane la fel
					rdata<= read ? caesar_key: 0;						//daca read e activ, citim
				
				end
				
				
				8'h12: begin									//adresa scytale_key
				
					scytale_key<= write ? wdata: scytale_key;
					rdata<= read? scytale_key: 0; 
				
				end
				
				
				8'h14: begin									//adresa zigzag_key
				
					zigzag_key<=write ? wdata: zigzag_key;
					rdata<= read? zigzag_key: 0 ;
				
				end
			endcase
			

		end else begin											//daca reset este activ
		
			select<=16'h0;
			caesar_key<=16'h0;									//resetam toate semnalele la valorile lor din tabel
			scytale_key<=16'hFFFF;
			zigzag_key<=16'h2;
			
		end
		
		if(read||write)               									//daca s-a citit sau s-a scris, afisam done=1 la urmatorul ciclu de ceas, altfel done ramane 0
			done<=1;
		else done<=0;
		
	end  //end always	
endmodule
		