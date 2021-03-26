`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:12 11/27/2020 
// Design Name: 
// Module Name:    scytale_decryption 
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
module scytale_decryption#(
            parameter D_WIDTH = 8, 
            parameter KEY_WIDTH = 8, 
            parameter MAX_NOF_CHARS = 50,
            parameter START_DECRYPTION_TOKEN = 8'hFA
        )(
            // Clock and reset interface
            input clk,
            input rst_n,
 
            // Input interface
            input[D_WIDTH - 1:0] data_i,
            input valid_i,
 
            // Decryption Key
            input[KEY_WIDTH - 1 : 0] key_N,
            input[KEY_WIDTH - 1 : 0] key_M,
 
            // Output interface
            output reg[D_WIDTH - 1:0] data_o,
            output reg valid_o,
 
            output reg busy
    );
 
        reg[D_WIDTH*MAX_NOF_CHARS-1:0] aux;
        reg[D_WIDTH-1 :0] i;
        reg[D_WIDTH-1 :0] j;
        reg[D_WIDTH-1 :0] k;
 
        initial begin        //initializare semnale
       
            i=0;        	//contor numar total litere
            busy=0;     	//semnalul busy e pe 0 la inceput
            j=0;            	//indice 2( will be explained later)
            k=0;	   	//indice 1
            valid_o=0;		//valid output si data sunt 0
            data_o=0;

        end
 
        always@(posedge clk) begin

            if(valid_i==1) begin
                if(data_i!= START_DECRYPTION_TOKEN) begin
                    if(busy==0) begin
                         aux[D_WIDTH*i +: D_WIDTH]<=data_i;					// scriem in aux toate datele ce ne sunt furnizare, pe cate 8 biti fiecare
                         i<=i+1;									        //numaram cuvintele scrise
                    end
                end
                else begin
                    busy<=1;
                end
            end
            if(busy==1) begin								//dupa ce busy devine 1, restul de etape pot incepe
                if (k < key_M) begin							//Am observat o regula de forma key_N*(0:key_M-1)+(0:key_M-1)
                    valid_o<=1;								//valid devine 1
                    data_o<=aux[D_WIDTH*(key_N*k+j) +: D_WIDTH];					//data out ia valoarea aux corespondenta literei de la pozitia det cu formula de mai sus
                    k<=k+1;								//k itereaza, k fiind inlocuitorul primei paranteze de mai sus
                end else begin
                    if (j < key_N - 1) begin						//daca k depaseste conditia alocata
                        valid_o<=1;
                        j<=j+1;								//j o sa creasca( iteram paranteza 2 la urm pas)
                        k<=1;								//k devine 1, in pregatire pentru reluarea urmatoarei linii
                        data_o <= aux[D_WIDTH*(j+1) +: D_WIDTH];					//data_o primeste valoarea coresp primului element din urm linie
                    end else begin
                        valid_o<=0;
                        i<=0;           
                        j<=0;           						//daca niciuna dintre conditiile de mai sus au fost indeplinite
                        k<=0;								//inseamna ca am terminat decriptarea, si readucem toate semnalele pe 0
                        busy<=0;        
                        data_o<=0;
                        aux <= 0;
                    end
                end
            end
        end
endmodule
 