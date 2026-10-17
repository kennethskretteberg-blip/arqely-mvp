# 065 · Varmeplan som installerbar app på Windows (PWA): manifest, ikon i Varmeplan-stil, minimal service worker, «Installer Varmeplan»-knapp

**Repo:** `arqely-mvp` · **Filer:** `index.html`, nye `manifest.webmanifest`, `sw.js`, `icons/`, `vercel.json` · **Prioritet: Normal** · **Størrelse: liten–middels**
**Meldt av Kenneth 12.10.2026.** Linjenumre fra `4d9422c` (gamle) — **symbolnavnene er fasit**, finn dem på nytt i `main` (`cd72f0e` eller nyere). **Ikke push.**

---

## Kenneths ord

> «Jeg ønsker å lage Varmeplan-appen som en desktop-app på Windows-PC.» — Valgt: installerbar
> nettapp (PWA) fremfor .exe. «Ikke Cenika-ikon eller farger — kjør Varmeplan-ikon og farger.»

## Hvorfor PWA (kort, for endringsloggen)

Edge og Chrome på Windows kan installere en nettside som app: eget vindu uten adresselinje, ikon
på skrivebord/oppgavelinje/Start-meny, egen oppføring i «Apper» i Windows. Appen er fortsatt
`varmeplan.no` — hver deploy er ute neste gang den åpnes, ingen installasjonsfil, ingen
kodesignering. En .exe (Electron/Tauri) er utsatt til det finnes et behov en nettside ikke dekker.

## Hva som finnes

| | I dag |
|---|---|
| Ikon | **Ingen.** Ingen `<link rel="icon">`, ingen favicon, ingen bildefiler i repoet. Fanen viser nettleserens standardikon |
| Varmeplan-identitet | Ordmerket «Varmeplan» i `Space Grotesk` 800, farge `--accent` (`.np-logo` :41, `.tb-logo` :418). Mørkt tema: `--bg #0d0e10`, `--surface #141517`, `--accent #22d3ee`, `--accent2 #47b4ff`. Lyst tema: `--bg #f0f4f8`, `--accent #0891b2` (:15–:27) |
| Manifest / service worker | Finnes ikke (`grep manifest\|serviceWorker` → 0) |
| Hosting | Vercel, `vercel.json` har bare én redirect. Lokalt `serve-varmeplan.js` |
| Org-branding | Org-logo i PDF og topplinje (`_orgBranding`-veien, :60787, :66033). **Ikke** brukt i app-ikonet — ikonet er Varmeplans, likt for alle |

## STEG 0

1. Finnes `package.json` eller annen Node-verktøykjede i repoet? (Nei ved `4d9422c` — da skal
   PNG-ene genereres med et engangsverktøy via `npx`, og bare resultatfilene committes.)
2. Hvordan svarer Vercel i dag på en ukjent sti (`/sw.js` før fila finnes) — 404 eller
   `index.html`? Viktig for at en gammel cache ikke skal kunne «se» en side som sw.
3. Hvilke boot-stier har appen (`?present=`, `?present=&forslag=`, `?kunde=`, `?invite=`,
   e-postlenker til prosjekt)? List dem — install-knappen skal aldri vises på kundens sider.

## Gjør

### 1. Ikonet (Varmeplan, ikke Cenika)

Én SVG-kilde `icons/varmeplan.svg`, 512 × 512, **ingen tekst-elementer** (alt som stier, så den
ikke er avhengig av fonter):

- Bakgrunn: avrundet kvadrat, hjørneradius 112, fyll `#0d0e10`, 1 px-ish kant `#252830`
  (`--border`) — skal se riktig ut på både lys og mørk oppgavelinje.
- Motiv: en tykk **«V»** i `#22d3ee` (`--accent`), geometrisk som Space Grotesk 800 (rette ben,
  flat bunn-spiss ikke spiss nål), som fyller ca. 60 % av høyden, sentrert litt over midten.
