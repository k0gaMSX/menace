#AS = /usr/local/bin/tniasm.linux
AS=/usr/local/bin/tniasm
SRC = menace.asm tnimsx1.asm
MSX = openmsx
MSXFLAGS = -machine turbor -ext debugdevice
SR52 = ../tools/sr52pat
PAT = patterns.pat
SPR = ../tools/sr52spr
TCF = wine ../tools/tcpack.exe
VPATH = ../sc5 ../sc2 ../data


all: menace.rom


menace.rom: $(SRC)
	$(AS) menace.asm



test: menace.rom
	$(MSX) $(MSXFLAGS) menace.rom

deps:
	files=`grep include *.asm | cut -d'"' -f2` ; \
	for i in  $$files; do \
	  if [ -f $$i ]; then \
	     echo menace.rom: $$i >> deps ;\
	  else \
	     tmp=`which tniasm.linux`;echo menace.rom: `dirname $$tmp`/$$i >> deps ;\
	  fi ; \
	  test -f $$i && \
	  for j in `grep include $$i | cut -d'"' -f2` ; do \
	    if [ -f $$j ]; then \
	     echo menace.rom: $$j >> deps ;\
	    else \
	     tmp=`which tniasm.linux`;echo menace.rom: `dirname $$tmp`/$$j >> deps ;\
	    fi ; \
	  done ;\
	done ;\
	files=`grep incbin *.asm | cut -d'"' -f2` ; \
	for i in $$files ; do \
	   echo menace.rom: $$i >> deps ;\
	done ;


%.pat: %.sc5 %.col
	$(SR52) $< 5 `dirname $<`/$*.col .
	mv -f `dirname $<`/$@  .
	cp -f `dirname $<`/$*.col .


%.pat: %.sc5
	$(SR52) $< 5
	mv -f `dirname $<`/$@  .
	cp -f `dirname $<`/$*.col .




%.spr: %.sc5 %.col
	$(SR52) $< 2 `dirname $<`/$*.col .
	mv -f `dirname $<`/$*.pat  $@

%.flr: %.sc5
	$(SR52) $< 2
	dd if=`dirname $<`/$*.pat of=$@ bs=1 count=400
	dd if=`dirname $<`/$*.col of=$*.col bs=1 count=400
	rm -f `dirname $<`/$*.pat
	rm -f `dirname $<`/$*.col


%.ene: %.sc5 ../sc5/enemy.col
	$(SR52) $< 3 ../sc5/enemy.col
	dd if=`dirname $<`/$*.pat of=$@ bs=1 count=640
	dd if=`dirname $<`/$*.col of=$*.col bs=1 count=640
	rm -f `dirname $<`/$*.pat



%.pat %.col: %.sc2
	dd if=`dirname $<`/$*.sc2 of=$*.pat bs=1 count=6144
	dd if=`dirname $<`/$*.sc2 of=$*.col bs=1 count=6144 skip=8192



%.tcf: %
	$(TCF) $< $@



include deps


.PHONY:

clean:
	rm -f *.sym
	rm -f *.out
	rm -f *.rom
	rm -f *~
	rm -f *.pat
	rm -f *.col
	rm -f *.spr
	rm -f *.flr
	rm -f *.ene
	rm -f *.tcf
	rm deps
