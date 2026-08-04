# syntax=docker/dockerfile:1

# ---------- Étape de build ----------
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

# ---------- Étape d'exécution ----------
FROM node:22-alpine AS runtime
ENV NODE_ENV=production \
    PORT=3000
WORKDIR /app

# Exécution sans privilèges
RUN addgroup -S app && adduser -S -G app app
COPY --from=build --chown=app:app /app /app
USER app

EXPOSE 3000

# Le healthcheck est utilisé par le MainDashboard pour afficher l'état réel
# hadolint ignore=DL3025
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -q --spider "http://127.0.0.1:${PORT}/health" || exit 1

CMD ["node", "src/server.js"]