- Under V-en: en **varmekabel i slynge** (tre-fire U-svinger, `stroke #22d3ee`, linjebredde ca.
  18, runde ender, `opacity 0.55`) — gjenkjennelig som gulvvarme, men underordnet V-en.
- Maskerbar variant `icons/varmeplan-maskable.svg`: samme motiv skalert til 80 % innenfor
  «trygg sone» (sirkel med radius 40 % av bredden), bakgrunnen fyller hele flaten uten avrunding.

Generer (engangs, `npx --yes @resvg/resvg-js-cli` eller tilsvarende — ikke legg til `package.json`):
`icons/icon-192.png`, `icon-512.png`, `icon-maskable-512.png`, `apple-touch-icon.png` (180),
`favicon-32.png`, `favicon-16.png`, og `favicon.ico` (16+32). Lag `docs/pwa/ikon-forhandsvisning.html`
som viser alle størrelsene på lys og mørk bakgrunn, og et simulert Windows-oppgavelinje-utsnitt
(32 og 48 px) — Kenneth ser på den før deploy. Si i rapporten hvordan 16 px-versjonen ser ut (V-en
skal være lesbar; slyngen kan droppes i 16/32 hvis den blir grøt — lag i så fall en forenklet
`favicon.svg` uten slynge).

### 2. `manifest.webmanifest`

```json
{
  "name": "Varmeplan",
  "short_name": "Varmeplan",
  "description": "Prosjektering av elektrisk varme",
  "id": "/",
  "start_url": "/?kilde=app",
  "scope": "/",
  "display": "standalone",
  "display_override": ["window-controls-overlay", "standalone"],
  "background_color": "#0d0e10",
  "theme_color": "#0d0e10",
  "lang": "nb",
  "launch_handler": { "client_mode": "focus-existing" },
  "icons": [ 192, 512, maskable 512 (purpose "maskable"), favicon.svg (purpose "any") ]
}
```
- `launch_handler: focus-existing` — åpner man Varmeplan to ganger, fokuseres vinduet som alt er
  åpent i stedet for å lage et nytt. Det demper 060-tilfellet «du har prosjektet åpent i et annet
  vindu».
- `?kilde=app` bare for at appen kan vite at den kjører installert (se §4); den skal ikke endre noe
  annet. Fjernes fra adressen med `history.replaceState` ved oppstart.
- **`window-controls-overlay`:** prøv. Gir appens egen topplinje opp i tittellinja (som Teams/VS
  Code). Fungerer det dårlig med `#topbar`/`tb-logo` (dra-område, knapper under Windows-knappene),
  dropp den og bruk bare `standalone` — si hva du valgte.

### 3. `<head>` i index.html (og `admin.html`)

`<link rel="manifest">`, `<link rel="icon">` (svg + png 32), `<link rel="apple-touch-icon">`,
`<meta name="theme-color" content="#0d0e10" media="(prefers-color-scheme: dark)">` og
`content="#f0f4f8"` for lys. Når brukeren bytter til lyst tema i appen (`body.light-theme`),
oppdater `theme-color` live, så tittellinja i det installerte vinduet følger temaet.

### 4. `sw.js` — minimal, og **aldri** gammel kode

Appen endres flere ganger om dagen. En service worker som cacher `index.html` ville gitt Fredrik
gårsdagens versjon. Derfor:
- `install` → `skipWaiting()`; `activate` → `clients.claim()` + slett alle cacher med annet navn.
- `fetch`: **bare** navigasjonsforespørsler (`request.mode === 'navigate'`) håndteres —
  nettverk først, alltid; ved nettverksfeil vises en liten innebygd side «Varmeplan trenger
  internett — prøv igjen» (laget i sw.js, ikke en cachet kopi av appen). Alt annet (Supabase,
  lumelo, CDN-skript, fonter) går urørt forbi — ingen `respondWith`.
