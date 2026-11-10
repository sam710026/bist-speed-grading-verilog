.PHONY: check test

check:
	python3 scripts/check_project.py

test:
	python3 scripts/run_tests.py
