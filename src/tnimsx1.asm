/;
 MSX1 TNI Logo module v1.0 by GuyveR800
 (c) The New Image 2006
\;




InitialWait:	equ	27

VDP.DR:		equ	6
VDP.DW:		equ	7

section code
	
ShowLogo:	
	ld	a,C9h		; disable interrupt hook
	ld	[FD9Ah],a

	xor	a		; color ,0,4
	ld	[BAKCLR],a
	ld	a,4
	ld	[BDRCLR],a
	ld	a,2		; screen 2
	call	CHGMOD
	call	DISSCR		; disable screen
	ld	a,[RG1SAV]	; 16x16 sprites
	and	FCh
	or	2
	ld	b,a
	ld	c,1
	call	WRTVDP

	ld	hl,TNIPatterns	; copy 'the new image presents' patterns
	ld	de,1000h+240
	ld	bc,17*8
	call	LDIRVM

	ld	hl,LogoPatterns
	ld	de,0000h+384
	ld	bc,LogoPatterns.len
	call	LDIRVM
	ld	hl,LogoPatterns
	ld	de,0800h+384
	ld	bc,LogoPatterns.len
	call	LDIRVM

	ld	a,54h		; setup bg color table
	ld	hl,2000h
	ld	bc,240
	call	FILVRM
	ld	a,54h
	ld	hl,2800h
	ld	bc,240
	call	FILVRM
	ld	a,54h
	ld	hl,3000h
	ld	bc,200
	call	FILVRM
	ld	a,F4h
	ld	hl,3000h+240
	ld	bc,17*8
	call	FILVRM

	ld	a,F1h
	ld	hl,2000h+384
	ld	bc,LogoPatterns.len
	call	FILVRM
	ld	a,F1h
	ld	hl,2800h+384
	ld	bc,LogoPatterns.len
	call	FILVRM

	ld	hl,SpritePatterns
	ld	de,3800h
	ld	bc,32*15
	call	LDIRVM

	ld	hl,1800h	; setup name table
	call	SETWRT
	ld	b,24
	xor	a
.loop:	push	af
	push	bc

	ld	l,a
	add	a,a
	add	a,a
	add	a,l
	add	a,Map & 255
	ld	l,a
	adc	a,Map >> 8
	sub	l
	ld	h,a

	ld	de,-5
	ld	bc,[VDP.DW]
	ld	a,6
.l:	ld	b,5	; 5 columns
	otir
	add	hl,de
	dec	a
	jr	nz,.l
	outi
	outi

	pop	bc
	pop	af
	inc	a
	cp	5
	jr	c,.nowrap
	sub	5
.nowrap:
	djnz	.loop

	ld	de,[TNIText]			; draw TNI presents
	ld	hl,TNIText+2
	ld	bc,13
	call	LDIRVM
	ld	de,[TNIText.row2]
	ld	hl,TNIText.row2+2
	ld	bc,9
	call	LDIRVM

	ld	hl,ROMBG
	ld	de,BG
	ld	bc,200
	ldir

	ld	hl,ROMSprites
	ld	de,Sprites
	ld	bc,128
	ldir

	xor	a
	ld	[FrameCtr],a

	call	ENASCR

	
	di
        ld      hl,FD9A
        ld      de,FD9Ah
        ld      bc,3
        ldir

	call	RDVDP		; clear pending interrupts
        ei

MainShow:	
	ld      hl,FrameCtr
        ld      a,[hl]
.wait:  halt
        cp      [hl]
        jp      z,.wait

	ld	hl,BG+1		; vertical scroll
	ld	de,BG
	ld	b,5
.loop:	push	bc

	ld	a,[de]
	ld	bc,8*5-1
	ldir
	ld	[de],a
	inc	hl
	inc	de

	pop	bc
	djnz	.loop

	ld	ix,BG+80		; horizontal scroll
	ld	b,8*5
.loop1:	ld	a,[ix-80]
	add	a,a
	rl	[ix+80]
	rl	[ix+40]
	rl	[ix+0]
	rl	[ix-40]
	rl	[ix-80]
	inc	ix
	djnz	.loop1

	ld	de,BG+200		; copy the right chars for overwriting by the top of the logo
	ld	a,[FrameCtr]		; here be dragons
	sub	InitialWait
	srl	a
	srl	a
	srl	a
	add	a,4
	
.wrap:	cp	5
	jr	c,.nowrap
	sub	5
	jp	.wrap
.nowrap:
	ld	b,a
	ld	a,4
	sub	b

	add	a,a
	add	a,a
	add	a,a

	add	a,BG & 255
	ld	l,a
	adc	a,BG >> 8
	sub	l
	ld	h,a

	push	hl
	ldi\ldi\ldi\ldi\ldi\ldi\ldi\ldi
	pop	hl
	ld	bc,8*5
	add	hl,bc
	push	hl
	ldi\ldi\ldi\ldi\ldi\ldi\ldi\ldi
	pop	hl
	ld	bc,8*5
	add	hl,bc
	push	hl
	ldi\ldi\ldi\ldi\ldi\ldi\ldi\ldi
	pop	hl
	ld	bc,8*5
	add	hl,bc
	push	hl
	ldi\ldi\ldi\ldi\ldi\ldi\ldi\ldi
	pop	hl
	ld	bc,8*5
	add	hl,bc
	ldi\ldi\ldi\ldi\ldi\ldi\ldi\ldi

	ld	a,[FrameCtr]
	sub	InitialWait
	ld	c,a
	ld	a,95
	sub	c
	ld	c,a

	ld	b,14
	ld	hl,ROMSprites+16*4
	ld	de,Sprites+16*4
