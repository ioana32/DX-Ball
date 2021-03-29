.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc


includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Calculator",0
area_width EQU 260
area_height EQU 390
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

ispos DD ?

operators dd 0,0
operator_nb dd 0

function_vector dd 20 dup(?) 

prev_oper dd -1
curent_op dd -1

x_calc dd ?
y_calc dd ?



symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc
.code

clear_button proc
	mov ebx,operator_nb
	mov operators[ebx*4],0
	ret
clear_button endp

delete_button proc
	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov edx,0
	mov ebx,10
	div ebx
	mov ebx,operator_nb
	mov operators[ebx*4],eax
	ret
delete_button endp

change_sign_button proc
	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov edx,0
	sub edx,eax
	mov operators[ebx*4],edx
	ret
change_sign_button endp

put_1 proc

	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov ebx,10
	mul ebx
	add eax,1
	mov ebx,operator_nb  ;il punem la loc in memorie
	mov operators[ebx*4],eax
	ret
put_1 endp

put_2 proc

	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov ebx,10
	mul ebx
	add eax,2
	mov ebx,operator_nb  ;il punem la loc in memorie
	mov operators[ebx*4],eax
	ret
put_2 endp

put_3 proc

	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov ebx,10
	mul ebx
	add eax,3
	mov ebx,operator_nb  ;il punem la loc in memorie
	mov operators[ebx*4],eax
	ret
put_3 endp

put_4 proc

	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov ebx,10
	mul ebx
	add eax,4
	mov ebx,operator_nb  ;il punem la loc in memorie
	mov operators[ebx*4],eax
	ret
put_4 endp

put_5 proc

	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov ebx,10
	mul ebx
	add eax,5
	mov ebx,operator_nb  ;il punem la loc in memorie
	mov operators[ebx*4],eax
	ret
put_5 endp

put_6 proc

	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov ebx,10
	mul ebx
	add eax,6
	mov ebx,operator_nb  ;il punem la loc in memorie
	mov operators[ebx*4],eax
	ret
put_6 endp

put_7 proc

	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov ebx,10
	mul ebx
	add eax,7
	mov ebx,operator_nb  ;il punem la loc in memorie
	mov operators[ebx*4],eax
	ret
put_7 endp

put_8 proc

	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov ebx,10
	mul ebx
	add eax,8
	mov ebx,operator_nb  ;il punem la loc in memorie
	mov operators[ebx*4],eax
	ret
put_8 endp

put_9 proc

	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov ebx,10
	mul ebx
	add eax,9
	mov ebx,operator_nb  ;il punem la loc in memorie
	mov operators[ebx*4],eax
	ret
put_9 endp

put_0 proc

	mov ebx,operator_nb
	mov eax,operators[ebx*4]
	mov ebx,10
	mul ebx
	add eax,0
	mov ebx,operator_nb  ;il punem la loc in memorie
	mov operators[ebx*4],eax
	ret
put_0 endp
 
do_nothing proc

	ret
do_nothing endp

add_but proc
	mov eax,operator_nb
	cmp eax,1
	je make_add
	mov prev_oper , 19
	inc operator_nb
	ret 
	make_add:
	mov eax,operators[0]
	mov ebx,operators[4]
	add eax,ebx
	mov ebx,0
	mov operators[0],eax
	mov operators[4],ebx
	dec operator_nb
	ret
add_but endp

sub_but proc
	mov eax,operator_nb
	cmp eax,1
	je make_sub
	inc operator_nb
	mov prev_oper , 15
	ret 
	make_sub:
	mov eax,operators[0]
	mov ebx,operators[4]
	sub eax,ebx
	mov ebx,0
	mov operators[0],eax
	mov operators[4],ebx
	dec operator_nb


	ret
sub_but endp

mul_but proc
	mov eax,operator_nb
	cmp eax,1
	je make_mul
	mov prev_oper , 11
	inc operator_nb
	ret 
	make_mul:
	mov eax,operators[0]
	mov ebx,operators[4]
	mul ebx
	mov ebx,0
	mov operators[0],eax
	mov operators[4],ebx
	dec operator_nb

	ret
mul_but endp

div_but proc
	mov eax,operator_nb
	cmp eax,1
	je make_div
	mov prev_oper , 7
	inc operator_nb
	ret 
	make_div:
	mov eax,operators[0]
	mov ebx,operators[4]
	xor edx,edx
	div ebx
	mov ebx,0
	mov operators[0],eax
	mov operators[4],ebx
	dec operator_nb

	ret
div_but endp

