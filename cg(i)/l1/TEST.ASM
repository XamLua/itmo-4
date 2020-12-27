
	.model	small		; small memory model - separate code and data sections
	.386
	.stack	2000

Include paint.inc
Include dline.inc
Include util.inc

.data

SESP DD ?


.code		        	; code section

start:
	mov AX, @data		; setup data segment
	mov DS, AX

	mov	AX,	010H		; EGA 640x350 16 colors
	int	10h				; apply BIOS code

;Base - 3CEh
	
;Register	Meaning						Default value		Address	
;00h 		Set / Reset 				00h 				3CEh
;01h 		Enable Set / Reset 			00h 				3CFh
;02h 		Color Compare	 			00h 				3D0h
;03h 		Function Select 			00h
;04h 		Read Map Select 			00h
;05h		Mode 						00h
;06h 		Miscellaneous 				varies
;07h 		Color Don't Care 			0Fh
;08h 		Bit Mask 					FFh 

;---------------------------------------------------------------------------

;						  0000 0110 1110 1111 0000	Segment,	16 bits, shifted 4 bits left (or multiplied by 0x10)
;						+      0001 0010 0011 0100	Offset,		16 bits                         	
;						  0000 1000 0001 0010 0100	Address,	20 bits

	mov	AX,	0A000H		; beginning Address (A0000)
	mov	ES,	AX			;
	mov	BX,	0			; first byte


;---------------------------------------------------------------------------


 	mov DX, 3CEh
	mov AL, 5
 	out DX, AL
 	inc DX
 	mov AL, 00000000b
 	out DX, AL 			; write mode - 0, read - 0

 	mov [SESP], ESP

_mode_chooser:

	mov DX, 3C4h 		; указатель на адресный регистр
 	mov AL, 2 			; индекс регистра маски цвета
 	out DX, AL 			; устанавливаем адрес регистра маски
 	inc DX 				; адрес регистра данных
 	mov AL, 0Fh 		; код цвета (белый)
 	out DX, AL 			; посылаем код цвета в контроллер

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, 0FFh
 	out DX, AL 			; set bit mask

	call clear_screen
	xor AX, AX
	;call set_offst
	;call mode_choose_message
	;call read_number

	mov AX, 8

	cmp AX, 0
	je _good_end

	cmp AX, 1
	je _mode_1

	cmp AX, 2
	je _mode_2

	cmp AX, 3
	je _mode_3

	cmp AX, 4
	je _mode_4

	cmp AX, 5
	je _mode_5

	cmp AX, 6
	je _mode_6

	cmp AX, 7
	je _mode_7

	cmp AX, 8
	je _mode_8

	jmp _good_end

_mode_1:

	mov AX, 1280
	call set_offst

	call draw_line_message_x
	call read_number
	push EAX

	mov AX, 2560
	call set_offst

	call draw_line_message_y
	call read_number
	push EAX

	MOV DX, 3C4h 		; указатель на адресный регистр
 	MOV AL, 2 			; индекс регистра маски цвета
 	OUT DX, AL 			; устанавливаем адрес регистра маски
 	INC DX 				; адрес регистра данных
 	MOV AL, 0Fh 		; код цвета (серый)
 	OUT DX, AL 			; посылаем код цвета в контроллер

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, 0FFh
 	out DX, AL 			; set bit mask

	call clear_screen
	
	call draw_dot

	xor AX, AX			; 00 - wait until next button press
	int 16h				; interupt 16h

	jmp _mode_chooser

_mode_2:

	mov AX, 1280
	call set_offst

	call draw_line_message_x
	call read_number
	push EAX

	mov AX, 2560
	call set_offst

	call draw_line_message_y
	call read_number
	push EAX

	mov AX, 3840
	call set_offst

	call draw_line_message_l	
	call read_number
	push EAX

	MOV DX, 3C4h 		; указатель на адресный регистр
 	MOV AL, 2 			; индекс регистра маски цвета
 	OUT DX, AL 			; устанавливаем адрес регистра маски
 	INC DX 				; адрес регистра данных
 	MOV AL, 0Fh 		; код цвета (серый)
 	OUT DX, AL 			; посылаем код цвета в контроллер

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, 0FFh
 	out DX, AL 			; set bit mask

	call clear_screen
	
	call draw_horizontal_line

	xor AX, AX			; 00 - wait until next button press
	int 16h				; interupt 16h

	jmp _mode_chooser

