.PHONY: lint test check

lint:
	hadolint Dockerfile
	yamllint -d relaxed .github/workflows/*.yml deploy/*.yaml 2>/dev/null || yamllint -d relaxed .github/workflows/*.yml deploy/*.yml

test:
	npm test --if-present

check: lint test
