GradinaruCristian332AC

This is a school project, and i havent gotten around to translating the readme into English yet, I am sorry. 

ETAPA 1- Bancul de registre
	Toata activitatea se petrece intr-un always secvential setat pe frontul crescator al undei, iar primul pas este cel de verificare a adresei: daca 
adresa este una dintre cele 4 mentionate, flag-ul de eroare nu este ridicat, totul este in regula. Daca, in schimb adresa nu este una dintre acestea, 
se ridica flagul de eroare pentru operatie efectuata la o adresa incorecta.
	Majoritatea programului este inclus intr-un if care testeaza daca resetul este sau nu activ, deoarece procedurile de tratare sunt diferite pentru
fiecare dintre aceste cazuri. Daca resetul este inactiv( adica pe 1 logic- pt ca este rst_neg) se selecteaza adresa, si in functie de aceasta se face o operatie
de scriere sau citire, in functie de semnalul care este activ( cel de read sau cel de write). Acest proces se repeta pentru fiecare dintre cele 4 optiuni, cea mai
speciala fiind cea a select register, care nu scrie decat primii 2 biti, deoarece ceilalti nu au nicio importanta. Am folosit operatorul ternar in alcaturirea
acestor instructiuni, pentru ca mi s-a parut ca ar fi in acelasi timp si mai eficient dar si mai usor de citit, specificand intr-un singur rand si conditia
, si rezultatele in ambele cazuri de adevar.
	Cel de-al doilea caz este acela unde resetul este activ, caz in care toti registrii sunt pusi in pozitia lor de reset, conform cu tabelul din 
documentul temei. Ultima faza este sa ne asiguram ca done este semnalat ca 1 daca s-a produs vreo operatie de scriere sau citire, iar acest lucru se face
cu o instructiune OR, care are scopul de a transmite 1 daca oricare dintre aceste doua operatii au fost efectuate, acest rezultat reflectandu-se in valoarea
lui done.

ETAPA 2- Modulele de decriptare

	Prima decriptare este cea a cifrului Caesar. Ea se face prin intermediul adunarii sau scaderii a unei constante pentru a obtine codul ASCII a literei
criptate sau decriptate. Am avut nevoie de o variabila auxiliara in care sa retin datele de intrare din care am scazut cheia de criptare, pentru a obtine
astfel semnalul decriptat. Caesar este o decriptare care lucreaza mereu cu semnalul busy 0, deci acest lucru nu se schimba. Pentru a trimite datele catre
iesire am folosit un always secvential, care atunci cand valid input este activ scrie datele la iesire, si transforma validitatea outputului in 1, pentru
a semnala ca este gata. 
	Cea de-a doua decriptare este cifrul Scytale. Acest cifru se bazeaza in mod ideologic pe o matrice, unde matricea primeste valorile pe coloane, iar
mesajul trebuie citit pe linii. In afara ideii de a reprezenta aceasta matrice propriu zis( fapt evident neideal) am ales sa urmaresc cu atentie indicii
pe care aceste litere le corespund in vectorul pe care il primim noi de la intrare. Asadar, dupa ce scriem datele intr-un auxiliar, cate o litera pe rand, 
trebuie ca la detectarea tokenului de incepere a decriptarii sa punem semnalul busy pe 1, si numai odata ce acesta este pe 1, putem sa incepem decriptarea
propriu-zisa. Am observat o anumita regula in formarea acestor propozitii decriptate, si anume ca urmaresc regula N*(M-1)+(M-1), unde M variaza de la 0. 
Aceasta observatie mi-a permis sa scriu doua if-uri, cate unul pentru fiecare dintre cele doua paranteze, si sa variez prima paranteza pana cand ies
din interval, moment in care ce-a de-a doua paranteza poate itera si ea tot pana la atingerea plafonului din formula de mai sus. Cand ambele paranteze
si-au terminat iteratiile, am citit practic toate literele care trebuia, si am realizat decriptarea, deci putem sa punem toate semnalele inapoi pe 0, in 
pregatirea urmatoarei decriptari.
	Ultima decriptare, si cea mai dificila, este cifrul Zig-Zag, care se imparte in doua cazuri: Zig zag pentru cheie 2, si zig zag pentru cheie 3.