.sprl:	ld	a,[hl]
	add	a,c
	ld	[de],a
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	de
	inc	de
	inc	de
	inc	de
	djnz	.sprl

	ld	a,[FrameCtr]
	cp	240
	jp	c,MainShow

	ld	a,0c9h
	ld	(0FD9Ah),a	
	call	DISSCR
	ret
 

;**********************
;* Interrupt routines *
;**********************

Interrupt:
	ld	bc,[VDP.DR]	; return if not vblank
	inc	c
	in	a,[c]
	rlca
	ret	nc

	ld	c,b
	ld	hl,0000h
	call	SETWRT
	ld	hl,BG
	;200x outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi

	ld	hl,0800h
	call	SETWRT
	ld	hl,BG
	;200x outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi

	ld	hl,1000h
	call	SETWRT
	ld	hl,BG
	;200x outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi

	ld	a,[FrameCtr]
	cp	InitialWait	; start logoscroll after X interrupts
	jp	c,.noscroll
	cp	InitialWait+96
	jp	nc,.noscroll

	ld	a,[FrameCtr]
	sub	InitialWait
	srl	a			; calculate map length
	srl	a
	srl	a
	inc	a

	push	af
	ld	hl,1800h+80h+04h -32	; calculate map offset
	ld	de,32
	ld	b,a
	ld	a,12 +1
	sub	b
	ld	b,a
.offsl:	add	hl,de
	djnz	.offsl
	ex	de,hl
	pop	af

	push	af
	ld	a,[FrameCtr]
	sub	InitialWait
	and	7
	inc	a
	ld	hl,LogoMaps-24*12
	ld	bc,24*12
.mapl:	add	hl,bc
	dec	a
	jr	nz,.mapl
	pop	af
	
.loop:	push	af
	ex	de,hl
	call	SETWRT
	ld	bc,32
	add	hl,bc
	ex	de,hl
	ld	bc,[VDP.DW]
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi
	pop	af
	dec	a
	jr	nz,.loop

	ld	a,[FrameCtr]
	sub	InitialWait
	and	7
	inc	a
	ld	hl,LogoColors-5*8
	ld	bc,5*8
.coll:	add	hl,bc
	dec	a
	jr	nz,.coll

	ex	de,hl
	ld	a,[FrameCtr]
	sub	InitialWait
	cp	64
	ld	hl,2800h+200
	jr	c,.bottom
	ld	bc,-800h
	add	hl,bc
.bottom:
	call	SETWRT
	ex	de,hl
	ld	bc,[VDP.DW]
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi

	ld	hl,1B00h
	call	SETWRT
	ld	hl,Sprites
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi
	outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi\outi

.noscroll:
	ld	hl,FrameCtr
	inc	[hl]
	ret

FD9A:	jp	Interrupt

ROMBG:
; column 1
%def8	11110000b,11110000b,11110000b,11110000b,11111111b,11111111b,11111111b,11111111b	; t
%def8	11110000b,11110000b,11110000b,11110000b,11111111b,11111111b,11111111b,01111111b
%def8	0,0,0,0,11111110b,11111111b,11111111b,11111111b	; n (right high)
%def8	00001111b,00001111b,00001111b,00001111b,00001111b,00001111b,00001111b,00001111b
%def8	00001111b,00001111b,00001111b,00001111b,0,0,0,0	; n (right low)

; column 2
%def8	00001111b,00001111b,00001111b,00001111b,10001111b,11001111b,00001111b,10001111b	; n (left)
%def8	00001111b,00001111b,00001111b,00001111b,11111111b,11111111b,11111111b,11111111b
%def8	0,0,0,0,00000110b,00001111b,00001111b,00000110b	; i (high)
%def8	00000000b,00001111b,00001111b,00001111b,00001111b,00001111b,00001111b,00001111b
%def8	11111111b,11111111b,11111111b,11111111b,0,0,0,0	; i (low)

; column 3
%def8	11111110b,11111111b,11111111b,11111111b,00001111b,00001111b,00001111b,00001111b	; n (right)
%def8	00001111b,00001111b,00001111b,00001111b,00001111b,00001111b,00001111b,00001111b
%def8	0,0,0,0,0,0,0,0	; space
%def8	0,0,0,0,0,0,0,0
%def8	0,0,0,0,0,0,0,0	; space

; column 4
%def8	00000110b,00001111b,00001111b,00000110b,00000000b,00001111b,00001111b,00001111b	; i
%def8	00001111b,00001111b,00001111b,00001111b,11111111b,11111111b,11111111b,11111111b
%def8	0,0,0,0,11110000b,11110000b,11110000b,11110000b	; t (high)
%def8	11111111b,11111111b,11111111b,11111111b,11110000b,11110000b,11110000b,11110000b
%def8	11111111b,11111111b,11111111b,01111111b,0,0,0,0	; t (low)

; column 5
%def8	0,0,0,0,0,0,0,0	; space
%def8	0,0,0,0,0,0,0,0
%def8	0,0,0,0,00001111b,00001111b,00001111b,00001111b	; n (left high)
%def8	10001111b,11001111b,00001111b,10001111b,00001111b,00001111b,00001111b,00001111b
%def8	11111111b,11111111b,11111111b,11111111b,0,0,0,0 ; n (left low)

