



initIntro:	ld	hl,20 *256+ 0
		ld	(intromode),hl
		ld	hl,0
		ld	(BAKCLR),hl
		xor	a
		ld	(CLIKSW),a
		call	INIGRP

.initloop:	ld	hl,intromode
		res	0,(hl)
		call	DISSCR

		call	.start

		ld	hl,intro.palette
		call	setplt

		xor	a
		ld	bc,$4000
		ld	hl,0
		call	FILVRM

		ld	de,16*8		; starting from " "
		ld	hl,font.pat
		push	hl
		;push	hl
		call	UnTCFV
		;pop	hl
		;ld	de,$800+32*8
		;call	UnTCFV
		pop	hl
		ld	de,$1000+32*8
		call	UnTCFV

		ld	de,$2000+16*8
		ld	hl,font.col
		push	hl
		;push	hl
		call	UnTCFV
		;pop	hl
		;ld	de,$2800+32*8
		;call	UnTCFV
		pop	hl
		ld	de,$3000+32*8
		call	UnTCFV

		ld	de,64*8		; starting from "@"
		ld	hl,intro.pat
		push	hl
		call	UnTCFV
		ld	de,$800+64*8
		pop	hl
		call	UnTCFV

		ld	de,$2000+64*8
		ld	hl,intro.col
		push	hl
		call	UnTCFV
		ld	de,$2800+64*8
		pop	hl
		call	UnTCFV

		ld	bc,6*32
		ld	de,$1880
		ld	hl,intro.even
		call	LDIRVM

		ld	bc,6*32
		ld	de,$1c80
		ld	hl,intro.odd
		call	LDIRVM

		ld	bc,32
		ld	de,$1800
		ld	hl,intro.score
		push	hl
		push	bc
		call	LDIRVM
		pop	bc
		pop	hl
		ld	de,$1c00
		call	LDIRVM

		ld	de,hiscore
		ld	hl,$1809
		push	de
		call	.printScore
		pop	de
		ld	hl,$1c09
		call	.printScore

		ld	de,score
		ld	hl,$181a
		push	de
		call	.printScore
		pop	de
		ld	hl,$1c1a
		call	.printScore

		ld	bc,32
		ld	de,$1ae0
		ld	hl,intro.cred
		push	hl
		push	bc
		call	LDIRVM
		pop	bc
		pop	hl
		ld	de,$1ee0
		call	LDIRVM


		di
		ld	a,$c3
		ld	hl,mainIntro
		ld	($fd9a),a
		ld	($fd9b),hl
		ei

		call	ENASCR


		ld	b,0
		ei
.wait:
		push	bc
		xor	a
		call	GTTRIG
		jr	nz,.fire
		ld	a,1
		call	GTTRIG
.fire:		pop	bc
		jr	z,.nostart
                call    menu_sfx
                ld      b,30h
.waitsfx:       halt
                djnz    .waitsfx
                jr      .start
.nostart:
		halt
		halt
		djnz	.wait

		ld	hl,intromode
		set	0,(hl)
		call	introdemo
		jp	.initloop

.start:
                ld	a,0c9h
		ld	(0fd9ah),a
		ret


.printScore:	ld	b,5
.printScore.loop:
		ld	a,(de)
		add	a,$2a
		call	WRTVRM
		inc	de
		inc	hl
		djnz	.printScore.loop
		ret
;
mainIntro:
		call	RDVDP
                call    SoundISR

		; $1800 = 0001 1000 0000 0000
		; $1C00 = 0001 1100 0000 0000

		ld	a,($f3e1)
		xor	1
		ld	b,a
		ld	c,2
		call	WRTVDP
		ld	hl,blinkdelay
		dec	(hl)
		ret	nz
		ld	(hl),20
		ld	hl,intromode
		ld	a,(hl)
		xor	2
		ld	(hl),a
		bit	0,(hl)
		ret	nz
		bit	1,(hl)
		jr	z,.off

		ld	bc,32
		ld	de,$1a20
		ld	hl,intro.trig
		push	hl
		push	bc
		call	LDIRVM
		pop	bc
		pop	hl
		ld	de,$1e20
		call	LDIRVM
		ret

.off:		xor	a
		ld	bc,32
		ld	hl,$1a20
		push	bc
		push	af
		call	FILVRM
		pop	af
		pop	bc
		ld	hl,$1e20
		call	FILVRM
		ret



;
setplt:
		ld	a,($2d)
		or	a
		ret	z
		ld	a,(7)
		inc	a
		ld	c,a
		xor	a
		di
		out	(c),a
		ld	a,128+16
		out	(c),a
		ei
		inc	c
		ld	b,32
		otir
		ret
;
; data
;




intro:
.palette:	dw	$000,$000,$612,$723,$227,$337,$262,$637
		dw	$271,$373,$562,$663,$512,$255,$666,$777


.pat:		incbin	"intro.pat.tcf",8
.col:		incbin	"intro.col.tcf",8
.even:		include	"intro0.asm"
.odd:		include "intro1.asm"
			; 01234567890123456789012345678901
			;" HISCORE 00000      SCORE 00000 "
.score:		db	$00,$17,$18,$22,$12,$1e,$21,$14,$00,$00,$00,$00,$00,$00,$00,$00
		db	$00,$00,$00,$00,$22,$12,$1e,$21,$14,$00,$00,$00,$00,$00,$00,$00
			; 01234567890123456789012345678901
			;"    c 2008 2009 THE NEW IMAGE   "
.cred:		db	$00,$00,$00,$46,$00,$3c,$3a,$3a,$42,$00,$3c,$3a,$3a,$43,$00,$33
		db	$27,$24,$00,$2d,$24,$36,$00,$28,$2c,$20,$26,$24,$00,$00,$00,$00
			; 01234567890123456789012345678901
			;"        PUSH FIRE BUTTON        "
.trig:		db	$00,$00,$00,$00,$00,$00,$00,$00,$2f,$34,$32,$27,$00,$25,$28,$31
		db	$24,$00,$21,$34,$33,$33,$2e,$2d,$00,$00,$00,$00,$00,$00,$00,$00

section rdata
intromode:	rb	1		; bit 0 = intro demo mode
					; bit 1 = blink flag
blinkdelay:	rb	1

section code
