PT3_ROUT:	XOR A
	
ROUT_A0:	; --- FIXES BITS 6 AND 7 OF MIXER ---
		LD	HL,AYREGS+7
		set	7,(hl)
		res	6,(hl)

		LD C,0A0h
		LD HL,AYREGS
.LOUT:		OUT (C),A
		INC C
		OUTI 
		DEC C
		INC A
		CP 13
		JR NZ,.LOUT
		OUT (C),A
		LD A,(HL)
		AND A
		RET M
		INC C
		OUT (C),A
		RET


/;		; --- PT3 REPLAYER WORKING ON ROM ---
		; --- Can be assembled with asMSX ---
		; --- ROM version: MSX-KUN        ---
		; --- asMSX version: SapphiRe     ---

; Based on MSX version of PT3 by Dioniso
;
; This version of the replayer uses a fixed volume and note table, if you need a 
; different note table you can copy it from TABLES.TXT file, distributed with the
; original PT3 distribution. This version also allows the use of PT3 commands.
;
; PLAY and PSG WRITE routines seperated to allow independent calls
;
; ROM LENGTH: 1528 bytes
; RAM LENGTH:  382 bytes

		; --- CONSTANT VALUES DEFINITION ---

;ChannelsVars
;struc	CHNPRM
;reset group

;; SapphiRe-MSX> el problema es que están en txt, sin convertir a pt3
;; <SapphiRe-MSX> de todas formas
;; <SapphiRe-MSX> aunque no tengas pt3...
;; <SapphiRe-MSX> para simular que lo usas
;; <SapphiRe-MSX> ld IY,AYREGS
;; <SapphiRe-MSX> ld [IY+7],$BF
;; <SapphiRe-MSX> ld [IY+8],0
;; <SapphiRe-MSX> ld [IY+8],0
;; <SapphiRe-MSX> ld [IY+9],0
;; <SapphiRe-MSX> ld [IY+10],0
;; <SapphiRe-MSX> es decir
;; <SapphiRe-MSX> tienes que poner el call PT3_ROUT
;; <SapphiRe-MSX> para volcar los registros que están en AYREGS
;; <SapphiRe-MSX> luego para simular el pt3
;; <SapphiRe-MSX> las instrucciones que te he dicho
;; <SapphiRe-MSX> y luego el call ayFX_PLAY


CHNPRM_PsInOr	equ 0	;RESB 1
CHNPRM_PsInSm	equ 1	;RESB 1
CHNPRM_CrAmSl	equ 2	;RESB 1
CHNPRM_CrNsSl	equ 3	;RESB 1
CHNPRM_CrEnSl	equ 4	;RESB 1
CHNPRM_TSlCnt	equ 5	;RESB 1
CHNPRM_CrTnSl	equ 6	;RESW 1
CHNPRM_TnAcc	equ 8	;RESW 1
CHNPRM_COnOff	equ 10	;RESB 1
;reset group

CHNPRM_OnOffD	equ 11	;RESB 1

;IX for PTDECOD here (+12)
CHNPRM_OffOnD	equ 12	;RESB 1
CHNPRM_OrnPtr	equ 13	;RESW 1
CHNPRM_SamPtr	equ 15	;RESW 1
CHNPRM_NNtSkp	equ 17	;RESB 1
CHNPRM_Note	equ 18	;RESB 1
CHNPRM_SlToNt	equ 19	;RESB 1
CHNPRM_Env_En	equ 20	;RESB 1
CHNPRM_Flags	equ 21	;RESB 1
 ;Enabled - 0,SimpleGliss - 2
CHNPRM_TnSlDl	equ 22	;RESB 1
CHNPRM_TSlStp	equ 23	;RESW 1
CHNPRM_TnDelt	equ 25	;RESW 1
CHNPRM_NtSkCn	equ 27	;RESB 1
CHNPRM_Volume	equ 28	;RESB 1
CHNPRM_Size	equ 29	;RESB 1
;endstruc

