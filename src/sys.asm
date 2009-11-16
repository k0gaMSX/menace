;;; Name:	SaveSlotC
;;; Function:	Save Slot in which cartridge is inserted
;;; Modify:	A,HL,DE

	
SaveSlotC:	
	call	RSLREG
	rrca
	rrca
	and	11b
	ld	e,a
	ld	d,0
	ld	hl,EXPTBL
	add	hl,de
	ld	e,a
	ld	a,(hl)
	and	80h
	or	e
	ld	e,a
	
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	
	and	00001100b
	or	e
	ld	(romslt),a
	ret


;;; Name:	RomSlotPageX
;;; Function:	Select Slot Cartridge for the page X
	

RomSlotPage0:
	ld	hl,0
	ld	a,(romslt)	
	jr	SlotChg
RomSlotPage1:
	ld	hl,1<<14
	ld	a,(romslt)	
	jr	SlotChg
			
RomSlotPage2:
	ld	hl,2<<14
	ld	a,(romslt)	
	jr	SlotChg
	
RomSlotPage3:
	ld	hl,3<<14
	ld	a,(romslt)
	
SlotChg:		
	jp	ENASLT



	

; in: hl = source
;     de = destination
; changes: af,af',bc,de,hl,ix

UnTCF:: ld      ix,-1           ; last_m_off

        ld      a,[hl]          ; read first byte
        inc     hl
        scf
        adc     a,a
        jr      nc,.endlit

.litlp: ldi
.loop:  call    GetBit
        jp      c,.litlp
.endlit:

        push    de              ; save dst
        ld      de,1
.moff:  call    GetBit
        rl      e
        rl      d
        call    GetBit
        jr      c,.gotmoff
        dec     de
        call    GetBit
        rl      e
        rl      d
        jp      nc,.moff
        pop     de              ; end of compression
        ret

.gotmoff:
        ex      af,af'
        ld      bc,0            ; m_len
        dec     de
        dec     de
        ld      a,e
        or      d
        jr      z,.prevdist
        ld      a,e
        dec     a
        cpl
        ld      d,a
        ld      e,[hl]
        inc     hl
        ex      af,af'
        ; scf - carry is already set!
        rr      d
        rr      e
        ld      ixl,e
        ld      ixh,d
        jp      .newdist
.prevdist:
        ex      af,af'
        ld      e,ixl
        ld      d,ixh
        call    GetBit
.newdist:
        jr      c,.mlenx
        inc     bc
        call    GetBit
        jr      c,.mlenx

.mlen:  call    GetBit
        rl      c
        rl      b
        call    GetBit
        jp      nc,.mlen
        inc     bc
        inc     bc
.gotmlen:
        ex      af,af'
        ld      a,d
        cp      -5
        jp      nc,.nc
        inc     bc
.nc:    inc     bc
        inc     bc
        ex      af,af'

        ex	[sp],hl		; save src, and get dst in hl, de = offset
        ex      de,hl           ; de = dst, hl = offset
        add     hl,de           ; new src = dst+offset
        ldir
        pop	hl		; get src back
        jp      .loop

.mlenx: call    GetBit
        rl      c
        rl      b
        jp      .gotmlen


	
GetBit: add     a,a
        ret     nz
        ld      a,[hl]          ; read new byte
        inc     hl
        adc     a,a             ; cf = 1, last bit shifted is always 1
        ret



	
section	rdata
romslt:		rb	1
section code	
