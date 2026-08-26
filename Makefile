.PHONY: analyze test help

help:
	@echo "make analyze  - Simulierte Sign-in-Logs analysieren"
	@echo "make test     - Unit Tests der Detection-Logik ausführen"

analyze:
	python3 scripts/analyze_signins.py \
		--input sample_logs/simulated_signins.jsonl \
		--output artifacts/simulated_signin_report.json

test:
	python3 -m unittest discover -s tests -v