_mode_3:
	mov AX, 1280
	call set_offst

	call draw_line_message_x
	call read_number
	push EAX

	mov AX, 2560
	call set_offst

	call draw_line_message_y
	call read_number
	push EAX

	mov AX, 3840
	call set_offst

	call draw_line_message_l	
	call read_number
	push EAX

	MOV DX, 3C4h 		; указатель на адресный регистр
 	MOV AL, 2 			; индекс регистра маски цвета
 	OUT DX, AL 			; устанавливаем адрес регистра маски
 	INC DX 				; адрес регистра данных
 	MOV AL, 0Fh 		; код цвета (серый)
 	OUT DX, AL 			; посылаем код цвета в контроллер

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, 0FFh
 	out DX, AL 			; set bit mask

	call clear_screen
	
	call draw_vertical_line

	xor AX, AX			; 00 - wait until next button press
	int 16h				; interupt 16h

	jmp _mode_chooser

_mode_4:

	mov AX, 1280
	call set_offst

	call draw_line_message_x1
	call read_number
	push EAX

	mov AX, 2560
	call set_offst

	call draw_line_message_y1
	call read_number
	push EAX

	mov AX, 3840
	call set_offst

	call draw_line_message_x2
	call read_number
	push EAX


	mov AX, 5120
	call set_offst

	call draw_line_message_y2	
	call read_number
	push EAX

	MOV DX, 3C4h 		; указатель на адресный регистр
 	MOV AL, 2 			; индекс регистра маски цвета
 	OUT DX, AL 			; устанавливаем адрес регистра маски
 	INC DX 				; адрес регистра данных
 	MOV AL, 0Fh 		; код цвета (серый)
 	OUT DX, AL 			; посылаем код цвета в контроллер

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, 0FFh
 	out DX, AL 			; set bit mask

	call clear_screen

	call draw_kx_line
	
	xor AX, AX			; 00 - wait until next button press
	int 16h				; interupt 16h

	jmp _mode_chooser

_mode_5:

 	mov DX, 3CEh
 	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, 0FFh
 	out DX, AL 			; set bit mask

 	mov DX, 3C4h 		; указатель на адресный регистр
 	mov AL, 2 			; индекс регистра маски цвета
 	out DX, AL 			; устанавливаем адрес регистра маски
 	inc DX 				; адрес регистра данных
 	mov AL, 0Fh 		; код цвета
 	out DX, AL 			; посылаем код цвета в контроллер

	xor DI,	DI			; DI = 0
	mov	CX,	0FFFFh		; counter 
	mov	AL,	000h 		; black color code
	rep	STOSB			; Fill block containing (E)CX bytes starting with address ES:(E)DI with ALs

	mov DX, 3C4h 		; указатель на адресный регистр
 	mov AL, 2 			; индекс регистра маски цвета
 	out DX, AL 			; устанавливаем адрес регистра маски
 	inc DX 				; адрес регистра данных
 	mov AL, 09h 		; код цвета
 	out DX, AL 			; посылаем код цвета в контроллер

 	mov BX, 0A1h
 	mov AL, ES:[BX]
 	mov AL, 0Ah
 	mov ES:[BX], AL

 	xor AX, AX			; 00 - wait until next button press
	int 16h				; interupt 16h

	jmp _mode_chooser

_mode_6:

	mov AX, 1280
	call set_offst

	call draw_line_message_x
	call read_number
	;mov EAX, 320
	push EAX

	mov AX, 2560
	call set_offst

	call draw_line_message_y
	call read_number
	;mov EAX, 175
	push EAX

	mov AX, 3840
	call set_offst

	call draw_line_message_r
	call read_number
	;mov EAX, 100
	push EAX

	mov AX, 5120
	call set_offst

	call draw_line_message_md
	call read_number
	;mov EAX, 255
	push EAX

	mov DX, 3C4h 		; указатель на адресsный регистр
 	mov AL, 2 			; индекс регистра маски цвета
 	out DX, AL 			; устанавливаем адрес регистра маски
 	inc DX 				; адрес регистра данных
 	mov AL, 0Fh 		; код цвета (серый)
 	out DX, AL 			; посылаем код цвета в контроллер

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, 0FFh
 	out DX, AL 			; set bit mask

	call clear_screen
	call draw_circle

	xor AX, AX			; 00 - wait until next button press
	int 16h				; interupt 16h

	jmp _mode_chooser

