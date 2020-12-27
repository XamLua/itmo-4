
.model	small, c		; small memory model - separate code and data sections
.386
.stack	4096

Include util.inc 

.data

TLL	DB 11111111b ; таблица
	DB 01111111b ; для
	DB 00111111b ; левого
	DB 00011111b ; конца
	DB 00001111b ; отрезка
	DB 00000111b ;
	DB 00000011b ;
	DB 00000001b ; 

TRR	DB 00000000b ; 
	DB 10000000b ;
	DB 11000000b ; отрезка
	DB 11100000b ; конца
	DB 11110000b ; 
	DB 11111000b ; правого
	DB 11111100b ; для
	DB 11111110b ; таблица

X 	DW ?				; X
Y 	DW ?				; Y
XC 	DW ?				; Xc(ircle)
YC	DW ?				; Yc(ircle)
R 	DW ?				; R
MD 	DW ?				; Mode for c(ircle)
X1 	DW ?				; X1
Y1 	DW ?				; Y1
X2 	DW ?				; X2
Y2 	DW ?				; Y2 
L 	DW ?				; L(ength)

_dgz	DW ?
_dlz 	DW ?
_rkx 	DB ?

S1	DW ?				; left byte offset
B1	DB ?				; left bit offset

S2	DW ?				; right byte offset
B2	DB ?				; right bit offset

.code

PUBLIC draw_dot_blue
draw_dot_blue PROC

	push EBP
	mov EBP, ESP
	push EDX

	mov DX, 3C4h 		; указатель на адресный регистр
 	mov AL, 2 			; индекс регистра маски цвета
 	out DX, AL 			; устанавливаем адрес регистра маски
 	inc DX 				; адрес регистра данных
 	mov AL, 06h 		; код цвета
 	out DX, AL 			; посылаем код цвета в контроллер

	xor	EAX, EAX		; clear
	xor EBX, EBX		; every
	xor ECX, ECX		; thing

	mov EAX, [ebp+6]	; load Y
	mov [Y], AX
	
	mov EAX, [ebp+10] 	; load X
	mov [X], AX	

;	Obtain offsets end

	mov AX, [Y] 			
	push AX
	mov AX, [X]
	push AX
	call calc_offset

	add ESP, 4			; clear stack

	mov CL, AL 			; bit off -> B1
	mov BL, 080h
	shr BL, CL

	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, BL
 	out DX, AL 			; set bit mask

	mov CL, 16			; shift 16
	shr EAX, CL 		; byte off -> AX
	mov BX, AX
	mov CX, 0

	mov AL, ES:[BX]
	mov AL, 00h
	mov ES:[BX], AL

	pop EDX
	mov ESP, EBP 		;Deallocate local (jic)
	pop EBP

	ret

draw_dot_blue ENDP

PUBLIC draw_dot
draw_dot PROC

	push EBP
	mov EBP, ESP
	push EDX

	mov DX, 3C4h 		; указатель на адресный регистр
 	mov AL, 2 			; индекс регистра маски цвета
 	out DX, AL 			; устанавливаем адрес регистра маски
 	inc DX 				; адрес регистра данных
 	mov AL, 03h 		; код цвета
 	out DX, AL 			; посылаем код цвета в контроллер

	xor	EAX, EAX		; clear
	xor EBX, EBX		; every
	xor ECX, ECX		; thing

	mov EAX, [ebp+6]	; load Y
	mov [Y], AX
	
	mov EAX, [ebp+10] 	; load X
	mov [X], AX	

;	Obtain offsets end

	mov AX, [Y] 			
	push AX
	mov AX, [X]
	push AX
	call calc_offset

	add ESP, 4			; clear stack

	mov CL, AL 			; bit off -> B1
	mov BL, 080h
	shr BL, CL

	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, BL
 	out DX, AL 			; set bit mask

	mov CL, 16			; shift 16
	shr EAX, CL 		; byte off -> AX
	mov BX, AX
	mov CX, 0

	mov AL, ES:[BX]
	mov AL, 00h
	mov ES:[BX], AL

	pop EDX
	mov ESP, EBP 		;Deallocate local (jic)
	pop EBP

	ret

draw_dot ENDP