- Registrering i index.html etter `load`, kun på `https:` eller `localhost`, og **ikke** i
  kundemodus/presentasjon (STEG 0.3) — der er det ingen grunn til å installere noe hos kunden.
- `vercel.json`: `headers` for `/sw.js` → `Cache-Control: no-cache` og `Service-Worker-Allowed: /`;
  `/manifest.webmanifest` → `Content-Type: application/manifest+json`.

### 5. «Installer Varmeplan»-knapp

- Fang `beforeinstallprompt` (`e.preventDefault()`, lagre hendelsen). Når den finnes: vis en knapp
  **«⬇ Installer Varmeplan»** i brukermenyen (avatar-menyen øverst til høyre / `_updateAuthUserBar`)
  og en diskret engangslinje på dashbordet: «Varmeplan kan installeres som app på denne PC-en ·
  Installer · Ikke nå» (husk «Ikke nå» i `localStorage` med try/catch).
- Klikk → `prompt()`; `appinstalled` → skjul begge, toast «Varmeplan er installert — finn den i
  Start-menyen».
- Kjører appen alt installert (`matchMedia('(display-mode: standalone)')` eller
  `window-controls-overlay`) → ingen knapp.
- Ingen knapp i kundemodus/presentasjon/`?invite=`-flyten.
- Nettlesere uten `beforeinstallprompt` (Firefox, Safari): ingen knapp, ingen feilmelding.

### 6. Instruks til brukerne

`docs/pwa/INSTALLER.md`, tre linjer som Kenneth kan lime i en e-post til Fredrik:
1. Åpne **varmeplan.no** i Microsoft Edge eller Chrome og logg inn.
2. Klikk **«Installer Varmeplan»** (i menyen øverst til høyre), eller ⊕-ikonet i adresselinja.
3. Varmeplan ligger nå i Start-menyen og kan festes til oppgavelinja (høyreklikk → Fest).

## Skal IKKE

- Cache `index.html`, JS eller data i service workeren (se §4).
- Bruke Cenika-logo/-farger eller org-branding i ikon/manifest.
- Endre appens oppførsel i nettleser for den som ikke installerer.
- Lage Electron/Tauri/.exe.
- Legge til `package.json` eller byggesteg for å lage ikonene.

## Test

1. Lokalt (`serve-varmeplan.js` på localhost) og etter deploy: Chrome/Edge DevTools → Application
   → Manifest: ingen feil, ikonene vises, «Installable». Lighthouse PWA-installerbarhet grønn.
2. Edge på Windows: knappen «Installer Varmeplan» vises → installer → eget vindu, ikon i
   Start-meny og oppgavelinje, tittellinja mørk (og lys når appen står i lyst tema). Logg inn
   består etter lukk/åpne.
3. Deploy en synlig endring → åpne den installerte appen → endringen er der **uten** omstart av
   PC eller avinstallering (nettverk først).
4. Slå av nettet → åpne appen → «Varmeplan trenger internett»-siden, ikke en hvit side og ikke en
   gammel versjon.
5. `?present=…` og `?kunde=…` i vanlig nettleser: ingen install-knapp, ingen service worker
   registrert (DevTools → Application → Service Workers tom for den økten), siden virker som før.
6. Åpne Varmeplan fra Start-menyen to ganger → samme vindu fokuseres (launch_handler).
7. Regresjon grønn; ny `_pwaRegressionTest`: manifest-lenken finnes i `<head>`, sw-registreringen
   er gatet på kundemodus/presentasjon (kildesjekk), `sw.js` inneholder ingen `caches.put` for
   annet enn sin egen offline-side.

## Rapport

STEG 0.1–0.3, om `window-controls-overlay` ble beholdt, hvordan 16/32 px-ikonet ble, og lenke til
`docs/pwa/ikon-forhandsvisning.html`. Endringslogg. Commit: «065: Varmeplan som installerbar app —
manifest, Varmeplan-ikon (V + kabelslynge), nettverk-først service worker, Installer-knapp,
instruks».
