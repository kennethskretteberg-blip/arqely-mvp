# 122 · Navnebytte arqely/lumelo → Varmeplan (web)

Kjørt 22.10.2026. `git remote -v` peker til `varmeplan-web` (sjekket før start). Ikke pushet.

## Hva ble byttet (12 steder i 5 filer)

- **Innstillingene i nettleseren:** `arqely_prefs` heter nå `varmeplan_prefs`, og `lumelo_engine_url`
  heter `varmeplan_engine_url`.
  - Ved oppstart kopieres den gamle verdien over hvis bare den finnes. Den gamle nøkkelen blir stående.
  - Kommentaren i koden sier at kopieringen kan fjernes etter 1.2.2027.
  - Unntak: «Nullstill lagret adresse» fjerner begge motornøklene. Ellers ville den gamle blitt kopiert
    tilbake ved neste oppstart.
- **Navn i koden:**
  - `LUMELO_FLY_URL` → `VARMEPLAN_MOTOR_URL`, og `LUMELO_LOCAL_URL` → `VARMEPLAN_MOTOR_LOCAL_URL`.
  - `window.LUMELO_ENGINE_URL` → `window.VARMEPLAN_ENGINE_URL`. Det gamle navnet leses fortsatt.
  - URL-en `https://lumelo-backend.fly.dev` står urørt.
- **Kommentarer** som nevnte `lumelo-backend`/lumelo som motor sier nå `varmeplan-motor`
  (`index.html`, `sw.js`).
- **`launch.json`** (Windows-oppsettet): `arqely-mvp` → `varmeplan-web` i navn og sti.
- **`docs/kart-lag.md`** (aktivt dokument, CLAUDE.md viser til det): lumelo-mønsteret → tolkemotoren.
- **Ingen synlig tekst måtte endres.** UI, `admin.html`, `manifest.webmanifest`, e-postmalene og
  `CLAUDE.md` sa allerede «Varmeplan».

## Gamle navn som står igjen (søk utenom `docs/`)

| Hvor | Hvorfor |
|---|---|
| `arqely_prefs`, `lumelo_engine_url`, `window.LUMELO_ENGINE_URL` | Den gamle nøkkelen leses for å flytte innstillingene. Fjernes etter 1.2.2027. |
| `https://lumelo-backend.fly.dev` (og statuslinja «Motor: lumelo-backend.fly.dev ✓», som viser adressen) | Motoren kjører der til den flyttes (egen prompt). |
| `arqely_usage`, `arqely_gbao10`, `arqely_recovery` | Flyttet i oppfølgingen (123, se under). De gamle navnene leses bare for å kopiere. |
| `arqely_mat_bench_history` (localStorage) | Bare et utviklerverktøy (matte-benchmark). Ikke flyttet. |
| `arqely.com` i opprinnelsessjekken og i kommentarer om lenker i e-post | Beholdes til domenet sies opp. |
| `noreply@arqely.no` / `invite.arqely.com` i `supabase/functions/kundelenke-mail/README.md` | Avsenderdomenet beholdes til varmeplan.no er satt opp. |
| «-- Arqely —» øverst i 11 gamle `supabase-migration-*.sql` | Kommentarer i migrasjoner som allerede er kjørt. Historikk, ingen endring i Supabase. |
| `.claude/settings.local.json` | Lokale godkjenninger med gamle stier, ikke i git. |

Supabase: ingen tabeller, kolonner, funksjoner eller secrets med gamle navn ble funnet i koden. Det
eneste er avsenderen i README-en over (secret `FROM_EMAIL`).

## Test

- **Nettleseren, med dine ekte innstillinger på localhost:4000.** Før oppdateringen fantes bare
  `arqely_prefs` (mørkt tema, 20 cm avstand) og `lumelo_engine_url` (localhost:8000). Etter
  omlasting var begge kopiert til de nye nøklene, de gamle står fortsatt, og appen bruker mørkt tema,
  20 cm og den lokale motoren.
- **Testbatteriene:** 31 batterier kjørt. 28 er grønne. Tre er røde, og de er røde på nøyaktig samme
  måte med den gamle koden (målt med `git stash`): `_listKalkyleClearRegressionTest`,
  `_matPathClickRegressionTest` og `_prosjektlaasRegressionTest` (E: «Deg (annet vindu)»). De kjøres
  i en presentasjonslenke, der klikk og lås oppfører seg annerledes.

## Må noe gjøres i Vercel, Supabase eller Fly?

Nei. Vercel-prosjektet følger GitHub-repoet. Sjekk likevel at det fortsatt er koblet etter
omdøpingen på GitHub.

## Oppfølging 123 · usage og IndexedDB flyttet (22.10.2026)

- **`arqely_usage` → `varmeplan_usage`:** samme kopiering ved oppstart som prefs. Den gamle nøkkelen
  står igjen.
- **`arqely_gbao10` → `varmeplan_gbao10` og `arqely_recovery` → `varmeplan_recovery`:** én felles
  funksjon, `_idbOpenFlyttet`, håndterer begge.
  - Første gang den nye databasen åpnes, kopieres alt den ikke har fra før over fra den gamle.
  - Et merke i localStorage gjør at det bare skjer én gang. En gjenopprettingskopi som slettes
    senere, kommer derfor ikke tilbake.
  - Den gamle databasen slettes ikke, og den opprettes ikke hvis den ikke fantes.
  - Kan fjernes etter 1.2.2027.
- **Målt i din nettleser:**
  - Gjenopprettingskopien `p-044` (6 KB) er identisk i den nye databasen.
  - Bruksloggen (69 produkter) er kopiert.
  - De gamle databasene og nøklene står igjen.
  - GBAO10-mappevalgene var tomme, så selve mappehåndtakene er ikke testet. De går gjennom samme
    kopiering.
- **Testet på to engangsdatabaser:**
  - Alt ble kopiert.
  - En oppføring som ble slettet i den nye databasen, kom ikke tilbake.
  - En avbrutt kopiering overskrev ikke en nyere verdi.
- **Testbatteriene:** samme resultat som over. 28 er grønne, og de samme tre er røde fra før.
