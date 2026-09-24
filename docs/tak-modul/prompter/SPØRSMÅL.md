# SPØRSMÅL til Kenneth — samles under kjøringen, besvares til slutt

Skriv ett punkt per spørsmål. Ta med **ditt midlertidige valg** (det du gikk videre med) så Kenneth
bare trenger å si «ok» eller «nei, gjør X».

## Kenneth må gjøre (kan ikke gjøres av Claude Code)

- [ ] **Fly-deploy av `varmeplan-roof`**: `fly auth login` → `fly launch --no-deploy --copy-config
      --name varmeplan-roof` → `fly secrets set ROOF_API_KEY=<lang tilfeldig streng>` → `fly deploy`.
      (Forberedt i 001. Til da kjører alt mot `localhost:4100`.)
- [ ] **App-nøkkel i klienten**: hvor skal nøkkelen ligge? Midlertidig valg i 005: `localStorage`
      `varmeplan_roof_key` (dev) + `window.VARMEPLAN_ROOF_KEY` (deploy). Alternativ: kolonne på
      `organizations` i Supabase så den følger org-en.

## Avklaringer (midlertidig valg står i parentes)

- [x] Bygningsomriss-kilde: **avgjort 24.09** — kun CC BY 4.0: INSPIRE → DOM1-avledet (004) →
      brukeren tegner. OSM (ODbL) brukes ikke. *(Gjenstår: send e-posten til Kartverket om
      INSPIRE-status — utkast i `varmeplan-roof/docs/epost-kartverket-inspire.md` etter 002.)*
- [ ] Ble INSPIRE-WFS verifisert live under 002, eller kjørte testene på syntetisk fixture?
      *(Claude Code fyller ut.)*
- [ ] Standard utsnitt rundt adressen: *(valg: 80 × 80 m, valg 60/80/120 i dialogen)*.
- [ ] Skal eiendomsgrenser tegnes som standard? *(valg: ja, tynn oransje, kan skjules)*.
- [ ] Skal DOM1-hillshade (skyggelagt høydemodell) ligge i kartbildet? *(valg: av som standard,
      bryter i dialogen — det tar 1–3 s ekstra)*.

## Oppdaget underveis

(legg til her)