;struc	AR
AR_TonA		equ 0	;RESW 1
AR_TonB		equ 2	;RESW 1
AR_TonC		equ 4	;RESW 1
AR_Noise	equ 6	;RESB 1
AR_Mixer	equ 7	;RESB 1
AR_AmplA	equ 8	;RESB 1
AR_AmplB	equ 9	;RESB 1
AR_AmplC	equ 10	;RESB 1
AR_Env		equ 11	;RESW 1
AR_EnvTp	equ 13	;RESB 1
;endstruc




	
	
		; --- CODE STARTS HERE ---

CHECKLP:	LD	HL,PT3_SETUP
		SET	7,(HL)
		BIT	0,(HL)
		RET	Z
		POP	HL
		LD	HL,DelyCnt
		INC	(HL)
		LD	HL,ChanA+CHNPRM_NtSkCn
		INC	(HL)
PT3_MUTE:	XOR	A
		LD	H,A
		LD	L,A
		LD	(AYREGS+AR_AmplA),A
		LD	(AYREGS+AR_AmplB),HL
		JP	ROUT_A0

PT3_INIT:	;HL - AddressOfModule - 100
		LD (PT3_MODADDR),HL
		PUSH HL
		LD DE,100
		ADD HL,DE
		LD A,(HL)
		LD (PT3_Delay),A
		PUSH HL
		POP IX
		ADD HL,DE
		LD (PT3_CrPsPtr),HL
		LD E,(IX+102-100)
		ADD HL,DE
		INC HL
		LD (PT3_LPosPtr),HL
		POP DE
		LD L,(IX+103-100)
		LD H,(IX+104-100)
		ADD HL,DE
		LD (PT3_PatsPtr),HL
		LD HL,169
		ADD HL,DE
		LD (PT3_OrnPtrs),HL
		LD HL,105
		ADD HL,DE
		LD (PT3_SAMPTRS),HL
		LD HL,PT3_SETUP
		RES 7,(HL)

		; --- CREATE PT3 VOLUME TABLE (c) Ivan Roshin, adapted by SapphiRe ---
		ld	hl,011h
		ld	d,h
		ld	e,h
		ld	IX,VT_+16
		ld	b,15
.INITV1:	push	hl
		add	hl,de
		ex	de,hl
		sbc	hl,hl
		ld	c,b
		ld	b,16
.INITV2:	ld	a,l
		rla
		ld	a,h
		adc	a,0
		ld	(ix),a
		inc	ix
		add	hl,de
		djnz	.INITV2
		pop	hl
		ld	a,e
		cp	077h
		jr	nz,.INITV3
		inc	e
.INITV3:	ld	b,c
		djnz	.INITV1

		; --- INITIALIZE PT3 VARIABLES ---
		XOR A
		LD HL,VARS
		LD (HL),A
		LD DE,VARS+1
		LD BC,VAR0END-VARS-1
		LDIR

		INC A
		LD (DelyCnt),A
		LD HL,0F001h ;H - CHNPRM_Volume, L - CHNPRM_NtSkCn
		LD (ChanA+CHNPRM_NtSkCn),HL
		LD (ChanB+CHNPRM_NtSkCn),HL
		LD (ChanC+CHNPRM_NtSkCn),HL

		LD HL,EMPTYSAMORN
		LD (PT3_AdInPtA),HL ;ptr to zero
		LD (ChanA+CHNPRM_OrnPtr),HL ;ornament 0 is "0,1,0"
		LD (ChanB+CHNPRM_OrnPtr),HL ;in all versions from
		LD (ChanC+CHNPRM_OrnPtr),HL ;3.xx to 3.6x and VTII

		LD (ChanA+CHNPRM_SamPtr),HL ;S1 There is no default
		LD (ChanB+CHNPRM_SamPtr),HL ;S2 sample in PT3, so, you
		LD (ChanC+CHNPRM_SamPtr),HL ;S3 can comment S1,2,3; see
					    ;also EMPTYSAMORN comment
		RET

		;pattern decoder
PD_OrSm:	LD (IX+(CHNPRM_Env_En-12)),0
		CALL SETORN
		LD A,(BC)
		INC BC
		RRCA

PD_SAM:		ADD A,A
PD_SAM_:	LD E,A
		LD D,0
		LD HL,(PT3_SAMPTRS)
		ADD HL,DE
		LD E,(HL)
		INC HL
		LD D,(HL)
		LD HL,(PT3_MODADDR)
		ADD HL,DE
		LD (IX+(CHNPRM_SamPtr-12)),L
		LD (IX+(CHNPRM_SamPtr+1-12)),H
		JR PD_LOOP

