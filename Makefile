SLUG := __APP_SLUG__
PORT := __APP_PORT__

.PHONY: help dev build run lint scan check ship logs stop clean

help:            ## Affiche cette aide
    @grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n",$$1,$$2}'

dev:             ## Lance l'application en local (conteneur)
    docker compose -f compose.dev.yaml up --build

build:           ## Construit l'image locale
    docker build -t $(SLUG):local .

run: build       ## Lance l'image construite
    docker run --rm -p 127.0.0.1:$(PORT):$(PORT) -e PORT=$(PORT) $(SLUG):local

lint:            ## Lint du Dockerfile et des YAML
    hadolint Dockerfile
    yamllint -d relaxed deploy/ .github/

scan:            ## Recherche de secrets et de vulnérabilités
    gitleaks detect --no-banner --redact
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy:latest image --severity HIGH,CRITICAL --ignore-unfixed $(SLUG):local

check: lint build ## Contrôle complet avant push
    @echo "✅ Contrôles OK"

ship: check      ## Commit + push (déclenche la CI et le déploiement)
    @test -n "$(M)" || (echo "Usage : make ship M=\"feat: description\"" && exit 1)
    git add -A && git commit -m "$(M)" && git push

logs:            ## Logs du conteneur local
    docker compose -f compose.dev.yaml logs -f

stop:            ## Arrête l'environnement local
    docker compose -f compose.dev.yaml down

clean: stop      ## Nettoyage complet
    docker image rm $(SLUG):local 2>/dev/null || true
