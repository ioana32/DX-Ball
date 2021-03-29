
.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc
includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
format1 DB "y_patrat=%d; y_minge=%d", 13, 10, 0
format2 DB "x_patrat=%d; x_minge=%d", 13, 10, 0
;aici declaram date
window_title DB "DX-Ball",0
area_width EQU 640
area_height EQU 480
area DD 0

a dd 0
b dd 0


counter DD 0
counterb DD 0; numara evenimentele de tip timer
i DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

butonx EQU 220
butony EQU 200
butonl1 EQU 90
butonl2 EQU 40

ball_x Dd 292
ball_y Dd 400

nr_click dd 0
x dd 0, 50, 130, 210, 290, 370, 450, 530,  50, 130, 210, 290, 370, 450, 530,  50, 130, 210, 290, 370, 450, 530, 130, 210, 290, 370, 450
y dd 0, 50,  50,  50,  50,  50,  50,  50, 100, 100, 100, 100, 100, 100, 100, 150, 150, 150, 150, 150, 150, 150, 200, 200, 200, 200, 200
cont dd 0,1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1


symbol_width EQU 10
symbol_height EQU 20
len EQU 50
h EQU 25


l EQU 50
p1 dd 272
p2 equ 412
include digits.inc
include letters.inc


.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y



make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, '*'
	jl make_letter
	cmp eax, '*'
	jg make_letter
	mov eax,27
	lea esi,letters
	jmp draw_text
make_letter:	
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text	
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	jmp draw_text
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	cmp byte ptr [esi], 1
	je simbol_pixel_negru
	cmp byte ptr [esi], 2
	je simbol_pixel_rosu
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_next
simbol_pixel_rosu:
	mov dword ptr [edi], 0DD3C1Dh
	jmp simbol_pixel_next
simbol_pixel_negru:
	mov dword ptr [edi], 0h
	jmp simbol_pixel_next
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
	
make_text endp



; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm



line macro x, y, len, color
local bucla
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax,2
	add eax, area
	mov ecx, len
bucla:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla
endm

linev macro x, y, len, color
local buclav
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax,2
	add eax, area
	mov ecx, len
buclav:
	mov dword ptr[eax], color
	add eax, 4*area_width
	loop buclav
endm

;desenare patrate
patrat macro x, y, h, len
local bucla_patrat
local buclap
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, h
bucla_patrat:
	mov edx, ecx
	mov ecx, len
buclap:
	mov dword ptr[eax], 043BF21h
	add eax, 4
	loop buclap
	add eax, 4*area_width
	sub eax, len*4
	mov ecx,edx
	loop bucla_patrat
endm

patratalb macro x, y, h, len
local bucla_patrata
local buclapa
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, h
bucla_patrata:
	mov edx, ecx
	mov ecx, len
buclapa:
	mov dword ptr[eax], 0FFFFFFh
	add eax, 4
	loop buclapa
	add eax, 4*area_width
	sub eax, len*4
	mov ecx,edx
	loop bucla_patrata
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y

draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz start_joc
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere


	

		
start_joc:
	cmp nr_click,0
	jne iesire
	add nr_click,1
	make_text_macro ' ', area, 230, 170
	make_text_macro ' ', area, 240, 170
	make_text_macro ' ', area, 250, 170
	make_text_macro ' ', area, 260, 170
	make_text_macro ' ', area, 270, 170
	make_text_macro ' ', area, 280, 170
	make_text_macro ' ', area, 290, 170
	
	line butonx, butony, butonl1, 0FFFFFFh
	line butonx, butony+butonl2, butonl1, 0FFFFFFh
	linev butonx, butony, butonl2, 0FFFFFFh
	linev butonx+butonl1, butony, butonl2, 0FFFFFFh
	
	make_text_macro ' ', area, butonx+butonl1/2-25, butony+butonl2/2-10
	make_text_macro ' ', area, butonx+butonl1/2-15, butony+butonl2/2-10
	make_text_macro ' ', area, butonx+butonl1/2-5, butony+butonl2/2-10
	make_text_macro ' ', area, butonx+butonl1/2+5, butony+butonl2/2-10
	make_text_macro ' ', area, butonx+butonl1/2+15, butony+butonl2/2-10

