// Varmeplan service worker (065) — minimal, og ALDRI gammel kode.
//
// Appen endres flere ganger om dagen. En service worker som cachet index.html ville gitt en
// installert bruker gårsdagens versjon. Derfor:
//   - install  → skipWaiting(): ny worker tar over med en gang.
//   - activate → clients.claim() + slett ALLE cacher med annet navn enn vår (vi lager ingen selv).
//   - fetch    → BARE navigasjonsforespørsler (request.mode === 'navigate') håndteres, og alltid
//                nettverk først. Feiler nettet, vises en liten innebygd side — laget her, ikke en
//                cachet kopi av appen. Alt annet (Supabase, tolkemotoren, CDN-skript, fonter, bilder)
//                går urørt forbi: ingen respondWith, ingen caches.put.
//
// Finnes bare for at Edge/Chrome skal regne Varmeplan som installerbar (krever en fetch-handler)
// og for å gi en ærlig «trenger internett»-side i stedet for nettleserens dinosaur.

const SW_VERSION = '065-1';

self.addEventListener('install', () => { self.skipWaiting(); });

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    try {
      const keys = await caches.keys();
      await Promise.all(keys.map((k) => caches.delete(k)));   // vi eier ingen cache — alt som finnes er gammelt
    } catch (e) { /* ingen cache-API: ingenting å rydde */ }
    await self.clients.claim();
  })());
});

const OFFLINE_HTML = `<!DOCTYPE html>
<html lang="nb"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Varmeplan</title>
<style>
  html,body{height:100%;margin:0;background:#0d0e10;color:#eef0f4;font-family:'Space Grotesk',system-ui,sans-serif}
  .boks{min-height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:14px;padding:24px;text-align:center}
  .logo{font-size:30px;font-weight:800;color:#22d3ee;letter-spacing:-.01em}
  p{color:#9097a8;max-width:420px;line-height:1.5;margin:0}
  button{margin-top:8px;background:#22d3ee;color:#0d0e10;border:0;border-radius:8px;padding:11px 24px;font-size:15px;font-weight:600;cursor:pointer}
</style></head>
<body><div class="boks">
  <div class="logo">Varmeplan</div>
  <p>Varmeplan trenger internett. Prosjektene ligger trygt i skyen, men kan ikke åpnes uten nett.</p>
  <button onclick="location.reload()">Prøv igjen</button>
</div></body></html>`;

self.addEventListener('fetch', (event) => {
  if (event.request.mode !== 'navigate') return;          // alt annet: urørt forbi
  event.respondWith((async () => {
    try {
      return await fetch(event.request);                     // nettverk først, alltid
    } catch (e) {
      return new Response(OFFLINE_HTML, { status: 503, headers: { 'Content-Type': 'text/html; charset=utf-8', 'Cache-Control': 'no-store' } });
    }
  })());
});
