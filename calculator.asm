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
;aici declaram date
window_title DB "Calculator",0
area_width EQU 250
area_height EQU 260
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

nrselect db 0
operand dd 0,0  ;operanzi
operand_number dd 0
vector_functii dd 20 dup(?)
intformat db "%d ", 0
nrselect_prev db 0

.code
;arg1 sa fie aria , arg2=x , arg3 e y, arg4 e dimensiunea liniei
draw_horizontal_line proc
	push ebp
	mov ebp, esp
	pusha
	mov esi, [ebp+arg1]
	mov eax ,[ebp+arg3] ;y
	mov ebx , area_width
	mul ebx
	mov ebx , [ebp+arg2] ;x
	add eax , ebx
	shl eax , 2
	add esi, eax
	mov ecx, [ebp+arg4]
	dhl:
	mov dword ptr [esi] , 0 
	add esi , 4
	loop dhl
	popa
	mov esp, ebp
	pop ebp
	ret
draw_horizontal_line endp

draw_vertical_line proc
	push ebp
	mov ebp, esp
	pusha
	mov esi, [ebp+arg1]
	mov eax ,[ebp+arg3]
	mov ebx , area_width
	mul ebx
	mov ebx , [ebp+arg2]
	add eax , ebx
	shl eax , 2
	add esi, eax
	mov ecx, [ebp+arg4]
	dvl:
	mov dword ptr [esi] , 0 
	add esi , area_width
	add esi , area_width
	add esi , area_width
	add esi , area_width
	loop dvl
	popa
	mov esp, ebp
	pop ebp
	ret
draw_vertical_line endp
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

draw_number proc  ;arg1= numarul arg2=aria
    push ebp
	mov ebp, esp
	pusha

	mov eax,[ebp+arg1]
	mov ecx, 215
		et_drawnumber: 
		cmp eax,0
		je final_draw_number
		
		xor edx,edx
		mov ebx,10
		div ebx
		
		push eax
		add edx, '0'
		mov esi, [ebp+arg2]
		make_text_macro edx, area,ecx,30
		pop eax
		sub ecx,10
	jmp et_drawnumber
	
	final_draw_number:
	
	popa
	mov esp, ebp
	pop ebp
	ret
draw_number endp;

put_0 proc
 
	mov eax, operand_number
	mov esi, offset operand
	shl eax,2
	add esi,eax
	mov eax, dword ptr [esi]
	mov ebx,10
	mul ebx
	add eax,0
	mov dword ptr [esi],eax
	ret
put_0 endp

put_1 proc
 
	mov eax, operand_number
	mov esi, offset operand
	shl eax,2
	add esi,eax
	mov eax, dword ptr [esi]
	mov ebx,10
	mul ebx
	add eax,1
	mov dword ptr [esi],eax
	ret
put_1 endp

put_2 proc
 
	mov eax, operand_number
	mov esi, offset operand
	shl eax,2
	add esi,eax
	mov eax, dword ptr [esi]
	mov ebx,10
	mul ebx
	add eax,2
	mov dword ptr [esi],eax
	ret
put_2 endp

put_3 proc
 
	mov eax, operand_number
	mov esi, offset operand
	shl eax,2
	add esi,eax
	mov eax, dword ptr [esi]
	mov ebx,10
	mul ebx
	add eax,3
	mov dword ptr [esi],eax
	ret
put_3 endp

put_4 proc
 
	mov eax, operand_number
	mov esi, offset  operand
	shl eax,2
	add esi,eax
	mov eax, dword ptr [esi]
	mov ebx,10
	mul ebx
	add eax,4
	mov dword ptr [esi],eax
	ret
put_4 endp

put_5 proc
 
	mov eax, operand_number
	mov esi, offset operand
	shl eax,2
	add esi,eax
	mov eax, dword ptr [esi]
	mov ebx,10
	mul ebx
	add eax,5
	mov dword ptr [esi],eax
	ret
put_5 endp

put_6 proc
 
	mov eax, operand_number
	mov esi, offset operand
	shl eax,2
	add esi,eax
	mov eax, dword ptr [esi]
	mov ebx,10
	mul ebx
	add eax,6
	mov dword ptr [esi],eax
	ret