PUBLIC draw_horizontal_line
draw_horizontal_line PROC

; Draws a line 

	push ebp
	mov ebp, esp
	push edx

	xor	EAX, EAX		; clear
	xor EBX, EBX		; every
	xor ECX, ECX		; thing

	mov EAX, [ebp+6]	; load L
	mov [L], AX
	
	mov EAX, [ebp+10] 	; load Y
	mov [Y], AX

	mov EAX, [ebp+14] 	; load X
	mov [X], AX


;	Obtain left end

	mov AX, [Y] 			
	push AX
	mov AX, [X]
	push AX
	call calc_offset

	add ESP, 4			; clear stack

	mov B1, AL 			; bit off -> B1
	mov CL, 16			; shift 16
	shr EAX, CL 		; byte off -> AX
	mov S1, AX			; AX -> S1

; 	Obtain right end

	mov	AX, S1
	mov S2, AX
	mov AL, B1
	mov B2, AL

	xor BX, BX
	mov BX, L 			; Length -> BX

	mov CL, 3
	shr BX, CL
	add S2, BX			; S2 = S1 + L div 8

	xor BX, BX
	mov BX, L
	and BL, 07h
	add B2, BL 			; B2 = B1 + L mod 8
	jz _b_0_

	cmp B2, 8			; B2 <= 8
	jl _draw_horizontal_line
	sub B2, 8
	inc S2
	jmp _draw_horizontal_line

_b_0_:
	dec S2
	mov B2, 07h

_draw_horizontal_line:

	mov AX, S2
	sub AX, S1

	jz	_same_byte

	jmp _not_same_byte
	
_same_byte:

	mov BL, 0FFh		; 11111111 -> AL

	xor DH, DH
	mov DL, B1
	mov SI, DX

	and BL, TLL+[SI]		; BL & B1 mask
	mov DL, B2
	mov SI, DX
	and BL, TRR+[SI]		; BL & B2 mask

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, BL
 	out DX, AL 			; set bit mask

 	mov BX, S1
 	mov AL, ES:[BX]
 	mov AL, 00h
 	mov ES:[BX], AL

	jmp _draw_horizontal_line_end

_not_same_byte:

	mov BL, 0FFh		; 11111111 -> AL

	xor DH, DH
	mov DL, B1
	mov SI, DX
	and BL, TLL+[SI]		; B1 mask

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, BL
 	out DX, AL 			; set bit mask

 	mov BX, S1
 	mov AL, ES:[BX]
 	mov AL, 00h
 	mov ES:[BX], AL 	; paint 1st byte

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, 0FFh
 	out DX, AL 			; set bit mask

	mov DI, S1
	inc DI
	mov CX, S2
	sub CX, S1
	dec CX
	mov	AL,	000h 		; white color code
	rep	STOSB			; Fill block containing (E)CX bytes starting with address ES:(E)DI with AL

	mov BL, 0FFh		; 11111111 -> AL
	
	xor DH, DH
	mov DL, B2
	mov SI, DX
	and BL, TRR+[SI]		; B2 mask

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, BL
 	out DX, AL 			; set bit mask

 	mov BX, S2
 	mov AL, ES:[BX]
 	mov AL, 00h
 	mov ES:[BX], AL 	; paint 2nd byte

_draw_horizontal_line_end:

	pop edx
	mov esp, ebp 		;Deallocate local (jic)
	pop ebp

	ret

draw_horizontal_line ENDP

PUBLIC draw_vertical_line
draw_vertical_line PROC

	push ebp
	mov ebp, esp
	push edx

	xor	EAX, EAX		; clear
	xor EBX, EBX		; every
	xor ECX, ECX		; thing

	mov EAX, [ebp+6]	; load L
	mov [L], AX
	
	mov EAX, [ebp+10] 	; load Y
	mov [Y], AX

	mov EAX, [ebp+14] 	; load X
	mov [X], AX


;	Obtain top end

	mov AX, [Y] 			
	push AX
	mov AX, [X]
	push AX
	call calc_offset

	add ESP, 4			; clear stack

	mov CL, AL 			; bit off -> B1
	mov BL, 080h
	shr BL, CL

	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, BL
 	out DX, AL 			; set bit mask

	mov CL, 16			; shift 16
	shr EAX, CL 		; byte off -> AX
	mov BX, AX
	mov CX, 0

