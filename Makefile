PYTHON ?= python3
GNATMAKE ?= gnatmake
FORTRAN ?= gfortran
COBOL ?= cobc
BUILD_DIR ?= build
BIN_DIR := $(BUILD_DIR)/bin
ADA_OBJ_DIR := $(BUILD_DIR)/obj/ada
RECEIPTS ?= receipts
V6_IMAGE := $(BUILD_DIR)/HERESY1440.IMG

.PHONY: all build stack check test demo boot clean legacy-v6 parent-lab-dry check-tools check-editions

all: build

build: stack

check-tools:
	@command -v $(GNATMAKE) >/dev/null || { echo "missing Ada compiler: $(GNATMAKE)" >&2; exit 1; }
	@command -v $(FORTRAN) >/dev/null || { echo "missing Fortran compiler: $(FORTRAN)" >&2; exit 1; }
	@command -v $(COBOL) >/dev/null || { echo "missing COBOL compiler: $(COBOL)" >&2; exit 1; }

$(BIN_DIR) $(ADA_OBJ_DIR):
	mkdir -p $@

$(BIN_DIR)/heresy-kernel: src/v7/heresy_kernel.adb | $(BIN_DIR) $(ADA_OBJ_DIR)
	$(GNATMAKE) -q -gnat2022 -D $(ADA_OBJ_DIR) -o $@ $<

$(BIN_DIR)/heresy-runtime: src/v7/heresy_runtime.f90 | $(BIN_DIR)
	$(FORTRAN) -std=f2008 -Wall -Wextra -O2 -o $@ $<

$(BIN_DIR)/heresy-app: src/v7/heresy_app.cob | $(BIN_DIR)
	$(COBOL) -x -free -Wall -o $@ $<

$(BIN_DIR)/heresy360: src/v7/heresy360.sh | $(BIN_DIR)
	install -m 755 $< $@

stack: check-tools $(BIN_DIR)/heresy-kernel $(BIN_DIR)/heresy-runtime $(BIN_DIR)/heresy-app $(BIN_DIR)/heresy360
	@echo "HERESY/360 built: Ada executive + Fortran runtime + COBOL terminal."

test: stack
	sh tests/test_v7.sh

check: stack
	$(PYTHON) -m compileall -q src tests
	$(PYTHON) -m unittest discover -s tests -p 'test_ai1440.py' -v
	sh tests/test_v7.sh
	@echo "v7 deterministic cross-language checks passed. Automated system has been asked to name the rule."

boot: stack
	$(BIN_DIR)/heresy360 boot

demo: stack
	$(BIN_DIR)/heresy360 demo-x

legacy-v6:
	$(PYTHON) -m src.cli build --receipts $(RECEIPTS) --output $(V6_IMAGE)
	@test "$$(wc -c < $(V6_IMAGE))" -eq 1474560
	@echo "v6 AI/1440 artifact rebuilt at $(V6_IMAGE)."

parent-lab-dry:
	$(PYTHON) -m src.cli parent-lab --dry-run

check-editions:
	@echo "Historical editions retain their original contracts beneath editions/."
	@echo "v6 source is anchored by its exact pre-v7 Git commit and tree under editions/v6-ai1440/original/."
	@echo "v5 example: cd editions/v5-heresy64/original && make check   # requires cc65"

clean:
	rm -rf $(BUILD_DIR) src/__pycache__ tests/__pycache__
