.model	small		; small memory model - separate code and data sections
.386
.stack	50000

Include util.inc 
Include dline.inc

.data

TLC DB 10000000b ; таблицаs
	DB 01000000b ; для
	DB 00100000b ; левого
	DB 00010000b ; конца
	DB 00001000b ; отрезка
	DB 00000100b ;
	DB 00000010b ;
	DB 00000001b ; 

TLL	DB 00000001b ; 
	DB 00000011b ;
	DB 00000111b ;
	DB 00001111b ; отрезка
	DB 00011111b ; конца
	DB 00111111b ; левого
	DB 01111111b ; для
	DB 11111111b ; таблица

TLP DB 00000000b ; 
	DB 00000001b ;
	DB 00000011b ;
	DB 00000111b ; отрезка
	DB 00001111b ; конца
	DB 00011111b ; левого
	DB 00111111b ; для
	DB 01111111b ; таблица

TRR	DB 10000000b ;
	DB 11000000b ; отрезка
	DB 11100000b ; конца
	DB 11110000b ; 
	DB 11111000b ; правого
	DB 11111100b ; для
	DB 11111110b ; таблица
	DB 11111111b ; таблица

TRP	DB 00000000b ;
	DB 10000000b ;
	DB 11000000b ; отрезка
	DB 11100000b ; конца
	DB 11110000b ; 
	DB 11111000b ; правого
	DB 11111100b ; для
	DB 11111110b ; таблица

XP 	DW ?				; XP(aint)
YP 	DW ?				; YP(aint)

atp	DW ?
wpp DB ?
ipp_b DB ?
ipp_r DB ?

ctr DW ?

bo 	DW ?

pc 	DB ?

XCP DW ?				;XC(urrent)P(aint)
XLP DW ?				;XL(eft)P(aint)
XSP DW ?
XRP DW ?				;XR(ight)P(aint)
YCP	DW ?				;YC(urrent)P(aint)

.code

PUBLIC paint2
paint2 PROC

	push EBP
	mov EBP, ESP
	push EDX

 	mov DX, 3CEh
 	mov AX, 0805h
 	out DX, AX 			; write mode - 0, read - 1

 	mov DX, 3CEh
	mov AX, 08FFh
 	out DX, AX			; set bit mask

 	xor	EAX, EAX		; clear
	xor EBX, EBX		; every
	xor ECX, ECX		; thing

	mov AX, 0FFh
	push AX

	mov EAX, [ebp+6]	; load YP
	mov [YP], AX
	push AX

	mov EAX, [ebp+10] 	; load XP
	mov [XP], AX
	push AX	

	mov [ctr], 1

_paint2_loop:

	xor EAX, EAX
	xor EBX, EBX

	cmp [ctr], 0
	je _paint2_end

	; Pop current point from stack
	pop AX
	;cmp AX, 0FFh
	;je _paint2_end

	mov [XCP], AX
	
	pop BX
	mov [YCP], BX

	dec [ctr]

	;Paint it
	push EAX
	push EBX

	call draw_dot_blue

	add ESP, 8

	jmp _check_w

_check_w:

	mov [ipp_b], 0
	mov [ipp_r], 0

 	mov DX, 3CEh
	mov AX, 0C02h
 	out DX, AX 			; cmp with red

	mov BX, [YCP]
	push BX	

	mov AX, [XCP]
	dec AX
	push AX
	
	call is_pixel_painted
	add ESP, 4			; clear stack

	mov [ipp_r], AL

	mov DX, 3CEh
	mov AX, 0902h
 	out DX, AX 			; cmp with blue

	mov BX, [YCP]
	push BX	

	mov AX, [XCP]
	dec AX
	push AX
	
	call is_pixel_painted
	add ESP, 4			; clear stack

	mov [ipp_b], AL

	cmp [ipp_b], 0
	jne _check_n

	cmp [ipp_r], 0
	jne _check_n
	
	cmp [ctr], 15000
	jge _paint2_loop

	mov BX, [YCP]
	push BX	

	mov AX, [XCP]
	dec AX
	push AX

	inc [ctr]

_check_n:

	mov [ipp_b], 0
	mov [ipp_r], 0

 	mov DX, 3CEh
	mov AX, 0C02h
 	out DX, AX 			; cmp with red

	mov BX, [YCP]
	dec BX
	push BX	

	mov AX, [XCP]
	push AX
	
	call is_pixel_painted
	add ESP, 4			; clear stack

	mov [ipp_r], AL

	mov DX, 3CEh
	mov AX, 0902h
 	out DX, AX 			; cmp with blue

	mov BX, [YCP]
	dec BX
	push BX	

	mov AX, [XCP]
	push AX
	
	call is_pixel_painted
	add ESP, 4			; clear stack

	mov [ipp_b], AL

	cmp [ipp_b], 0
	jne _check_e

	cmp [ipp_r], 0
	jne _check_e

	cmp [ctr], 15000
	jge _paint2_loop
	
	mov BX, [YCP]
	dec BX
	push BX	

	mov AX, [XCP]
	push AX

	inc [ctr]

_check_e:

	mov [ipp_b], 0
	mov [ipp_r], 0

 	mov DX, 3CEh
	mov AX, 0C02h
 	out DX, AX 			; cmp with red

	mov BX, [YCP]
	push BX	

	mov AX, [XCP]
	inc AX
	push AX
	
	call is_pixel_painted
	add ESP, 4			; clear stack

	mov [ipp_r], AL

	mov DX, 3CEh
	mov AX, 0902h
 	out DX, AX 			; cmp with blue

	mov BX, [YCP]
	push BX	

	mov AX, [XCP]
	inc AX
	push AX
	
	call is_pixel_painted
	add ESP, 4			; clear stack

	mov [ipp_b], AL

	cmp [ipp_b], 0
	jne _check_s

	cmp [ipp_r], 0
	jne _check_s

	cmp [ctr], 15000
	jge _check_s

	mov BX, [YCP]
	push BX	

	mov AX, [XCP]
	inc AX
	push AX

	inc [ctr]
	jmp _paint2_loop

_check_s:

	mov [ipp_b], 0
	mov [ipp_r], 0

 	mov DX, 3CEh
	mov AX, 0C02h
 	out DX, AX 			; cmp with red

	mov BX, [YCP]
	inc BX
	push BX	

	mov AX, [XCP]
	push AX
	
	call is_pixel_painted
	add ESP, 4			; clear stack

	mov [ipp_r], AL

	mov DX, 3CEh
	mov AX, 0902h
 	out DX, AX 			; cmp with blue

	mov BX, [YCP]
	inc BX
	push BX	

	mov AX, [XCP]
	push AX
	
	call is_pixel_painted
	add ESP, 4			; clear stack

	mov [ipp_b], AL

	cmp [ipp_b], 0
	jne _paint2_loop

	cmp [ipp_r], 0
	jne _paint2_loop

	cmp [ctr], 15000
	jge _paint2_loop
	
	mov BX, [YCP]
	inc BX
	push BX	

	mov AX, [XCP]
	push AX

	inc [ctr]

	jmp _paint2_loop

_paint2_end:
	pop EDX
	mov ESP, EBP 		;Deallocate local (jic)
	pop EBP

	ret

paint2 ENDP

PUBLIC paint
paint PROC

paint ENDP

end