eg_but proc
	mov eax , operator_nb
	cmp eax , 1
	jne skip
	
	mov eax , prev_oper 
	
	mov ebx,function_vector[eax*4]
	call ebx
	
	skip:
	ret
eg_but endp


init_function_vector proc

	mov eax,offset do_nothing
	mov function_vector[0],eax
	mov eax,offset clear_button
	mov function_vector[4],eax
	mov eax,offset delete_button
	mov function_vector[8],eax
	mov eax,offset do_nothing
	mov function_vector[12],eax
	
	mov eax,offset put_7
	mov function_vector[16],eax
	mov eax,offset put_8
	mov function_vector[20],eax
	mov eax,offset put_9
	mov function_vector[24],eax
	mov eax,offset div_but
	mov function_vector[28],eax
	
	mov eax,offset put_4
	mov function_vector[32],eax
	mov eax,offset put_5
	mov function_vector[36],eax
	mov eax,offset put_6
	mov function_vector[40],eax
	mov eax,offset mul_but
	mov function_vector[44],eax
	
	mov eax,offset put_1
	mov function_vector[48],eax
	mov eax,offset put_2
	mov function_vector[52],eax
	mov eax,offset put_3
	mov function_vector[56],eax
	mov eax,offset sub_but
	mov function_vector[60],eax
	
	mov eax,offset change_sign_button
	mov function_vector[64],eax
	mov eax,offset put_0
	mov function_vector[68],eax
	mov eax,offset eg_but
	mov function_vector[72],eax
	mov eax,offset add_but
	mov function_vector[76],eax
	
	ret 
init_function_vector endp

;arg1 - x , arg2 - y, 
transform proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax,[ebp+arg1]
	mov ebx,65
	xor edx,edx
	div ebx
	
	mov x_calc,eax
	mov eax,[ebp+arg2]
	sub eax,65
	mov ebx,65
	xor edx,edx
	div ebx
	mov y_calc,eax
	
	
	popa
	mov esp, ebp
	pop ebp

	ret
transform endp

mak_op proc
	mov eax,y_calc
	mov  ebx,4
	mul ebx
	mov ebx,x_calc
	add eax,ebx
	
	; cmp eax,7
	; je continue
	; cmp eax,11
	; je continue
	; cmp eax,15
	; je continue
	; cmp eax,18
	; je continue
	; cmp eax,19
	; je continue
	
	mov ebx,function_vector[eax*4]
	call ebx
	
	
	continue:
	

	ret
mak_op endp



;decidem ca argumentul 1 e x, argumentul 2 y, argumentul 3 lungimea liniei
draw_orizontal_line proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, area_width
	mov ebx,[ebp+arg2]
	mul ebx
	mov ebx,[ebp+arg1]
	add eax,ebx
	shl eax,2
	mov esi, area
	add esi,eax
	mov ecx,[ebp+arg3]
	et_for:
		mov dword ptr [esi],0 ;dword pune 4 bytes
		add esi,4	;trece la urmatorul
	loop et_for
	
	popa
	mov esp, ebp
	pop ebp
	ret	
draw_orizontal_line endp

draw_vertical_line proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, area_width
	mov ebx,[ebp+arg2]
	mul ebx
	mov ebx,[ebp+arg1]
	add eax,ebx
	shl eax,2
	mov esi, area
	add esi,eax
	mov ecx,[ebp+arg3]
	et_for:
		mov dword ptr [esi],0 ;dword pune 4 bytes
		mov eax,area_width
		shl eax,2
		add esi,eax	;trece la urmatorul
	loop et_for
	
	popa
	mov esp, ebp
	pop ebp
	ret	
draw_vertical_line endp

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
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
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

;arg1 nr care trebuie desenat
draw_nb proc
	push ebp
	mov ebp, esp
	pusha 
	
	mov ecx,20			;curat spatiu pt afisare
	mov edx,230
	et_for:
	push ecx
	push edx
	make_text_macro ' ', area,edx,30
	pop edx
	pop ecx
	sub edx,10
	loop et_for
	
	mov eax,[ebp+arg1]
	cmp eax,0
	jne continue
	make_text_macro '0', area,230,30
	continue:
	
	mov eax,[ebp+arg1]
	cmp eax,0
	jl is_negative
	mov ispos,1
	jmp skip
	is_negative:
	mov ispos,0
	mov ebx,0			; daca nr e neg il facem poz
	sub ebx,eax
	mov eax,ebx
	skip:
	mov ecx,230 ;unde se afiseaza cifra unit
	
	et_while:
		cmp eax,0
		je exit_while
	
		mov edx,0
		mov ebx,10
		div ebx   ;edx are rest, eax cat
		add edx,'0'
		push eax		;le salvam
		push ecx
		make_text_macro edx,area,ecx,30
		pop ecx			;le scoatem ca se modifica
		pop eax
		
		sub ecx,10
	jmp et_while
	
	exit_while:
	cmp ispos,1
	je skip2
	push 10
	push 40
	push ecx
	call draw_orizontal_line
	add esp,12
	
	skip2:
	popa
	mov esp, ebp
	pop ebp
	ret
