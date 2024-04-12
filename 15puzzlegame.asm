.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern fscanf: proc
extern fopen: proc
extern fprintf: proc
extern fclose: proc

includelib canvas.lib
extern BeginDrawing: proc

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.data
window_title DB "15 Puzzle Game - Assembly Project", 0
area_width equ 640
area_height equ 480
area DD 0

counter DD 1
Player_Score DD 1
Player_Clicks DD 1
time_penalty DD 0 
game_started DD 0
time_elapsed DD 0
time_seconds DD 0
choose_level DD 0

file_highscore DB "high_score.txt", 0
file_allscores DB "player_scores.txt", 0
file_format DB "%s", 0
format_write_nr DB "%d ", 0
format_read_nr DB "%d", 0
mode_write DB "w", 0 
check_highscore DD 0
new_score DD 0 
mode_read DB "r", 0 
current_score DD 0 

high_score DD 0
game_won DB 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20

button_11_x EQU 60
button_11_y EQU 30
button_size EQU 48




numbers_array DB 1,15,14,13,12,11,10,9,8,7,6,5,4,3,0,2
xsl_array DB 9,8,7,6,5,4,3,0,2
													;fiecare numar corespunde imaginii cu gigi
													;dupa ce adaugam toate imaginile, vom vedea care e ordinea numerelor a.i imaginile sa fie in ordine	
													;de ex: 3 -> 1 -> 7....
													;cand facem o mutare, intre imagini permutam si numere coresp. din array
													;verificam tot timpul daca s-a ajuns la ordinea corecta a numerelor a.i sa fie imaginile in ordine
													;daca da, jucatorul a castigat
						
.data
							;gigi_1 corespunde array[0]



include empty.inc
include gigi_1.inc
include gigi_2.inc
include gigi_3.inc
include gigi_4.inc
include gigi_5.inc
include gigi_6.inc
include gigi_7.inc
include gigi_8.inc
include gigi_9.inc
include gigi_10.inc
include gigi_11.inc
include gigi_12.inc
include gigi_13.inc
include gigi_14.inc
include gigi_15.inc
include xsl1.inc
include xsl2.inc
include xsl3.inc
include xsl4.inc
include xsl5.inc
include xsl6.inc
include xsl7.inc
include xsl8.inc
include xsl9.inc

include digits.inc
include letters.inc


.code

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

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y

verificare_poze proc 
	push ebp
	mov ebp, esp
	pusha 
	
	



verificare_poze endp

