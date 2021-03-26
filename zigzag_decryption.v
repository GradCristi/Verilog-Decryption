`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:33:04 11/23/2020 
// Design Name: 
// Module Name:    zigzag_decryption 
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
module zigzag_decryption #(
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
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
         output reg busy,
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o
    );
	reg[D_WIDTH*MAX_NOF_CHARS-1:0] aux;
	reg[7:0] cycle;
	reg[7:0] i;
	reg[7:0] j;  // egal cu 0
	reg[7:0] x;
	reg[7:0] nrofcycles;
	reg[7:0] k;
	reg[7:0] m;
	reg[7:0] p;
	
	initial begin
				i=0;        	//contor numar total litere
            busy=0;     	//semnalul busy e pe 0 la inceput
            j=0;           //contor de litere
            x=0;	 			//indice pentru citirea datelor in data_o
            valid_o=0;		//semnal de valididitate a iesirii
            data_o=0;		//datele de iesire
				k=0;				//semnal pentru cheia 3
				m=0;				//tot semnal pentru cheia 3
				p=0;				// :))))))))) nu vreau sa ma tot repet...
				
	end
	
	
	
	// in prima faza trebuie sa citim toate literele care ne sunt furnizate pe data_i
	//acest lucru se face cat timp semnalul valid este activ, si cat timp nu am intalnit
	//nici semnalul de incepere a fazei de decriptare, si nici semnalul activ busy
	
	always @(posedge clk) begin
		if(valid_i==1) begin
			if(data_i !=START_DECRYPTION_TOKEN) begin      	//faza de citire
				if(busy==0) begin
					aux[D_WIDTH*i +: D_WIDTH]<=data_i;			//citim litera cu litera, cate 8 biti in acest caz
					i<=i+1;												//numaram cate cuvinte am citit
				end
			end
			else if(data_i== START_DECRYPTION_TOKEN) begin	//incepere faza decriptare
						busy<=1;
						j<=0;
						if(key==2)begin								//setam valorile pentru busy si pentru j 
							nrofcycles<= i>>1;						// si calculam numarul de ciclii pentru fiecare dintre chei
						end												//stim ca cheii 2 ii corespunde un ciclu de 2 variabile
						else												//si cheii 3 ii corespunde un ciclu de 4 variabile
						if(key==3) begin
							nrofcycles<= i>>2;						//am folosit shiftarea pentru impartire cu puteri ale lui 2,
							cycle<=4;									//asa cum ne-a fost aratat in laboratorul cu UAL(cred?)
						end
				  end
		end
		if(busy==1) begin												//faza decriptare
			case(key)

//pentru cazul cheii 2 am observat o regula in ceea ce priveste paritatea literei pe care o citim
//si anume ca urmeaza o formula de tipul x+nrofcycles care alterneaza cu n-nrofcycles, si difera 
//in functie de "intregimea" ciclilor 
				2: begin														
					if(j<i)begin											//cat timp nu am citit toate literele
						if(j[0]==0) begin									//daca j este par		
							valid_o<=1;
							j<=j+1;											//valid devine 1, incrementam j
							data_o<=aux[8*x +: 8];						//adaugam in data_o datele de la adresa x
							if(i[0]==1) begin								//in functie daca ciclurile sunt complete sau nu
							x<= x+nrofcycles+1;							// x ia valori diferite
							end
							else
							x<= x+nrofcycles;
						end
						else
						if(j[0]==1)begin									//daca j este impar
						valid_o<=1;											//urmam aceiasi pasi, insa trebuie sa scadem de aceasta data
						j<=j+1;												//pentru a ajunge pe pozitia liniei 1 din nou
						data_o<=aux[8*x +: 8];
						if(i[0]==1) begin									//am observat ca aceeasi regula ca mai sus are loc si la j impar
							x<= x-nrofcycles;
						end
						else x<= x-nrofcycles+1;
						end
					end
					else begin												//cand am terminat de citit toate literele, punem toate semnalele pe 0
						cycle<=0;											//ca sa nu ne incurce la decriptarea cheii 3
						i<=0;													
						x<=0;
						busy<=0;
						valid_o<=0;
						nrofcycles<=0;
						j<=0;
						data_o<=0;
						aux<=0;
						p<=0;
						m<=0;
					end
					
				end

//Pentru cheie 3, stim ca ciclul are 4 elemente, deci daca impartim la 4 putem sa aflam numarul de ciclii prezenti 
//Dupa, trebuie sa stim cum arata ciclii care nu sunt completi( lipsesc 1, 2 sau 3 elemente) si asta o facem cu ajutorul
//lui (i-nrofcycles*cycle) iar rezultatul este cate litere sunt in ciclul incomplet. 
//pentru un numar de litere format in ciclu complet trebuie sa extragem litrele 0,4,12,5, 1,6,13,7, 2,8,14,9, 3,10,15,11 etc
//deci eu m-am gandit la o formula de forma x<=(nrofcycles+1)*k+m, cu mici variatii pentru fiecare dintre cazurile de ciclii.
//pentru ciclu plin: x<=nrofcycles*k+m; 
// pentru ciclu cu lipsa un element sau 2: x<=(nrofcycles+1)*k+m-1, pentru ca ne trebuie cu un
//ciclu mai sus decat numarul de ciclii, ca sa acoperim si ciclul partial;
//pentru  ciclu cu lipsa 3 elemente:x<=(nrofcycles+1)*k+m-2;
//deci o sa trebuiasca sa tratam separat cazul cu ciclii plini
//un ciclu de 4 elemente are 2 elemente pare si doua impare, deci le vom trata pe fiecare in parte, pentru ca 
//creeaza cazuri diferite de tipul:
// 4*0+0, 4*1+0, 4*3+0, 4*1+1; 
// 4*0+1, 4*1+2, 4*3+1, 4*1+3; etc
//pentru cazul cu j par, dat fiind ca prima oara o sa se faca scrierea datelor pentru x=0 (fapt constatat dupa simulari)
//o sa trebuiasca sa incepem cu valorile pentru x de la urmatoarea adresa valida, adica nrofcycles*1+p; pentru completi si 
//pentru ciclii incompleti x<=(nrofcycles+1)*1+p; Initial incercasem sa le fac tratand prima oara o solutie de ecuatie
// x<=nrofcycles*0+m, fapt care ma ducea intr-o decriptare corecta insa cu prima litera dublata, deoarece x ramanea pe 0 
// de doua ori. Asa ca am avut ideea sa incep cu elementul 4*1+0 din lista de mai sus, deoarece 4*0+0 este cazul initial.
// dupa ce rezolvam elementul 1, j trebuie incrementat si astfel ajungem in partea impara a algoritmului, unde pe ramura de 
//k==3 tratam familia 4*3+m, dar cu grija sa tinem cont si de particularitatile de cicluri pe care elementele din ultima 
//linie a matricei imaginare le poseda din punctul de vedere al adreselor literelor lor. Urmeaza cazurile 3 si 4, pe care 
// le voi comenta pe cod, deoarece nu sunt chiar asa interesante
//o ultima observatie este ca in cod am inlocuit k cu valorile explicite pe care o sa le aiba cand se afla pe o anumita
//"ramura" pentru a ma ajuta sa inteleg mai usor ce se intampla
				3: begin

						if(j<i)begin												// cat timp nu am citit toate literele
							if(j[0]==0) begin										//j par
								if(p[0]==0)begin
									if(i-nrofcycles*cycle==0) begin			//ciclu plin
												x<=nrofcycles*1+p;				//valoarea lui x pentru un ciclu plin, cu p ce se incrementeaza
									end else x<=(nrofcycles+1)*1+p;			//aceeasi idee si pentru ciclu incomplet, insa trebuie sa compensam
									p<=p+1;											//pentru valorile din ultimul ciclu
									k<=3;												//k ma duce in 3 deoarece aceea este urmatoarea stare pe care trebuie
								end													//sa o urmez
								if(p[0]==1)begin									
									if(i-nrofcycles*cycle==0) begin			//ciclu plin
												x<=nrofcycles*1+p;				//aceeasi idee generala ca mai sus
									end else x<=(nrofcycles+1)*1+p;
									p<=p+1;											//insa pe langa incrementarea lui p, k se duce in 0 de data asta
									k<=0;
									m<=m+1;											//si fiind la final de ciclu de elemente( de 4) si m va fi incrementat
								end
	
							end
							else
							if(j[0]==1) begin		//impar
								if(k==0)begin										//ramurile pentru impar se iau in functie de k, el fiind variantul
									if(i-nrofcycles*cycle==0) begin			//ciclu plin
												x<=nrofcycles*0+m;				// ne intereseaza sa ajungem 4*0+m;
									end else x<=(nrofcycles+1)*0+m;
								end
								//pentru k=3, tratam fiecare dintre posibilitatile de completare a ciclului separat, deoarece fiecare influenteaza
								//rezultatul decriptarii iar lipsa unei valori din ultimul ciclu afecteaza pozitia fiecarei linii de mai jos
								if(k==3)begin
									if(i-nrofcycles*cycle==0) begin			//ciclu plin
												x<=nrofcycles*3+m;
									end
									else if(i-nrofcycles*cycle==1) begin	//missing last 3
												x<=(nrofcycles+1)*3+m-2;
									end
									else if(i-nrofcycles*cycle==2) begin	//missing last 2
												x<=(nrofcycles+1)*3+m-1;
									end
									else if(i-nrofcycles*cycle==3) begin	//missing last
												x<=(nrofcycles+1)*3+m-1;
									end
									
								end
								k<=1;   												//in cazul impar, k mereu variaza catre cazul par cu valoarea 1
							end
							valid_o<=1;
							j<=j+1;													//valid trece pe 1 si incrementarea lui J are loc
							data_o<=aux[8*x +: 8];								//scriem datele in out, de la pozitia x determinata
						end

						else
						begin
							cycle<=0;												//daca am citit toate literele, ne reintoarcem cu semnalele in 0
							i<=0;														// ca sa nu influenteze decriptarile viitoare.
							x<=0;	
							busy<=0;
							valid_o<=0;
							nrofcycles<=0;
							j<=0;
							k<=0;
							p<=0;
							m<=0;
							aux<=0;
							data_o<=0;
							
						end	
					end
			endcase
		end
	end
endmodule