_mode_7:

	mov DX, 3C4h 		; указатель на адресsный регистр
 	mov AL, 2 			; индекс регистра маски цвета
 	out DX, AL 			; устанавливаем адрес регистра маски
 	inc DX 				; адрес регистра данных
 	mov AL, 0Fh 		; код цвета (белый)
 	out DX, AL 			; посылаем код цвета в контроллер

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, 0FFh
 	out DX, AL 			; set bit mask

	call clear_screen

	mov DX, 3C4h 		; указатель на адресsный регистр
 	mov AL, 2 			; индекс регистра маски цвета
 	out DX, AL 			; устанавливаем адрес регистра маски
 	inc DX 				; адрес регистра данных
 	mov AL, 0Fh 		; код цвета (серый)
 	out DX, AL 			; посылаем код цвета в контроллер

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, 0FFh
 	out DX, AL 			; set bit mask

	;xor AX, AX
	;int 16h

	mov EAX, 50
	push EAX

	mov EAX, 200
	push EAX

	mov EAX, 150
	push EAX

	mov EAX, 200
	push EAX

	call draw_kx_line

	mov EAX, 80
	push EAX

	mov EAX, 150
	push EAX

	mov EAX, 180
	push EAX

	mov EAX, 150
	push EAX

	call draw_kx_line

	mov EAX, 80
	push EAX

	mov EAX, 150
	push EAX

	mov EAX, 50
	push EAX

	mov EAX, 200
	push EAX

	call draw_kx_line

	mov EAX, 180
	push EAX

	mov EAX, 150
	push EAX

	mov EAX, 150
	push EAX

	mov EAX, 200
	push EAX

	call draw_kx_line


	mov DX, 3C4h 		; указатель на адресный регистр
 	mov AL, 2 			; индекс регистра маски цвета
 	out DX, AL 			; устанавливаем адрес регистра маски
 	inc DX 				; адрес регистра данных
 	mov AL, 03h 		; код цвета (синий)
 	out DX, AL 			; посылаем код цвета в контроллер

 	mov EAX, 76
 	push EAX

 	mov EAX, 158
 	push EAX

 	mov EAX, 99
 	push EAX
 	call draw_horizontal_line

	mov EAX, 77
	push EAX

	mov EAX, 157
	push EAX

	call paint2

	xor AX, AX			; 00 - wait until next button press
	int 16h				; interupt 16h
	
	jmp _good_end

_mode_8:

	mov DX, 3C4h 		; указатель на адресsный регистр
 	mov AL, 2 			; индекс регистра маски цвета
 	out DX, AL 			; устанавливаем адрес регистра маски
 	inc DX 				; адрес регистра данных
 	mov AL, 0Fh 		; код цвета (серый)
 	out DX, AL 			; посылаем код цвета в контроллер

 	mov DX, 3CEh
	mov AL, 8
 	out DX, AL
 	inc DX
 	mov AL, 0FFh
 	out DX, AL 			; set bit mask

	call clear_screen

; v l
	mov EAX, 213
	push EAX
	mov EAX, 82
	push EAX

	mov EAX, 182
	push EAX
	mov EAX, 250
	push EAX

	call draw_kx_line
	add ESP, 16

; v r1
	mov EAX, 259
	push EAX
	mov EAX, 82
	push EAX

	mov EAX, 245
	push EAX
	mov EAX, 160
	push EAX

	call draw_kx_line
	add ESP, 16

; v r2
	mov EAX, 241
	push EAX
	mov EAX, 180
	push EAX

	mov EAX, 228
	push EAX
	mov EAX, 250
	push EAX

	call draw_kx_line
	add ESP, 16

; t h
	mov EAX, 213
	push EAX
	mov EAX, 82
	push EAX
	mov EAX, 46
	push EAX

	;call draw_horizontal_line
	add ESP, 12

; b h

	mov EAX, 182
	push EAX
	mov EAX, 250
	push EAX
	mov EAX, 46
	push EAX

	;call draw_horizontal_line
	add ESP, 12

