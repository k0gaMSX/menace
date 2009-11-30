


IMPACT01_NUMBER:	equ   1
IMPACT01_PRIO:		equ  10

PJEXP_NUMBER:	        equ   2
PJEXP_PRIO:		equ   0

RCKIGN_NUMBER:		equ   3
RCKIGN_PRIO:		equ   5
RCKIGN_FRAMES:		equ   6

BASEMTR_NUMBER:		equ   4
BASEMTR_PRIO:		equ   6
BASEMTR_FRAMES:		equ   7

ENEMYEXP_NUMBER:	equ   5
ENEMYEXP_PRIO:		equ   1


MENU_NUMBER:            equ   8
MENU_PRIO:              equ   1

LETTER_NUMBER:          equ   10
LETTER_PRIO:            equ   10


GAMEOVER_NUMBER:        equ   11
GAMEOVER_PRIO:          equ    1


SoundISR:
	call	PT3_ROUT
	ld	a,(inIntro)
	or	a
	push	af
	call	nz,PT3_PLAY
	pop	af
	call	z,SimPT3
	call	ayFX_PLAY
	ret



SimPT3:
	ld IY,AYREGS
	ld [IY+7],$BF
	ld [IY+8],0
	ld [IY+8],0
	ld [IY+9],0
	ld [IY+10],0
	ret




initsound:
	ld	hl,sfx
 	call	ayFX_SETUP
	call	SimPT3
	xor	a
	ld	(rckign),a
	ld	(atmos),a
	ld	(basemtr),a
	push	af
	call	PT3_ROUT
	pop	af
	ret


gameover_sfx:
	ld	c,GAMEOVER_PRIO
	ld	a,GAMEOVER_NUMBER
	jp	ayFX_INIT



impact01:
	ld	c,IMPACT01_PRIO
	ld	a,IMPACT01_NUMBER
	jp	ayFX_INIT


enemyexp:
	ld	c,ENEMYEXP_PRIO
	ld	a,ENEMYEXP_NUMBER
	jp	ayFX_INIT


pjexp:
	ld	c,PJEXP_PRIO
	ld	a,PJEXP_NUMBER
	jp	ayFX_INIT


letter_sfx:
	ld	c,LETTER_PRIO
	ld	a,LETTER_NUMBER
	jp	ayFX_INIT



menu_sfx:
	ld	c,MENU_PRIO
	ld	a,MENU_NUMBER
	jp	ayFX_INIT


base_motor:
	ld	a,(basemtr)
	or	a
	jr	z,.1
	dec	a
	ld	(basemtr),a
	ret

.1:	ld	a,BASEMTR_FRAMES
	ld	(basemtr),a
	ld	c,BASEMTR_PRIO
	ld	a,BASEMTR_NUMBER
	jp	ayFX_INIT





rck_ignition:
	ld	a,(rckign)
	or	a
	jr	z,.1
	dec	a
	ld	(rckign),a
	ret

.1:	ld	a,RCKIGN_FRAMES
	ld	(rckign),a
	ld	c,RCKIGN_PRIO
	ld	a,RCKIGN_NUMBER
	jp	ayFX_INIT


section rdata
rckign:	    rb	0
basemtr:    rb  0
atmos:	    rb  0
section code