draw proc
	push ebp
	mov ebp, esp
	pusha		; pusheaza toate REGISTRELE pe stack EAX->ECX->EDX->EBX->ESP->EBP->ESI->EDI
	
	mov EAX, [ebp+arg1]
	cmp EAX,1 			; daca e 1 inseamna ca s-a dat click -> vom sari la functia evt_click
	je evt_click
	cmp EAX, 2 			;daca e 2 inseamna ca s-a scurs un interval de 200ms fara sa se dea click
	je evt_timer
	
	;INITIALIZEM CU PIXELI ALBI
	
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	
	
	initializare_meniu:
	;INITIALIZEM MENIUL DE INCEPUT
	make_text_macro '1', area, 240, 150
	make_text_macro '5', area, 250, 150
	
	make_text_macro 'P', area, 270, 150
	make_text_macro 'U', area, 280, 150
	make_text_macro 'Z', area, 290, 150
	make_text_macro 'Z', area, 300, 150
	make_text_macro 'L', area, 310, 150
	make_text_macro 'E', area, 320, 150
	
	make_text_macro 'G', area, 340, 150
	make_text_macro 'A', area, 350, 150
	make_text_macro 'M', area, 360, 150
	make_text_macro 'E', area, 370, 150
	
	make_text_macro 'S', area, 280, 200 
	make_text_macro 'T', area, 290, 200
	make_text_macro 'A', area, 300, 200
	make_text_macro 'R', area, 310, 200
	make_text_macro 'T', area, 320, 200
	
	make_text_macro 'L', area, 270, 250
	make_text_macro 'E', area, 280, 250
	make_text_macro 'V', area, 290, 250
	make_text_macro 'E', area, 300, 250
	make_text_macro 'L', area, 310, 250
	make_text_macro '1', area, 330, 250
	
	make_text_macro 'L', area, 270, 280
	make_text_macro 'E', area, 280, 280 
	make_text_macro 'V', area, 290, 280
	make_text_macro 'E', area, 300, 280
	make_text_macro 'L', area, 310, 280
	make_text_macro '2', area, 330, 280
	
	make_text_macro 'L', area, 250, 400
	make_text_macro 'E', area, 260, 400
	make_text_macro 'V', area, 270, 400
	make_text_macro 'E', area, 280, 400
	make_text_macro 'L', area, 290, 400
	
	make_text_macro 'C', area, 310, 400
	make_text_macro 'H', area, 320, 400
	make_text_macro 'O', area, 330, 400
	make_text_macro 'S', area, 340, 400
	make_text_macro 'E', area, 350, 400
	make_text_macro 'N', area, 360, 400
	
	
	
	
	evt_click:
	;mov eax, [ebp+arg3] 	; in EAX punem Y
	;mov EBX, area_width 
	;mul EBX			; EAX = Y * area_width
	;add EAX, [ebp+arg2]		;EAX = Y*area_width + X
	;shl EAX, 2				;inmultim totul cu 4 pt ca FIECARE PIXEL ESTE DWORD = 4 bytes
	;add EAX, area 			;pt a desena pe acel pixel, adunam la EAX, area de inceput ; AREA = pointer la adresa de inceput a vectorului de pixeli
	;mov dword ptr [EAX], 0FF0000h		; desenam pixelul pe care s-a dat click cu ROSU
	
	;mov dword ptr [EAX + 4], 0FF0000h	;daca adaugam aceste 2 linii, practic desenam atat pixelul selectat, cat si pixelul dinainte si de dupa pixelul selectat
	;mov dword ptr [EAX - 4], 0FF0000h
	
	
	;mov dword ptr [EAX + 4*area_width], 0FF0000h	;imaginea fiind un vector de pixeli, pt a ajunge la pixelul de SUB pixelul selectat, mergem de la PIXELUL selectat
	
	
	
	;MENIUL DE INCEPUT
	
	
	check_level_1:
	mov eax, [ebp+arg2]		;buton LEVEL 1
	cmp eax, 270
	jl check_level_1_fail
	cmp eax, 340
	jg check_level_1_fail
	mov eax, [ebp+arg3]
	cmp eax, 250
	jl check_level_1_fail
	cmp eax, 268 
	jg check_level_1_fail
	
	mov choose_level, 2
	make_text_macro '1', area, 390, 400
	
	
	check_level_1_fail:
		jmp check_level_2
	
	check_level_2:
	mov eax, [ebp+arg2]
	cmp eax, 270
	jl check_level_2_fail
	cmp eax, 340
	jg check_level_2_fail
	mov eax, [ebp+arg3]
	cmp eax, 283 
	jl check_level_2_fail
	cmp eax, 298
	jg check_level_2_fail
	
	mov choose_level, 1
	make_text_macro '2', area, 390, 400
	
	check_level_2_fail:
		
	
	
	start_menu:
	mov EAX, [ebp+arg2] ; X
	cmp EAX, 280
	jl start_button_fail
	cmp EAX, 320
	jg start_button_fail
	mov EAX, [ebp+arg3] ;Y
	cmp EAX, 180
	jl start_button_fail
	cmp EAX, 220
	jg start_button_fail
	
	check_if_level_chosen:
		mov eax, choose_level
		cmp choose_level, 0
		je no_level_chosen_message
		jmp level_was_chosen
		
	no_level_chosen_message:
	
		make_text_macro 'C', area, 200, 425
		make_text_macro 'H', area, 210, 425
		make_text_macro 'O', area, 220, 425
		make_text_macro 'O', area, 230, 425
		make_text_macro 'S', area, 240, 425
		make_text_macro 'E', area, 250, 425 
		
		make_text_macro 'L', area, 270, 425
		make_text_macro 'E', area, 280, 425
		make_text_macro 'V', area, 290, 425 
		make_text_macro 'E', area, 300, 425 
		make_text_macro 'L', area, 310, 425 
		
		make_text_macro 'F', area, 330, 425
		make_text_macro 'I', area, 340, 425 
		make_text_macro 'R', area, 350, 425
		make_text_macro 'S', area, 360, 425
		make_text_macro 'T', area, 370, 425 
		jmp evt_timer 
		
	level_was_chosen:	
		
		
		make_text_macro ' ', area, 200, 425		;stergem mesajul cu choose level first, dupa ce s-a dat start 
		make_text_macro ' ', area, 210, 425
		make_text_macro ' ', area, 220, 425
		make_text_macro ' ', area, 230, 425
		make_text_macro ' ', area, 240, 425
		make_text_macro ' ', area, 250, 425 
		
		make_text_macro ' ', area, 270, 425
		make_text_macro ' ', area, 280, 425
		make_text_macro ' ', area, 290, 425 
		make_text_macro ' ', area, 300, 425 
		make_text_macro ' ', area, 310, 425 
		
		make_text_macro ' ', area, 330, 425
		make_text_macro ' ', area, 340, 425 
		make_text_macro ' ', area, 350, 425
		make_text_macro ' ', area, 360, 425
		make_text_macro ' ', area, 370, 425 
	
	
	mov game_started, 1		; momentan start = choose_level_1, adica este nivelul 1
	
	no_start_menu_button:
	
	make_text_macro ' ', area, 240, 150
	make_text_macro ' ', area, 250, 150
	
	make_text_macro ' ', area, 270, 150
	make_text_macro ' ', area, 280, 150
	make_text_macro ' ', area, 290, 150
	make_text_macro ' ', area, 300, 150
	make_text_macro ' ', area, 310, 150
	make_text_macro ' ', area, 320, 150
	
	make_text_macro ' ', area, 340, 150
	make_text_macro ' ', area, 350, 150
	make_text_macro ' ', area, 360, 150
	make_text_macro ' ', area, 370, 150
	
	make_text_macro ' ', area, 280, 200 
	make_text_macro ' ', area, 290, 200
	make_text_macro ' ', area, 300, 200
	make_text_macro ' ', area, 310, 200
	make_text_macro ' ', area, 320, 200
	
	make_text_macro ' ', area, 270, 250		;stergem meniu level1 dupa ce se apasa start 
	make_text_macro ' ', area, 280, 250
	make_text_macro ' ', area, 290, 250
	make_text_macro ' ', area, 300, 250
	make_text_macro ' ', area, 310, 250
	make_text_macro ' ', area, 330, 250
	
	make_text_macro ' ', area, 270, 280
	make_text_macro ' ', area, 280, 280 
	make_text_macro ' ', area, 290, 280
	make_text_macro ' ', area, 300, 280
	make_text_macro ' ', area, 310, 280
	make_text_macro ' ', area, 330, 280
	
		
		
	button_fail:
		mov EAX, game_started
		cmp EAX, 1
		je show_score 
		jmp no_show_score
	
	show_score:
		
	
	make_text_macro 'P', area, 185, 315
	make_text_macro 'L', area, 195, 315 
	make_text_macro 'A', area, 205, 315
	make_text_macro 'Y', area, 215, 315
	make_text_macro 'E', area, 225, 315
	make_text_macro 'R', area, 235, 315 
	
	make_text_macro 'S', area, 255, 315
	make_text_macro 'C', area, 265, 315 
	make_text_macro 'O', area, 275, 315
	make_text_macro 'R', area, 285, 315
	make_text_macro 'E', area, 295, 315 
	
	make_text_macro 'T', area, 185, 340
	make_text_macro 'I', area, 195, 340
	make_text_macro 'M', area, 205, 340
	make_text_macro 'E', area, 215, 340
	
	make_text_macro 'E', area, 235, 340
	make_text_macro 'L', area, 245, 340
	make_text_macro 'A', area, 255, 340
	make_text_macro 'P', area, 265, 340
	make_text_macro 'S', area, 275, 340
	make_text_macro 'E', area, 285, 340
	make_text_macro 'D', area, 295, 340
	
	make_text_macro 'S', area, 380, 340
	make_text_macro 'E', area, 390, 340
	make_text_macro 'C', area, 400, 340
	make_text_macro 'O', area, 410, 340
	make_text_macro 'N', area, 420, 340
	make_text_macro 'D', area, 430, 340
	make_text_macro 'S', area, 440, 340
	
	make_text_macro 'H', area, 185, 365 
	make_text_macro 'I', area, 195, 365
	make_text_macro 'G', area, 205, 365
	make_text_macro 'H', area, 215, 365
	
	make_text_macro 'S', area, 235, 365
	make_text_macro 'C', area, 245, 365
	make_text_macro 'O', area, 255, 365
	make_text_macro 'R', area, 265, 365
	make_text_macro 'E', area, 275, 365
	
	cmp game_won, 1
	je skip_time
	
	
	mov eax, choose_level
	cmp eax, 1
	je load_level_1
	cmp eax, 2
	je load_level_2
	jmp no_level_chosen
	
	load_level_2:
		jmp verificare_poz11_lvl2 		; AICI VOM INCARCA POZELE DE LA CELALALT NIVEL, la fel ca la load_level_1:
		
	verificare_poz11_lvl2:
		;make_text_macro 'N', area, 400, 400 
		;jmp evt_timer

	mov eax, 0
	mov al, [xsl_array + 0]
	cmp al, 1
	je load_xsl_11_pic1
	cmp al, 2
	je load_xsl_11_pic2
	cmp al,3
	je load_xsl_11_pic3
	cmp al,4
	je load_xsl_11_pic4
	cmp al,5
	je load_xsl_11_pic5
	cmp al,6
	je load_xsl_11_pic6
	cmp al,7
	je load_xsl_11_pic7
	cmp al,8
	je load_xsl_11_pic8
	cmp al, 9
	je load_xsl_11_pic9
	cmp al, 0
	je load_xsl_11_empty
	
	load_xsl_11_pic1:
		lea esi, xsl1
		jmp load_xsl_11
	load_xsl_11_pic2:
		lea esi, xsl2
		jmp load_xsl_11
	load_xsl_11_pic3:
		lea esi, xsl3
		jmp load_xsl_11
	load_xsl_11_pic4:
		lea esi, xsl4
		jmp load_xsl_11
	load_xsl_11_pic5:
		lea esi, xsl5
		jmp load_xsl_11
	load_xsl_11_pic6:
		lea esi, xsl6
		jmp load_xsl_11
	load_xsl_11_pic7:
		lea esi, xsl7
		jmp load_xsl_11
	load_xsl_11_pic8:
		lea esi, xsl8
		jmp load_xsl_11
	load_xsl_11_pic9:
		lea esi, xsl9
		jmp load_xsl_11
	load_xsl_11_empty:
		lea esi, empty
		jmp load_xsl_11
		
	load_xsl_11:
		mov eax, area_width
		mov ebx, 30
		mul ebx
		add EAX, 210
		shl eax, 2
		add eax, area
		mov edx, 48
		mov ecx, 48
		
		loop_xsl_1:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_xsl_1
		je next_line_xsl_1
		
	next_line_xsl_1:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_xsl_1
		
		
	verificare_poz12_lvl2:
		

	mov eax, 0
	mov al, [xsl_array + 1]
	cmp al, 1
	je load_xsl_12_pic1
	cmp al, 2
	je load_xsl_12_pic2
	cmp al,3
	je load_xsl_12_pic3
	cmp al,4
	je load_xsl_12_pic4
	cmp al,5
	je load_xsl_12_pic5
	cmp al,6
	je load_xsl_12_pic6
	cmp al,7
	je load_xsl_12_pic7
	cmp al,8
	je load_xsl_12_pic8
	cmp al, 9
	je load_xsl_12_pic9
	cmp al, 0
	je load_xsl_12_empty
	
	load_xsl_12_pic1:
		lea esi, xsl1
		jmp load_xsl_12
	load_xsl_12_pic2:
		lea esi, xsl2
		jmp load_xsl_12
	load_xsl_12_pic3:
		lea esi, xsl3
		jmp load_xsl_12
	load_xsl_12_pic4:
		lea esi, xsl4
		jmp load_xsl_12
	load_xsl_12_pic5:
		lea esi, xsl5
		jmp load_xsl_12
	load_xsl_12_pic6:
		lea esi, xsl6
		jmp load_xsl_12
	load_xsl_12_pic7:
		lea esi, xsl7
		jmp load_xsl_12
	load_xsl_12_pic8:
		lea esi, xsl8
		jmp load_xsl_12
	load_xsl_12_pic9:
		lea esi, xsl9
		jmp load_xsl_12
	load_xsl_12_empty:
		lea esi, empty
		jmp load_xsl_12
		
	load_xsl_12:
		mov eax, area_width
		mov ebx, 30
		mul ebx
		add EAX, 260
		shl eax, 2
		add eax, area
		mov edx, 48
		mov ecx, 48
		
		loop_xsl_2:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_xsl_2
		je next_line_xsl_2
		
	next_line_xsl_2:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_xsl_2
		
		
	verificare_poz13_lvl2:
		;make_text_macro 'N', area, 400, 400 
		;jmp evt_timer

	mov eax, 0
	mov al, [xsl_array + 2]
	cmp al, 1
	je load_xsl_13_pic1
	cmp al, 2
	je load_xsl_13_pic2
	cmp al,3
	je load_xsl_13_pic3
	cmp al,4
	je load_xsl_13_pic4
	cmp al,5
	je load_xsl_13_pic5
	cmp al,6
	je load_xsl_13_pic6
	cmp al,7
	je load_xsl_13_pic7
	cmp al,8
	je load_xsl_13_pic8
	cmp al, 9
	je load_xsl_13_pic9
	cmp al, 0
	je load_xsl_13_empty
	
	load_xsl_13_pic1:
		lea esi, xsl1
		jmp load_xsl_13
	load_xsl_13_pic2:
		lea esi, xsl2
		jmp load_xsl_13
	load_xsl_13_pic3:
		lea esi, xsl3
		jmp load_xsl_13
	load_xsl_13_pic4:
		lea esi, xsl4
		jmp load_xsl_13
	load_xsl_13_pic5:
		lea esi, xsl5
		jmp load_xsl_13
	load_xsl_13_pic6:
		lea esi, xsl6
		jmp load_xsl_13
	load_xsl_13_pic7:
		lea esi, xsl7
		jmp load_xsl_13
	load_xsl_13_pic8:
		lea esi, xsl8
		jmp load_xsl_13
	load_xsl_13_pic9:
		lea esi, xsl9
		jmp load_xsl_13
	load_xsl_13_empty:
		lea esi, empty
		jmp load_xsl_13
		
	load_xsl_13:
		mov eax, area_width
		mov ebx, 30
		mul ebx
		add EAX, 310
		shl eax, 2
		add eax, area
		mov edx, 48
		mov ecx, 48
		
		loop_xsl_3:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_xsl_3
		je next_line_xsl_3
		
	next_line_xsl_3:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_xsl_3
		
		
	verificare_poz21_lvl2:

	mov eax, 0
	mov al, [xsl_array + 3]
	cmp al, 1
	je load_xsl_21_pic1
	cmp al, 2
	je load_xsl_21_pic2
	cmp al,3
	je load_xsl_21_pic3
	cmp al,4
	je load_xsl_21_pic4
	cmp al,5
	je load_xsl_21_pic5
	cmp al,6
	je load_xsl_21_pic6
	cmp al,7
	je load_xsl_21_pic7
	cmp al,8
	je load_xsl_21_pic8
	cmp al, 9
	je load_xsl_21_pic9
	cmp al, 0
	je load_xsl_21_empty
	
	load_xsl_21_pic1:
		lea esi, xsl1
		jmp load_xsl_21
	load_xsl_21_pic2:
		lea esi, xsl2
		jmp load_xsl_21
	load_xsl_21_pic3:
		lea esi, xsl3
		jmp load_xsl_21
	load_xsl_21_pic4:
		lea esi, xsl4
		jmp load_xsl_21
	load_xsl_21_pic5:
		lea esi, xsl5
		jmp load_xsl_21
	load_xsl_21_pic6:
		lea esi, xsl6
		jmp load_xsl_21
	load_xsl_21_pic7:
		lea esi, xsl7
		jmp load_xsl_21
	load_xsl_21_pic8:
		lea esi, xsl8
		jmp load_xsl_21
	load_xsl_21_pic9:
		lea esi, xsl9
		jmp load_xsl_21
	load_xsl_21_empty:
		lea esi, empty
		jmp load_xsl_21
		
	load_xsl_21:
		mov eax, area_width
		mov ebx, 80
		mul ebx
		add EAX, 210
		shl eax, 2
		add eax, area
		mov edx, 48
		mov ecx, 48
		
		loop_xsl_4:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_xsl_4
		je next_line_xsl_4
		
	next_line_xsl_4:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_xsl_4


	verificare_poz22_lvl2:

	mov eax, 0
	mov al, [xsl_array + 4]
	cmp al, 1
	je load_xsl_22_pic1
	cmp al, 2
	je load_xsl_22_pic2
	cmp al,3
	je load_xsl_22_pic3
	cmp al,4
	je load_xsl_22_pic4
	cmp al,5
	je load_xsl_22_pic5
	cmp al,6
	je load_xsl_22_pic6
	cmp al,7
	je load_xsl_22_pic7
	cmp al,8
	je load_xsl_22_pic8
	cmp al, 9
	je load_xsl_22_pic9
	cmp al, 0
	je load_xsl_22_empty
	
	load_xsl_22_pic1:
		lea esi, xsl1
		jmp load_xsl_22
	load_xsl_22_pic2:
		lea esi, xsl2
		jmp load_xsl_22
	load_xsl_22_pic3:
		lea esi, xsl3
		jmp load_xsl_22
	load_xsl_22_pic4:
		lea esi, xsl4
		jmp load_xsl_22
	load_xsl_22_pic5:
		lea esi, xsl5
		jmp load_xsl_22
	load_xsl_22_pic6:
		lea esi, xsl6
		jmp load_xsl_22
	load_xsl_22_pic7:
		lea esi, xsl7
		jmp load_xsl_22
	load_xsl_22_pic8:
		lea esi, xsl8
		jmp load_xsl_22
	load_xsl_22_pic9:
		lea esi, xsl9
		jmp load_xsl_22
	load_xsl_22_empty:
		lea esi, empty
		jmp load_xsl_22
		
	load_xsl_22:
		mov eax, area_width
		mov ebx, 80
		mul ebx
		add EAX, 260
		shl eax, 2
		add eax, area
		mov edx, 48
		mov ecx, 48
		
		loop_xsl_5:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_xsl_5
		je next_line_xsl_5
		
	next_line_xsl_5:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_xsl_5
		
	
	verificare_poz23_lvl2:

	mov eax, 0
	mov al, [xsl_array + 5]
	cmp al, 1
	je load_xsl_23_pic1
	cmp al, 2
	je load_xsl_23_pic2
	cmp al,3
	je load_xsl_23_pic3
	cmp al,4
	je load_xsl_23_pic4
	cmp al,5
	je load_xsl_23_pic5
	cmp al,6
	je load_xsl_23_pic6
	cmp al,7
	je load_xsl_23_pic7
	cmp al,8
	je load_xsl_23_pic8
	cmp al, 9
	je load_xsl_23_pic9
	cmp al, 0
	je load_xsl_23_empty
	
	load_xsl_23_pic1:
		lea esi, xsl1
		jmp load_xsl_23
	load_xsl_23_pic2:
		lea esi, xsl2
		jmp load_xsl_23
	load_xsl_23_pic3:
		lea esi, xsl3
		jmp load_xsl_23
	load_xsl_23_pic4:
		lea esi, xsl4
		jmp load_xsl_23
	load_xsl_23_pic5:
		lea esi, xsl5
		jmp load_xsl_23
	load_xsl_23_pic6:
		lea esi, xsl6
		jmp load_xsl_23
	load_xsl_23_pic7:
		lea esi, xsl7
		jmp load_xsl_23
	load_xsl_23_pic8:
		lea esi, xsl8
		jmp load_xsl_23
	load_xsl_23_pic9:
		lea esi, xsl9
		jmp load_xsl_23
	load_xsl_23_empty:
		lea esi, empty
		jmp load_xsl_23
		
	load_xsl_23:
		mov eax, area_width
		mov ebx, 80
		mul ebx
		add EAX, 310
		shl eax, 2
		add eax, area
		mov edx, 48
		mov ecx, 48
		
		loop_xsl_6:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_xsl_6
		je next_line_xsl_6
		
	next_line_xsl_6:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_xsl_6
		
		
	verificare_poz31_lvl2:

	mov eax, 0
	mov al, [xsl_array + 6]
	cmp al, 1
	je load_xsl_31_pic1
	cmp al, 2
	je load_xsl_31_pic2
	cmp al,3
	je load_xsl_31_pic3
	cmp al,4
	je load_xsl_31_pic4
	cmp al,5
	je load_xsl_31_pic5
	cmp al,6
	je load_xsl_31_pic6
	cmp al,7
	je load_xsl_31_pic7
	cmp al,8
	je load_xsl_31_pic8
	cmp al, 9
	je load_xsl_31_pic9
	cmp al, 0
	je load_xsl_31_empty
	
	load_xsl_31_pic1:
		lea esi, xsl1
		jmp load_xsl_31
	load_xsl_31_pic2:
		lea esi, xsl2
		jmp load_xsl_31
	load_xsl_31_pic3:
		lea esi, xsl3
		jmp load_xsl_31
	load_xsl_31_pic4:
		lea esi, xsl4
		jmp load_xsl_31
	load_xsl_31_pic5:
		lea esi, xsl5
		jmp load_xsl_31
	load_xsl_31_pic6:
		lea esi, xsl6
		jmp load_xsl_31
	load_xsl_31_pic7:
		lea esi, xsl7
		jmp load_xsl_31
	load_xsl_31_pic8:
		lea esi, xsl8
		jmp load_xsl_31
	load_xsl_31_pic9:
		lea esi, xsl9
		jmp load_xsl_31
	load_xsl_31_empty:
		lea esi, empty
		jmp load_xsl_31
		
	load_xsl_31:
		mov eax, area_width
		mov ebx, 130
		mul ebx
		add EAX, 210
		shl eax, 2
		add eax, area
		mov edx, 48
		mov ecx, 48
		
		loop_xsl_7:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_xsl_7
		je next_line_xsl_7
		
	next_line_xsl_7:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_xsl_7
		
		
	verificare_poz32_lvl2:

	mov eax, 0
	mov al, [xsl_array + 7]
	cmp al, 1
	je load_xsl_32_pic1
	cmp al, 2
	je load_xsl_32_pic2
	cmp al,3
	je load_xsl_32_pic3
	cmp al,4
	je load_xsl_32_pic4
	cmp al,5
	je load_xsl_32_pic5
	cmp al,6
	je load_xsl_32_pic6
	cmp al,7
	je load_xsl_32_pic7
	cmp al,8
	je load_xsl_32_pic8
	cmp al, 9
	je load_xsl_32_pic9
	cmp al, 0
	je load_xsl_32_empty
	
	load_xsl_32_pic1:
		lea esi, xsl1
		jmp load_xsl_32
	load_xsl_32_pic2:
		lea esi, xsl2
		jmp load_xsl_32
	load_xsl_32_pic3:
		lea esi, xsl3
		jmp load_xsl_32
	load_xsl_32_pic4:
		lea esi, xsl4
		jmp load_xsl_32
	load_xsl_32_pic5:
		lea esi, xsl5
		jmp load_xsl_32
	load_xsl_32_pic6:
		lea esi, xsl6
		jmp load_xsl_32
	load_xsl_32_pic7:
		lea esi, xsl7
		jmp load_xsl_32
	load_xsl_32_pic8:
		lea esi, xsl8
		jmp load_xsl_32
	load_xsl_32_pic9:
		lea esi, xsl9
		jmp load_xsl_32
	load_xsl_32_empty:
		lea esi, empty
		jmp load_xsl_32
		
	load_xsl_32:
		mov eax, area_width
		mov ebx, 130
		mul ebx
		add EAX, 260
		shl eax, 2
		add eax, area
		mov edx, 48
		mov ecx, 48
		
		loop_xsl_8:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_xsl_8
		je next_line_xsl_8
		
	next_line_xsl_8:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_xsl_8
	
	verificare_poz33_lvl2:

	mov eax, 0
	mov al, [xsl_array + 8]
	cmp al, 1
	je load_xsl_33_pic1
	cmp al, 2
	je load_xsl_33_pic2
	cmp al,3
	je load_xsl_33_pic3
	cmp al,4
	je load_xsl_33_pic4
	cmp al,5
	je load_xsl_33_pic5
	cmp al,6
	je load_xsl_33_pic6
	cmp al,7
	je load_xsl_33_pic7
	cmp al,8
	je load_xsl_33_pic8
	cmp al, 9
	je load_xsl_33_pic9
	cmp al, 0
	je load_xsl_33_empty
	
	load_xsl_33_pic1:
		lea esi, xsl1
		jmp load_xsl_33
	load_xsl_33_pic2:
		lea esi, xsl2
		jmp load_xsl_33
	load_xsl_33_pic3:
		lea esi, xsl3
		jmp load_xsl_33
	load_xsl_33_pic4:
		lea esi, xsl4
		jmp load_xsl_33
	load_xsl_33_pic5:
		lea esi, xsl5
		jmp load_xsl_33
	load_xsl_33_pic6:
		lea esi, xsl6
		jmp load_xsl_33
	load_xsl_33_pic7:
		lea esi, xsl7
		jmp load_xsl_33
	load_xsl_33_pic8:
		lea esi, xsl8
		jmp load_xsl_33
	load_xsl_33_pic9:
		lea esi, xsl9
		jmp load_xsl_33
	load_xsl_33_empty:
		lea esi, empty
		jmp load_xsl_33
		
	load_xsl_33:
		mov eax, area_width
		mov ebx, 130
		mul ebx
		add EAX, 310
		shl eax, 2
		add eax, area
		mov edx, 48
		mov ecx, 48
		
		loop_xsl_9:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_xsl_9
		je next_line_xsl_9
		
	next_line_xsl_9:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_xsl_9
	
		
	jmp evt_timer 
		
		
	
	load_level_1:
	
	no_show_score:
	
	
	;jmp verificare_poza_1
	;interschimbare:
		;mov EAX, 0
		;mov EBX, 0
		;mov BL, [numbers_array+2]
		;mov AL, [numbers_array+0]
		;mov [numbers_array+1], AL		; IN ACEST MOD INTERSCHIMBAM POZELE CAND DAM CLICK PE ELE
		;mov [numbers_array+0], BL		; DOAR UN PROTOTIP, TREBUIE VERIFICAT PRIMA DATA PE CE POZA DAM CLICK, SI CU CARE SE SCHIMBA 
		
	verificare_poza_11:
	mov EAX, 0
	mov AL, [numbers_array + 0]	;se verifica ce poza ESTE pe POZITIA 0 DIN ARRAY pt a vedea ce poza INCARCAM 
	cmp AL, 1
	je load_gigi_11_pic1
	cmp AL, 2
	je load_gigi_11_pic2
	cmp  AL, 3
	je load_gigi_11_pic3
	cmp AL,4
	je load_gigi_11_pic4
	cmp AL, 5
	je load_gigi_11_pic5
	cmp AL, 6
	je load_gigi_11_pic6
	cmp AL, 7
	je load_gigi_11_pic7
	cmp AL, 8
	je load_gigi_11_pic8
	cmp AL, 9
	je load_gigi_11_pic9
	cmp AL, 10
	je load_gigi_11_pic10
	cmp AL, 11
	je load_gigi_11_pic11
	cmp AL, 12
	je load_gigi_11_pic12
	cmp AL, 13
	je load_gigi_11_pic13
	cmp AL, 14
	je load_gigi_11_pic14
	cmp AL, 15
	je load_gigi_11_pic15
	cmp AL, 0
	je load_gigi_11_empty
							; verificam acest lucru pt fiecare 15 poze 
	load_gigi_11_pic1:			; PT FIECARE POZA VERIFICAM CORESPONDENTUL EI IN ARRAY, iar cand se FACE O MUTARE, INTERSCHIMBAM SI IN ARRAY, pt a vedea ce poza se incarca
		;jmp interschimbare
		
		lea ESI, gigi_1
		jmp load_picture_11
	load_gigi_11_pic2:
		lea ESI, gigi_2
		jmp load_picture_11
	load_gigi_11_pic3:
		lea ESI, gigi_3
		jmp load_picture_11

	load_gigi_11_pic4:
		lea ESI, gigi_4
		jmp load_picture_11
	load_gigi_11_pic5:
		lea ESI, gigi_5
		jmp load_picture_11
		
	load_gigi_11_pic6:
		lea ESI, gigi_6
		jmp load_picture_11
	load_gigi_11_pic7:
		lea ESI, gigi_7
		jmp load_picture_11
	load_gigi_11_pic8:
		lea ESI, gigi_8
		jmp load_picture_11
	load_gigi_11_pic9:
		lea ESI, gigi_9
		jmp load_picture_11
	load_gigi_11_pic10:
		lea ESI, gigi_10
		jmp load_picture_11
	load_gigi_11_pic11:
		lea ESI, gigi_11
		jmp load_picture_11
	load_gigi_11_pic12:
		lea ESI, gigi_12
		jmp load_picture_11
	load_gigi_11_pic13:
		lea ESI, gigi_13
		jmp load_picture_11
	load_gigi_11_pic14:
		lea ESI, gigi_14
		jmp load_picture_11
	load_gigi_11_pic15:
		lea ESI, gigi_15
		jmp load_picture_11
	load_gigi_11_empty:
		lea ESI, empty
		jmp load_picture_11
		
	
	load_picture_11:
	mov EAX, 640 
	mov EBX, 10
	mul EBX
	add EAX, 210		;EAX = Y = 10, X = 40
	shl EAX, 2
	add EAX, area
	mov EDX, 48 ; pentru a tine cont de LINII, avem 48 de "linii" pt imaginea cu GIGI
	mov ECX, 48		;GIGI are 48x48
	
	
	loop_gigi_1:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_gigi_1
		je next_line_gigi_1
		
	next_line_gigi_1:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_1
		
	verificare_poza_12:
		mov EAX, 0
		mov AL, [numbers_array + 1]	;se verifica ce poza ESTE pe POZITIA 1 DIN ARRAY pt a vedea ce poza INCARCAM 
		cmp AL, 1
		je load_gigi_12_pic1
		cmp AL, 2
		je load_gigi_12_pic2
		cmp  AL, 3
		je load_gigi_12_pic3
		cmp AL, 4
		je load_gigi_12_pic4
		cmp AL, 5
		je load_gigi_12_pic5
		cmp AL, 6
		je load_gigi_12_pic6
		cmp AL, 7
		je load_gigi_12_pic7
		cmp AL, 8
		je load_gigi_12_pic8
		cmp  AL, 9
		je load_gigi_12_pic9
		cmp AL, 10
		je load_gigi_12_pic10
		cmp AL, 11
		je load_gigi_12_pic11
		cmp AL, 12
		je load_gigi_12_pic12
		cmp AL, 13
		je load_gigi_12_pic13
		cmp AL, 14
		je load_gigi_12_pic14
		cmp AL, 15
		je load_gigi_12_pic15
		
		cmp AL, 0
		je load_gigi_12_empty
		
		
	load_gigi_12_pic1:
		lea ESI, gigi_1
		jmp load_picture_12
	load_gigi_12_pic2:
		lea ESI, gigi_2
		jmp load_picture_12
	load_gigi_12_pic3:
		lea ESI, gigi_3
		jmp load_picture_12
	load_gigi_12_pic4:
		lea ESI, gigi_4
		jmp load_picture_12
	load_gigi_12_pic5:
		lea ESI, gigi_5
		jmp load_picture_12
	load_gigi_12_pic6:
		lea ESI, gigi_6
		jmp load_picture_12
	load_gigi_12_pic7:
		lea ESI, gigi_7
		jmp load_picture_12
	load_gigi_12_pic8:
		lea ESI, gigi_8
		jmp load_picture_12
	load_gigi_12_pic9:
		lea ESI, gigi_9
		jmp load_picture_12
	load_gigi_12_pic10:
		lea ESI, gigi_10
		jmp load_picture_12
	load_gigi_12_pic11:
		lea ESI, gigi_11
		jmp load_picture_12
	load_gigi_12_pic12:
		lea ESI, gigi_12
		jmp load_picture_12
	load_gigi_12_pic13:
		lea ESI, gigi_13
		jmp load_picture_12
	load_gigi_12_pic14:
		lea ESI, gigi_14
		jmp load_picture_12
	load_gigi_12_pic15:
		lea ESI, gigi_15
		jmp load_picture_12
		
		
		
	load_gigi_12_empty:
		lea ESI, empty
		jmp load_picture_12
		
	load_picture_12:
		mov EAX, area_width
		mov EBX, 10
		mul EBX
		add EAX, 260
		shl EAX, 2
		add EAX, area
		mov EDX, 48
		mov ECX, 48
	
	loop_gigi_2:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_gigi_2
		je next_line_gigi_2
		
	next_line_gigi_2:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_2
		
	verificare_poza_13:
		mov EAX, 0
		mov AL, [numbers_array + 2]	;se verifica ce poza ESTE pe POZITIA 2 DIN ARRAY pt a vedea ce poza INCARCAM 
		cmp AL, 1
		je load_gigi_13_pic1
		cmp AL, 2
		je load_gigi_13_pic2
		cmp  AL, 3
		je load_gigi_13_pic3
		cmp AL, 4
		je load_gigi_13_pic4
		cmp AL, 5
		je load_gigi_13_pic5
		cmp AL, 6
		je load_gigi_13_pic6
		cmp AL, 7
		je load_gigi_13_pic7
		cmp  AL, 8
		je load_gigi_13_pic8
		cmp AL, 9
		je load_gigi_13_pic9
		cmp AL, 10
		je load_gigi_13_pic10
		cmp AL, 11
		je load_gigi_13_pic11
		cmp AL, 12
		je load_gigi_13_pic12
		cmp  AL, 13
		je load_gigi_13_pic13
		cmp AL, 14
		je load_gigi_13_pic14
		cmp AL, 15
		je load_gigi_13_pic15
		cmp AL, 0
		je load_gigi_13_empty
		
		load_gigi_13_pic1:
			lea ESI, gigi_1
			jmp load_picture_13
		load_gigi_13_pic2:
			lea ESI, gigi_2
			jmp load_picture_13
		load_gigi_13_pic3:
			lea ESI, gigi_3
			jmp load_picture_13
		load_gigi_13_pic4:
			lea ESI, gigi_4
			jmp load_picture_13
		load_gigi_13_pic5:
			lea ESI, gigi_5
			jmp load_picture_13
		load_gigi_13_pic6:
			lea ESI, gigi_6
			jmp load_picture_13
		load_gigi_13_pic7:
			lea ESI, gigi_7
			jmp load_picture_13
		load_gigi_13_pic8:
			lea ESI, gigi_8
			jmp load_picture_13
		load_gigi_13_pic9:
			lea ESI, gigi_9
			jmp load_picture_13
		load_gigi_13_pic10:
			lea ESI, gigi_10
			jmp load_picture_13
		load_gigi_13_pic11:
			lea ESI, gigi_11
			jmp load_picture_13
		load_gigi_13_pic12:
			lea ESI, gigi_12
			jmp load_picture_13
		load_gigi_13_pic13:
			lea ESI, gigi_13
			jmp load_picture_13
		load_gigi_13_pic14:
			lea ESI, gigi_14
			jmp load_picture_13
		load_gigi_13_pic15:
			lea ESI, gigi_15
			jmp load_picture_13
		load_gigi_13_empty:
			lea ESI, empty
			jmp load_picture_13


			
		load_picture_13:
			mov EAX, area_width
			mov EBX, 10
			mul EBX
			add EAX, 310
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
		
	loop_gigi_3:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_gigi_3
		je next_line_gigi_3
		
	next_line_gigi_3:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_3
		
		
	;GIGI 4
	verificare_poza_14:
		mov EAX, 0
		mov AL, [numbers_array + 3]	;se verifica ce poza ESTE pe POZITIA 3 DIN ARRAY pt a vedea ce poza INCARCAM 
		cmp AL, 1
		je load_gigi_14_pic1
		cmp AL, 2
		je load_gigi_14_pic2
		cmp  AL, 3
		je load_gigi_14_pic3
		cmp AL, 4
		je load_gigi_14_pic4
		cmp AL, 5
		je load_gigi_14_pic5
		cmp AL, 6
		je load_gigi_14_pic6
		cmp AL, 7
		je load_gigi_14_pic7
		cmp  AL, 8
		je load_gigi_14_pic8
		cmp AL, 9
		je load_gigi_14_pic9
		cmp AL, 10
		je load_gigi_14_pic10
		cmp AL, 11
		je load_gigi_14_pic11
		cmp AL, 12
		je load_gigi_14_pic12
		cmp  AL, 13
		je load_gigi_14_pic13
		cmp AL, 14
		je load_gigi_14_pic14
		cmp AL, 15
		je load_gigi_14_pic15
		cmp AL, 0
		je load_gigi_14_empty
		
		
		load_gigi_14_pic1:
			lea ESI, gigi_1
			jmp load_picture_14
		load_gigi_14_pic2:
			lea ESI, gigi_2
			jmp load_picture_14
		load_gigi_14_pic3:
			lea ESI, gigi_3
			jmp load_picture_14
		load_gigi_14_pic4:
			lea ESI, gigi_4
			jmp load_picture_14
		load_gigi_14_pic5:
			lea ESI, gigi_5
			jmp load_picture_14
		load_gigi_14_pic6:
			lea ESI, gigi_6
			jmp load_picture_14
		load_gigi_14_pic7:
			lea ESI, gigi_7
			jmp load_picture_14
		load_gigi_14_pic8:
			lea ESI, gigi_8
			jmp load_picture_14
		load_gigi_14_pic9:
			lea ESI, gigi_9
			jmp load_picture_14
		load_gigi_14_pic10:
			lea ESI, gigi_10
			jmp load_picture_14
		load_gigi_14_pic11:
			lea ESI, gigi_11
			jmp load_picture_14
		load_gigi_14_pic12:
			lea ESI, gigi_12
			jmp load_picture_14
		load_gigi_14_pic13:
			lea ESI, gigi_13
			jmp load_picture_14
		load_gigi_14_pic14:
			lea ESI, gigi_14
			jmp load_picture_14
		load_gigi_14_pic15:
			lea ESI, gigi_15
			jmp load_picture_14
		load_gigi_14_empty:
			lea ESI, empty
			jmp load_picture_14
			
		load_picture_14:
			mov EAX, area_width
			mov EBX, 10
			mul EBX
			add EAX, 360
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
	
	loop_gigi_4:
		mov EBX, [ESI]
		mov dword ptr [EAX], EBX
		add EAX, 4
		add ESI, 4
		
		dec ECX
		cmp ECX, 0
		jne loop_gigi_4
		je next_line_gigi_4
		
	next_line_gigi_4:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_4
		
		
	verificare_poza_21:
		mov EAX, 0
		mov AL, [numbers_array + 4]	;se verifica ce poza ESTE pe POZITIA 4 DIN ARRAY pt a vedea ce poza INCARCAM 
		cmp AL, 1
		je load_gigi_21_pic1
		cmp AL, 2
		je load_gigi_21_pic2
		cmp AL, 3
		je load_gigi_21_pic3
		cmp AL, 4
		je load_gigi_21_pic4
		cmp AL, 5
		je load_gigi_21_pic5
		cmp AL, 6
		je load_gigi_21_pic6
		cmp AL, 7
		je load_gigi_21_pic7
		cmp AL, 8
		je load_gigi_21_pic8
		cmp AL, 9
		je load_gigi_21_pic9
		cmp AL, 10
		je load_gigi_21_pic10
		cmp AL, 11
		je load_gigi_21_pic11
		cmp AL, 12
		je load_gigi_21_pic12
		cmp AL, 13
		je load_gigi_21_pic13
		cmp AL, 14
		je load_gigi_21_pic14
		cmp AL, 15
		je load_gigi_21_pic15
		cmp AL, 0
		je load_gigi_21_empty

		
		load_gigi_21_pic1:
			lea ESI, gigi_1
			jmp load_picture_21
		load_gigi_21_pic2:
			lea ESI, gigi_2
			jmp load_picture_21
		load_gigi_21_pic3:
			lea ESI, gigi_3
			jmp load_picture_21
		load_gigi_21_pic4:
			lea ESI, gigi_4
			jmp load_picture_21
		load_gigi_21_pic5:
			lea ESI, gigi_5
			jmp load_picture_21
		load_gigi_21_pic6:
			lea ESI, gigi_6
			jmp load_picture_21
		load_gigi_21_pic7:
			lea ESI, gigi_7
			jmp load_picture_21
		load_gigi_21_pic8:
			lea ESI, gigi_8
			jmp load_picture_21
		load_gigi_21_pic9:
			lea ESI, gigi_9
			jmp load_picture_21
		load_gigi_21_pic10:
			lea ESI, gigi_10
			jmp load_picture_21
		load_gigi_21_pic11:
			lea ESI, gigi_11
			jmp load_picture_21
		load_gigi_21_pic12:
			lea ESI, gigi_12
			jmp load_picture_21
		load_gigi_21_pic13:
			lea ESI, gigi_13
			jmp load_picture_21
		load_gigi_21_pic14:
			lea ESI, gigi_14
			jmp load_picture_21
		load_gigi_21_pic15:
			lea ESI, gigi_15
			jmp load_picture_21
		load_gigi_21_empty:
			lea ESI, empty
			jmp load_picture_21
			
		load_picture_21:
			mov EAX, area_width
			mov EBX, 60
			mul EBX
			add EAX, 210
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_5:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_5
			je next_line_gigi_5
		
	next_line_gigi_5:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_5
		
	verificare_poza_22_empty:
		mov EAX, 0
		mov AL, [numbers_array + 5]	;se verifica ce poza ESTE pe POZITIA 5 DIN ARRAY pt a vedea ce poza INCARCAM 
		cmp AL, 1
		je load_gigi_22_pic1
		cmp AL, 2
		je load_gigi_22_pic2
		cmp  AL, 3
		je load_gigi_22_pic3
		cmp AL, 4
		je load_gigi_22_pic4
		cmp AL, 5
		je load_gigi_22_pic5
		cmp AL, 6
		je load_gigi_22_pic6
		cmp AL, 7
		je load_gigi_22_pic7
		cmp  AL, 8
		je load_gigi_22_pic8
		cmp AL, 9
		je load_gigi_22_pic9
		cmp AL, 10
		je load_gigi_22_pic10
		cmp AL, 11
		je load_gigi_22_pic11
		cmp AL, 12
		je load_gigi_22_pic12
		cmp  AL, 13
		je load_gigi_22_pic13
		cmp AL, 14
		je load_gigi_22_pic14
		cmp AL, 15
		je load_gigi_22_pic15
		cmp AL, 0
		je load_gigi_22_empty
		
		load_gigi_22_pic1:
			lea ESI, gigi_1
			jmp load_picture_22
		load_gigi_22_pic2:
			lea ESI, gigi_2
			jmp load_picture_22
		load_gigi_22_pic3:
			lea ESI, gigi_3
			jmp load_picture_22
		load_gigi_22_pic4:
			lea ESI, gigi_4
			jmp load_picture_22
		load_gigi_22_pic5:
			lea ESI, gigi_5
			jmp load_picture_22
		load_gigi_22_pic6:
			lea ESI, gigi_6
			jmp load_picture_22
		load_gigi_22_pic7:
			lea ESI, gigi_7
			jmp load_picture_22
		load_gigi_22_pic8:
			lea ESI, gigi_8
			jmp load_picture_22
		load_gigi_22_pic9:
			lea ESI, gigi_9
			jmp load_picture_22
		load_gigi_22_pic10:
			lea ESI, gigi_10
			jmp load_picture_22
		load_gigi_22_pic11:
			lea ESI, gigi_11
			jmp load_picture_22
		load_gigi_22_pic12:
			lea ESI, gigi_12
			jmp load_picture_22
		load_gigi_22_pic13:
			lea ESI, gigi_13
			jmp load_picture_22
		load_gigi_22_pic14:
			lea ESI, gigi_14
			jmp load_picture_22
		load_gigi_22_pic15:
			lea ESI, gigi_15
			jmp load_picture_22
		load_gigi_22_empty:
			lea ESI, empty
			jmp load_picture_22
			
		load_picture_22:
			mov EAX, area_width
			mov EBX, 60
			mul EBX
			add EAX, 260
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_6:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_6
			je next_line_gigi_6
		
	next_line_gigi_6:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_6
		
		
	verificare_poza_23:
		mov EAX, 0
		mov AL, [numbers_array + 6]	;se verifica ce poza ESTE pe POZITIA 6 DIN ARRAY pt a vedea ce poza INCARCAM 
		cmp AL, 1
		je load_gigi_23_pic1
		cmp AL, 2
		je load_gigi_23_pic2
		cmp  AL, 3
		je load_gigi_23_pic3
		cmp AL, 4
		je load_gigi_23_pic4
		cmp AL, 5
		je load_gigi_23_pic5
		cmp AL, 6
		je load_gigi_23_pic6
		cmp AL, 7
		je load_gigi_23_pic7
		cmp  AL, 8
		je load_gigi_23_pic8
		cmp AL, 9
		je load_gigi_23_pic9
		cmp AL, 10
		je load_gigi_23_pic10
		cmp AL, 11
		je load_gigi_23_pic11
		cmp AL, 12
		je load_gigi_23_pic12
		cmp  AL, 13
		je load_gigi_23_pic13
		cmp AL, 14
		je load_gigi_23_pic14
		cmp AL, 15
		je load_gigi_23_pic15
		cmp AL, 0
		je load_gigi_23_empty
		
		
		load_gigi_23_pic1:
			lea ESI, gigi_1
			jmp load_picture_23
		load_gigi_23_pic2:
			lea ESI, gigi_2
			jmp load_picture_23
		load_gigi_23_pic3:
			lea ESI, gigi_3
			jmp load_picture_23
		load_gigi_23_pic4:
			lea ESI, gigi_4
			jmp load_picture_23
		load_gigi_23_pic5:
			lea ESI, gigi_5
			jmp load_picture_23
		load_gigi_23_pic6:
			lea ESI, gigi_6
			jmp load_picture_23
		load_gigi_23_pic7:
			lea ESI, gigi_7
			jmp load_picture_23
		load_gigi_23_pic8:
			lea ESI, gigi_8
			jmp load_picture_23
		load_gigi_23_pic9:
			lea ESI, gigi_9
			jmp load_picture_23
		load_gigi_23_pic10:
			lea ESI, gigi_10
			jmp load_picture_23
		load_gigi_23_pic11:
			lea ESI, gigi_11
			jmp load_picture_23
		load_gigi_23_pic12:
			lea ESI, gigi_12
			jmp load_picture_23
		load_gigi_23_pic13:
			lea ESI, gigi_13
			jmp load_picture_23
		load_gigi_23_pic14:
			lea ESI, gigi_14
			jmp load_picture_23
		load_gigi_23_pic15:
			lea ESI, gigi_15
			jmp load_picture_23
		load_gigi_23_empty:
			lea ESI, empty
			jmp load_picture_23
			
		load_picture_23:
			mov EAX, area_width
			mov EBX, 60
			mul EBX
			add EAX, 310
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_7:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_7
			je next_line_gigi_7
		
	next_line_gigi_7:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_7
		
		
		verificare_poza_24:
		mov EAX, 0
		mov AL, [numbers_array + 7]	;se verifica ce poza ESTE pe POZITIA 7 DIN ARRAY pt a vedea ce poza INCARCAM 
		cmp AL, 1
		je load_gigi_24_pic1
		cmp AL, 2
		je load_gigi_24_pic2
		cmp  AL, 3
		je load_gigi_24_pic3
		cmp AL, 4
		je load_gigi_24_pic4
		cmp AL, 5
		je load_gigi_24_pic5
		cmp AL, 6
		je load_gigi_24_pic6
		cmp AL, 7
		je load_gigi_24_pic7
		cmp  AL, 8
		je load_gigi_24_pic8
		cmp AL, 9
		je load_gigi_24_pic9
		cmp AL, 10
		je load_gigi_24_pic10
		cmp AL, 11
		je load_gigi_24_pic11
		cmp AL, 12
		je load_gigi_24_pic12
		cmp  AL, 13
		je load_gigi_24_pic13
		cmp AL, 14
		je load_gigi_24_pic14
		cmp AL, 15
		je load_gigi_24_pic15
		cmp AL, 0
		je load_gigi_24_empty
		
		
		load_gigi_24_pic1:
			lea ESI, gigi_1
			jmp load_picture_24
		load_gigi_24_pic2:
			lea ESI, gigi_2
			jmp load_picture_24
		load_gigi_24_pic3:
			lea ESI, gigi_3
			jmp load_picture_24
		load_gigi_24_pic4:
			lea ESI, gigi_4
			jmp load_picture_24
		load_gigi_24_pic5:
			lea ESI, gigi_5
			jmp load_picture_24
		load_gigi_24_pic6:
			lea ESI, gigi_6
			jmp load_picture_24
		load_gigi_24_pic7:
			lea ESI, gigi_7
			jmp load_picture_24
		load_gigi_24_pic8:
			lea ESI, gigi_8
			jmp load_picture_24
		load_gigi_24_pic9:
			lea ESI, gigi_9
			jmp load_picture_24
		load_gigi_24_pic10:
			lea ESI, gigi_10
			jmp load_picture_24
		load_gigi_24_pic11:
			lea ESI, gigi_11
			jmp load_picture_24
		load_gigi_24_pic12:
			lea ESI, gigi_12
			jmp load_picture_24
		load_gigi_24_pic13:
			lea ESI, gigi_13
			jmp load_picture_24
		load_gigi_24_pic14:
			lea ESI, gigi_14
			jmp load_picture_24
		load_gigi_24_pic15:
			lea ESI, gigi_15
			jmp load_picture_24
		load_gigi_24_empty:
			lea ESI, empty
			jmp load_picture_24
			
		load_picture_24:
			mov EAX, area_width
			mov EBX, 60
			mul EBX
			add EAX, 360
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_8:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_8
			je next_line_gigi_8
		
	next_line_gigi_8:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_8
		
		
		
	verificare_poza_31:
		mov EAX, 0
		mov AL, [numbers_array + 8]	;se verifica ce poza ESTE pe POZITIA 8 DIN ARRAY pt a vedea ce poza INCARCAM 
		cmp AL, 1
		je load_gigi_31_pic1
		cmp AL, 2
		je load_gigi_31_pic2
		cmp  AL, 3
		je load_gigi_31_pic3
		cmp AL, 4
		je load_gigi_31_pic4
		cmp AL, 5
		je load_gigi_31_pic5
		cmp AL, 6
		je load_gigi_31_pic6
		cmp AL, 7
		je load_gigi_31_pic7
		cmp  AL, 8
		je load_gigi_31_pic8
		cmp AL, 9
		je load_gigi_31_pic9
		cmp AL, 10
		je load_gigi_31_pic10
		cmp AL, 11
		je load_gigi_31_pic11
		cmp AL, 12
		je load_gigi_31_pic12
		cmp  AL, 13
		je load_gigi_31_pic13
		cmp AL, 14
		je load_gigi_31_pic14
		cmp AL, 15
		je load_gigi_31_pic15
		cmp AL, 0
		je load_gigi_31_empty
		
		
		load_gigi_31_pic1:
			lea ESI, gigi_1
			jmp load_picture_31
		load_gigi_31_pic2:
			lea ESI, gigi_2
			jmp load_picture_31
		load_gigi_31_pic3:
			lea ESI, gigi_3
			jmp load_picture_31
		load_gigi_31_pic4:
			lea ESI, gigi_4
			jmp load_picture_31
		load_gigi_31_pic5:
			lea ESI, gigi_5
			jmp load_picture_31
		load_gigi_31_pic6:
			lea ESI, gigi_6
			jmp load_picture_31
		load_gigi_31_pic7:
			lea ESI, gigi_7
			jmp load_picture_31
		load_gigi_31_pic8:
			lea ESI, gigi_8
			jmp load_picture_31
		load_gigi_31_pic9:
			lea ESI, gigi_9
			jmp load_picture_31
		load_gigi_31_pic10:
			lea ESI, gigi_10
			jmp load_picture_31
		load_gigi_31_pic11:
			lea ESI, gigi_11
			jmp load_picture_31
		load_gigi_31_pic12:
			lea ESI, gigi_12
			jmp load_picture_31
		load_gigi_31_pic13:
			lea ESI, gigi_13
			jmp load_picture_31
		load_gigi_31_pic14:
			lea ESI, gigi_14
			jmp load_picture_31
		load_gigi_31_pic15:
			lea ESI, gigi_15
			jmp load_picture_31
		load_gigi_31_empty:
			lea ESI, empty
			jmp load_picture_31

	load_picture_31:
		mov EAX, area_width
			mov EBX, 110
			mul EBX
			add EAX, 210
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_9:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_9
			je next_line_gigi_9
		
	next_line_gigi_9:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_9
		
	verificare_poza_32:
		mov EAX, 0
		mov AL, [numbers_array + 9]	;se verifica ce poza ESTE pe POZITIA 8 DIN ARRAY pt a vedea ce poza INCARCAM 
		cmp AL, 1
		je load_gigi_32_pic1
		cmp AL, 2
		je load_gigi_32_pic2
		cmp  AL, 3
		je load_gigi_32_pic3
		cmp AL, 4
		je load_gigi_32_pic4
		cmp AL, 5
		je load_gigi_32_pic5
		cmp AL, 6
		je load_gigi_32_pic6
		cmp AL, 7
		je load_gigi_32_pic7
		cmp  AL, 8
		je load_gigi_32_pic8
		cmp AL, 9
		je load_gigi_32_pic9
		cmp AL, 10
		je load_gigi_32_pic10
		cmp AL, 11
		je load_gigi_32_pic11
		cmp AL, 12
		je load_gigi_32_pic12
		cmp  AL, 13
		je load_gigi_32_pic13
		cmp AL, 14
		je load_gigi_32_pic14
		cmp AL, 15
		je load_gigi_32_pic15
		cmp AL, 0
		je load_gigi_32_empty
		
		
		load_gigi_32_pic1:
			lea ESI, gigi_1
			jmp load_picture_32
		load_gigi_32_pic2:
			lea ESI, gigi_2
			jmp load_picture_32
		load_gigi_32_pic3:
			lea ESI, gigi_3
			jmp load_picture_32
		load_gigi_32_pic4:
			lea ESI, gigi_4
			jmp load_picture_32
		load_gigi_32_pic5:
			lea ESI, gigi_5
			jmp load_picture_32
		load_gigi_32_pic6:
			lea ESI, gigi_6
			jmp load_picture_32
		load_gigi_32_pic7:
			lea ESI, gigi_7
			jmp load_picture_32
		load_gigi_32_pic8:
			lea ESI, gigi_8
			jmp load_picture_32
		load_gigi_32_pic9:
			lea ESI, gigi_9
			jmp load_picture_32
		load_gigi_32_pic10:
			lea ESI, gigi_10
			jmp load_picture_32
		load_gigi_32_pic11:
			lea ESI, gigi_11
			jmp load_picture_32
		load_gigi_32_pic12:
			lea ESI, gigi_12
			jmp load_picture_32
		load_gigi_32_pic13:
			lea ESI, gigi_13
			jmp load_picture_32
		load_gigi_32_pic14:
			lea ESI, gigi_14
			jmp load_picture_32
		load_gigi_32_pic15:
			lea ESI, gigi_15
			jmp load_picture_32
		load_gigi_32_empty:
			lea ESI, empty
			jmp load_picture_32

	load_picture_32:
		mov EAX, area_width
			mov EBX, 110
			mul EBX
			add EAX, 260
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_10:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_10
			je next_line_gigi_10
		
	next_line_gigi_10:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_10
		
	verificare_poza_33:
		mov EAX, 0
		mov AL, [numbers_array + 10]	;se verifica ce poza ESTE pe POZITIA 8 DIN ARRAY pt a vedea ce poza INCARCAM 
	cmp AL, 1