Inainte sa incepem decriptarea, trebuie sa citim literele furnizate pe intrare. Acest lucru se face cat timp semnalul valid este activ, si cat timp nu am 
nici semnalul busy activ, dar nici nu am intalnit tokenul de incepere a fazei de decriptare. Atunci cand intalnim semnalul de decriptare, punem busy pe 1, 
pentru a putea incepe decriptarea la ciclul de ceas urmator, si in concomitenta cu asta, setam valorile pentru numarul de ciclu si numarul de elemente
dintr-un ciclu pentru ambele cazuri de decriptare.
	Cand toate acestea sunt facute, incepem cu decriptarea printr-un case care separa decriptarea pentru cheie 2 de cea pentru cheie 3.  pentru cazul cheii 2 am 
observat o regula in ceea ce priveste paritatea literei pe care o citim si anume ca urmeaza o formula de tipul x+nrofcycles care alterneaza cu n-nrofcycles, si difera 
in functie de "intregimea" ciclilor. Adica valorile mele se schimba daca ciclul este intreg, sau daca este incomplet, pentru ca lipsa unui element de pe 
prima linie influenteaza pozitita tututor elementelor de pe linia 2.
	Cu ajutorul lui j, care tine numarul de litere citite pana acum, putem intra intr-o bucla pana cand citim toate literele din acel sir. Cazul in care
j este par este in concordanta cu semnul + in formula x+-nrofcycles, si in functie de intregimea ciclurilor mai trebuie sa adaugam sau nu 1 pentru a obtine
o reprezentare fidela a propozitiei decriptate. Aceeasi idee o urmreaza si cazul j impar, doar ca trebuie sa avem in vedere faptul ca semnele lui nrofcycles
alterneaza, deci in acest caz trebuie sa le scadem, pentru a simula parcurgerea unei matrice. Atunci cand am citit toate literele, putem sa trimitem toate
semnalele in valoarea lor 0, ca sa nu cumva sa influenteze urmatoarea decriptare.
	Pentru cheie 3, stim ca ciclul are 4 elemente, deci daca impartim la 4 putem sa aflam numarul de ciclii prezenti. Dupa, trebuie sa stim cum arata 
ciclii care nu sunt completi( lipsesc 1, 2 sau 3 elemente) si asta o facem cu ajutorul lui (i-nrofcycles*cycle) iar rezultatul este cate litere sunt in 
ciclul incomplet. Pentru un numar de litere format in ciclu complet trebuie sa extragem litrele 0,4,12,5, 1,6,13,7, 2,8,14,9, 3,10,15,11 etc
deci eu m-am gandit la o formula de forma x<=(nrofcycles+1)*k+m, cu mici variatii pentru fiecare dintre cazurile de ciclii.
pentru ciclu plin: x<=nrofcycles*k+m; 
pentru ciclu cu lipsa un element sau 2: x<=(nrofcycles+1)*k+m-1, pentru ca ne trebuie cu un ciclu mai sus decat numarul de ciclii, 
ca sa acoperim si ciclul partial;
pentru  ciclu cu lipsa 3 elemente:x<=(nrofcycles+1)*k+m-2;
deci o sa trebuiasca sa tratam separat cazul cu ciclii plini
un ciclu de 4 elemente are 2 elemente pare si doua impare, deci le vom trata pe fiecare in parte, pentru ca creeaza cazuri diferite de tipul:
 4*0+0, 4*1+0, 4*3+0, 4*1+1; 
 4*0+1, 4*1+2, 4*3+1, 4*1+3; etc