put_6 endp

put_7 proc
 
	mov eax, operand_number
	mov esi, offset operand
	shl eax,2
	add esi,eax
	mov eax, dword ptr [esi]
	mov ebx,10
	mul ebx
	add eax,7
	mov dword ptr [esi],eax
	ret
put_7 endp

put_8 proc
 
	mov eax, operand_number
	mov esi, offset operand
	shl eax,2
	add esi,eax
	mov eax, dword ptr [esi]
	mov ebx,10
	mul ebx
	add eax,8
	mov dword ptr [esi],eax
	ret
put_8 endp

put_9 proc
 
	mov eax, operand_number
	mov esi, offset operand
	shl eax,2
	add esi,eax
	mov eax, dword ptr [esi]
	mov ebx,10
	mul ebx
	add eax,9
	mov dword ptr [esi],eax
	ret
put_9 endp

put_plus proc
	mov eax, operand_number
	cmp eax, 0
	je skip
	mov esi, offset operand
	mov eax, dword ptr [esi]
	add esi,4
	mov ebx, dword ptr [esi]
	add eax,ebx
	mov dword ptr [esi] , 0
	sub esi , 4
	mov dword ptr [esi] , eax
	dec operand_number
	jmp final
	skip:
	inc operand_number
	final:
	ret
put_plus endp

put_minus proc
mov eax, operand_number
cmp eax, 0
je skip
mov esi, offset operand
mov eax, dword ptr [esi]
add esi,4
mov ebx, dword ptr [esi]
sub eax,ebx
mov dword ptr [esi] , 0
sub esi , 4
mov dword ptr [esi] , eax
dec operand_number
jmp final
skip:
inc operand_number
final:
ret
put_minus endp

put_inmultire proc
mov eax, operand_number
cmp eax, 0
je skip
mov esi, offset operand
mov eax, dword ptr [esi]
add esi,4
mov ebx, dword ptr [esi]
mul ebx
mov dword ptr [esi] , 0
sub esi , 4
	mov dword ptr [esi] , eax
dec operand_number
jmp final
skip:
inc operand_number
final:
ret
put_inmultire endp


do_nothing proc
ret
do_nothing endp

put_reset proc
	mov operand_number,0
	mov operand,0
ret
put_reset endp 

put_delete proc
	mov eax, operand_number
	mov esi, offset operand
	shl eax,2
	add esi,eax
	mov eax, dword ptr [esi]
	mov ebx,10
	xor edx , edx
	div ebx
	mov dword ptr [esi],eax
ret
put_delete endp

put_impartire proc
mov eax, operand_number
cmp eax, 0
je skip
mov esi, offset operand
mov eax, dword ptr [esi]
add esi,4
mov ebx, dword ptr [esi]
cmp edx,0
je final
xor edx,edx
div ebx
mov dword ptr [esi] , 0
sub esi , 4
	mov dword ptr [esi] , eax
dec operand_number
jmp final
skip:
inc operand_number
final:
ret
put_impartire endp

put_egal proc
	mov eax, operand_number
cmp eax, 0
je skip
mov esi, offset operand
mov ebx, dword ptr [esi]
	call ebx
	skip:
	
ret
put_egal endp

init_vector_functii proc
mov esi, offset vector_functii
mov eax, offset do_nothing
mov dword ptr [esi], eax
add esi,4
mov eax, offset  put_reset 
mov dword ptr[esi], eax
add esi,4
mov eax, offset put_delete
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_impartire
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_7
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_8
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_9
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_inmultire
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_4
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_5
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_6
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_minus
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_1
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_2
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_3
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_plus
mov dword ptr [esi], eax
add esi,4
mov eax, offset do_nothing
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_0
mov dword ptr [esi], eax
add esi,4
mov eax, offset do_nothing
mov dword ptr [esi], eax
add esi,4
mov eax, offset put_egal
mov dword ptr [esi], eax
add esi,4
ret
init_vector_functii endp;

numbergrid_selection proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax , [ebp+arg1] ;x
	mov ebx , 25
	sub eax,ebx
	mov bl , 50
	div bl 
	xor ah , ah 
	mov dl , al
	mov eax , [ebp+arg2] ;y
	mov bl, 30
	div bl
	xor ah, ah
	dec al
	dec al
	dec al
	mov dh , al 
	mov bl , 4
	mov al , dh 
	mul bl
	add al , dl
	mov nrselect , al 
	
	popa
	mov esp, ebp
	pop ebp
	ret