je load_gigi_33_pic1
cmp AL, 2
je load_gigi_33_pic2
cmp  AL, 3
je load_gigi_33_pic3
cmp AL, 4
je load_gigi_33_pic4
cmp AL, 5
je load_gigi_33_pic5
cmp AL, 6
je load_gigi_33_pic6
cmp AL, 7
je load_gigi_33_pic7
cmp  AL, 8
je load_gigi_33_pic8
cmp AL, 9
je load_gigi_33_pic9
cmp AL, 10
je load_gigi_33_pic10
cmp AL, 11
je load_gigi_33_pic11
cmp AL, 12
je load_gigi_33_pic12
cmp  AL, 13
je load_gigi_33_pic13
cmp AL, 14
je load_gigi_33_pic14
cmp AL, 15
je load_gigi_33_pic15
cmp AL, 0
je load_gigi_33_empty
	
	
load_gigi_33_pic1:
	lea ESI, gigi_1
	jmp load_picture_33
load_gigi_33_pic2:
	lea ESI, gigi_2
	jmp load_picture_33
load_gigi_33_pic3:
	lea ESI, gigi_3
	jmp load_picture_33
load_gigi_33_pic4:
	lea ESI, gigi_4
	jmp load_picture_33
load_gigi_33_pic5:
	lea ESI, gigi_5
	jmp load_picture_33