draw_square:	
	
	 mov esi,1
	 buclas:
	 cmp esi,26
	 ja iesire
	
	 patrat x[4*esi],y[4*esi],h,len
	
	inc esi
	jmp buclas
	
	iesire:
	
	make_text_macro '*', area, ball_x, ball_y	
	patratalb p1,p2,8,l
	mov eax,[ebp+arg2]
	
	cmp eax, 290
	jg dreapta
	
	mov edx,p1
	sub edx,24
	cmp edx, 8
	jl yes
	mov p1,edx
	; patrat p1,p2,8,l
	jmp yes
	
dreapta:
	
	mov edx,p1
	add edx,24
	cmp edx, 584
	jg yes
	mov p1,edx
	; patrat p1,p2,8,l
	
yes:
	patrat p1,p2,8,l
	
move_ball:
	mov ecx, area_height
	sub ecx, ball_y
	mov eax, ball_x
	mov ebx, ball_y
	mov counter, 0
	
	
	
	cmp i, 0
	jz sus
	cmp i, 1
	jz jos
	cmp i, 2
	jz sus2
	cmp i, 3
	jz jos2
	cmp i,4
	jz sus3
	cmp i,5
	jz sus4

paleta2:
	mov ecx,p1
	sub ecx, 5
	cmp ball_x, ecx
	jl sfarsit
	add ecx,55
	cmp ball_x, ecx
	jg sfarsit
	sub ecx, 18
	cmp ball_x,ecx
	jg contor4
	sub ecx, 19
	cmp ball_x, ecx
	jl contor5

contor0:
	mov i,0
	
sus:
	cmp i, 1
	jz jos
	cmp i, 2
	jz sus2
	cmp i, 3
	jz jos2
	cmp i,4
	jz sus3
	cmp i,5
	jz sus4
	
	make_text_macro ' ', area, ball_x, ball_y
	sub eax,8
	sub ebx,8
	mov ball_x,eax
	mov ball_y,ebx
	make_text_macro '*', area, ball_x, ball_y
	cmp ball_x, 10
	jl contor2
	cmp ball_y, 10
	jl contor3
	
	mov esi,0
	
	color:
	cmp esi, 25
	ja evt_timer
	add esi,1
	mov edi, y[4*esi]
	sub edi, 20
	cmp ebx, edi
	jl color
	mov edi, y[4*esi]
	add edi, 25
	cmp ebx, edi
	jg color
	mov edi, x[4*esi]
	sub edi, 10
	cmp eax, edi
	jl color
	mov edi, x[4*esi]
	add edi, 60
	cmp eax, edi
	jg color
	
	mov edi, cont[esi*4]
	cmp edi,1
	jne evt_timer
	
	mov cont[esi*4],0
	patratalb x[4*esi], y[4*esi], h, len	
	mov i,3
	 
	jmp evt_timer
	
paleta1:
	mov ecx,p1
	sub ecx, 5
	cmp ball_x, ecx
	jl sfarsit
	add ecx,55
	cmp ball_x, ecx
	jg sfarsit
	sub ecx, 18
	cmp ball_x,ecx
	jg contor4
	sub ecx, 19
	cmp ball_x, ecx
	jl contor5	
	
contor2:
	mov i,2	
	
sus2:
	cmp i,0
	jz sus
	cmp i, 1
	jz jos
	cmp i, 3
	jz jos2
	cmp i,4
	jz sus3
	cmp i,5
	jz sus4
	
	make_text_macro ' ', area, ball_x, ball_y
	add eax,8
	sub ebx,8
	mov ball_x,eax
	mov ball_y,ebx
	make_text_macro '*', area, ball_x, ball_y
	cmp ball_x, area_width-20
	jg contor0
	cmp ball_y, 10
	jl contor1
	
	mov esi,0
	
	color2:
	cmp esi, 25
	ja evt_timer
	add esi,1
	mov edi, y[4*esi]
	sub edi, 20
	cmp ebx, edi
	jl color2
	mov edi, y[4*esi]
	add edi, 25
	cmp ebx, edi
	jg color2
	mov edi, x[4*esi]
	sub edi, 10
	cmp eax, edi
	jl color2
	mov edi, x[4*esi]
	add edi, 60
	cmp eax, edi
	jg color2
	mov edi, cont[esi*4]
	cmp edi,1
	jne evt_timer
	mov cont[esi*4],0
	patratalb x[4*esi], y[4*esi], h, len
	mov i,1
	jmp evt_timer
	