PD_VOL:		RLCA
		RLCA
		RLCA
		RLCA
		LD (IX+(CHNPRM_Volume-12)),A
		JR PD_LP2
	
PD_EOff:	LD (IX+(CHNPRM_Env_En-12)),A
		LD (IX+(CHNPRM_PsInOr-12)),A
		JR PD_LP2

PD_SorE:	DEC A
		JR NZ,PD_ENV
		LD A,(BC)
		INC BC
		LD (IX+(CHNPRM_NNtSkp-12)),A
		JR PD_LP2

PD_ENV:		CALL SETENV
		JR PD_LP2

PD_ORN:		CALL SETORN
		JR PD_LOOP
       
PD_ESAM:	LD (IX+(CHNPRM_Env_En-12)),A
		LD (IX+(CHNPRM_PsInOr-12)),A
		CALL NZ,SETENV
		LD A,(BC)
		INC BC
		JR PD_SAM_

PTDECOD:	LD A,(IX+(CHNPRM_Note-12))
		LD (PT3_PrNote),A
		LD L,(IX+(CHNPRM_CrTnSl-12))
		LD H,(IX+(CHNPRM_CrTnSl+1-12))
		LD (PT3_PrSlide),HL

PD_LOOP:	LD DE,02010h
PD_LP2:		LD A,(BC)
		INC BC
		ADD A,E
		JR C,PD_OrSm
		ADD A,D
		JR Z,PD_FIN
		JR C,PD_SAM
		ADD A,E
		JR Z,PD_REL
		JR C,PD_VOL
		ADD A,E
		JR Z,PD_EOff
		JR C,PD_SorE
		ADD A,96
		JR C,PD_NOTE
		ADD A,E
		JR C,PD_ORN
		ADD A,D
		JR C,PD_NOIS
		ADD A,E
		JR C,PD_ESAM
		ADD A,A
		LD E,A
		LD HL,((SPCCOMS+0DF20h) % 65536)	; Adapted from original Speccy version (saves 6 bytes)
		ADD HL,DE
		LD E,(HL)
		INC HL
		LD D,(HL)
		PUSH DE
		JR PD_LOOP

PD_NOIS:	LD (Ns_Base),A
		JR PD_LP2

PD_REL:		RES 0,(IX+(CHNPRM_Flags-12))
		JR PD_RES
	
PD_NOTE:	LD (IX+(CHNPRM_Note-12)),A
		SET 0,(IX+(CHNPRM_Flags-12))
		XOR A

PD_RES:		LD (PT3_PDSP),SP
		LD SP,IX
		LD H,A
		LD L,A
		PUSH HL
		PUSH HL
		PUSH HL
		PUSH HL
		PUSH HL
		PUSH HL
		LD SP,(PT3_PDSP)

PD_FIN:		LD A,(IX+(CHNPRM_NNtSkp-12))
		LD (IX+(CHNPRM_NtSkCn-12)),A
		RET

C_PORTM:	RES 2,(IX+(CHNPRM_Flags-12))
		LD A,(BC)
		INC BC
		;SKIP PRECALCULATED TONE DELTA [BECAUSE
		;CANNOT BE RIGHT AFTER PT3 COMPILATION]
		INC BC
		INC BC
		LD (IX+(CHNPRM_TnSlDl-12)),A
		LD (IX+(CHNPRM_TSlCnt-12)),A
		LD DE,NT_
		LD A,(IX+(CHNPRM_Note-12))
		LD (IX+(CHNPRM_SlToNt-12)),A
		ADD A,A
		LD L,A
		LD H,0
		ADD HL,DE
		LD A,(HL)
		INC HL
		LD H,(HL)
		LD L,A
		PUSH HL
		LD A,(PT3_PrNote)
		LD (IX+(CHNPRM_Note-12)),A
		ADD A,A
		LD L,A
		LD H,0
		ADD HL,DE
		LD E,(HL)
		INC HL
		LD D,(HL)
		POP HL
		SBC HL,DE
		LD (IX+(CHNPRM_TnDelt-12)),L
		LD (IX+(CHNPRM_TnDelt+1-12)),H
		LD DE,(PT3_PrSlide)
		LD (IX+(CHNPRM_CrTnSl-12)),E
		LD (IX+(CHNPRM_CrTnSl+1-12)),D
		LD A,(BC) ;SIGNED TONE STEP
		INC BC
		EX AF,AF'
		LD A,(BC)
		INC BC
		AND A
		JR Z,.NOSIG
		EX DE,HL