load_gigi_33_pic6:
	lea ESI, gigi_6
	jmp load_picture_33
load_gigi_33_pic7:
	lea ESI, gigi_7
	jmp load_picture_33
load_gigi_33_pic8:
	lea ESI, gigi_8
	jmp load_picture_33
load_gigi_33_pic9:
	lea ESI, gigi_9
	jmp load_picture_33
load_gigi_33_pic10:
	lea ESI, gigi_10
	jmp load_picture_33
load_gigi_33_pic11:
	lea ESI, gigi_11
	jmp load_picture_33
load_gigi_33_pic12:
	lea ESI, gigi_12
	jmp load_picture_33
load_gigi_33_pic13:
	lea ESI, gigi_13
	jmp load_picture_33
load_gigi_33_pic14:
	lea ESI, gigi_14
	jmp load_picture_33
load_gigi_33_pic15:
	lea ESI, gigi_15
	jmp load_picture_33
load_gigi_33_empty:
	lea ESI, empty
	jmp load_picture_33


	load_picture_33:
		mov EAX, area_width
			mov EBX, 110
			mul EBX
			add EAX, 310
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_11:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_11
			je next_line_gigi_11
		
	next_line_gigi_11:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_11
		
		verificare_poza_34:
			mov EAX, 0
			mov AL, [numbers_array + 11]
			cmp AL, 1
		je load_gigi_34_pic1
		cmp AL, 2
		je load_gigi_34_pic2
		cmp  AL, 3
		je load_gigi_34_pic3
		cmp AL, 4
		je load_gigi_34_pic4
		cmp AL, 5
		je load_gigi_34_pic5
		cmp AL, 6
		je load_gigi_34_pic6
		cmp AL, 7
		je load_gigi_34_pic7
		cmp  AL, 8
		je load_gigi_34_pic8
		cmp AL, 9
		je load_gigi_34_pic9
		cmp AL, 10
		je load_gigi_34_pic10
		cmp AL, 11
		je load_gigi_34_pic11
		cmp AL, 12
		je load_gigi_34_pic12
		cmp  AL, 13
		je load_gigi_34_pic13
		cmp AL, 14
		je load_gigi_34_pic14
		cmp AL, 15
		je load_gigi_34_pic15
		cmp AL, 0
		je load_gigi_34_empty
		
		
		load_gigi_34_pic1:
			lea ESI, gigi_1
			jmp load_picture_34
		load_gigi_34_pic2:
			lea ESI, gigi_2
			jmp load_picture_34
		load_gigi_34_pic3:
			lea ESI, gigi_3
			jmp load_picture_34
		load_gigi_34_pic4:
			lea ESI, gigi_4
			jmp load_picture_34
		load_gigi_34_pic5:
			lea ESI, gigi_5
			jmp load_picture_34
		load_gigi_34_pic6:
			lea ESI, gigi_6
			jmp load_picture_34
		load_gigi_34_pic7:
			lea ESI, gigi_7
			jmp load_picture_34
		load_gigi_34_pic8:
			lea ESI, gigi_8
			jmp load_picture_34
		load_gigi_34_pic9:
			lea ESI, gigi_9
			jmp load_picture_34
		load_gigi_34_pic10:
			lea ESI, gigi_10
			jmp load_picture_34
		load_gigi_34_pic11:
			lea ESI, gigi_11
			jmp load_picture_34
		load_gigi_34_pic12:
			lea ESI, gigi_12
			jmp load_picture_34
		load_gigi_34_pic13:
			lea ESI, gigi_13
			jmp load_picture_34
		load_gigi_34_pic14:
			lea ESI, gigi_14
			jmp load_picture_34
		load_gigi_34_pic15:
			lea ESI, gigi_15
			jmp load_picture_34
		load_gigi_34_empty:
			lea ESI, empty
			jmp load_picture_34
			
		load_picture_34:
		mov EAX, area_width
			mov EBX, 110
			mul EBX
			add EAX, 360
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_12:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_12
			je next_line_gigi_12
		
	next_line_gigi_12:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_12
		
	verificare_poza_41:
		mov EAX, 0
		mov AL, [numbers_array + 12]
		cmp AL, 1
