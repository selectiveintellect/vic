###############################################
### COPYRIGHT: Vikas N Kumar <vikas@cpan.org>
### AUTHOR: Vikas Kumar
### DATE: 29th May 2013
### SOFTWARE: PIC uC Software
###############################################
GPASM?=$(shell which gpasm)
GPLINK?=$(shell which gplink)
PK2CMD?=$(shell which pk2cmd)
PIC?=PIC16F690
VIC?=$(shell which vic)
CURDIR:=$(shell pwd)

ifeq ($(VIC),)
$(error "Unable to find the 'vic' program for compiling. Please set it in the $$PATH")
endif

ifeq ($(VERBOSE),1)
 QUIET:=
 VICOPT:=-i
else
 QUIET:=-q
 VICOPT:=
endif

ASMFILES:=$(patsubst %.vic,%.asm,$(wildcard *.vic))
HEXFILES:=$(patsubst %.vic,%.hex,$(wildcard *.vic))
TARGETS:=$(patsubst %.vic,%,$(wildcard *.vic))

default: all
.PHONY: default

all: $(HEXFILES)
.PHONY: all

rebuild: clean all
.PHONY: rebuild

clean:
	rm -f *.hex *.d *.lst *.cod *.o *.asm
.PHONY: clean

test:
	@echo "Starting test"
	$(PK2CMD) -P$(PIC) -T
.PHONY: test

stoptest:
	@echo "Stopping test"
	$(PK2CMD) -P$(PIC)
.PHONY: stoptest

erase:
	@echo "Erasing $(PIC)"
	$(PK2CMD) -P$(PIC) -E
.PHONY: erase

# using a static pattern to automatically create a dependency on corresponding
# hex file
$(TARGETS): %: %.hex
	@echo "Programming $@ with $<"
	$(PK2CMD) -P$(PIC) -M -F$<
.PHONY: $(TARGETS)

%.hex: %.o
	$(GPLINK) $(QUIET) -o $@ $*.o

%.o: %.asm
	$(GPASM) -p$(PIC) -M -c $<

%.asm: %.vic
	$(VIC) $(VICOPT) $< -o $@

-include $(HEXFILES:.hex=.d)