TNIPatterns:				; The New Image
%def8	11111b	;T
%def8	00100b
%def8	00100b
%def8	00100b
%def8	00100b
%def8	00100b
%def8	00100b
%def8	00000b

%def8	10000b	;h
%def8	10000b
%def8	11110b
%def8	10001b
%def8	10001b
%def8	10001b
%def8	10001b
%def8	00000b

%def8	00000b	;e
%def8	00000b
%def8	01110b
%def8	10001b
%def8	11111b
%def8	10000b
%def8	01110b
%def8	00000b

%def8	10001b	;N
%def8	11001b
%def8	11001b
%def8	10101b
%def8	10011b
%def8	10011b
%def8	10001b
%def8	00000b

%def8	00000b	;w
%def8	00000b
%def8	10001b
%def8	10101b
%def8	10101b
%def8	10101b
%def8	01010b
%def8	00000b

%def8	01110b	;I
%def8	00100b
%def8	00100b
%def8	00100b
%def8	00100b
%def8	00100b
%def8	01110b
%def8	00000b

%def8	00000b	;m
%def8	00000b
%def8	11010b
%def8	10101b
%def8	10101b
%def8	10101b
%def8	10101b
%def8	00000b

%def8	00000b	;a
%def8	00000b
%def8	01110b
%def8	00001b
%def8	01111b
%def8	10001b
%def8	01111b
%def8	00000b

%def8	00000b	;g
%def8	00000b
%def8	01101b
%def8	10011b
%def8	10011b
%def8	01101b
%def8	00001b
%def8	01110b


%def8	00000b	;P
%def8	11110b
%def8	10001b
%def8	10001b
%def8	11110b
%def8	10000b
%def8	10000b
%def8	10000b

%def8	00000b	;r
%def8	00000b
%def8	00000b
%def8	10110b
%def8	11001b
%def8	10000b
%def8	10000b
%def8	10000b

%def8	00000b	;e
%def8	00000b
%def8	00000b
%def8	01110b
%def8	10001b
%def8	11111b
%def8	10000b
%def8	01110b

%def8	00000b	;s
%def8	00000b
%def8	00000b
%def8	01111b
%def8	10000b
%def8	11110b
%def8	00001b
%def8	11110b

%def8	00000b	;n
%def8	00000b
%def8	00000b
%def8	10110b
%def8	11001b
%def8	10001b
%def8	10001b
%def8	10001b

%def8	00000b	;t
%def8	01000b
%def8	01000b
%def8	11110b
%def8	01000b
%def8	01000b
%def8	01001b
%def8	00110b

%def8	00000b	;:
%def8	00000b
%def8	00000b
%def8	00100b
%def8	00000b
%def8	00000b
%def8	00100b
%def8	00000b

Map:
%def8	 0, 5,10,15,20
%def8	 1, 6,11,16,21
%def8	 2, 7,12,17,22
%def8	 3, 8,13,18,23
%def8	 4, 9,14,19,24

TNIText:
%def16	1800h+544+9
%def8	30,31,32, 12 ,33,32,34, 7 ,35,36,37,38,32
.row2:
%def16	1800h+576+11
%def8	39,40,41,42,41,43,44,42,45

LogoPatterns:
%def8	00001111b	;48
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00000111b
%def8	00000111b
%def8	00000011b
%def8	00000011b

%def8	00001111b	;49
%def8	00001111b
%def8	00001111b
%def8	00000111b
%def8	00000111b
%def8	00000011b
%def8	00000011b
%def8	00000001b

%def8	00001111b	;50
%def8	00001111b
%def8	00000111b
%def8	00000111b
%def8	00000011b
%def8	00000011b
%def8	00000001b
%def8	00000000b

%def8	00001111b	;51
%def8	00000111b
%def8	00000111b
%def8	00000011b
%def8	00000011b
%def8	00000001b
%def8	00000000b
%def8	00000000b

%def8	00001111b	;52
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00000111b

%def8	00001111b	;53
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00000111b
%def8	00000111b

%def8	00001111b	;54
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00000111b
%def8	00000111b
%def8	00000011b

%def8	11111111b	;55
%def8	11111111b
%def8	01111111b
%def8	00011111b
%def8	00000111b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11111111b	;56
%def8	01111111b
%def8	00011111b
%def8	00000111b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	01111111b	;57
%def8	00011111b
%def8	00000111b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00011111b	;58
%def8	00000111b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11111111b	;59
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	01111111b
%def8	00011111b

%def8	00000111b	;60
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11111111b	;61
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	01111111b
%def8	00011111b
%def8	00000111b

%def8	11111111b	;62
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	01111111b
%def8	00011111b
%def8	00000111b
%def8	00000000b

%def8	11111111b	;63
%def8	11111111b
%def8	11111111b
%def8	01111111b
%def8	00011111b
%def8	00000111b
%def8	00000000b
%def8	00000000b

%def8	00000000b	;64
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11111111b	;65
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00001111b	;66
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b

%def8	00000000b	;67
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b

%def8	00000000b	;68
%def8	00000000b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b

%def8	00000000b	;69
%def8	00000000b
%def8	00000000b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b