.NOSIG:	SBC HL,DE
		JP P,SET_STP
		CPL
		EX AF,AF'
		NEG
		EX AF,AF'
SET_STP:	LD (IX+(CHNPRM_TSlStp+1-12)),A
		EX AF,AF'
		LD (IX+(CHNPRM_TSlStp-12)),A
		LD (IX+(CHNPRM_COnOff-12)),0
		RET

C_GLISS:	SET 2,(IX+(CHNPRM_Flags-12))
		LD A,(BC)
		INC BC
		LD (IX+(CHNPRM_TnSlDl-12)),A
		LD (IX+(CHNPRM_TSlCnt-12)),A
		LD A,(BC)
		INC BC
		EX AF,AF'
		LD A,(BC)
		INC BC
		JR SET_STP

C_SMPOS:	LD A,(BC)
		INC BC
		LD (IX+(CHNPRM_PsInSm-12)),A
		RET

C_ORPOS:	LD A,(BC)
		INC BC
		LD (IX+(CHNPRM_PsInOr-12)),A
		RET

C_VIBRT:	LD A,(BC)
		INC BC
		LD (IX+(CHNPRM_OnOffD-12)),A
		LD (IX+(CHNPRM_COnOff-12)),A
		LD A,(BC)
		INC BC
		LD (IX+(CHNPRM_OffOnD-12)),A
		XOR A
		LD (IX+(CHNPRM_TSlCnt-12)),A
		LD (IX+(CHNPRM_CrTnSl-12)),A
		LD (IX+(CHNPRM_CrTnSl+1-12)),A
		RET

C_ENGLS:	LD A,(BC)
		INC BC
		LD (PT3_Env_Del),A
		LD (CurEDel),A
		LD A,(BC)
		INC BC
		LD L,A
		LD A,(BC)
		INC BC
		LD H,A
		LD (PT3_ESldAdd),HL
		RET

C_DELAY:	LD A,(BC)
		INC BC
		LD (PT3_Delay),A
		RET
	
SETENV:		LD (IX+(CHNPRM_Env_En-12)),E
		LD (AYREGS+AR_EnvTp),A
		LD A,(BC)
		INC BC
		LD H,A
		LD A,(BC)
		INC BC
		LD L,A
		LD (EnvBase),HL
		XOR A
		LD (IX+(CHNPRM_PsInOr-12)),A
		LD (CurEDel),A
		LD H,A
		LD L,A
		LD (CurESld),HL
C_NOP:		RET

SETORN:		ADD A,A
		LD E,A
		LD D,0
		LD (IX+(CHNPRM_PsInOr-12)),D
		LD HL,(PT3_OrnPtrs)
		ADD HL,DE
		LD E,(HL)
		INC HL
		LD D,(HL)
		LD HL,(PT3_MODADDR)
		ADD HL,DE
		LD (IX+(CHNPRM_OrnPtr-12)),L
		LD (IX+(CHNPRM_OrnPtr+1-12)),H
		RET

		;ALL 16 ADDRESSES TO PROTECT FROM BROKEN PT3 MODULES
SPCCOMS:	dw C_NOP
		dw C_GLISS
		dw C_PORTM
		dw C_SMPOS
		dw C_ORPOS
		dw C_VIBRT
		dw C_NOP
		dw C_NOP
		dw C_ENGLS
		dw C_DELAY
		dw C_NOP
		dw C_NOP
		dw C_NOP
		dw C_NOP
		dw C_NOP
		dw C_NOP