je load_gigi_41_pic1
cmp AL, 2
je load_gigi_41_pic2
cmp AL, 3
je load_gigi_41_pic3
cmp AL, 4
je load_gigi_41_pic4
cmp AL, 5
je load_gigi_41_pic5
cmp AL, 6
je load_gigi_41_pic6
cmp AL, 7
je load_gigi_41_pic7
cmp AL, 8
je load_gigi_41_pic8
cmp AL, 9
je load_gigi_41_pic9
cmp AL, 10
je load_gigi_41_pic10
cmp AL, 11
je load_gigi_41_pic11
cmp AL, 12
je load_gigi_41_pic12
cmp AL, 13
je load_gigi_41_pic13
cmp AL, 14
je load_gigi_41_pic14
cmp AL, 15
je load_gigi_41_pic15
cmp AL, 0
je load_gigi_41_empty

load_gigi_41_pic1:
    lea ESI, gigi_1
    jmp load_picture_41
load_gigi_41_pic2:
    lea ESI, gigi_2
    jmp load_picture_41
load_gigi_41_pic3:
    lea ESI, gigi_3
    jmp load_picture_41
load_gigi_41_pic4:
    lea ESI, gigi_4
    jmp load_picture_41
load_gigi_41_pic5:
    lea ESI, gigi_5
    jmp load_picture_41
load_gigi_41_pic6:
    lea ESI, gigi_6
    jmp load_picture_41
load_gigi_41_pic7:
    lea ESI, gigi_7
    jmp load_picture_41
load_gigi_41_pic8:
    lea ESI, gigi_8
    jmp load_picture_41
load_gigi_41_pic9:
    lea ESI, gigi_9
    jmp load_picture_41
load_gigi_41_pic10:
    lea ESI, gigi_10
    jmp load_picture_41
load_gigi_41_pic11:
    lea ESI, gigi_11
    jmp load_picture_41
load_gigi_41_pic12:
    lea ESI, gigi_12
    jmp load_picture_41
load_gigi_41_pic13:
    lea ESI, gigi_13
    jmp load_picture_41
load_gigi_41_pic14:
    lea ESI, gigi_14
    jmp load_picture_41
load_gigi_41_pic15:
    lea ESI, gigi_15
    jmp load_picture_41
load_gigi_41_empty:
    lea ESI, empty
    jmp load_picture_41
	
	load_picture_41:
		mov EAX, area_width
			mov EBX, 160
			mul EBX
			add EAX, 210
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_13:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_13
			je next_line_gigi_13
		
	next_line_gigi_13:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_13
		
	verificare_poza_42:
		mov EAX, 0
		mov AL, [numbers_array + 13]
		cmp AL, 1
je load_gigi_42_pic1
cmp AL, 2
je load_gigi_42_pic2
cmp  AL, 3
je load_gigi_42_pic3
cmp AL, 4
je load_gigi_42_pic4
cmp AL, 5
je load_gigi_42_pic5
cmp AL, 6
je load_gigi_42_pic6
cmp AL, 7
je load_gigi_42_pic7
cmp  AL, 8
je load_gigi_42_pic8
cmp AL, 9
je load_gigi_42_pic9
cmp AL, 10
je load_gigi_42_pic10
cmp AL, 11
je load_gigi_42_pic11
cmp AL, 12
je load_gigi_42_pic12
cmp  AL, 13
je load_gigi_42_pic13
cmp AL, 14
je load_gigi_42_pic14
cmp AL, 15
je load_gigi_42_pic15
cmp AL, 0
je load_gigi_42_empty


load_gigi_42_pic1:
    lea ESI, gigi_1
    jmp load_picture_42
load_gigi_42_pic2:
    lea ESI, gigi_2
    jmp load_picture_42
load_gigi_42_pic3:
    lea ESI, gigi_3
    jmp load_picture_42
load_gigi_42_pic4:
    lea ESI, gigi_4
    jmp load_picture_42
load_gigi_42_pic5:
    lea ESI, gigi_5
    jmp load_picture_42
load_gigi_42_pic6:
    lea ESI, gigi_6
    jmp load_picture_42
load_gigi_42_pic7:
    lea ESI, gigi_7
    jmp load_picture_42
load_gigi_42_pic8:
    lea ESI, gigi_8
    jmp load_picture_42
load_gigi_42_pic9:
    lea ESI, gigi_9
    jmp load_picture_42
load_gigi_42_pic10:
    lea ESI, gigi_10
    jmp load_picture_42
load_gigi_42_pic11:
    lea ESI, gigi_11
    jmp load_picture_42
load_gigi_42_pic12:
    lea ESI, gigi_12
    jmp load_picture_42
load_gigi_42_pic13:
    lea ESI, gigi_13
    jmp load_picture_42
load_gigi_42_pic14:
    lea ESI, gigi_14
    jmp load_picture_42
load_gigi_42_pic15:
    lea ESI, gigi_15
    jmp load_picture_42
load_gigi_42_empty:
    lea ESI, empty
    jmp load_picture_42

	load_picture_42:
		mov EAX, area_width
			mov EBX, 160
			mul EBX
			add EAX, 260
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_14:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_14
			je next_line_gigi_14
		
	next_line_gigi_14:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_14
		
	verificare_poza_43:
		mov EAX, 0
		mov AL, [numbers_array + 14]
		cmp AL, 1
je load_gigi_43_pic1
cmp AL, 2
je load_gigi_43_pic2
cmp  AL, 3
je load_gigi_43_pic3
cmp AL, 4
je load_gigi_43_pic4
cmp AL, 5
je load_gigi_43_pic5
cmp AL, 6
je load_gigi_43_pic6
cmp AL, 7
je load_gigi_43_pic7
cmp  AL, 8
je load_gigi_43_pic8
cmp AL, 9
je load_gigi_43_pic9
cmp AL, 10
je load_gigi_43_pic10
cmp AL, 11
je load_gigi_43_pic11
cmp AL, 12
je load_gigi_43_pic12
cmp  AL, 13
je load_gigi_43_pic13
cmp AL, 14
je load_gigi_43_pic14
cmp AL, 15
je load_gigi_43_pic15
cmp AL, 0
je load_gigi_43_empty


load_gigi_43_pic1:
    lea ESI, gigi_1
    jmp load_picture_43
load_gigi_43_pic2:
    lea ESI, gigi_2
    jmp load_picture_43
load_gigi_43_pic3:
    lea ESI, gigi_3
    jmp load_picture_43
load_gigi_43_pic4:
    lea ESI, gigi_4
    jmp load_picture_43
load_gigi_43_pic5:
    lea ESI, gigi_5
    jmp load_picture_43
load_gigi_43_pic6:
    lea ESI, gigi_6
    jmp load_picture_43
load_gigi_43_pic7:
    lea ESI, gigi_7
    jmp load_picture_43
load_gigi_43_pic8:
    lea ESI, gigi_8
    jmp load_picture_43
load_gigi_43_pic9:
    lea ESI, gigi_9
    jmp load_picture_43
load_gigi_43_pic10:
    lea ESI, gigi_10
    jmp load_picture_43
load_gigi_43_pic11:
    lea ESI, gigi_11
    jmp load_picture_43
load_gigi_43_pic12:
    lea ESI, gigi_12
    jmp load_picture_43
load_gigi_43_pic13:
    lea ESI, gigi_13
    jmp load_picture_43
load_gigi_43_pic14:
    lea ESI, gigi_14
    jmp load_picture_43
load_gigi_43_pic15:
    lea ESI, gigi_15
    jmp load_picture_43