%def8	00000000b	;70
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00001111b
%def8	00001111b
%def8	00001111b
%def8	00001111b

%def8	00000000b	;71
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00001111b
%def8	00001111b
%def8	00001111b

%def8	00000000b	;72
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00001111b
%def8	00001111b

%def8	00000000b	;73
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00001111b

%def8	00000000b	;74
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;75
%def8	00000000b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;76
%def8	00000000b
%def8	00000000b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;77
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;78
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;79
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;80
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111111b

%def8	11111110b	;81
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b

%def8	00000000b	;82
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b

%def8	00000000b	;83
%def8	00000000b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b

%def8	00000000b	;84
%def8	00000000b
%def8	00000000b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b

%def8	00000000b	;85
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b

%def8	00000000b	;86
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111110b
%def8	11111110b
%def8	11111110b

%def8	00000000b	;87
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111110b
%def8	11111110b

%def8	00000000b	;88
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111110b

%def8	11111110b	;89
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111110b	;90
%def8	11111110b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111110b	;91
%def8	11111110b
%def8	11111110b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111110b	;92
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111110b	;93
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111110b	;94
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111111b
%def8	11111111b

%def8	11111110b	;95
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111111b

%def8	00000111b	;96
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b

%def8	00000000b	;97
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b

%def8	00000000b	;98
%def8	00000000b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b

%def8	00000000b	;99
%def8	00000000b
%def8	00000000b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b

%def8	00000000b	;100
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b

%def8	00000000b	;101
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000111b
%def8	00000111b
%def8	00000111b

%def8	00000000b	;102
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000111b
%def8	00000111b

%def8	00000000b	;103
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000111b

%def8	11111111b	;104
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	00000000b

%def8	11111111b	;105
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	00000000b
%def8	00000000b

%def8	11111111b	;106
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11111111b	;107
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11111111b	;108
%def8	11111111b
%def8	11111111b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11111111b	;109
%def8	11111111b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11111111b	;110
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11111111b	;111
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	00011111b

%def8	11111111b	;112
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	00011111b
%def8	00011111b

%def8	11111111b	;113
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	00011111b
%def8	00011111b
%def8	00011111b

%def8	11111111b	;114
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b

%def8	11111111b	;115
%def8	11111111b
%def8	11111111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b

%def8	11111111b	;116
%def8	11111111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b

%def8	11111111b	;117
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b

%def8	00000000b	;118
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111000b

%def8	00000000b	;119
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111000b
%def8	11111110b

%def8	00000000b	;120
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111000b
%def8	11111110b
%def8	11111111b

%def8	00000000b	;121
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111000b
%def8	11111110b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;122
%def8	00000000b
%def8	00000000b
%def8	11111000b
%def8	11111110b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;123
%def8	00000000b
%def8	11111000b
%def8	11111110b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;124
%def8	11111000b
%def8	11111110b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111000b	;125
%def8	11111110b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;126
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	10000000b

%def8	00000000b	;127
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	10000000b
%def8	11000000b

%def8	00000000b	;128
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	10000000b
%def8	11000000b
%def8	11100000b

%def8	00000000b	;129
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	10000000b
%def8	11000000b
%def8	11100000b
%def8	11110000b

%def8	00000000b	;130
%def8	00000000b
%def8	00000000b
%def8	10000000b
%def8	11000000b
%def8	11100000b
%def8	11110000b
%def8	11110000b

%def8	00000000b	;131
%def8	00000000b
%def8	10000000b
%def8	11000000b
%def8	11100000b
%def8	11110000b
%def8	11110000b
%def8	11111000b

%def8	00000000b	;132
%def8	10000000b
%def8	11000000b
%def8	11100000b
%def8	11110000b
%def8	11110000b
%def8	11111000b
%def8	11111000b

%def8	10000000b	;133
%def8	11000000b
%def8	11100000b
%def8	11110000b
%def8	11110000b
%def8	11111000b
%def8	11111000b
%def8	11111100b

%def8	11000000b	;134
%def8	11100000b
%def8	11110000b
%def8	11110000b
%def8	11111000b
%def8	11111000b
%def8	11111100b
%def8	11111100b

%def8	11100000b	;135
%def8	11110000b
%def8	11110000b
%def8	11111000b
%def8	11111000b
%def8	11111100b
%def8	11111100b
%def8	11111100b

%def8	11110000b	;136
%def8	11110000b
%def8	11111000b
%def8	11111000b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b

%def8	11110000b	;137
%def8	11111000b
%def8	11111000b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b

%def8	11111000b	;138
%def8	11111000b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b

%def8	11111000b	;139
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b

%def8	11111100b	;140
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b

%def8	00000000b	;141,142,143
%def8	00000001b
%def8	00000111b
%def8	00001111b
%def8	00011111b
%def8	00111111b
%def8	00111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	00111111b
%def8	00111111b
%def8	00011111b
%def8	00001111b
%def8	00000111b
%def8	00000001b
%def8	00000000b
%def8	01111111b
%def8	01111111b
%def8	01111111b

%def8	00000001b	;144,145,146
%def8	00000111b
%def8	00001111b
%def8	00011111b
%def8	00111111b
%def8	00111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	00111111b
%def8	00111111b
%def8	00011111b
%def8	00001111b
%def8	00000111b
%def8	00000001b
%def8	00000000b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b