; v r
	mov EAX, 411
	push EAX
	mov EAX, 83
	push EAX

	mov EAX, 380
	push EAX
	mov EAX, 251
	push EAX

	call draw_kx_line
	add ESP, 16

; v l1
	mov EAX, 365
	push EAX
	mov EAX, 83
	push EAX

	mov EAX, 353
	push EAX
	mov EAX, 149
	push EAX

	call draw_kx_line
	add ESP, 16

; v l2
	mov EAX, 349
	push EAX
	mov EAX, 169
	push EAX

	mov EAX, 334
	push EAX
	mov EAX, 251
	push EAX

	call draw_kx_line
	add ESP, 16

; t h
	mov EAX, 365
	push EAX
	mov EAX, 83
	push EAX
	mov EAX, 46
	push EAX

	;call draw_horizontal_line
	add ESP, 12

; b h

	mov EAX, 334
	push EAX
	mov EAX, 251
	push EAX
	mov EAX, 46
	push EAX

	;call draw_horizontal_line
	add ESP, 12

; t m

	mov EAX, 245
	push EAX
	mov EAX, 160
	push EAX

	mov EAX, 353
	push EAX
	mov EAX, 149
	push EAX

	call draw_kx_line
	add ESP, 16

; b m 

	mov EAX, 241
	push EAX
	mov EAX, 180
	push EAX

	mov EAX, 349
	push EAX
	mov EAX, 169
	push EAX

	call draw_kx_line
	add ESP, 16

;--------------- curves bottom ---------------

; b l1

	mov EAX, 157
	push EAX

	mov EAX, 250
	push EAX

	mov EAX, 25
	push EAX

	mov EAX, 192
	push EAX

	call draw_circle

	add ESP, 16

; b l1

	mov EAX, 165
	push EAX

	mov EAX, 185
	push EAX

	mov EAX, 90
	push EAX

	mov EAX, 64
	push EAX

	call draw_circle

	add ESP, 16

; b r1

	mov EAX, 309
	push EAX

	mov EAX, 251
	push EAX

	mov EAX, 25
	push EAX

	mov EAX, 192
	push EAX

	call draw_circle

	add ESP, 16

; b r2 

	mov EAX, 317
	push EAX

	mov EAX, 186
	push EAX

	mov EAX, 90
	push EAX

	mov EAX, 64
	push EAX

	call draw_circle

	add ESP, 16

;--------------- curves top ---------------

; t l1

	mov EAX, 284
	push EAX

	mov EAX, 82
	push EAX

	mov EAX, 25
	push EAX

	mov EAX, 12	
	push EAX

	call draw_circle

	add ESP, 16

; t l2

	mov EAX, 276
	push EAX

	mov EAX, 147
	push EAX

	mov EAX, 90
	push EAX

	mov EAX, 8
	push EAX

	call draw_circle

	add ESP, 16

; t r1

	mov EAX, 436
	push EAX

	mov EAX, 83
	push EAX

	mov EAX, 25
	push EAX

	mov EAX, 12	
	push EAX

	call draw_circle

	add ESP, 16

; t r2 

	mov EAX, 428
	push EAX

	mov EAX, 148
	push EAX

	mov EAX, 90
	push EAX

	mov EAX, 8
	push EAX

	call draw_circle

	add ESP, 16

;--------------- paintin ---------------

; l

	mov EAX, 398
	push EAX
	mov EAX, 149
	push EAX

	;call paint2
	add ESP, 8

	mov EAX, 244
	push EAX
	mov EAX, 160
	push EAX

	call paint2
	add ESP, 8

	xor AX, AX			; 00 - wait until next button press
	int 16h				; interupt 16h

	jmp _good_end

_bad_end:

	xor DI,	DI			; DI = 0
	mov	CX,	28000		; counter 
	mov	AL,	000h 		; white color code
	rep	STOSB			; Fill block containing (E)CX bytes starting with address ES:(E)DI with AL

_good_end:
;---------------------------------------------------------------------------

	xor AX, AX			; 00 - wait until next button press
	int 16h				; interupt 16h

;---------------------------------------------------------------------------

	mov	AH,	04ch		; 4c - end programm
	int	21h				; interupt 21h

end 