# Makefile for the JBOL project

project := jbol

# jq used to run tests and examples if called from this makefile.
JQ=/usr/local/bin/jq

########################################################################
# Prerequisites
########################################################################

# We are using some of the newest GNU Make features... so require GNU
# Make version >= 3.82
version_test := $(filter 3.82,$(firstword $(sort $(MAKE_VERSION) 3.82)))
ifndef version_test
$(error GNU Make version $(MAKE_VERSION); version >= 3.82 is needed)
endif

########################################################################
# Parameters (redefine as you like)
########################################################################

prefix	?= /usr/local
datadir	?= $(prefix)/share
bindir	?= $(prefix)/bin

########################################################################
# Paranoia
########################################################################

ifeq (,$(filter install uninstall,$(MAKECMDGOALS)))
ifeq (0,$(shell id --user))
$(error  Root only can make "(un)install" targets)
endif
SUDO := 
else
SUDO := sudo
endif

########################################################################
# Configuration
########################################################################

# Disable builtins.
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

# Warn when an undefined variable is referenced.
MAKEFLAGS += --warn-undefined-variables

# Make will not print the recipe used to remake files.
.SILENT:

# Eliminate use of the built-in implicit rules. Also clear out the
# default list of suffixes for suffix rules.
.SUFFIXES:

# Sets the default goal to be used if no targets were specified on the
# command line.
.DEFAULT_GOAL := all

# When it is time to consider phony targets, make will run its recipe
# unconditionally, regardless of whether a file with that name exists or
# what its last-modification time is.
.PHONY: all

# Default shell: if we require GNU Make, why not require Bash?
SHELL := /bin/bash

# The argument(s) passed to the shell are taken from the variable
# .SHELLFLAGS.
.SHELLFLAGS := -o errexit -o pipefail -o nounset -c

# Make will delete the target of a rule if it has changed and its recipe
# exits with a nonzero exit status.
.DELETE_ON_ERROR:

########################################################################
# Targets and files
########################################################################