draw_nb endp

draw proc
	push ebp
	mov ebp, esp
	pusha 
	mov eax,[ebp+arg1]
	cmp eax,1
	je event_click
	cmp eax,2
	je event_timer
	call init_function_vector
	mov eax,area_width
	mov ebx,area_height
	mul ebx
	shl eax,2	;calc nr biti
	push eax
	push 0FFh
	push area
	call memset 
	add esp,12
	; desenare interfata -------------------------------------------------------------------------------------------------------------------
	push 260
	push 65
	push 0
	call draw_orizontal_line
	add esp,12
	
	push 260
	push 130
	push 0
	call draw_orizontal_line
	add esp,12
	
	push 260
	push 195
	push 0
	call draw_orizontal_line
	add esp,12
	
	push 260
	push 260
	push 0
	call draw_orizontal_line
	add esp,12
	
	push 260
	push 325
	push 0
	call draw_orizontal_line
	add esp,12
	
	push 325
	push 65
	push 65
	call draw_vertical_line
	add esp,12
	
	push 325
	push 65
	push 130
	call draw_vertical_line
	add esp,12
	
	push 325
	push 65
	push 195
	call draw_vertical_line
	add esp,12
	
	make_text_macro 'C', area,90,90
	make_text_macro '7',area,30,160
	make_text_macro '8',area,90,160
	make_text_macro '9',area,160,160
	make_text_macro '4',area,30,220
	make_text_macro '5',area,90,220
	make_text_macro '6',area,160,220
	make_text_macro 'X',area,220,220
	make_text_macro '1',area,30,280
	make_text_macro '2',area, 90,280
	make_text_macro '3',area,160,280
	make_text_macro '0',area,90,345
	
	push 30
	push 90
	push 140
	call draw_vertical_line
	add esp,12
	
	push 30
	push 90
	push 141
	call draw_vertical_line
	add esp,12
	
	push 40
	push 105
	push 140
	call draw_orizontal_line
	add esp,12
	
	push 40
	push 106
	push 140
	call draw_orizontal_line
	add esp,12
	
	
	push 3
	push 150
	push 230
	call draw_orizontal_line
	add esp,12
	
	push 3
	push 151
	push 230
	call draw_orizontal_line
	add esp,12
	
	push 3
	push 152
	push 230
	call draw_orizontal_line
	add esp,12
	
	push 3
	push 175
	push 230
	call draw_orizontal_line
	add esp,12
	
	push 3
	push 176
	push 230
	call draw_orizontal_line
	add esp,12
	
	push 3
	push 177
	push 230
	call draw_orizontal_line
	add esp,12
	
	push 30
	push 162
	push 215
	call draw_orizontal_line
	add esp,12
	
	push 30
	push 163
	push 215
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 290
	push 220
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 291
	push 220
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 355
	push 220
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 343
	push 232
	call draw_vertical_line
	add esp,12
	
	push 25
	push 343
	push 233
	call draw_vertical_line
	add esp,12
	
	push 25
	push 356
	push 220
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 350
	push 150
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 351
	push 150
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 359
	push 150
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 360
	push 150
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 370
	push 20
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 371
	push 20
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 340
	push 32
	call draw_vertical_line
	add esp,12
	
	push 25
	push 340
	push 33
	call draw_vertical_line
	add esp,12
	
	push 25
	push 352
	push 20
	call draw_orizontal_line
	add esp,12
	
	push 25
	push 353
	push 20
	call draw_orizontal_line
	add esp,12
	
	;-----------------------------------------------------------------------------------------------------------------------------------------
	
	;push 234
	;call draw_nb 
	;add esp,4
	
	
	jmp final_drew
	
	
	event_click:
		mov eax,[ebp+arg2]
		mov ebx,[ebp+arg3]
		cmp ebx,65
		jl final_drew
		push ebx
		push eax
		call transform
		add esp,8
		call mak_op
		mov ebx,operator_nb
		mov eax,operators[ebx*4]
		push eax
		call draw_nb
		add esp,4
	event_timer:
	
	final_drew:
	
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp



start:
	; call init_function_vector
	; mov eax,1
	; mov x_calc,eax
	; mov y_calc,eax
	; call mak_op
	call add_but
	call add_but

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