CHREGS:		XOR A
		LD (AYREGS+AR_AmplC),A
		BIT 0,(IX+CHNPRM_Flags)
		PUSH HL
		JP Z,.CH_EXIT
		LD (PT3_CSP),SP
		LD L,(IX+CHNPRM_OrnPtr)
		LD H,(IX+CHNPRM_OrnPtr+1)
		LD SP,HL
		POP DE
		LD H,A
		LD A,(IX+CHNPRM_PsInOr)
		LD L,A
		ADD HL,SP
		INC A
		CP D
		JR C,.CH_ORPS
		LD A,E
.CH_ORPS:	LD (IX+CHNPRM_PsInOr),A
		LD A,(IX+CHNPRM_Note)
		ADD A,(HL)
		JP P,.CH_NTP
		XOR A
.CH_NTP:	CP 96
		JR C,.CH_NOK
		LD A,95
.CH_NOK:	ADD A,A
		EX AF,AF'
		LD L,(IX+CHNPRM_SamPtr)
		LD H,(IX+CHNPRM_SamPtr+1)
		LD SP,HL
		POP DE
		LD H,0
		LD A,(IX+CHNPRM_PsInSm)
		LD B,A
		ADD A,A
		ADD A,A
		LD L,A
		ADD HL,SP
		LD SP,HL
		LD A,B
		INC A
		CP D
		JR C,.CH_SMPS
		LD A,E
.CH_SMPS:	LD (IX+CHNPRM_PsInSm),A
		POP BC
		POP HL
		LD E,(IX+CHNPRM_TnAcc)
		LD D,(IX+CHNPRM_TnAcc+1)
		ADD HL,DE
		BIT 6,B
		JR Z,.CH_NOAC
		LD (IX+CHNPRM_TnAcc),L
		LD (IX+CHNPRM_TnAcc+1),H
.CH_NOAC:	EX DE,HL
		EX AF,AF'
		LD L,A
		LD H,0
		LD SP,NT_
		ADD HL,SP
		LD SP,HL
		POP HL
		ADD HL,DE
		LD E,(IX+CHNPRM_CrTnSl)
		LD D,(IX+CHNPRM_CrTnSl+1)
		ADD HL,DE
		LD SP,(PT3_CSP)
		EX (SP),HL
		XOR A
		OR (IX+CHNPRM_TSlCnt)
		JR Z,.CH_AMP
		DEC (IX+CHNPRM_TSlCnt)
		JR NZ,.CH_AMP
		LD A,(IX+CHNPRM_TnSlDl)
		LD (IX+CHNPRM_TSlCnt),A
		LD L,(IX+CHNPRM_TSlStp)
		LD H,(IX+CHNPRM_TSlStp+1)
		LD A,H
		ADD HL,DE
		LD (IX+CHNPRM_CrTnSl),L
		LD (IX+CHNPRM_CrTnSl+1),H
		BIT 2,(IX+CHNPRM_Flags)
		JR NZ,.CH_AMP
		LD E,(IX+CHNPRM_TnDelt)
		LD D,(IX+CHNPRM_TnDelt+1)
		AND A
		JR Z,.CH_STPP
		EX DE,HL
.CH_STPP:	SBC HL,DE
		JP M,.CH_AMP
		LD A,(IX+CHNPRM_SlToNt)
		LD (IX+CHNPRM_Note),A
		XOR A
		LD (IX+CHNPRM_TSlCnt),A
		LD (IX+CHNPRM_CrTnSl),A
		LD (IX+CHNPRM_CrTnSl+1),A
.CH_AMP:	LD A,(IX+CHNPRM_CrAmSl)
		BIT 7,C
		JR Z,.CH_NOAM
		BIT 6,C
		JR Z,.CH_AMIN
		CP 15
		JR Z,.CH_NOAM
		INC A
		JR .CH_SVAM
.CH_AMIN:	CP -15
		JR Z,.CH_NOAM
		DEC A
.CH_SVAM:	LD (IX+CHNPRM_CrAmSl),A
.CH_NOAM:	LD L,A
		LD A,B
		AND 15
		ADD A,L
		JP P,.CH_APOS
		XOR A
.CH_APOS:	CP 16
		JR C,.CH_VOL
		LD A,15
.CH_VOL:	OR (IX+CHNPRM_Volume)
		LD L,A
		LD H,0
		LD DE,VT_
		ADD HL,DE
		LD A,(HL)
