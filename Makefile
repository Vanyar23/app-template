.PHONY: lint test check dev ship

lint:
	hadolint Dockerfile
	yamllint -d "{extends: relaxed, rules: {line-length: {max: 120}}}" .github/workflows/*.yml deploy/*.yaml 2>/dev/null || yamllint -d "{extends: relaxed, rules: {line-length: {max: 120}}}" .github/workflows/*.yml deploy/*.yml

test:
	npm test --if-present

check: lint test

dev:
	docker compose -f compose.dev.yaml up --build

ship:
	@if [ -z "$(M)" ]; then echo "Erreur: spécifiez un message avec M=\"votre message\""; exit 1; fi
	git add -A
	git commit -m "$(M)"
	git push