load_gigi_43_empty:
    lea ESI, empty
    jmp load_picture_43

	load_picture_43:
		mov EAX, area_width
			mov EBX, 160
			mul EBX
			add EAX, 310
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_15:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_15
			je next_line_gigi_15
		
	next_line_gigi_15:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_15
		
	verificare_poza_44:
		mov EAX, 0
		mov AL, [numbers_array + 15]
		cmp AL, 1
		je load_gigi_44_pic1
		cmp AL, 2
		je load_gigi_44_pic2
		cmp  AL, 3
		je load_gigi_44_pic3
		cmp AL, 4
		je load_gigi_44_pic4
		cmp AL, 5
		je load_gigi_44_pic5
		cmp AL, 6
		je load_gigi_44_pic6
		cmp AL, 7
		je load_gigi_44_pic7
		cmp  AL, 8
		je load_gigi_44_pic8
		cmp AL, 9
		je load_gigi_44_pic9
		cmp AL, 10
		je load_gigi_44_pic10
		cmp AL, 11
		je load_gigi_44_pic11
		cmp AL, 12
		je load_gigi_44_pic12
		cmp  AL, 13
		je load_gigi_44_pic13
		cmp AL, 14
		je load_gigi_44_pic14
		cmp AL, 15
		je load_gigi_44_pic15
		cmp AL, 0
		je load_gigi_44_empty
		
		
		load_gigi_44_pic1:
			lea ESI, gigi_1
			jmp load_picture_44
		load_gigi_44_pic2:
			lea ESI, gigi_2
			jmp load_picture_44
		load_gigi_44_pic3:
			 lea ESI, gigi_3
			 jmp load_picture_44
		load_gigi_44_pic4:
			 lea ESI, gigi_4
			 jmp load_picture_44
		load_gigi_44_pic5:
			 lea ESI, gigi_5
			 jmp load_picture_44
		load_gigi_44_pic6:
			 lea ESI, gigi_6
			 jmp load_picture_44
		load_gigi_44_pic7:
			 lea ESI, gigi_7
			 jmp load_picture_44
		load_gigi_44_pic8:
			 lea ESI, gigi_8
			 jmp load_picture_44
		load_gigi_44_pic9:
			 lea ESI, gigi_9
			 jmp load_picture_44
		load_gigi_44_pic10:
			 lea ESI, gigi_10
			 jmp load_picture_44
		load_gigi_44_pic11:
			 lea ESI, gigi_11
			 jmp load_picture_44
		load_gigi_44_pic12:
			 lea ESI, gigi_12
			 jmp load_picture_44
		load_gigi_44_pic13:
			 lea ESI, gigi_13
			 jmp load_picture_44
		load_gigi_44_pic14:
			 lea ESI, gigi_14
			 jmp load_picture_44
		load_gigi_44_pic15:
			 lea ESI, gigi_15
			 jmp load_picture_44
		load_gigi_44_empty:
			 lea ESI, empty
			 jmp load_picture_44

		load_picture_44:
			mov EAX, area_width
			mov EBX, 160
			mul EBX
			add EAX, 360
			shl EAX, 2
			add EAX, area
			mov EDX, 48
			mov ECX, 48
			
		loop_gigi_16:
			mov EBX, [ESI]
			mov dword ptr [EAX], EBX
			add EAX, 4
			add ESI, 4
			
			dec ECX
			cmp ECX, 0
			jne loop_gigi_16
			je next_line_gigi_16
		
	next_line_gigi_16:
		dec EDX
		add EAX, 4*area_width - 192
		mov ECX, 48
		cmp EDX, 0
		jne loop_gigi_16
		
	
	start_button_fail:
		cmp choose_level,1
		je click_level_1
		cmp choose_level, 2
		je click_level_2 
		
		
		click_level_1:
			cmp game_won, 1
			je skip_time 
		
		click_picture_11:
		mov EAX, [ebp+arg2]
		cmp EAX, 211
		jl click_picture_11_fail
		cmp EAX, 256
		jg click_picture_11_fail
		mov EAX, [ebp+arg3]
		cmp EAX, 12
		jl click_picture_11_fail
		cmp EAX, 57
		jg click_picture_11_fail
		
		add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
		mov EAX, 0
		mov EBX, 0
		mov ECX, 0
		
		mov CL, [numbers_array + 1]
		cmp CL, 0
		je change_11_right
		mov CL, [numbers_array + 4]
		cmp CL, 0
		je change_11_under
		jmp click_picture_11_fail
		
		change_11_right:
			make_text_macro '1', area, 300, 400
			mov AL, [numbers_array + 0]
			mov BL, [numbers_array + 1]
			mov [numbers_array + 0], BL
			mov [numbers_array + 1], AL
			jmp verificare_poza_11
		
		change_11_under:
			mov AL, [numbers_array + 0]
			mov BL, [numbers_array + 4]
			mov [numbers_array + 0], BL
			mov [numbers_array + 4], AL
			jmp verificare_poza_11
			
			
		
		click_picture_11_fail:
			jmp click_picture_12
	
	
	
		click_picture_12:
			mov EAX,[ebp+arg2]
			cmp EAX, 261
			jl click_picture_12_fail
			cmp EAX, 305
			jg click_picture_12_fail
			mov EAX, [ebp+arg3]
			cmp EAX, 12
			jl click_picture_12_fail
			cmp EAX, 57 
			jg click_picture_12_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov EAX, 0
			mov EBX, 0
			mov ECX, 0
			
			mov CL, [numbers_array + 5]
			cmp CL, 0
			je change_12_under
			mov CL, [numbers_array + 0]
			cmp CL, 0
			je change_12_left
			mov CL, [numbers_array + 2]
			cmp CL, 0
			je change_12_right
			jmp click_picture_12_fail			
			
			change_12_left:
				mov AL, [numbers_array + 0]
				mov BL, [numbers_array + 1]
				mov [numbers_array + 0], BL
				mov [numbers_array + 1], AL
				jmp verificare_poza_11
			change_12_under:
				mov AL, [numbers_array + 1]
				mov BL, [numbers_array + 5]
				mov [numbers_array + 1], BL
				mov [numbers_array + 5], AL
				jmp verificare_poza_11
			change_12_right:
				mov AL, [numbers_array + 1]
				mov BL, [numbers_array + 2]
				mov [numbers_array + 1], BL
				mov [numbers_array + 2], AL
				jmp verificare_poza_11
			
			
		click_picture_12_fail:
			jmp click_picture_13
			
		click_picture_13:
			mov EAX, [ebp+arg2] ;X
			cmp EAX, 310
			jl click_picture_13_fail
			cmp EAX, 357
			jg click_picture_13_fail
			mov EAX, [ebp+arg3] 	;Y
			cmp EAX, 12
			jl click_picture_13_fail
			cmp EAX, 57
			jg click_picture_13_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov EAX, 0
			mov EBX, 0
			mov ECX, 0
			
			mov CL, [numbers_array + 3]
			cmp CL, 0
			je change_13_right
			mov CL, [numbers_array + 1]
			cmp CL, 0
			je change_13_left
			mov CL, [numbers_array + 6]
			cmp CL, 0
			je change_13_under 
			jmp click_picture_13_fail
			
			change_13_right:
				mov AL, [numbers_array + 2]
				mov BL, [numbers_array + 3]
				mov [numbers_array + 2], BL
				mov [numbers_array + 3], AL
				jmp verificare_poza_11 
				
			change_13_left:
				mov AL, [numbers_array + 2]
				mov BL, [numbers_array + 1]
				mov [numbers_array + 2], BL
				mov [numbers_array + 1], AL
				jmp verificare_poza_11
				
			change_13_under:
				mov AL, [numbers_array + 2]
				mov BL, [numbers_array + 6]
				mov [numbers_array + 2], BL
				mov [numbers_array + 6], AL
				jmp verificare_poza_11
				
		click_picture_13_fail:
			jmp click_picture_14
			
		click_picture_14:
			mov EAX, [ebp+arg2]
			cmp EAX, 361
			jl click_picture_14_fail
			cmp EAX, 405
			jg click_picture_14_fail
			mov EAX, [ebp+arg3]
			cmp EAX,12
			jl click_picture_14_fail
			cmp EAX, 57
			jg click_picture_14_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX 
			
			mov EAX, 0
			mov EBX, 0
			mov ECX, 0
			
			mov CL, [numbers_array + 2]
			cmp CL, 0
			je change_14_left
			mov CL, [numbers_array + 7]
			cmp CL, 0
			je change_14_under
			jmp click_picture_14_fail
			
			change_14_left:
				mov AL, [numbers_array + 3]
				mov BL,[ numbers_array + 2]
				mov [numbers_array + 3], BL
				mov [numbers_array + 2], AL
				jmp verificare_poza_11
				
			change_14_under:
				mov AL, [numbers_array + 3]
				mov BL,[ numbers_array + 7]
				mov [numbers_array + 3], BL
				mov [numbers_array + 7], AL
				jmp verificare_poza_11
			
			
			
			
			click_picture_14_fail:
				jmp click_picture_21
				
			click_picture_21:
				mov EAX, [ebp+arg2]
				cmp EAX, 211
				jl click_picture_21_fail
				cmp EAX, 256
				jg click_picture_21_fail
				mov EAX, [ebp+arg3]
				cmp EAX, 61
				jl click_picture_21_fail
				cmp EAX, 106
				jg click_picture_21_fail
				
				add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX 
				
				mov EAX, 0
				mov EBX, 0
				mov ECX, 0
				
				mov CL, [numbers_array + 0]
				cmp CL, 0
				je change_21_above
				mov CL, [numbers_array + 5]
				cmp CL, 0
				je change_21_right
				mov CL, [numbers_array + 8]
				cmp CL, 0
				je change_21_under 
				jmp click_picture_21_fail
				
				change_21_above:
					mov AL, [numbers_array + 4]
					mov BL, [numbers_array + 0]
					mov [numbers_array + 4], BL
					mov [numbers_array + 0], AL
					jmp verificare_poza_11
					
				change_21_right:
					mov AL, [numbers_array + 4]
					mov BL, [numbers_array + 5]
					mov [numbers_array + 4], BL
					mov [numbers_array + 5], AL
					jmp verificare_poza_11
				change_21_under:
					mov AL, [numbers_array + 4]
					mov BL, [numbers_array + 8]
					mov [numbers_array + 4], BL
					mov [numbers_array + 8], AL
					jmp verificare_poza_11
					
				click_picture_21_fail:
					jmp click_picture_22
					
					
			click_picture_22:
				mov EAX, [ebp+arg2]
				cmp EAX, 261
				jl click_picture_22_fail
				cmp EAX, 305 	
				jg click_picture_22_fail
				mov EAX, [ebp+arg3]
				cmp EAX, 61
				jl click_picture_22_fail
				cmp EAX, 106 
				jg click_picture_22_fail
				
				add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX 
				
				mov EAX, 0
				mov EBX, 0
				mov ECX, 0
				
				mov CL, [numbers_array + 6]
				cmp CL, 0
				je change_22_right 
				mov CL, [numbers_array + 4]
				cmp CL, 0
				je change_22_left
				mov CL, [numbers_array + 1]
				cmp CL, 0
				je change_22_above
				mov CL, [numbers_array + 9]
				cmp CL, 0
				je change_22_under
				jmp click_picture_22_fail
				
				change_22_right:
					mov AL, [numbers_array + 5]
					mov BL, [numbers_array + 6]
					mov [numbers_array + 5], BL
					mov [numbers_array + 6], AL
					jmp verificare_poza_11
					
				change_22_left:
					mov AL, [numbers_array + 5]
					mov BL, [numbers_array + 4]
					mov [numbers_array + 5], BL
					mov [numbers_array + 4], AL
					jmp verificare_poza_11
					
				change_22_above:
					mov AL, [numbers_array + 5]
					mov BL, [numbers_array + 1]
					mov [numbers_array + 5], BL
					mov [numbers_array + 1], AL
					jmp verificare_poza_11
					
				change_22_under:
					mov AL, [numbers_array + 5]
					mov BL, [numbers_array + 9]
					mov [numbers_array + 5], BL
					mov [numbers_array + 9], AL
					jmp verificare_poza_11
					
					
			click_picture_22_fail:
				jmp click_picture_23
				
			click_picture_23:
				mov EAX, [ebp+arg2]
				cmp EAX, 310
				jl click_picture_23_fail
				cmp EAX, 357
				jg click_picture_23_fail
				mov EAX, [ebp+arg3]
				cmp EAX, 61
				jl click_picture_23_fail
				cmp EAX, 106
				jg click_picture_23_fail
				
				add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX 
				
				mov EAX, 0
				mov EBX, 0
				mov ECX, 0
				
				mov CL, [numbers_array + 7]
				cmp CL, 0
				je change_23_right
				mov CL, [numbers_array + 5]
				cmp CL, 0
				je change_23_left
				mov CL, [numbers_array + 2]
				cmp CL, 0
				je change_23_above
				mov CL, [numbers_array + 10]
				cmp CL, 0
				je change_23_under
				jmp click_picture_23_fail
				
				change_23_right:
					mov AL, [numbers_array + 6]
					mov BL, [numbers_array + 7]
					mov [numbers_array + 6], BL
					mov [numbers_array + 7], AL
					jmp verificare_poza_11
					
				change_23_left:
					mov AL, [numbers_array + 6]
					mov BL, [numbers_array + 5]
					mov [numbers_array + 6], BL
					mov [numbers_array + 5], AL
					jmp verificare_poza_11
				
				change_23_above:
					mov AL, [numbers_array + 6]
					mov BL, [numbers_array + 2]
					mov [numbers_array + 6], BL
					mov [numbers_array + 2], AL
					jmp verificare_poza_11
					
				change_23_under:
					mov AL, [numbers_array + 6]
					mov BL, [numbers_array + 10]
					mov [numbers_array + 6], BL
					mov [numbers_array + 10], AL
					jmp verificare_poza_11
				
				click_picture_23_fail:
					jmp click_picture_24
					
			click_picture_24:
				mov EAX, [ebp+arg2]
				cmp EAX, 361
				jl click_picture_24_fail
				cmp EAX, 405
				jg click_picture_24_fail
				mov EAX, [ebp+arg3]
				cmp EAX, 61 
				jl click_picture_24_fail
				cmp EAX, 106 
				jg click_picture_24_fail
				
				add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX 
				
				mov EAX, 0
				mov EBX, 0
				mov ECX, 0
				
				mov CL, [numbers_array + 6]
				cmp CL, 0
				je change_24_left
				mov CL, [numbers_array + 3]
				cmp CL, 0
				je change_24_above
				mov CL, [numbers_array + 11]
				cmp CL, 0
				je change_24_under
				jmp click_picture_24_fail
				
				change_24_left:
					mov AL, [numbers_array + 7]
					mov BL, [numbers_array + 6]
					mov [numbers_array + 7], BL
					mov [numbers_array + 6], AL
					jmp verificare_poza_11
				
				change_24_above:
					mov AL, [numbers_array + 7]
					mov BL, [numbers_array + 3]
					mov [numbers_array + 7], BL
					mov [numbers_array + 3], AL
					jmp verificare_poza_11
					
				change_24_under:
					mov AL, [numbers_array + 7]
					mov BL, [numbers_array + 11]
					mov [numbers_array + 7], BL
					mov [numbers_array + 11], AL
					jmp verificare_poza_11
				
				click_picture_24_fail:
					jmp click_picture_31
					
			click_picture_31:
				mov EAX, [ebp+arg2]
				cmp EAX, 211
				jl click_picture_31_fail
				cmp EAX, 256
				jg click_picture_31_fail
				mov EAX, [ebp+arg3]
				cmp EAX, 112
				jl click_picture_31_fail
				cmp EAX, 158
				jg click_picture_31_fail
				
				add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX 
				
				mov EAX, 0
				mov EBX, 0
				mov ECX, 0
				
				mov CL, [numbers_array + 9]
				cmp CL, 0
				je change_31_right
				mov CL, [numbers_array + 4]
				cmp CL, 0
				je change_31_above
				mov CL, [numbers_array + 12]
				cmp CL, 0
				je change_31_under 
				jmp click_picture_31_fail
				
				change_31_right:
					mov AL, [numbers_array + 8]
					mov BL, [numbers_array + 9]
					mov [numbers_array + 8], BL
					mov [numbers_array + 9], AL
					jmp verificare_poza_11
					
				change_31_above:
					mov AL, [numbers_array + 8]
					mov BL, [numbers_array + 4]
					mov [numbers_array + 8], BL
					mov [numbers_array + 4], AL
					jmp verificare_poza_11
					
				change_31_under:
					mov AL, [numbers_array + 8]
					mov BL, [numbers_array + 12]
					mov [numbers_array + 8], BL
					mov [numbers_array + 12], AL
					jmp verificare_poza_11
				
				click_picture_31_fail:
					jmp click_picture_32
					
			click_picture_32:
				mov EAX, [EBP+arg2]
				CMP EAX, 261
				jl click_picture_32_fail
				cmp eax, 305
				jg click_picture_32_fail
				mov EAX, [ebp+arg3]
				cmp eax, 112
				jl click_picture_32_fail
				cmp EAX, 158
				jg click_picture_32_fail
				
				add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
				
				mov EAX, 0
				mov EBX, 0
				mov ecx, 0
				
				mov CL, [numbers_array + 10]
				cmp CL, 0
				je change_32_right
				mov CL, [numbers_array + 8]
				cmp CL, 0
				je change_32_left
				mov CL, [numbers_array + 5]
				cmp CL, 0
				je change_32_above
				mov CL, [numbers_array + 13]
				cmp CL, 0
				je change_32_under
				jmp click_picture_32_fail
				
				change_32_right:	
					mov AL, [numbers_array + 9]
					mov BL, [numbers_array + 10]
					mov [numbers_array + 9], BL
					mov [numbers_array + 10], AL
					jmp verificare_poza_11
					
				change_32_left:
					mov AL, [numbers_array + 9]
					mov BL, [numbers_array + 8]
					mov [numbers_array + 9], BL
					mov [numbers_array + 8], AL
					jmp verificare_poza_11
					
				change_32_above:
					mov AL, [numbers_array + 9]
					mov BL, [numbers_array + 5]
					mov [numbers_array + 9], BL
					mov [numbers_array + 5], AL
					jmp verificare_poza_11
					
				change_32_under:
					mov AL, [numbers_array + 9]
					mov BL, [numbers_array + 13]
					mov [numbers_array + 9], BL
					mov [numbers_array + 13], AL
					jmp verificare_poza_11
					
			click_picture_32_fail:
				jmp click_picture_33
				
		click_picture_33:
			mov EAX, [ebp+arg2]
			cmp EAX, 310
			jl click_picture_33_fail
			cmp EAX, 357
			jg click_picture_33_fail
			mov EAX, [ebp+arg3]
			cmp EAX, 112
			jl click_picture_33_fail
			cmp EAX, 158
			jg click_picture_33_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
	
			
			mov EAX, 0
			mov EBX, 0
			mov ECX, 0
			
			mov CL, [numbers_array + 11]
			cmp CL, 0
			je change_33_right
			mov CL, [numbers_array + 9]
			cmp CL, 0
			je change_33_left
			mov CL, [numbers_array + 6]
			cmp cl, 0
			je change_33_above
			mov cl, [numbers_array + 14]
			cmp cl, 0
			je change_33_under
			jmp click_picture_33_fail
			
			change_33_right:
				mov al, [numbers_array + 10]
				mov bl, [numbers_array + 11]
				mov [numbers_array + 10], bl
				mov [numbers_array + 11], al
				jmp verificare_poza_11
				
			change_33_left:
				mov al, [numbers_array + 10]
				mov bl, [numbers_array + 9]
				mov [numbers_array + 10], bl
				mov [numbers_array + 9], al
				jmp verificare_poza_11
				
			change_33_above:
				mov al, [numbers_array + 10]
				mov bl, [numbers_array + 6]
				mov [numbers_array + 10], bl
				mov [numbers_array + 6], al
				jmp verificare_poza_11
				
			change_33_under:
				mov al, [numbers_array + 10]
				mov bl, [numbers_array + 14]
				mov [numbers_array + 10], bl
				mov [numbers_array + 14], al
				jmp verificare_poza_11
				
		click_picture_33_fail:
			jmp click_picture_34
			
		click_picture_34:
			mov eax, [ebp+arg2]
			cmp eax, 361
			jl click_picture_34_fail
			cmp eax, 405
			jg click_picture_34_fail
			mov eax, [ebp+arg3]
			cmp eax, 112
			jl click_picture_34_fail
			cmp eax, 158
			jg click_picture_34_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			
			mov eax, 0
			mov ebx, 0
			mov ecx, 0
			
			mov cl, [numbers_array + 10]
			cmp cl, 0
			je change_34_left
			mov cl, [numbers_array + 7]
			cmp cl, 0
			je change_34_above
			mov cl, [numbers_array + 15]
			cmp cl, 0
			je change_34_under
			jmp click_picture_34_fail
			
			change_34_left:
				mov al, [numbers_array + 11]
				mov bl, [numbers_array + 10]
				mov [numbers_array + 11], bl
				mov [numbers_array + 10], al
				jmp verificare_poza_11
				
			change_34_above:
				mov al, [numbers_array + 11]
				mov bl, [numbers_array + 7]
				mov [numbers_array + 11], bl
				mov [numbers_array + 7], al
				jmp verificare_poza_11
				
			change_34_under:
				mov al, [numbers_array + 11]
				mov bl, [numbers_array + 15]
				mov [numbers_array + 11], bl
				mov [numbers_array + 15], al
				jmp verificare_poza_11
				
		click_picture_34_fail:
			jmp click_picture_41
			
		click_picture_41:
			mov EAX, [ebp+arg2]
			cmp EAX, 211
			jl click_picture_41_fail
			cmp eax, 256
			jg click_picture_41_fail
			mov eax, [ebp+arg3]
			cmp eax, 161
			jl click_picture_41_fail
			cmp eax, 206
			jg click_picture_41_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ebx, 0
			mov ecx, 0
			
			mov CL, [numbers_array + 13]
			cmp cl, 0
			je change_41_right
			mov cl, [numbers_array + 8]
			cmp cl, 0
			je change_41_above
			jmp click_picture_41_fail
			
			change_41_right:
				mov AL, [numbers_array + 12]
				mov BL, [numbers_array + 13]
				mov [numbers_array + 12], BL
				mov [numbers_array + 13], AL
				jmp verificare_poza_11
				
			change_41_above:
				mov AL, [numbers_array + 12]
				mov BL, [numbers_array + 8]
				mov [numbers_array + 12], BL
				mov [numbers_array + 8], AL
				jmp verificare_poza_11
				
		click_picture_41_fail:
			jmp click_picture_42
			
		click_picture_42:
			mov EAX, [ebp+arg2]
			cmp EAX, 261
			jl click_picture_42_fail
			cmp EAX, 305
			jg click_picture_42_fail
			mov eax, [ebp+arg3]
			cmp EAX, 161
			jl click_picture_42_fail
			cmp EAX, 206
			jg click_picture_42_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ebx, 0
			mov ecx, 0
			
			mov CL, [numbers_array + 14]
			cmp cl, 0
			je change_42_right
			mov cl, [numbers_array + 12]
			cmp cl, 0
			je change_42_left
			mov CL, [numbers_array + 9]
			cmp cl, 0
			je change_42_above
			jmp click_picture_42_fail
			
			change_42_right:
				mov al, [numbers_array + 13]
				mov bl, [numbers_array + 14]
				mov [numbers_array + 13], bl
				mov [numbers_array + 14], al
				jmp verificare_poza_11
				
			change_42_left:
				mov al, [numbers_array + 13]
				mov bl, [numbers_array + 12]
				mov [numbers_array + 13], bl
				mov [numbers_array + 12], al
				jmp verificare_poza_11
				
			change_42_above:
				mov al, [numbers_array + 13]
				mov bl, [numbers_array + 9]
				mov [numbers_array + 13], bl
				mov [numbers_array + 9], al
				jmp verificare_poza_11
				
		click_picture_42_fail:
			jmp click_picture_43
			
		click_picture_43:
			mov eax, [ebp+arg2]
			cmp EAX, 310
			jl click_picture_43_fail
			cmp eax, 357
			jg click_picture_43_fail
			mov eax, [ebp+arg3]
			cmp eax, 161
			jl click_picture_43_fail
			cmp eax, 206
			jg click_picture_43_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ebx, 0
			mov ecx, 0
			
			mov cl, [numbers_array + 15]
			cmp cl, 0
			je change_43_right
			mov cl, [numbers_array + 13]
			cmp CL, 0
			je change_43_left 
			mov cl, [numbers_array + 10]
			cmp cl, 0
			je change_43_above
			jmp click_picture_43_fail
			
			change_43_right:
				mov al, [numbers_array + 14]
				mov bl, [numbers_array + 15]
				mov [numbers_array + 14], bl
				mov [numbers_array + 15], al
				jmp verificare_poza_11
				
			change_43_left:
				mov al, [numbers_array + 14]
				mov bl, [numbers_array + 13]
				mov [numbers_array + 14], bl
				mov [numbers_array + 13], al
				jmp verificare_poza_11
				
			change_43_above:
				mov al, [numbers_array + 14]
				mov bl, [numbers_array + 10]
				mov [numbers_array + 14], bl
				mov [numbers_array + 10], al
				jmp verificare_poza_11
			
			
			click_picture_43_fail:
				jmp click_picture_44
				
		click_picture_44:
			mov eax, [ebp+arg2]
			cmp EAX, 361
			jl click_picture_44_fail
			cmp eax, 405
			jg click_picture_44_fail
			mov eax, [ebp+arg3]
			cmp EAX, 161
			jl click_picture_44_fail
			cmp eax, 206
			jg click_picture_44_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ebx, 0
			mov ecx, 0
			
			mov cl,[numbers_array + 14]
			cmp cl, 0
			je change_44_left
			mov cl, [numbers_array + 11]
			cmp cl, 0
			je change_44_above
			jmp click_picture_44_fail
			
			change_44_left:
				mov al, [numbers_array + 15]
				mov bl, [numbers_array + 14]
				mov [numbers_array + 15], bl
				mov [numbers_array + 14], al
				jmp verificare_poza_11
				
			change_44_above:
				mov al, [numbers_array + 15]
				mov bl, [numbers_array + 11]
				mov [numbers_array + 15], bl
				mov [numbers_array + 11], al
				jmp verificare_poza_11
			
			
			
			click_picture_44_fail:
				jmp evt_timer 
				
		click_level_2:
			cmp game_won, 1
			je skip_time 
		
		
		click_xsl_11:
			mov eax, [ebp+arg2]
			cmp eax, 211
			jl click_xsl_11_fail
			cmp eax, 258
			jg click_xsl_11_fail
			mov eax, [ebp+arg3]
			cmp eax, 31
			jl click_xsl_11_fail
			cmp eax, 75 
			jg click_xsl_11_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ebx, 0
			mov ecx, 0
			
			mov cl, [xsl_array  + 1]
			cmp cl, 0
			je change_xsl_11_right
			mov cl, [xsl_array  + 3]
			cmp cl, 0
			je change_xsl_11_under
			jmp click_xsl_11_fail
			
			change_xsl_11_right:
				mov al, [xsl_array + 0]
				mov bl, [xsl_array + 1]
				mov [xsl_array + 0], bl
				mov [xsl_array + 1], al
				jmp verificare_poz11_lvl2
				
			change_xsl_11_under:
				mov al, [xsl_array + 0]
				mov bl, [xsl_array + 3]
				mov [xsl_array + 0], bl
				mov [xsl_array + 3], al
				jmp verificare_poz11_lvl2
				
			click_xsl_11_fail:
				jmp click_xsl_12
				
		click_xsl_12:
			mov eax, [ebp+arg2]
			cmp eax, 262
			jl click_xsl_12_fail
			cmp eax, 306
			jg click_xsl_12_fail
			mov eax, [ebp+arg3]
			cmp eax, 31
			jl click_xsl_12_fail
			cmp eax, 75 
			jg click_xsl_12_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ebx, 0
			mov ecx, 0
			
			mov cl,[ xsl_array + 2]
			cmp cl, 0
			je change_xsl_12_right
			mov cl, [xsl_array + 0]
			cmp cl, 0
			je change_xsl_12_left
			mov cl,[xsl_array + 4]
			cmp cl, 0
			je change_xsl_12_under
			jmp click_picture_12_fail
			
			change_xsl_12_right:
				mov al,[xsl_array + 1]
				mov bl,[xsl_array + 2]
				mov [xsl_array + 1], bl
				mov [xsl_array + 2], al
				jmp verificare_poz11_lvl2
				
			change_xsl_12_left:
				mov al,[xsl_array + 1]
				mov bl,[xsl_array + 0]
				mov [xsl_array + 1], bl
				mov [xsl_array + 0], al
				jmp verificare_poz11_lvl2
				
			change_xsl_12_under:
			mov al,[xsl_array + 1]
				mov bl,[xsl_array + 4]
				mov [xsl_array + 1], bl
				mov [xsl_array + 4], al
				jmp verificare_poz11_lvl2
				
		click_xsl_12_fail:
				jmp click_xsl_13
				
		click_xsl_13:
			mov eax, [ebp+arg2]
			cmp eax, 311
			jl click_xsl_13_fail
			cmp eax, 357
			jg click_xsl_13_fail
			mov eax,[ ebp+arg3]
			cmp eax, 31
			jl click_xsl_13_fail
			cmp eax, 75
			jg click_xsl_13_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ebx, 0
			mov ecx, 0
			
			mov cl,[xsl_array + 1]
			cmp cl, 0
			je change_xsl_13_left
			mov cl, [xsl_array + 5]
			cmp cl, 0
			je change_xsl_13_under
			jmp click_xsl_13_fail
			
		change_xsl_13_left:
			mov al,[xsl_array + 2]
				mov bl,[xsl_array + 1]
				mov [xsl_array + 2], bl
				mov [xsl_array + 1], al
				jmp verificare_poz11_lvl2
				
			change_xsl_13_under:
			mov al,[xsl_array + 2]
				mov bl,[xsl_array + 5]
				mov [xsl_array + 2], bl
				mov [xsl_array + 5], al
				jmp verificare_poz11_lvl2
				
		click_xsl_13_fail:
			jmp click_xsl_21
			
			
		click_xsl_21:
			mov eax, [ebp+arg2]
			cmp eax, 210
			jl click_xsl_21_fail
			cmp eax, 257
			jg click_xsl_21_fail
			mov eax, [ebp+arg3]
			cmp eax, 81
			jl click_xsl_21_fail
			cmp eax, 125
			jg click_xsl_21_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ecx, 0
			mov ebx, 0
			
			mov cl,[xsl_array + 4]
			cmp cl, 0
			je change_xsl_21_right
			mov cl,[xsl_array + 0]
			cmp cl, 0
			je change_xsl_21_above
			mov cl, [xsl_array + 6]
			cmp cl, 0
			je change_xsl_21_under
			jmp click_xsl_21_fail
			
			change_xsl_21_right:
				mov al,[ xsl_array + 3]
				mov bl,[ xsl_array + 4]
				mov [xsl_array + 3], bl
				mov [xsl_array + 4], al
				jmp verificare_poz11_lvl2
				
			change_xsl_21_above:
				mov al,[ xsl_array + 3]
				mov bl,[ xsl_array + 0]
				mov [xsl_array + 3], bl
				mov [xsl_array + 0], al
				jmp verificare_poz11_lvl2
				
			change_xsl_21_under:
				mov al,[ xsl_array + 3]
				mov bl,[ xsl_array + 6]
				mov [xsl_array + 3], bl
				mov [xsl_array + 6], al
				jmp verificare_poz11_lvl2
				
		click_xsl_21_fail:
			jmp click_xsl_22
			
		click_xsl_22:
			mov eax, [ebp+arg2]
			cmp eax, 260
			jl click_xsl_22_fail
			cmp eax, 305
			jg click_xsl_22_fail
			mov eax, [ebp+arg3]
			cmp eax, 81
			jl click_xsl_22_fail
			cmp eax, 125
			jg click_xsl_22_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ebx, 0
			mov ecx ,0
			
			mov cl,[xsl_array + 5]
			cmp cl, 0
			je change_xsl_22_right
			mov cl,[xsl_array + 3]
			cmp cl, 0
			je change_xsl_22_left
			mov cl,[xsl_array + 1]
			cmp cl, 0
			je change_xsl_22_above
			mov cl,[xsl_array + 7]
			cmp cl, 0
			je change_xsl_22_under
			jmp click_xsl_22_fail 
			
			change_xsl_22_right:
				mov al,[ xsl_array + 4]
				mov bl,[ xsl_array + 5]
				mov [xsl_array + 4], bl
				mov [xsl_array + 5], al
				jmp verificare_poz11_lvl2
				
			change_xsl_22_left:
				mov al,[ xsl_array + 4]
				mov bl,[ xsl_array + 3]
				mov [xsl_array + 4], bl
				mov [xsl_array + 3], al
				jmp verificare_poz11_lvl2
				
			change_xsl_22_above:
				mov al,[ xsl_array + 4]
				mov bl,[ xsl_array + 1]
				mov [xsl_array + 4], bl
				mov [xsl_array + 1], al
				jmp verificare_poz11_lvl2
				
			change_xsl_22_under:
				mov al,[ xsl_array + 4]
				mov bl,[ xsl_array + 7]
				mov [xsl_array + 4], bl
				mov [xsl_array + 7], al
				jmp verificare_poz11_lvl2
			
		click_xsl_22_fail:
			jmp click_xsl_23
			
		click_xsl_23:
			mov eax, [ebp+arg2]
			cmp eax, 311
			jl click_xsl_23_fail
			cmp eax, 357
			jg click_xsl_23_fail
			mov eax, [ebp+arg3]
			cmp eax, 82
			jl click_xsl_23_fail
			cmp eax, 126
			jg click_xsl_23_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ebx, 0
			mov ecx, 0
			
			mov cl,[xsl_array + 4]
			cmp cl, 0
			je change_xsl_23_left
			mov cl, [xsl_array + 2]
			cmp cl, 0
			je change_xsl_23_above
			mov cl, [xsl_array + 8]
			cmp cl, 0
			je change_xsl_23_under
			jmp click_xsl_23_fail
			
			change_xsl_23_left:
				mov al,[ xsl_array + 5]
				mov bl,[ xsl_array + 4]
				mov [xsl_array + 5], bl
				mov [xsl_array + 4], al
				jmp verificare_poz11_lvl2
			
			change_xsl_23_above:
				mov al,[ xsl_array + 5]
				mov bl,[ xsl_array + 2]
				mov [xsl_array + 5], bl
				mov [xsl_array + 2], al
				jmp verificare_poz11_lvl2
				
			change_xsl_23_under:
				mov al,[ xsl_array + 5]
				mov bl,[ xsl_array + 8]
				mov [xsl_array + 5], bl
				mov [xsl_array + 8], al
				jmp verificare_poz11_lvl2
				
		click_xsl_23_fail:
			jmp click_xsl_31
			
		click_xsl_31:
			mov eax, [ebp+arg2]
			cmp eax, 211
			jl click_xsl_31_fail
			cmp eax, 255
			jg click_xsl_31_fail
			mov eax,[ebp+arg3]
			cmp eax, 132
			jl click_xsl_31_fail
			cmp eax, 176
			jg click_xsl_31_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ebx, 0
			mov ecx, 0
			
			mov cl,[xsl_array + 3]
			cmp cl, 0
			je change_xsl_31_above
			mov cl,[xsl_array + 7]
			cmp cl, 0
			je change_xsl_31_right
			jmp click_xsl_31_fail
			
			change_xsl_31_above:
				mov al,[ xsl_array + 6]
				mov bl,[ xsl_array + 3]
				mov [xsl_array + 6], bl
				mov [xsl_array + 3], al
				jmp verificare_poz11_lvl2
			
			change_xsl_31_right:
					mov al,[ xsl_array + 6]
				mov bl,[ xsl_array + 7]
				mov [xsl_array + 6], bl
				mov [xsl_array + 7], al
				jmp verificare_poz11_lvl2
				
		click_xsl_31_fail:
			jmp click_xsl_32
			
		click_xsl_32:
			mov eax, [ebp+arg2]
			cmp eax, 260
			jl click_xsl_32_fail
			cmp eax, 307
			jg click_xsl_32_fail
			mov eax, [ebp+arg3]
			cmp eax, 132
			jl click_xsl_32_fail
			cmp eax, 176
			jg click_xsl_32_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ebx, 0
			mov ecx, 0
			
			mov cl,[xsl_array + 6]
			cmp cl, 0
			je change_xsl_32_left
			mov cl,[xsl_array+8]
			cmp cl, 0
			je change_xsl_32_right
			mov cl,[xsl_array + 4]
			cmp cl, 0
			je change_xsl_32_above
			jmp click_xsl_32_fail
			
			change_xsl_32_left:
				mov al,[ xsl_array + 7]
				mov bl,[ xsl_array + 6]
				mov [xsl_array + 7], bl
				mov [xsl_array + 6], al
				jmp verificare_poz11_lvl2
				
		
			change_xsl_32_right:
				mov al,[ xsl_array + 7]
				mov bl,[ xsl_array + 8]
				mov [xsl_array + 7], bl
				mov [xsl_array + 8], al
				jmp verificare_poz11_lvl2
				
			change_xsl_32_above:
				mov al,[ xsl_array + 7]
				mov bl,[ xsl_array + 4]
				mov [xsl_array + 7], bl
				mov [xsl_array + 4], al
				jmp verificare_poz11_lvl2
				
			click_xsl_32_fail:
				jmp click_xsl_33
				
		click_xsl_33:
			mov eax, [ebp+arg2]
			cmp eax, 311
			jl click_xsl_33_fail
			cmp eax, 356
			jg click_xsl_33_fail
			mov eax, [ebp+arg3]
			cmp eax, 132
			jl click_xsl_33_fail
			cmp eax, 176
			jg click_xsl_33_fail
			
			add Player_Clicks, 1
			
			mov EAX, counter
			mov EBX, Player_Clicks
			mov edx, 0
			div EBX
			add Player_Score, EAX
			
			mov eax, 0
			mov ecx, 0
			mov ebx, 0
			
			mov cl,[xsl_array + 7]
			cmp cl, 0
			je change_xsl_33_left
			mov cl,[xsl_array + 5]
			cmp cl, 0
			je change_xsl_33_above
			jmp click_xsl_33_fail
			
			change_xsl_33_left:
				mov al,[ xsl_array + 8]
				mov bl,[ xsl_array + 7]
				mov [xsl_array + 8], bl
				mov [xsl_array + 7], al
				jmp verificare_poz11_lvl2
				
			change_xsl_33_above:
				mov al,[ xsl_array + 8]
				mov bl,[ xsl_array + 5]
				mov [xsl_array + 8], bl
				mov [xsl_array + 5], al
				jmp verificare_poz11_lvl2
				
		click_xsl_33_fail:
			jmp evt_timer 
			
		
		no_level_chosen:	
		jmp evt_timer 
			
	
	evt_timer:
		cmp game_won, 0
		je delete_win_message
		jmp check_win
		
		delete_win_message:
			make_text_macro ' ', area, 400, 450
			make_text_macro ' ', area, 410, 450
			make_text_macro ' ', area, 420, 450
	
		check_win:
			cmp choose_level, 1
			je check_win_gigi
			cmp choose_level, 2
			je check_win_xslayder
			jmp no_check_win
			
		check_win_gigi:
			cmp [numbers_array + 0], 1
			jne no_check_win
			cmp [numbers_array + 1], 15
			jne no_check_win
			cmp [numbers_array + 2], 14
			jne no_check_win
			cmp [numbers_array + 3], 13
			jne no_check_win
			cmp [numbers_array + 4], 12
			jne no_check_win
			cmp [numbers_array + 5], 11
			jne no_check_win
			cmp [numbers_array + 6], 10
			jne no_check_win
			cmp [numbers_array + 7], 9
			jne no_check_win
			cmp [numbers_array + 8], 8
			jne no_check_win
			cmp [numbers_array + 9], 7
			jne no_check_win
			cmp [numbers_array + 10], 6
			jne no_check_win
			cmp [numbers_array + 11], 5
			jne no_check_win
			cmp [numbers_array + 12], 4
			jne no_check_win
			cmp [numbers_array + 13], 3
			jne no_check_win
			cmp [numbers_array + 14], 2
			jne no_check_win
			cmp [numbers_array + 15], 0
			jne no_check_win
			jmp WIN 
			
			
			jmp no_check_win
			
		check_win_xslayder:
			cmp [xsl_array + 0], 9
			jne no_check_win
			cmp [xsl_array + 1], 8
			jne no_check_win
			cmp [xsl_array + 2], 7
			jne no_check_win
			cmp [xsl_array + 3], 6
			jne no_check_win
			cmp [xsl_array + 4], 5
			jne no_check_win
			cmp [xsl_array + 5], 4
			jne no_check_win
			cmp [xsl_array + 6], 3
			jne no_check_win
			cmp [xsl_array + 7], 2
			jne no_check_win
			cmp [xsl_array + 8], 0
			jne no_check_win
			jmp WIN
			
			jmp no_check_win
			
		WIN:
			mov game_won, 1
			
			push offset mode_read 
			push offset file_highscore
			call fopen
			add esp, 8
			mov ebx, EAX ;	- pointer la file 
			
			push offset check_highscore 
			push offset format_read_nr     
			push ebx
			call fscanf
			add esp, 12 
			
			mov EDX, check_highscore
			cmp EDX, player_score 
			jl new_high_score
			jmp no_new_high_score 
			
			new_high_score:
				mov new_score, 1
				jmp close_file 
			
			no_new_high_score:
				mov new_score, 0
				jmp close_file 
				
			close_file:
			
			
			push EBX
			call fclose
			add esp, 4 
			
			cmp new_score, 0
			je no_change_highscore
			
			push offset mode_write  
			push offset file_highscore
			call fopen
			add esp, 8
			mov ebx, EAX 
			
			push player_score 
			push offset format_write_nr
			push EBX
			call fprintf 
			add esp, 12 
			
			
			
			push ebx
			call fclose
			add esp, 4 
			
			
			no_change_highscore:
			
			make_text_macro 'W', area, 310, 450
			make_text_macro 'I', area, 320, 450
			make_text_macro 'N', area, 330, 450
			
		check_time_or_not:	
			
		cmp game_won, 0
		je continue_time
		jmp skip_time
			
		no_check_win:
	
		
		continue_time:
	
		add time_penalty, 1
		
		cmp game_started, 1
		je add_seconds
		jmp dont_add_seconds 
		
		add_seconds:
		add time_seconds, 1
		
		dont_add_seconds:
		
		check_time_elapsed:
			mov EAX, time_seconds
			cmp EAX, 5
			jne check_time_penalty
			add time_elapsed, 1
			mov time_seconds, 0
	
			
		check_time_penalty:
		
		mov EAX, time_penalty 		; verificam daca intr-un interval de timp s-a apasat click de mai mult de o data, ca sa verificam click score abuse 
		cmp EAX, 25					; facem ca odata la un interval de timp sa se scada puncte 
		je add_penalty_time 		; de asemenea la un alt interval de timp adaugam puncte la scor
		jmp no_penalty				; mai scadem din puncte pt CLICK apasat 
		
		add_penalty_time:
			cmp Player_Score, 0
			jne substract_score
			jmp no_sub
			substract_score:
			sub Player_Score, 1
			
			no_sub:
			mov time_penalty, 0
			
		
		no_penalty:
		inc counter
		
		skip_time:
		
		
	afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter 
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;afisam valoarea SCORULUI jucatorului
	mov EAX, game_started
	cmp EAX, 1
	je show_player_score
	jmp no_show_player_score
	
	
	show_player_score:
	mov ebx, 10
	mov eax, Player_Score 
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 360, 315
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 350, 315
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 340, 315
	
	;afisare secunde scurse 
	mov ebx, 10
	mov eax, time_elapsed  
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 360, 340
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 350, 340
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 340, 340
	
	;afisare high score 
	push offset mode_read 
	push offset file_highscore 
	call fopen
	add esp, 8 
	mov ebx, eax
	
	push offset current_score 
	push offset format_read_nr 
	push ebx 
	call fscanf
	add esp, 12 
	
	
	push ebx
	call fclose
	add esp, 4 
	
	mov ebx, 10
	mov EAX, current_score
	
	;cifra unitatilor 
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 360, 365
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 350, 365
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 340, 365
	
	
	no_show_player_score:
		
	final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
	
draw endp

start:
	mov EAX, area_width
	mov EBX, area_height
	mul EAX		; pregatim zona de memorie necesara, (EAX * EBX) -> in EAX
	shl EAX, 2    ;inmultim cu 4, pt ca un pixel este DWORD, adica 4 bytes
	push EAX
	call malloc
	add ESP, 4		
	mov AREA, EAX		; mutam IN AREA, care initial e 0, EAX, adica in area vom avea locatia primului PIXEL de desenat
	
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char* title, int width, int height, unsigned int* area, DrawFunc draw);
	
	
	
	push offset draw
	push area			;pusham pe stack argumentele functiei, in ordine inversa, deoarece e functie CDECL (BeginDrawing)
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add ESP, 20		;curatam stiva
	

	
	
	push 0
	call exit
end start 