.CH_ENV:	BIT 0,C
		JR NZ,.CH_NOEN
		OR (IX+CHNPRM_Env_En)
.CH_NOEN:	LD (AYREGS+AR_AmplC),A
		BIT 7,B
		LD A,C
		JR Z,.NO_ENSL
		RLA
		RLA
		SRA A
		SRA A
		SRA A
		ADD A,(IX+CHNPRM_CrEnSl) ;SEE COMMENT BELOW
		BIT 5,B
		JR Z,.NO_ENAC
		LD (IX+CHNPRM_CrEnSl),A
.NO_ENAC:	LD HL,PT3_AddToEn
		ADD A,(HL) ;BUG IN PT3 - NEED WORD HERE.
			   ;FIX IT IN NEXT VERSION?
		LD (HL),A
		JR .CH_MIX
.NO_ENSL:	RRA
		ADD A,(IX+CHNPRM_CrNsSl)
		LD (AddToNs),A
		BIT 5,B
		JR Z,.CH_MIX
		LD (IX+CHNPRM_CrNsSl),A
.CH_MIX:	LD A,B
		RRA
		AND 048h
.CH_EXIT:	LD HL,AYREGS+AR_Mixer
		OR (HL)
		RRCA
		LD (HL),A
		POP HL
		XOR A
		OR (IX+CHNPRM_COnOff)
		RET Z
		DEC (IX+CHNPRM_COnOff)
		RET NZ
		XOR (IX+CHNPRM_Flags)
		LD (IX+CHNPRM_Flags),A
		RRA
		LD A,(IX+CHNPRM_OnOffD)
		JR C,.CH_ONDL
		LD A,(IX+CHNPRM_OffOnD)
.CH_ONDL:	LD (IX+CHNPRM_COnOff),A
		RET

PT3_PLAY:	XOR A
		LD (PT3_AddToEn),A
		LD (AYREGS+AR_Mixer),A
		DEC A
		LD (AYREGS+AR_EnvTp),A
		LD HL,DelyCnt
		DEC (HL)
		JP NZ,.PL2
		LD HL,ChanA+CHNPRM_NtSkCn
		DEC (HL)
		JR NZ,.PL1B
		LD BC,(PT3_AdInPtA)
		LD A,(BC)
		AND A
		JR NZ,.PL1A
		LD D,A
		LD (Ns_Base),A
		LD HL,(PT3_CrPsPtr)
		INC HL
		LD A,(HL)
		INC A
		JR NZ,.PLNLP
		CALL CHECKLP
		LD HL,(PT3_LPosPtr)
		LD A,(HL)
		INC A
.PLNLP:	LD (PT3_CrPsPtr),HL
		DEC A
		ADD A,A
		LD E,A
		RL D
		LD HL,(PT3_PatsPtr)
		ADD HL,DE
		LD DE,(PT3_MODADDR)
		LD (PT3_PSP),SP
		LD SP,HL
		POP HL
		ADD HL,DE
		LD B,H
		LD C,L
		POP HL
		ADD HL,DE
		LD (PT3_AdInPtB),HL
		POP HL
		ADD HL,DE
		LD (PT3_AdInPtC),HL
		LD SP,(PT3_PSP)

.PL1A:		LD IX,ChanA+12
		CALL PTDECOD
		LD (PT3_AdInPtA),BC

.PL1B:		LD HL,ChanB+CHNPRM_NtSkCn
		DEC (HL)
		JR NZ,.PL1C
		LD IX,ChanB+12
		LD BC,(PT3_AdInPtB)
		CALL PTDECOD
		LD (PT3_AdInPtB),BC

.PL1C:		LD HL,ChanC+CHNPRM_NtSkCn
		DEC (HL)
		JR NZ,.PL1D
		LD IX,ChanC+12
		LD BC,(PT3_AdInPtC)
		CALL PTDECOD
		LD (PT3_AdInPtC),BC

.PL1D:		LD A,(PT3_Delay)
		LD (DelyCnt),A