numbergrid_selection endp

callfunction proc

mov esi, offset vector_functii
xor eax,eax
mov al, nrselect
shl eax,2
add esi,eax
mov eax, dword ptr [esi]
call eax
ret
callfunction endp;

draw_number_final proc 
mov esi, offset operand
mov eax, operand_number
shl eax,2
add esi,eax
mov eax, dword ptr [esi]

push area
push eax
call draw_number
add esp, 8
ret
draw_number_final endp;

draw_spaces proc


	mov ecx , 10
	mov edx , 215
	
	
	et_for:
		push ecx
		push edx
		make_text_macro ' ',area, edx, 30
		pop edx
		pop ecx
		sub edx , 10
	loop et_for

ret
draw_spaces endp
	
draw proc 
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
			
	cmp eax, 1
	jz evt_click
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
	
	
	push 200 ;dim
	push 25  ;y
	push 25  ;x
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 200 ;dim
	push 85  ;y
	push 25  ;x
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 200 ;dim
	push 115  ;y
	push 25  ;x
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 200 ;dim
	push 145  ;y
	push 25  ;x
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 200 ;dim
	push 175  ;y
	push 25  ;x
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 200 ;dim
	push 205  ;y
	push 25  ;x
	push area
	call draw_horizontal_line
	add esp, 16 
	
	push 200 ;dim
	push 235  ;y
	push 25  ;x
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 210;
	push 25;
	push 25;
	push area
	call draw_vertical_line
	add esp, 16
	
	push 150;
	push 85;
	push 75;
	push area
	call draw_vertical_line
	add esp, 16
	
	push 150;
	push 85;
	push 125;
	push area
	call draw_vertical_line
	add esp, 16
	
	push 150;
	push 85;
	push 175;
	push area
	call draw_vertical_line
	add esp, 16
	
	push 210;
	push 25;
	push 225;
	push area
	call draw_vertical_line
	add esp, 16
	
	push 20
	push 215
	push 190
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 20
	push 220
	push 190
	push area
	call draw_horizontal_line
	add esp,16
	
	push 20
	push 160
	push 190
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 20
	push 190
	push 190
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 15
	push 185
	push 200
	push area
	call draw_vertical_line
	add esp, 16
	
	push 20
	push 100
	push 190
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 2
	push 95
	push 200
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 2
	push 105
	push 200
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 20
	push 100
	push 140
	push area
	call draw_horizontal_line
	add esp, 16
	
	push 15
	push 93
	push 140
	push area
	call draw_vertical_line
	add esp, 16
	
	make_text_macro '1',area, 45, 180
	make_text_macro '0',area, 95, 210
	make_text_macro '2',area, 95, 180
	make_text_macro '3', area, 145,180
	make_text_macro '4', area, 45, 150
	make_text_macro '5', area, 95, 150
	make_text_macro '6', area, 145,150
	make_text_macro '7', area, 45, 120
	make_text_macro '8', area, 95, 120
	make_text_macro '9', area, 145,120
	make_text_macro 'C', area, 95, 90
	make_text_macro 'X', area, 195,120
	
	
evt_timer:
	inc counter
evt_click: 
		mov eax , [ebp+arg3]
		cmp eax , 85
		jl final_draw
		cmp eax , 235
		jg final_draw
		mov eax , [ebp+arg2]
		cmp eax , 25
		jl final_draw
		cmp eax , 225
		jg final_draw
		mov eax , [ebp+arg3]
		mov ebx , [ebp+arg2]
		push eax
		push ebx
		call numbergrid_selection
		add esp , 8
		xor eax , eax
		mov al , nrselect
		push eax
		push offset intformat 
		call printf
		add esp , 8
		
		call callfunction 
		call draw_spaces
		call draw_number_final
		
	final_draw:
		
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
call init_vector_functii
	
	mov ecx , 19
	
	; et_for:
	
		; mov nrselect , cl
		; call callfunction
	
	; loop et_for

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