contor4:
	mov i,4	
	
sus3:
	cmp i,0
	jz sus
	cmp i, 1
	jz jos
	cmp i, 2
	jz sus2
	cmp i, 3
	jz jos2
	cmp i,5
	jz sus4
	
	make_text_macro ' ', area, ball_x, ball_y
	add eax,14
	sub ebx,8
	mov ball_x,eax
	mov ball_y,ebx
	make_text_macro '*', area, ball_x, ball_y
	cmp ball_x, area_width-20
	jg contor0
	cmp ball_y, 10
	jl contor1
	
	mov esi,0
	
	color5:
	cmp esi, 25
	ja evt_timer
	add esi,1
	mov edi, y[4*esi]
	sub edi, 20
	cmp ebx, edi
	jl color5
	mov edi, y[4*esi]
	add edi, 25
	cmp ebx, edi
	jg color5
	mov edi, x[4*esi]
	sub edi, 10
	cmp eax, edi
	jl color5
	mov edi, x[4*esi]
	add edi, 60
	cmp eax, edi
	jg color5
	mov edi, cont[esi*4]
	cmp edi,1
	jne evt_timer
	mov cont[esi*4],0
	patratalb x[4*esi], y[4*esi], h, len
	mov i,1
	jmp evt_timer

contor5:
	mov i,5
	
sus4:
	cmp i,0
	jz sus
	cmp i, 1
	jz jos
	cmp i, 2
	jz sus2
	cmp i, 3
	jz jos2
	cmp i,4
	jz sus3
	
	make_text_macro ' ', area, ball_x, ball_y
	sub eax,2
	sub ebx,8
	mov ball_x,eax
	mov ball_y,ebx
	make_text_macro '*', area, ball_x, ball_y
	cmp ball_x, 10
	jl contor2
	cmp ball_y, 10
	jl contor3
	
	mov esi,0
	
	color6:
	cmp esi, 25
	ja evt_timer
	add esi,1
	mov edi, y[4*esi]
	sub edi, 20
	cmp ebx, edi
	jl color6
	mov edi, y[4*esi]
	add edi, 25
	cmp ebx, edi
	jg color6
	mov edi, x[4*esi]
	sub edi, 10
	cmp eax, edi
	jl color6
	mov edi, x[4*esi]
	add edi, 60
	cmp eax, edi
	jg color6
	
	mov edi, cont[esi*4]
	cmp edi,1
	jne evt_timer
	
	mov cont[esi*4],0
	patratalb x[4*esi], y[4*esi], h, len	
	mov i,3
	
    jmp evt_timer	
	
contor1:
	mov i,1
	
jos:
	cmp i,0
	jz sus
	cmp i, 2
	jz sus2
	cmp i, 3
	jz jos2
	cmp i,4
	jz sus3
	cmp i,5
	jz sus4
	
	make_text_macro ' ', area, ball_x, ball_y
	add eax,8
	add ebx,8
	mov ball_x,eax
	mov ball_y,ebx
	make_text_macro '*', area, ball_x, ball_y
	cmp ball_x, area_width-20
	jg contor3
	cmp ball_y,p2-20
	jz paleta1
	cmp ball_y, area_height-30
	jg contor2
	
	mov esi,0
	
	color3:
	cmp esi, 25
	ja evt_timer
	add esi,1
	mov edi, y[4*esi]
	sub edi, 20
	cmp ebx, edi
	jl color3
	mov edi, y[4*esi]
	add edi, 25
	cmp ebx, edi
	jg color3
	mov edi, x[4*esi]
	sub edi, 10
	cmp eax, edi
	jl color3
	mov edi, x[4*esi]
	add edi, 60
	cmp eax, edi
	jg color3
	mov edi, cont[esi*4]
	cmp edi,1
	jne evt_timer
	mov cont[esi*4],0
	patratalb x[4*esi], y[4*esi], h, len
	mov i,2
	jmp evt_timer


	
	
