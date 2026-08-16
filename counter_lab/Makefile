# Tarang2_dp1 — Verilog compile & simulate
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
# Source lives decrypted in LABS (~/lab/build) already — tarang2p1-decrypt-all.sh
# populates it once at container startup and tarang2p1-sweep.sh keeps it synced
# with the encrypted *.v.enc under WORK for the whole session. This Makefile
# just compiles what's already there — it no longer does its own decrypt/shred
# step, so it follows the same always-decrypted-in-build model as the rest of
# the lab tooling instead of a separate narrower one.
#
# This Makefile is for self-contained single-testbench designs like counter.v,
# NOT multi-file projects with their own build system (e.g. tarang2_dp1 — use
# `tarang2p1-tree shell tarang2_dp1` for that instead, see HOW_IT_WORKS.md).
#
# Looks for sources in LABS's top level and LABS/mywork/ only (matching WORK's
# top level and WORK/mywork/) — NOT a full recursive find, which would sweep
# in unrelated designs nested elsewhere under LABS (e.g. tarang2_dp1's own .v
# files) and compile them all together by mistake.
#
# vvp is always run with cwd set to LABS (`cd $(LABS) && vvp ...`) — if a
# testbench's $dumpfile() uses a bare relative filename, the .vcd it writes
# needs to land inside LABS (and stay there), not escape into ~/lab itself
# where tarang2p1-sweep.sh would otherwise treat it as stray plaintext and
# encrypt it.
#
# WORK/LABS can be overridden: make WORK=~/mywork LABS=~/scratch

WORK    ?= $(HOME)/lab
LABS    ?= $(WORK)/build
FILE    ?= counter
SIM_OUT := $(LABS)/sim.vvp

GREEN  := \033[0;32m
YELLOW := \033[0;33m
RESET  := \033[0m

.PHONY: all compile sim wave run clean

all: compile sim

compile:
	@set -e; \
	SRCS=$$(ls $(LABS)/*.v $(LABS)/mywork/*.v 2>/dev/null); \
	[ -n "$$SRCS" ] || { echo "Tarang2_dp1: no .v source files found in $(LABS) or $(LABS)/mywork — is the lab container's decrypt/sweep running?"; exit 1; }; \
	echo "$(GREEN)Compiling: $$(basename -a $$SRCS)$(RESET)"; \
	iverilog -g2012 -Wall -o $(SIM_OUT) $$SRCS
	@echo "$(GREEN)Done — run 'make sim' to simulate$(RESET)"

sim:
	@test -f $(SIM_OUT) || { echo "$(YELLOW)No build found — running 'make compile' first…$(RESET)"; $(MAKE) --no-print-directory compile; }
	@echo "$(YELLOW)Running simulation …$(RESET)"
	@cd $(LABS) && vvp sim.vvp
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
run:
	@SRC=$$(ls $(LABS)/$(FILE).v $(LABS)/mywork/$(FILE).v 2>/dev/null | head -1); \
	[ -n "$$SRC" ] || { echo "No such design: $(FILE)"; exit 1; }; \
	echo "$(GREEN)Compiling: $$(basename $$SRC)$(RESET)"; \
	iverilog -g2012 -Wall -o $(LABS)/$(FILE).vvp "$$SRC"; \
	echo "$(YELLOW)Running $(FILE) …$(RESET)"; \
	cd $(LABS) && vvp $(FILE).vvp; \
	echo "$(GREEN)Done.$(RESET)"

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
