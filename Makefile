# ChipCraft Lab — Verilog compile & simulate
#
# Usage (from any directory):
#   make                   – compile + simulate (all files with testbench)
#   make wave              – compile + simulate + open GTKWave
#   make compile           – compile only
#   make sim               – run simulation only (after compile)
#   make run FILE=counter  – compile + simulate a single file
#   make counter           – compile + simulate counter.v directly
#   make clean             – remove build outputs
#
# Source files are encrypted at rest as *.v.enc, anywhere under ~/lab/
# (any subfolder depth — lab1/, lab2/, mywork/, etc.). Editing happens in
# gvim, which decrypts/encrypts entirely in memory and never writes
# plaintext .v files (see tools/chipcraft-crypt.vim). iverilog is a
# separate process and can only read real files, so this Makefile decrypts
# just-in-time right before compiling and shreds the plaintext the moment
# iverilog exits — plaintext source exists on disk only for the duration
# of that one compile step, not for the whole session.
#
# Files are flattened by basename into LABS for compiling — two .v.enc
# files with the same name in different subfolders would collide there.
#
# LABS lives inside WORK (~/lab/.build) rather than as a sibling folder —
# one top-level directory for students to think about, not two.
#
# WORK/LABS can be overridden: make WORK=~/mywork LABS=~/scratch

WORK    ?= $(HOME)/lab
LABS    ?= $(WORK)/.build
FILE    ?= counter
KEYFILE := $(HOME)/.chipcraft_key
SIM_OUT := $(LABS)/sim.vvp

GREEN  := \033[0;32m
YELLOW := \033[0;33m
RESET  := \033[0m

.PHONY: all compile sim wave run clean _decrypt _shred

all: compile sim

# Decrypt every *.v.enc anywhere under WORK (any subfolder depth) into LABS,
# flattened by filename, just before compiling.
_decrypt:
	@mkdir -p $(LABS)
	@test -f $(KEYFILE) || { echo "ChipCraft: no key at $(KEYFILE) — run inside the lab container."; exit 1; }
	@KEY=$$(cat $(KEYFILE)); \
	found=0; \
	find $(WORK) -name '*.v.enc' -print 2>/dev/null | while IFS= read -r enc; do \
	  out="$(LABS)/$$(basename "$${enc%.enc}")"; \
	  openssl enc -d -aes-256-cbc -pbkdf2 -k "$$KEY" -in "$$enc" -out "$$out" 2>/dev/null && echo ok; \
	done | grep -q ok && found=1; \
	[ "$$found" = "1" ] || { echo "ChipCraft: no .v.enc source files found anywhere under $(WORK)"; exit 1; }

_shred:
	@find $(LABS) -maxdepth 1 -name '*.v' -exec shred -u {} \; 2>/dev/null \
	  || find $(LABS) -maxdepth 1 -name '*.v' -delete 2>/dev/null \
	  || true

compile: _decrypt
	@set -e; \
	TB=$$(ls $(LABS)/tb_*.v 2>/dev/null | head -1); \
	SRCS=$$(ls $(LABS)/*.v 2>/dev/null); \
	echo "$(GREEN)Compiling: $$(basename -a $$SRCS)$(RESET)"; \
	iverilog -g2012 -Wall -o $(SIM_OUT) $$SRCS; rc=$$?; \
	$(MAKE) --no-print-directory _shred; \
	exit $$rc
	@echo "$(GREEN)Done — run 'make sim' to simulate$(RESET)"

sim:
	@test -f $(SIM_OUT) || { echo "$(YELLOW)No build found — running 'make compile' first…$(RESET)"; $(MAKE) --no-print-directory compile; }
	@echo "$(YELLOW)Running simulation …$(RESET)"
	@vvp $(SIM_OUT)
	@echo "$(GREEN)Simulation complete.$(RESET)"
	@vcd=$$(ls $(LABS)/*.vcd 2>/dev/null | head -1); \
	[ -n "$$vcd" ] && echo "$(GREEN)Waveform: $$(basename $$vcd)  →  run 'make wave' to open GTKWave$(RESET)" || true

wave: sim
	@vcd=$$(ls $(LABS)/*.vcd 2>/dev/null | head -1); \
	if [ -n "$$vcd" ]; then \
	  echo "$(YELLOW)Opening GTKWave …$(RESET)"; \
	  gtkwave "$$vcd" & \
	else \
	  echo "No waveform file found."; \
	fi

# Single-file: make run FILE=counter
run: _decrypt
	@test -f $(LABS)/$(FILE).v || { echo "No such design: $(FILE)"; $(MAKE) --no-print-directory _shred; exit 1; }
	@echo "$(GREEN)Compiling: $(FILE).v$(RESET)"
	@iverilog -g2012 -Wall -o $(LABS)/$(FILE).vvp $(LABS)/$(FILE).v; rc=$$?; \
	$(MAKE) --no-print-directory _shred; \
	[ $$rc -eq 0 ] || exit $$rc
	@echo "$(YELLOW)Running $(FILE) …$(RESET)"
	@vvp $(LABS)/$(FILE).vvp
	@echo "$(GREEN)Done.$(RESET)"

# Bare name shorthand: make counter  →  compiles + runs counter.v
%:
	@$(MAKE) --no-print-directory run FILE=$@

clean:
ifdef FILE
	rm -f $(LABS)/$(FILE).vvp $(LABS)/$(FILE).vcd
	@echo "Cleaned $(FILE)."
else
	rm -f $(SIM_OUT) $(LABS)/*.vcd $(LABS)/*.vvp
	@echo "Cleaned."
endif