%def8	00000000b	;147,148,149,150
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000001b	
%def8	00000111b
%def8	00001111b
%def8	00011111b
%def8	00111111b
%def8	00111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	00111111b
%def8	00111111b
%def8	00011111b
%def8	00001111b
%def8	00000111b
%def8	00000001b
%def8	00000000b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b

%def8	00000000b	;151,152,153,154
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000001b	
%def8	00000111b
%def8	00001111b
%def8	00011111b
%def8	00111111b
%def8	00111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	00111111b
%def8	00111111b
%def8	00011111b
%def8	00001111b
%def8	00000111b
%def8	00000001b
%def8	00000000b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b

%def8	00000000b	;155,156,157,158
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000001b	
%def8	00000111b
%def8	00001111b
%def8	00011111b
%def8	00111111b
%def8	00111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	00111111b
%def8	00111111b
%def8	00011111b
%def8	00001111b
%def8	00000111b
%def8	00000001b
%def8	00000000b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b

%def8	00000000b	;159,160,161
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000001b	
%def8	00000111b
%def8	00001111b
%def8	00011111b
%def8	00111111b
%def8	00111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	00111111b
%def8	00111111b
%def8	00011111b
%def8	00001111b
%def8	00000111b
%def8	00000001b
%def8	00000000b

%def8	01111111b	;162
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b

%def8	00000000b	;163,164,165
%def8	00000000b
%def8	00000000b
%def8	00000001b	
%def8	00000111b
%def8	00001111b
%def8	00011111b
%def8	00111111b
%def8	00111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	00111111b
%def8	00111111b
%def8	00011111b
%def8	00001111b
%def8	00000111b
%def8	00000001b
%def8	00000000b
%def8	01111111b

%def8	00000000b	;166,167,168
%def8	00000000b
%def8	00000001b	
%def8	00000111b
%def8	00001111b
%def8	00011111b
%def8	00111111b
%def8	00111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	00111111b
%def8	00111111b
%def8	00011111b
%def8	00001111b
%def8	00000111b
%def8	00000001b
%def8	00000000b
%def8	01111111b
%def8	01111111b

%def8	00000000b	;169
%def8	11111100b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111100b	;170
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;171
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111100b

%def8	00000000b	;172
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111100b
%def8	11111111b

%def8	00000000b	;173
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111100b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;174
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11111100b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;175
%def8	00000000b
%def8	00000000b
%def8	11111100b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;176
%def8	00000000b
%def8	11111100b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111111b	;177
%def8	11111111b
%def8	11111111b
%def8	11111100b
%def8	00000000b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111111b	;178
%def8	11111111b
%def8	11111100b
%def8	00000000b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111111b	;179
%def8	11111100b
%def8	00000000b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111100b	;180
%def8	00000000b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111111b	;181
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111100b

%def8	11111111b	;182
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111100b
%def8	00000000b

%def8	11111111b	;183
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111100b
%def8	00000000b
%def8	11111111b

%def8	11111111b	;184
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111100b
%def8	00000000b
%def8	11111111b
%def8	11111111b

%def8	00000000b	;185,186,187
%def8	00000000b
%def8	00000000b
%def8	10000000b
%def8	11000000b
%def8	11100000b
%def8	11100000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11100000b
%def8	11100000b
%def8	11000000b
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11110000b
%def8	11110000b
%def8	11110000b

%def8	00000000b	;188,189,190
%def8	00000000b
%def8	10000000b
%def8	11000000b
%def8	11100000b
%def8	11100000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11100000b
%def8	11100000b
%def8	11000000b
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b

%def8	00000000b	;191,192,193
%def8	10000000b
%def8	11000000b
%def8	11100000b
%def8	11100000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11100000b
%def8	11100000b
%def8	11000000b
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b

%def8	10000000b	;194,195,196
%def8	11000000b
%def8	11100000b
%def8	11100000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11100000b
%def8	11100000b
%def8	11000000b
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b

%def8	11000000b	;197,198,199
%def8	11100000b
%def8	11100000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11100000b
%def8	11100000b
%def8	11000000b
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b

%def8	11100000b	;200,201
%def8	11100000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11100000b
%def8	11100000b
%def8	11000000b
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11110000b	;202
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b

%def8	11100000b	;203,204
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11100000b
%def8	11100000b
%def8	11000000b
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11110000b

%def8	00000000b	;205,206,207
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	10000000b
%def8	11000000b
%def8	11100000b
%def8	11100000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11100000b
%def8	11100000b
%def8	11000000b
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	11110000b
%def8	11110000b

%def8	00011111b	;208
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b

%def8	11111111b	;209
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111110b

%def8	11111111b	;210
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111110b
%def8	11111110b

%def8	11111111b	;211
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111110b
%def8	11111110b
%def8	11111110b

%def8	11111111b	;212
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b

%def8	11111111b	;213
%def8	11111111b
%def8	11111111b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b

%def8	11111111b	;214
%def8	11111111b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b

%def8	11111111b	;215
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b
%def8	11111110b

%def8	00000111b	;216
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	11111111b

%def8	00000111b	;217
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	11111111b
%def8	11111111b

%def8	00000111b	;218
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000111b	;219
%def8	00000111b
%def8	00000111b
%def8	00000111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000111b	;220
%def8	00000111b
%def8	00000111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000111b	;221
%def8	00000111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00000111b	;222
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111100b	;223
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111111b

%def8	11111100b	;224
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111111b
%def8	11111111b