_draw_vertical_line_loop:
	mov AL, ES:[BX]
	mov AL, 00h
	mov ES:[BX], AL
	add BX, 80

	inc CX
	cmp CX, [L]
	jb _draw_vertical_line_loop

	pop edx
	mov esp, ebp 		;Deallocate local (jic)
	pop ebp

	ret

draw_vertical_line ENDP

PUBLIC draw_kx_line
draw_kx_line PROC

	push ebp
	mov ebp, esp
	push edx

	xor	EAX, EAX		; clear
	xor EBX, EBX		; every
	xor ECX, ECX		; thing
	xor EDX, EDX		; thing

	mov EBX, [ebp+6]	; load Y2
	mov [Y2], BX
	
	mov EAX, [ebp+10] 	; load X2
	mov [X2], AX

	mov ECX, [ebp+14]	; load Y2
	mov [Y1], CX
	
	mov EDX, [ebp+18] 	; load X2
	mov [X1], DX

; 	Check for reverse

	sub EAX, EDX
	cdq
	xor EAX, EDX
	sub EAX, EDX 		; |x1 - x2| -> EAX

	mov EDX, EBX
	mov EBX, EAX		; |x1 - x2| = dx -> EBX
	mov EAX, ECX

	sub EAX, EDX
	cdq
	xor EAX, EDX
	sub EAX, EDX 		; |y1 - y2| = dy -> EAX

	mov ECX, EAX		; dy -> ECX, dx -> EBX

	mov [_rkx], 00h
	cmp ECX, EBX
	jl _no_reverse

	xor	EAX, EAX		; clear
	xor EBX, EBX		; every
	xor ECX, ECX		; thing
	xor EDX, EDX		; thing

	mov AX, [X1]
	mov BX, [Y1]
	mov [Y1], AX
	mov [X1], BX

	mov AX, [X2]
	mov BX, [Y2]
	mov [Y2], AX
	mov [X2], BX

	mov BX, [Y2]
	mov AX, [X2]
	mov CX, [Y1]
	mov DX, [X1]
	mov [_rkx], 0FFh

; 	Main Part 
	sub EAX, EDX
	cdq
	xor EAX, EDX
	sub EAX, EDX 		; |x1 - x2| -> EAX

	mov EDX, EBX
	mov EBX, EAX		; |x1 - x2| = dx -> EBX
	mov EAX, ECX

	sub EAX, EDX
	cdq
	xor EAX, EDX
	sub EAX, EDX 		; |y1 - y2| = dy -> EAX

	mov ECX, EAX		; dy -> ECX, dx -> EBX

_no_reverse:
	shl EAX, 1
	mov [_dlz], AX		; 2dy -> _dlz

	sub ECX, EBX
	sal ECX, 1
	mov [_dgz], CX		; 2(dy-dx) -> _dgz

	sub EAX, EBX 		; d0 = 2dy-dx -> EAX
	mov EDX, EAX 		; d0 -> EDX

	mov CX, BX
	inc CX

;	Choose MODE

	mov AX, [X1]
	mov BX, [X2]

	cmp AX, BX
	jl _x1lx2

	xor SI, SI
	sub SI, 1
	jmp _cmp_ys

_x1lx2:
	mov SI, 1

_cmp_ys:
	mov AX, [Y1]	
	mov BX, [Y2]

	cmp AX, BX
	jl _y1ly2

	xor DI, DI
	sub DI, 1
	jmp _draw_kx_line_init

_y1ly2:
	mov DI, 1

_draw_kx_line_init:

	mov AX, [X1]
	mov BX, [Y1]

_draw_kx_line_loop:
	
	push DX
	push CX
	push SI
	push DI

	mov CL, [_rkx]
	cmp CL, 0
	jne _rdp

	push EAX
	push EBX
	call draw_dot
	pop EBX
	pop EAX
	jmp _adp

_rdp:
	push EBX
	push EAX
	call draw_dot
	pop EAX
	pop EBX

_adp:
	pop DI
	pop SI
	pop CX
	pop DX

	cmp DX, 0
	jl _draw_kx_line_dlz
	jmp _draw_kx_line_dgz