.PL2:		LD IX,ChanA
		LD HL,(AYREGS+AR_TonA)
		CALL CHREGS
		LD (AYREGS+AR_TonA),HL
		LD A,(AYREGS+AR_AmplC)
		LD (AYREGS+AR_AmplA),A
		LD IX,ChanB
		LD HL,(AYREGS+AR_TonB)
		CALL CHREGS
		LD (AYREGS+AR_TonB),HL
		LD A,(AYREGS+AR_AmplC)
		LD (AYREGS+AR_AmplB),A
		LD IX,ChanC
		LD HL,(AYREGS+AR_TonC)
		CALL CHREGS
		LD (AYREGS+AR_TonC),HL

		LD HL,(Ns_Base_AddToNs)
		LD A,H
		ADD A,L
		LD (AYREGS+AR_Noise),A

		LD A,(PT3_AddToEn)
		LD E,A
		ADD A,A
		SBC A,A
		LD D,A
		LD HL,(EnvBase)
		ADD HL,DE
		LD DE,(CurESld)
		ADD HL,DE
		LD (AYREGS+AR_Env),HL

		XOR A
		LD HL,CurEDel
		OR (HL)
		RET Z
		DEC (HL)
		RET NZ
		LD A,(PT3_Env_Del)
		LD (HL),A
		LD HL,(PT3_ESldAdd)
		ADD HL,DE
		LD (CurESld),HL
		RET

EMPTYSAMORN: 	db 0,1,0,090h ;delete 090h if you don't need default sample

NT_:	;Note table 2 [if you use another in Vortex Tracker II copy it and paste
	;it from TABLES.TXT]

	dw 00D10h,00C55h,00BA4h,00AFCh,00A5Fh,009CAh,0093Dh,008B8h,0083Bh,007C5h,00755h,006ECh
	dw 00688h,0062Ah,005D2h,0057Eh,0052Fh,004E5h,0049Eh,0045Ch,0041Dh,003E2h,003ABh,00376h
	dw 00344h,00315h,002E9h,002BFh,00298h,00272h,0024Fh,0022Eh,0020Fh,001F1h,001D5h,001BBh
	dw 001A2h,0018Bh,00174h,00160h,0014Ch,00139h,00128h,00117h,00107h,000F9h,000EBh,000DDh
	dw 000D1h,000C5h,000BAh,000B0h,000A6h,0009Dh,00094h,0008Ch,00084h,0007Ch,00075h,0006Fh
	dw 00069h,00063h,0005Dh,00058h,00053h,0004Eh,0004Ah,00046h,00042h,0003Eh,0003Bh,00037h
	dw 00034h,00031h,0002Fh,0002Ch,00029h,00027h,00025h,00023h,00021h,0001Fh,0001Dh,0001Ch
	dw 0001Ah,00019h,00017h,00016h,00015h,00014h,00012h,00011h,00010h,0000Fh,0000Eh,0000Dh


section rdata
		; --- PT3 WORKAREA [self-modifying code patched] ---

PT3_SETUP:		rb	1	;set bit0 to 1, if you want to play without looping
					;bit7 is set each time, when loop point is passed
PT3_MODADDR:		rb	2
PT3_CrPsPtr:		rb	2
PT3_SAMPTRS:		rb	2
PT3_OrnPtrs:		rb	2
PT3_PRBP:		rb	2
PT3_CSP:		rb	2
PT3_PSP:		rb	2
PT3_PrNote:		rb	1
PT3_PrSlide:		rb	2
PT3_AdInPtA:		rb	2
PT3_AdInPtB:		rb	2
PT3_AdInPtC:		rb	2
PT3_LPosPtr:		rb	2
PT3_PatsPtr:		rb	2
PT3_Delay:		rb	1
PT3_AddToEn:		rb	1
PT3_Env_Del:		rb	1
PT3_ESldAdd:		rb	2
PT3_PDSP:		rb	2
	
VARS:

ChanA:			rb	29			;CHNPRM_Size
ChanB:			rb	29			;CHNPRM_Size
ChanC:			rb	29			;CHNPRM_Size

;GlobalVars
DelyCnt:		rb	1
CurESld:		rb	2
CurEDel:		rb	1
Ns_Base_AddToNs:
Ns_Base:		rb	1
AddToNs:		rb	1

AYREGS:
VT_:			rb	14
EnvBase:		rb	2
VAR0END:		rb	240
section code	
\;