# Tests to check
Tests := $(wildcard tests/*.test)

# Sentinel targets simulating the tests are done
LogDir := .logs
Logs := $(subst tests/,$(LogDir)/,$(Tests:.test=.log))

# Packages
ARRAY=$(LIB)/array
GEN=$(LIB)/generator
LIB=fadado.github.io
MATH=$(LIB)/math
MUSIC=$(LIB)/music
OBJECT=$(LIB)/object
STR=$(LIB)/string
WORD=$(LIB)/word
XLIB=fadado.github.io/x

########################################################################
# Rules
########################################################################

# Default target
all: $(Logs)

# Hidden directory for logs
$(Logs): | $(LogDir)
$(LogDir): ; mkdir --parents $@

# Tests output is saved in a log file
$(LogDir)/%.log: tests/%.test
	echo '>>>' $< '<<<' | tee $@
	$(JQ) -L./fadado.github.io --run-tests $<	\
		| tee --append $@	\
		| grep --invert-match '^Testing'
	grep --quiet '^\*\*\*' $@ && touch $< || true

# Common tests
$(LogDir)/prelude.log: $(LIB)/prelude.jq
$(LogDir)/types.log: $(LIB)/types.jq
$(LogDir)/stream.log: $(LIB)/stream.jq
$(LogDir)/schema.log: $(LIB)/schema/schema.jq $(LIB)/prelude.jq $(LIB)/types.jq $(STR)/url.jq $(STR)/regexp.jq $(LIB)/stream.jq

# Math tests
$(LogDir)/math.log: $(MATH)/math.jq $(LIB)/types.jq
$(LogDir)/math_chance.log: $(MATH)/chance.jq $(LIB)/prelude.jq
$(LogDir)/math_sequence.log: $(MATH)/sequence.jq $(LIB)/prelude.jq
$(LogDir)/math_bitwise.log: $(MATH)/bitwise.jq

# Arrays tests
$(LogDir)/array.log: $(ARRAY)/array.jq
$(LogDir)/array_set.log: $(ARRAY)/set.jq
$(LogDir)/array_kleene.log: $(ARRAY)/kleene.jq
$(LogDir)/array_tuple.log: $(ARRAY)/tuple.jq

# Object tests
$(LogDir)/object_set.log: $(OBJECT)/set.jq $(LIB)/types.jq

# Word tests
$(LogDir)/word.log: $(WORD)/word.jq $(LIB)/prelude.jq $(LIB)/types.jq
$(LogDir)/word_scanner.log: $(WORD)/scanner.jq $(LIB)/prelude.jq
$(LogDir)/word_alphabet.log: $(WORD)/alphabet.jq $(ARRAY)/kleene.jq $(LIB)/prelude.jq $(LIB)/types.jq
$(LogDir)/word_language.log: $(WORD)/language.jq $(ARRAY)/kleene.jq $(LIB)/prelude.jq

# String tests
$(LogDir)/string.log: $(STR)/string.jq $(LIB)/prelude.jq $(STR)/ascii.jq $(STR)/ascii.json
$(LogDir)/string_ascii.log: $(STR)/ascii.jq $(STR)/ascii.json $(LIB)/prelude.jq
$(LogDir)/string_latin1.log: $(STR)/latin1.jq $(STR)/latin1.json $(LIB)/prelude.jq
$(LogDir)/string_regexp.log: $(STR)/regexp.jq $(LIB)/prelude.jq $(STR)/string.jq $(LIB)/types.jq
$(LogDir)/string_snobol.log: $(STR)/snobol.jq $(LIB)/prelude.jq  $(STR)/string.jq $(LIB)/types.jq
$(LogDir)/string_url.log: $(STR)/url.jq $(MATH)/math.jq

# Music tests
$(LogDir)/music_pitch.log: $(MUSIC)/pitch.jq $(LIB)/prelude.jq $(STR)/regexp.jq $(LIB)/types.jq
$(LogDir)/music_pitch-class.log: $(MUSIC)/pitch-class.jq $(MUSIC)/pitch.jq $(LIB)/prelude.jq $(ARRAY)/set.jq $(MATH)/math.jq $(LIB)/types.jq
$(LogDir)/music_pitch-class-set.log: $(MUSIC)/pitch-class-set.jq $(MUSIC)/pitch-class.jq $(LIB)/prelude.jq $(ARRAY)/set.jq $(MATH)/math.jq $(LIB)/types.jq
$(LogDir)/music_interval-class-vector.log: $(MUSIC)/interval-class-vector.jq $(MUSIC)/pitch-class.jq $(ARRAY)/array.jq $(MATH)/math.jq $(LIB)/prelude.jq 
$(LogDir)/music_interval-pattern.log: $(MUSIC)/interval-pattern.jq $(MUSIC)/pitch-class.jq $(LIB)/prelude.jq 
$(LogDir)/music_interval-table.log: $(MUSIC)/interval-table.jq $(MUSIC)/pitch-class.jq $(ARRAY)/array.jq $(LIB)/prelude.jq 

# x
$(LogDir)/relations.log: $(XLIB)/rel.jq $(LIB)/stream.jq

########################################################################
# Utilities
########################################################################

.PHONY: clean clobber check help install uninstall prototypes

clean:
	rm --force -- $(LogDir)/*.log

clobber: clean
	test -d $(LogDir) && rmdir --parents $(LogDir) || true

check: clean all

install:
	test -d $(datadir)/$(project) || $(SUDO) mkdir -v --parents $(datadir)/$(project)
	test -d $(bindir) || $(SUDO) mkdir -v --parents $(bindir)
	$(SUDO) cp -v -u -r fadado.github.io/ $(datadir)/$(project)
	$(SUDO) cp -v -u -r schemata/ $(datadir)/$(project)
	$(SUDO) install --verbose --compare --mode 555 bin/{jgen,jval} $(bindir)
	$(SUDO) install --verbose --compare --mode 644 bin/{jgen,jval}.jq $(bindir)

uninstall:
	test -d $(datadir)/$(project)					  \
	&& $(SUDO) rm --verbose --force --recursive $(datadir)/$(project) \
	|| true
	$(SUDO) rm -f $(bindir)/{jgen,jval}* 

# Show targets
help:
	echo 'Targets:';					\
	$(MAKE) --print-data-base --just-print 2>&1		\
	| grep -v '^[mM]akefile'				\
	| awk '/^[^ \t.%][-A-Za-z0-9_]*:/ { print $$1 }'	\
	| sort --unique						\
	| sed 's/:\+$$//'					\
	| pr --omit-pagination --indent=4 --width=80 --columns=4

define make_prototypes
  find fadado.github.io -name '*.jq' -print | while read m; do	\
    M=$${m##*/};						\
    P=$${M%.jq};						\
    <$$m grep '^def  *[^_].*\#::'	 			\
    | sed -e 's/^def  *//' -e 's/:  *\#/ /'			\
    | sort >|/tmp/$$P.md ;					\
  done
endef

prototypes:
	$(call make_prototypes)

########################################################################
# Examples
########################################################################

.PHONY: bogussort cross cut dice newton nondet nqbrute nqsmart octcode \
	script seconds sendmoremoney series shuffle nqsbrute triple \
	prolog

bogussort: ; $(JQ) -cnRrf examples/$@.jq
cross: ; $(JQ) -nRrf examples/$@.jq
cut: ; $(JQ) -cnRrf examples/$@.jq
dice: ; $(JQ) -cnRrf examples/$@.jq
newton: ; $(JQ) -cnRrf examples/$@.jq
nqbrute: ; $(JQ) -cnRrf examples/$@.jq
nqsmart: ; $(JQ) -cnRrf examples/$@.jq
octcode: ; $(JQ) -cnRrf examples/$@.jq
prolog: ; $(JQ) -cnRrf examples/$@.jq
script: ; $(JQ) -cnrf examples/$@.jq
seconds: ; $(JQ) -nRrf examples/$@.jq
sendmoremoney: ; $(JQ) -cnRrf examples/$@.jq
series: ; $(JQ) -cnRrf examples/$@.jq
shuffle: ; $(JQ) -cnRrf examples/$@.jq
nqsbrute: ; $(JQ) -cnRrf examples/$@.jq
triple: ; $(JQ) -cnrf examples/$@.jq

# vim:ai:sw=8:ts=8:noet:syntax=make