_draw_kx_line_dlz:
	add DX, [_dlz]
	jmp _draw_kx_line_loop_end

_draw_kx_line_dgz:
	add DX, [_dgz]
	add BX, DI
	jmp _draw_kx_line_loop_end

_draw_kx_line_loop_end:
	add AX, SI
	dec CX

	jnz _draw_kx_line_loop

	pop edx
	mov esp, ebp 		;Deallocate local (jic)
	pop ebp

	ret

draw_kx_line ENDP

PUBLIC draw_circle
draw_circle PROC

	push EBP
	mov EBP, ESP
	push EDX

	xor	EAX, EAX		; clear
	xor EBX, EBX		; every
	xor ECX, ECX		; thing
	xor EDX, EDX		; thing

	mov ECX, [EBP+6]
	mov [MD], CX

	mov ECX, [ebp+10]	; load R
	mov [R], CX
	
	mov EBX, [ebp+14] 	; load Y
	mov [YC], BX

	mov EAX, [ebp+18] 	; load X
	mov [XC], AX

	xor AX, AX
	mov BX, CX

_draw_circle_loop:
	add DX, AX
	mov CX, BX
	shr CX, 1
	cmp DX, CX
	jl _dspl
	sub DX, BX
	dec BX

_dspl:

_11:
	mov CX, [MD]
	and CX, 00000001b
	jz _12

	push AX
	push BX

	add AX, [XC]
	push EAX

	mov CX, BX
	mov BX, [YC]
	sub BX, CX
	push EBX

	call draw_dot
	add ESP, 8			; clear stack

	pop BX
	pop AX

_12:
	mov CX, [MD]
	and CX, 00000010b
	jz _21

	push AX
	push BX

	add BX, [XC]
	push EBX

	mov CX, AX
	mov AX, [YC]
	sub AX, CX
	push EAX

	call draw_dot
	add ESP, 8			; clear stack

	pop BX
	pop AX
_21:
	mov CX, [MD]
	and CX, 00000100b
	jz _22

	push AX
	push BX

	mov CX, BX
	mov BX, [XC]
	sub BX, CX
	push EBX

	mov CX, AX
	mov AX, [YC]
	sub AX, CX
	push EAX

	call draw_dot
	add ESP, 8			; clear stack

	pop BX
	pop AX
_22:
	mov CX, [MD]
	and CX, 00001000b
	jz _31

	push AX
	push BX

	mov CX, AX
	mov AX, [XC]
	sub AX, CX
	push EAX

	mov CX, BX
	mov BX, [YC]
	sub BX, CX
	push EBX

	call draw_dot
	add ESP, 8			; clear stack

	pop BX
	pop AX
_31:
	mov CX, [MD]
	and CX, 00010000b
	jz _32

	push AX
	push BX

	mov CX, BX
	mov BX, [XC]
	sub BX, CX
	push EBX

	add AX, [YC]
	push EAX

	call draw_dot
	add ESP, 8			; clear stack

	pop BX
	pop AX
_32:
	mov CX, [MD]
	and CX, 00100000b
	jz _41

	push AX
	push BX

	mov CX, AX
	mov AX, [XC]
	sub AX, CX
	push EAX

	mov CX, BX
	mov BX, [YC]
	add BX, CX
	push EBX

	call draw_dot
	add ESP, 8			; clear stack

	pop BX
	pop AX
_41:
	mov CX, [MD]
	and CX, 01000000b
	jz _42

	push AX
	push BX

	add AX, [XC]
	push EAX

	add BX, [YC]
	push EBX

	call draw_dot
	add ESP, 8			; clear stack

	pop BX
	pop AX
_42:
	mov CX, [MD]
	and CX, 10000000b
	jz _endd

	push AX
	push BX

	add BX, [XC]
	push EBX

	add AX, [YC]
	push EAX

	call draw_dot
	add ESP, 8			; clear stack

	pop BX
	pop AX

_endd:
	inc AX
	cmp AX, BX
	jle _draw_circle_loop

	pop EDX
	mov ESP, EBP 		;Deallocate local (jic)
	pop EBP

	ret
draw_circle ENDP

end