%def8	11111100b	;225
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111100b	;226
%def8	11111100b
%def8	11111100b
%def8	11111100b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111100b	;227
%def8	11111100b
%def8	11111100b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	11111100b	;228
%def8	11111100b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	01111111b	;229
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	11111111b

%def8	01111111b	;230
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	11111111b
%def8	11111111b

%def8	01111111b	;231
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	01111111b	;232
%def8	01111111b
%def8	01111111b
%def8	01111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	01111111b	;233
%def8	01111111b
%def8	01111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	01111111b	;234
%def8	01111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	01111111b	;235
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b

%def8	00011111b	;236
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00000000b

%def8	00011111b	;237
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00000000b
%def8	00000000b

%def8	00011111b	;238
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00011111b	;239
%def8	00011111b
%def8	00011111b
%def8	00011111b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00011111b	;240
%def8	00011111b
%def8	00011111b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00011111b	;241
%def8	00011111b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00011111b	;242
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11110000b	;243
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	00000000b

%def8	11110000b	;244
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	00000000b
%def8	00000000b

%def8	11110000b	;245
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11110000b	;246
%def8	11110000b
%def8	11110000b
%def8	11110000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11110000b	;247
%def8	11110000b
%def8	11110000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11110000b	;248
%def8	11110000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11110000b	;249
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00000001b	;250
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00000011b	;251
%def8	00000001b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00000011b	;252
%def8	00000011b
%def8	00000001b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00000111b	;253
%def8	00000011b
%def8	00000011b
%def8	00000001b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00000111b	;254
%def8	00000111b
%def8	00000011b
%def8	00000011b
%def8	00000001b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	11111111b	;255
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	11111111b
%def8	01111111b

.len:	equ	$-LogoPatterns

LogoMaps:
.7:
%def8	29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27
%def8	64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64
%def8	64,64,67,74,82,64,64,64,64,97,74,74,74,74,74,124,130,64,64,141,169,185,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,65,138,64,64,142,65,186,64,64
%def8	64,64,66,65,92,77,77,78,64,96,65,65,107,107,114,65,140,64,64,143,177,187,64,64
%def8	64,64,66,65,65,65,65,140,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,209,104,104,195,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,90,75,75,75,75,221,65,65,64,64,208,65,228,75,75,234,65,202,64,64
%def8	64,64,48,65,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,250,55,106,106,106,106,106,106,106,106,64,64,238,106,106,106,106,106,106,245,64,64

.6:
%def8	29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27
%def8	64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,125,131,64,64,144,170,188,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,65,139,64,64,145,65,189,64,64
%def8	64,64,66,65,91,76,76,77,64,96,65,65,108,108,115,65,140,64,64,146,178,190,64,64
%def8	64,64,66,65,65,65,65,202,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,210,105,105,198,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,89,74,74,74,74,222,65,65,64,64,208,65,170,74,74,235,65,202,64,64
%def8	64,64,49,65,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,64,56,107,107,107,107,107,107,107,107,64,64,239,107,107,107,107,107,107,246,64,64

.5:
%def8	29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27
%def8	64,64,73,80,88,64,64,64,64,103,80,80,80,80,80,118,64,64,64,147,171,64,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,89,132,64,64,148,65,191,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,65,140,64,64,149,65,192,64,64
%def8	64,64,66,65,90,75,75,76,64,96,65,65,109,109,116,65,140,64,64,150,179,193,64,64
%def8	64,64,66,65,65,65,65,202,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,211,106,106,201,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,50,65,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,64,57,108,108,108,108,108,108,108,108,64,64,240,108,108,108,108,108,108,247,64,64

.4:
%def8	29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27
%def8	64,64,72,79,87,64,64,64,64,102,79,79,79,79,79,119,64,64,64,151,172,64,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,65,133,64,64,152,65,194,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,65,140,64,64,153,65,195,64,64
%def8	64,64,66,65,89,74,74,75,64,96,65,65,110,110,117,65,140,64,64,154,180,196,64,64
%def8	64,64,66,65,65,65,65,202,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,212,107,107,248,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,95,80,80,80,80,216,65,65,64,64,208,65,223,80,80,229,65,202,64,64
%def8	64,64,66,65,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,51,255,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,64,58,109,109,109,109,109,109,109,109,64,64,241,109,109,109,109,109,109,248,64,64

.3:
%def8	29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27
%def8	64,64,71,78,86,64,64,64,64,101,78,78,78,78,78,120,126,64,64,155,173,126,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,65,134,64,64,156,65,197,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,65,140,64,64,157,181,198,64,64
%def8	64,64,66,65,65,65,65,74,64,96,65,65,64,64,208,65,140,64,64,158,74,199,64,64
%def8	64,64,66,65,65,65,65,202,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,213,108,108,110,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,94,79,79,79,79,217,65,65,64,64,208,65,224,79,79,230,65,202,64,64
%def8	64,64,66,65,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,254,59,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,64,60,110,110,110,110,110,110,110,110,64,64,242,110,110,110,110,110,110,249,64,64

.2:
%def8	29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27
%def8	64,64,70,77,85,64,64,64,64,100,77,77,77,77,77,121,127,64,64,159,174,127,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,65,135,64,64,160,65,200,64,64
%def8	64,64,66,65,95,80,80,64,64,96,65,65,104,104,111,65,140,64,64,161,182,201,64,64
%def8	64,64,66,65,65,65,65,65,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,65,65,65,202,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,214,109,109,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,93,78,78,78,78,218,65,65,64,64,208,65,225,78,78,231,65,202,64,64
%def8	64,64,52,65,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,253,61,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64

