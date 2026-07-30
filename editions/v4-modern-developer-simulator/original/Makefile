.PHONY: check serve punch

check:
	node scripts/punch-cobol.js --check
	node scripts/selftest.js
	node scripts/verify-size.js

punch:
	node scripts/punch-cobol.js

serve:
	python3 -m http.server 8000