contor3:
	mov i,3
	
jos2:
	cmp i,0
	jz sus
	cmp i, 1
	jz jos
	cmp i, 2
	jz sus2
	cmp i,4
	jz sus3
	cmp i,5
	jz sus4
	
	make_text_macro ' ', area, ball_x, ball_y
	sub eax,8
	add ebx,8
	mov ball_x,eax
	mov ball_y,ebx
	make_text_macro '*', area, ball_x, ball_y
	cmp ball_y,p2
	jg sfarsit
	cmp ball_x, 10
	jl contor1
	cmp ball_y,p2-20
	jz paleta2
	cmp ball_y, area_height-30
	jg contor0
	
	mov esi,0
	
	color4:
	cmp esi, 25
	ja evt_timer
	add esi,1
	mov edi, y[4*esi]
	sub edi, 20
	cmp ebx, edi
	jl color4
	mov edi, y[4*esi]
	add edi, 25
	cmp ebx, edi
	jg color4
	mov edi, x[4*esi]
	sub edi, 10
	cmp eax, edi
	jl color4
	mov edi, x[4*esi]
	add edi, 60
	cmp eax, edi
	jg color4
	mov edi, cont[esi*4]
	cmp edi,1
	jne evt_timer
	mov cont[esi*4],0
	patratalb x[4*esi], y[4*esi], h, len
	mov i, 0
	
	jmp evt_timer
	
evt_timer:
	inc counter
	cmp counter, 2
	jne final_draw
	
	mov esi,0
	bucla_cont:
		inc esi
		cmp esi,25
		jz castig
	
		mov edi, cont[esi*4]
		cmp edi, 0
		jz bucla_cont
	
	jmp move_ball
	
castig:
	make_text_macro 'F', area, 230, 170
	make_text_macro 'E', area, 240, 170
	make_text_macro 'L', area, 250, 170
	make_text_macro 'I', area, 260, 170
	make_text_macro 'C', area, 270, 170
	make_text_macro 'I', area, 280, 170
	make_text_macro 'T', area, 290, 170
	make_text_macro 'A', area, 300, 170
	make_text_macro 'R', area, 310, 170
	make_text_macro 'I', area, 320, 170
	jmp final_draw
	
	

sfarsit:
	make_text_macro 'G', area, 230, 170
	make_text_macro 'A', area, 240, 170
	make_text_macro 'M', area, 250, 170
	make_text_macro 'E', area, 260, 170
	
	make_text_macro 'O', area, 225, 200
	make_text_macro 'V', area, 235, 200
	make_text_macro 'E', area, 245, 200
	make_text_macro 'R', area, 255, 200
	jmp final_draw
	

afisare_litere:
		
	;scriem un mesaj
	make_text_macro 'D', area, 230, 170
	make_text_macro 'X', area, 240, 170
	make_text_macro '-', area, 250, 170
	make_text_macro 'B', area, 260, 170
	make_text_macro 'A', area, 270, 170
	make_text_macro 'L', area, 280, 170
	make_text_macro 'L', area, 290, 170
		
	make_text_macro 'S', area, butonx+butonl1/2-25, butony+butonl2/2-10
	make_text_macro 'T', area, butonx+butonl1/2-15, butony+butonl2/2-10
	make_text_macro 'A', area, butonx+butonl1/2-5, butony+butonl2/2-10
	make_text_macro 'R', area, butonx+butonl1/2+5, butony+butonl2/2-10
	make_text_macro 'T', area, butonx+butonl1/2+15, butony+butonl2/2-10


	
final_draw:
	
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