.1:
%def8	29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27,28,29,25,26,27
%def8	64,64,69,76,84,64,64,64,64,99,76,76,76,76,76,122,128,64,64,163,175,128,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,65,136,64,64,164,65,203,64,64
%def8	64,64,66,65,94,79,79,80,64,96,65,65,105,105,112,65,140,64,64,165,183,204,64,64
%def8	64,64,66,65,65,65,65,104,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,65,65,65,202,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,215,110,110,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,92,77,77,77,77,219,65,65,64,64,208,65,226,77,77,232,65,202,64,64
%def8	64,64,53,65,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,252,62,104,104,104,104,104,104,104,104,64,64,236,104,104,104,104,104,104,243,64,64
%def8	64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64

.0:
%def8	64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64
%def8	64,64,68,75,83,64,64,64,64,98,75,75,75,75,75,123,129,64,64,166,176,205,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,65,65,65,65,137,64,64,167,65,206,64,64
%def8	64,64,66,65,93,78,78,79,64,96,65,65,106,106,113,65,140,64,64,168,184,207,64,64
%def8	64,64,66,65,65,65,65,140,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,65,65,65,202,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,81,64,64,64,64,96,65,65,64,64,208,65,140,64,64,162,65,202,64,64
%def8	64,64,66,65,91,76,76,76,76,220,65,65,64,64,208,65,227,76,76,233,65,202,64,64
%def8	64,64,54,65,65,65,65,65,65,65,65,65,64,64,208,65,65,65,65,65,65,202,64,64
%def8	64,64,251,63,105,105,105,105,105,105,105,105,64,64,237,105,105,105,105,105,105,244,64,64
%def8	64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64

LogoColors:
%def8	54h,54h,54h,54h,54h,54h,54h,11h
%def8	54h,54h,54h,54h,54h,54h,54h,11h
%def8	54h,54h,54h,54h,54h,54h,54h,11h
%def8	54h,54h,54h,54h,54h,54h,54h,11h
%def8	54h,54h,54h,54h,54h,54h,54h,11h

%def8	54h,54h,54h,54h,54h,54h,11h,11h
%def8	54h,54h,54h,54h,54h,54h,11h,11h
%def8	54h,54h,54h,54h,54h,54h,11h,11h
%def8	54h,54h,54h,54h,54h,54h,11h,11h
%def8	54h,54h,54h,54h,54h,54h,11h,11h

%def8	54h,54h,54h,54h,54h,11h,11h,11h
%def8	54h,54h,54h,54h,54h,11h,11h,11h
%def8	54h,54h,54h,54h,54h,11h,11h,11h
%def8	54h,54h,54h,54h,54h,11h,11h,11h
%def8	54h,54h,54h,54h,54h,11h,11h,11h

%def8	54h,54h,54h,54h,11h,11h,11h,11h
%def8	54h,54h,54h,54h,11h,11h,11h,11h
%def8	54h,54h,54h,54h,11h,11h,11h,11h
%def8	54h,54h,54h,54h,11h,11h,11h,11h
%def8	54h,54h,54h,54h,11h,11h,11h,11h

%def8	54h,54h,54h,11h,11h,11h,11h,11h
%def8	54h,54h,54h,11h,11h,11h,11h,11h
%def8	54h,54h,54h,11h,11h,11h,11h,11h
%def8	54h,54h,54h,11h,11h,11h,11h,11h
%def8	54h,54h,54h,11h,11h,11h,11h,11h

%def8	54h,54h,11h,11h,11h,11h,11h,11h
%def8	54h,54h,11h,11h,11h,11h,11h,11h
%def8	54h,54h,11h,11h,11h,11h,11h,11h
%def8	54h,54h,11h,11h,11h,11h,11h,11h
%def8	54h,54h,11h,11h,11h,11h,11h,11h

%def8	54h,11h,11h,11h,11h,11h,11h,11h
%def8	54h,11h,11h,11h,11h,11h,11h,11h
%def8	54h,11h,11h,11h,11h,11h,11h,11h
%def8	54h,11h,11h,11h,11h,11h,11h,11h
%def8	54h,11h,11h,11h,11h,11h,11h,11h

SpritePatterns:
%def8	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	
%def8	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

%def8	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;I(topleft)
%def8	0,0,0,0,0,0,0,0
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000001b
%def8	00000110b
%def8	00001000b

%def8	0,0,0,0,0,0,0,0		; I (topright)
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	10001100b
%def8	00000011b
%def8	00000000b
%def8	0,0,0,0,0,0,0,0
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	10000000b

%def8	00000000b	;N
%def8	00000000b
%def8	00111000b
%def8	00000110b
%def8	00000001b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	0,0,0,0,0,0,0,0
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	10000000b
%def8	01000000b
%def8	00100000b
%def8	00010000b
%def8	00010000b
%def8	00001000b
%def8	00001000b
%def8	00000100b
%def8	00000100b
%def8	00000100b
%def8	00000000b
%def8	00000000b