pentru cazul cu j par, dat fiind ca prima oara o sa se faca scrierea datelor pentru x=0 (fapt constatat dupa simulari)o sa trebuiasca sa incepem 
cu valorile pentru x de la urmatoarea adresa valida, adica nrofcycles*1+p; pentru completi si pentru ciclii incompleti x<=(nrofcycles+1)*1+p; 
Initial incercasem sa le fac tratand prima oara o solutie de ecuatie x<=nrofcycles*0+m, fapt care ma ducea intr-o decriptare corecta insa cu prima litera 
dublata, deoarece x ramanea pe 0 de doua ori. Asa ca am avut ideea sa incep cu elementul 4*1+0 din lista de mai sus, deoarece 4*0+0 este cazul initial.
dupa ce rezolvam elementul 1, j trebuie incrementat si astfel ajungem in partea impara a algoritmului, unde pe ramura de 
k==3 tratam familia 4*3+m, dar cu grija sa tinem cont si de particularitatile de cicluri pe care elementele din ultima 
linie a matricei imaginare le poseda din punctul de vedere al adreselor literelor lor. Urmeaza cazurile 3 si 4, insa ele urmeaza aceeasi idee de baza,
singura diferenta semnificativa ar fi incrementarile pentru p, k si m, care sunt facute in concordanta cu formula de mai sus.
o ultima observatie este ca in cod am inlocuit k cu valorile explicite pe care o sa le aiba cand se afla pe o anumita
"ramura" pentru a ma ajuta sa inteleg mai usor ce se intampla
Atunci cand toate literele au fost citite, putem readuce toate semnalele pe 0, pentru a nu interfera cu urmatoarea decriptare.

ETAPA 3- Mux, Demux, Top

	In ceea ce priveste fisierul TOP, acesta nu contine decat instantierea tuturor modulelor, cu o declarare in prealabil a variabilelor ce urmeaza sa fie folosite, si
cu un always in care tratez semnalul busy, trecandu-l pe 1 daca oricare dintre cele 3 module de decriptare sunt pe busy.
	La etapa 3, partea dificila a inceput la Demux, deoarece faptul ca semnalul valid poate ramane pe 1 s-a dovedit un obstacol relativ semnificativ: am inceput cu un initial in
care reinitializez toate datele cu 0, ca sa plecam dintr-un loc cunoscut. Intr-un always pe ceasul system( am ales asa pentru ca e o legatura directa intre clock sys si clock mst)
am inceput sa analizez fiecare dintre starile posibile, in functie de ciclul de ceas in care se afla in intervalul 1-4( coresp unui ciclu mst). O sa abordez fiecare dintre operatiie 
posibile de la cap la coada, pentru a fi usor de urmarit: In ceea ce priveste etapa de primire a informatiei,( adica intrare==1) nu am nevoie de mare lucru, decat sa trec din stare instare
urmand ciclurile de ceas, pana la starea 2 unde vreau sa citesc informatia prezenta pe data in, sa o pun in aux, pentru a pregati automatul meu de etapa de scriere, care ar trebui sa inceapa
in ceasul 3, pentru a fi "gata" in ceasul 4, cand practic termin ciclul. O data ce aux contine informatia, pivotam in cazul de routare a informatiilor catre exterior, tot pe principiul unui automat,
care la fiecare dintre stari scrie cate un cuvant din cele 4 disponibile, iar odata ce acest proces s-a terminat, ne reintoarcem in situatia in care eram inainte, gata sa citim urmatoarele 4 caractere
serializate. Etapa 2 este destul de importanta aici, deoarece in functie de valid in, daca mai urmeaza un cuvant de citit, o putem face, altfel trebuie sa tranzitam inspre situatia de asteptare, eventual
si prin starea 3, care nu doar ca ne trimite catre starea 0, ci ne si reseteaza semnalele, ca sa nu transmitem "frimititurile(firimituri? nu mai stiu)" pana la urmatoarea decriptare.
	In mux situatia este straight-forward : in functie de selectul pe care il primim, daca avem voie sa transmitem informatia mai departe, o transmitem pe canalul data out si valid out, care preiau valorile
de la intrare, tot in functie de select.

	