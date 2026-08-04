# __APP_NAME__

## Identité de l'application
| Champ | Valeur |
|---|---|
| Slug | `__APP_SLUG__` |
| Port interne | `__APP_PORT__` |
| URL publique | `https://__APP_SLUG__.vanyar.website` |
| Image | `ghcr.io/vanyar23/__APP_SLUG__:latest` |
| Dépôt | `Vanyar23/__APP_SLUG__` |
| Emplacement VPS | `/opt/stacks/__APP_SLUG__/` |

## Structure
```
src/                 code applicatif
Dockerfile           image de production (multi-étapes, non-root, healthcheck)
compose.dev.yaml     exécution locale de développement
deploy/compose.yaml  stack déployé sur le VPS — labels Traefik + dashboard
deploy/.env.example  variables attendues en production
.github/workflows/   CI : lint, build, publication GHCR, scan Trivy
```

## Commandes
- `make dev`     — exécution locale avec rechargement
- `make check`   — lint + build (à passer avant tout push)
- `make ship M="feat: ..."` — contrôles, commit et push (déclenche la CI)

## Contraintes propres à cette application
- Écoute sur `0.0.0.0:$PORT`.
- Expose `/health` qui renvoie `{"status":"ok"}` en 200.
- Pas d'authentification interne : Authelia protège l'application en amont.
  L'utilisateur connecté est lisible dans l'en-tête `Remote-User`,
  ses groupes dans `Remote-Groups` (séparés par des virgules).
- Toute nouvelle variable d'environnement doit être ajoutée à `deploy/.env.example`
  **et** au bloc `environment:` de `deploy/compose.yaml`.
- Toute modification du port ou du nom d'affichage impose de mettre à jour les labels
  `traefik.http.services.*.loadbalancer.server.port` et `vanyar.dashboard.*`.

## Déploiement (rappel, exécuté sur le VPS, pas ici)
1. `git push` → la CI construit et publie `ghcr.io/vanyar23/__APP_SLUG__:latest`
2. Sur le VPS : `sudo /opt/vps-infra/scripts/add-app.sh __APP_SLUG__` (première fois)
3. Les mises à jour suivantes sont tirées automatiquement par `vps-sync.timer`