%def8	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		; I (bottomleft)
%def8	00010000b
%def8	00100000b
%def8	00100000b
%def8	01000000b
%def8	01000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	01000000b
%def8	01000000b
%def8	00100000b
%def8	00100000b
%def8	00010000b
%def8	00001000b
%def8	00000110b
%def8	00000001b

%def8	0,0,0,0,0,0,0,0		; I(bottomright)
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000011b
%def8	10001100b

%def8	01000000b
%def8	00100000b
%def8	00100000b
%def8	00010000b
%def8	00010000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00010000b
%def8	00010000b
%def8	00100000b
%def8	00100000b
%def8	01000000b
%def8	10000000b
%def8	00000000b
%def8	00000000b

%def8	00110000b	; fire1(top)
%def8	00000011b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000001b
%def8	00000000b
%def8	00000000b
%def8	00000110b
%def8	00011000b
%def8	00000011b
%def8	00000001b
%def8	00000100b
%def8	00110000b
%def8	10000000b
%def8	00110000b

%def8	00000000b
%def8	00000000b
%def8	11000000b
%def8	00011000b
%def8	00110000b
%def8	00000000b
%def8	11000000b
%def8	01100000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00001100b	; fire2(top)
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000001b
%def8	00000110b
%def8	00000000b
%def8	00000000b
%def8	00000011b
%def8	00001100b
%def8	01100000b
%def8	00001100b

%def8	00000000b
%def8	10000000b
%def8	00100000b
%def8	00000100b
%def8	00001000b
%def8	11000000b
%def8	00100000b
%def8	00011000b
%def8	10000000b
%def8	00000000b
%def8	11000000b
%def8	01100000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00000010b	;fire3(top)
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000001b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000010b
%def8	00011000b
%def8	00000011b

%def8	00000000b
%def8	01000000b
%def8	00011000b
%def8	00000010b
%def8	00000110b
%def8	00110000b
%def8	00011000b
%def8	00000100b
%def8	01000000b
%def8	00000000b
%def8	00100000b
%def8	00010000b
%def8	11000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00111000b	;fire4(top) (offset right)
%def8	00000111b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000001b
%def8	00000000b
%def8	00000000b
%def8	00000111b
%def8	00011100b
%def8	00000011b
%def8	00000001b
%def8	00000111b
%def8	00111000b
%def8	11110000b
%def8	00011100b

%def8	00000000b
%def8	10000000b
%def8	11100000b
%def8	00111100b
%def8	00111000b
%def8	11100000b
%def8	11100000b
%def8	01110000b
%def8	00000000b
%def8	00000000b
%def8	11000000b
%def8	11000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b

%def8	00000010b	;fire1(bottom)
%def8	00001100b
%def8	11000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	0,0,0,0,0,0,0,0
%def8	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

%def8	00000001b	;fire2(bottom)
%def8	00000011b
%def8	00110000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	0,0,0,0,0,0,0,0
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	0,0,0,0,0,0,0,0

%def8	00000000b	;fire3(bottom)
%def8	00000000b
%def8	00001100b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	0,0,0,0,0,0,0,0
%def8	01100000b
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	0,0,0,0,0,0,0,0

%def8	00000000b	;fire4(bottom)
%def8	00000000b
%def8	00000011b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	0,0,0,0,0,0,0,0
%def8	00011100b
%def8	01111000b
%def8	10000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	0,0,0,0,0,0,0,0

%def8	00000000b	;T
%def8	00000000b
%def8	00001000b
%def8	00001000b
%def8	00001000b
%def8	00000100b
%def8	00000100b
%def8	00000010b
%def8	00000010b
%def8	00000001b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	00000000b
%def8	0,0,0,0,0,0,0,0
%def8	00000000b
%def8	00000000b
%def8	10000000b
%def8	01100000b
%def8	00011000b
%def8	00000111b
%def8	00000000b
%def8	00000000b

ROMSprites:
%def8	128-1,0,0,0
%def8	128-1,0,0,0
%def8	128-1,0,0,0
%def8	128-1,0,0,0
%def8	144-1,0,0,0
%def8	144-1,0,0,0
%def8	144-1,0,0,0
%def8	144-1,0,0,0

%def8	160-1,0,0,0
%def8	160-1,0,0,0
%def8	160-1,0,0,0
%def8	160-1,0,0,0
%def8	176-1,0,0,0
%def8	176-1,0,0,0
%def8	176-1,0,0,0
%def8	176-1,0,0,0

%def8	29-1,176, 1*4,14	;I(topleft)
%def8	29-1,192, 2*4,14	;I(topright)
%def8	40-1,152, 3*4,14	;N
%def8	45-1,176, 4*4,14	;I(bottomleft)
%def8	45-1,192, 5*4,14	;I(bottomright)
%def8	61-1, 83, 6*4,11	;fire1(top)
%def8	61-1, 83, 7*4,10	;fire2(top)
%def8	61-1, 83, 8*4, 8	;fire3(top)
%def8	61-1, 88, 9*4, 6	;fire4(top)
%def8	77-1, 83,10*4,11	;fire1(bottom)
%def8	77-1, 83,11*4,10	;fire2(bottom)
%def8	77-1, 83,12*4, 8	;fire3(bottom)
%def8	77-1, 83,13*4, 6	;fire4(bottom)
%def8	104-1,48,14*4,14	;T

%def8	208


section rdata	
OldISR:		rb	5
FrameCtr:	rb	1
BG:		rb	200+40
Sprites:	rb	128
