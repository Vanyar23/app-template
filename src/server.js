import http from 'node:http';

const PORT = Number(process.env.PORT || 3000);
const APP  = process.env.APP_NAME || '__APP_NAME__';

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'content-type': 'application/json' });
    return res.end(JSON.stringify({ status: 'ok', app: APP, uptime: process.uptime() }));
  }
  res.writeHead(200, { 'content-type': 'text/html; charset=utf-8' });
  res.end(`<!doctype html><meta charset="utf-8"><title>${APP}</title>
  <body style="background:#0d0d0d;color:#e6e6e6;font-family:system-ui;padding:3rem">
  <h1>${APP}</h1><p>Application opérationnelle.</p></body>`);
});

// 0.0.0.0 impératif : Traefik doit pouvoir joindre le conteneur
server.listen(PORT, '0.0.0.0', () => console.log(`${APP} écoute sur :${PORT}`));
