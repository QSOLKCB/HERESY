PYTHON ?= python3
BUILD_DIR ?= build
RECEIPTS ?= receipts
IMAGE := $(BUILD_DIR)/HERESY1440.IMG

.PHONY: all build check test clean heretic parent parent-lab-dry check-editions

all: build

build:
	$(PYTHON) -m src.cli build --receipts $(RECEIPTS) --output $(IMAGE)

test:
	$(PYTHON) -m unittest discover -s tests -v

check:
	$(PYTHON) -m compileall -q src tests
	$(PYTHON) -m unittest discover -s tests -v
	rm -rf $(BUILD_DIR)/check-a $(BUILD_DIR)/check-b
	mkdir -p $(BUILD_DIR)/check-a $(BUILD_DIR)/check-b
	$(PYTHON) -m src.cli build --receipts $(RECEIPTS) --output $(BUILD_DIR)/check-a/HERESY1440.IMG
	$(PYTHON) -m src.cli build --receipts $(RECEIPTS) --output $(BUILD_DIR)/check-b/HERESY1440.IMG
	cmp $(BUILD_DIR)/check-a/HERESY1440.IMG $(BUILD_DIR)/check-b/HERESY1440.IMG
	@test "$$(wc -c < $(BUILD_DIR)/check-a/HERESY1440.IMG)" -eq 1474560
	@echo "AI/1440 deterministic. Cloud invoice still missing."

heretic:
	$(PYTHON) -m src.cli heretic0

parent:
	$(PYTHON) -m src.cli parent0

parent-lab-dry:
	$(PYTHON) -m src.cli parent-lab --dry-run

check-editions:
	@echo "Historical editions are checked independently in CI."
	@echo "v5 remains capable of running make check with cc65 from editions/v5-heresy64/original."

clean:
	rm -rf $(BUILD_DIR) src/__pycache__ tests/__pycache__
