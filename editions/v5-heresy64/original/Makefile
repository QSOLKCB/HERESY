CA65 ?= ca65
LD65 ?= ld65
PYTHON ?= python3

PRG := dist/HERESY64.PRG
D64 := dist/HERESY64.D64
OBJ := build/heresy64.o
MAP := build/heresy64.map
LBL := build/heresy64.lbl

.PHONY: all check clean check-editions

all: $(PRG) $(D64)

$(OBJ): $(shell find src -type f \( -name '*.s' -o -name '*.inc' \)) cfg/heresy64.cfg
	mkdir -p build dist
	$(CA65) -I src -g -o $@ src/heresy64.s

$(PRG): $(OBJ) cfg/heresy64.cfg
	$(LD65) -C cfg/heresy64.cfg -m $(MAP) -Ln $(LBL) -o $@ $(OBJ)

$(D64): $(PRG) scripts/make_d64.py
	$(PYTHON) scripts/make_d64.py $(PRG) $(D64)

check: all
	$(PYTHON) scripts/verify.py
	$(PYTHON) scripts/verify_determinism.py "$(CA65)" "$(LD65)"
	$(PYTHON) scripts/runtime_test.py

check-editions:
	$(MAKE) -C editions/v4-modern-developer-simulator/original check
	cd editions/v3-cloud-native-punch-card/original && \
		NPM_CONFIG_CACHE=/tmp/heresy-npm-cache npm ci && npm run check
	cd editions/v2-react-in-basic-in-react/original && \
		NPM_CONFIG_CACHE=/tmp/heresy-npm-cache npm ci && npm run check
	@if command -v cargo >/dev/null; then \
		cd editions/v1-c-in-rust-in-c && cargo run -q && \
		./target/heresy_c/heresy_exe; \
	else \
		echo "SKIP v1: cargo is not installed"; \
	fi

clean:
	rm -f $(OBJ) $(MAP) $(LBL) $(PRG) $(D64)
