### COPYRIGHT: Vikas N Kumar <vikas@cpan.org>
### DATE: 21st Aug 2014
### SOFTWARE: VIC
CURDIR=$(shell pwd)
HTMLIZE?=$(CURDIR)/htmlize
HTMLFILES:=$(patsubst %.md,%.html,$(wildcard *.md))

default: all

all: $(HTMLFILES)

$(HTMLFILES): %.html: %.md
	/bin/sh $(HTMLIZE) $<
	rm -f $@-e

.PHONY: all default
