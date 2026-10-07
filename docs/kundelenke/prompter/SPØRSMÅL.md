# SPØRSMÅL — serien Kundelenke (027–030)

Claude Code: legg spørsmål under riktig prompt mens du kjører. Skriv hva du **valgte** i mellomtiden,
så Kenneth kan si «ok» eller «endre». Kenneth svarer til slutt.

## Avklart av Kenneth før start (07.10.2026)

- Kunden kan endre mål på **alle** vegger, ikke bare de merkede. Merkede vises først.
- Tegn-modus: **Mål, Polygon, L-form og WBW.** WBW på telefon = pilknapper + talltastatur på skjermen.
- Lenker bruker **varmeplan.no**, ikke arqely.
- Reservekabel (025) er ikke del av denne serien.

## 027

- **Balansesjekken på et FERDIG rom er alltid stille.** Prompten ba om `_roomAxisBalance` tre
  steder, inkludert ctxbar-en for en valgt målelinje. Men et tegnet rom er per definisjon lukket,
  og en lukket form summerer alltid til null — sjekken ville aldri sagt noe der.
  **Valgt:** linja vises i WBW (mens man tegner, åpen kjede) og på kundesiden (kundens tall), ikke
  på et ferdig rom. 028-panelet får den når det bygges. Minst endring, ingen funksjonstap.
- **`wallIdx` = punktindeks.** STEG 0.2 målte at `compWalls(pts)` bygger `walls[i]` av
  `points[i] → points[(i+1)%n]`, og at den kalles på nytt ved hver geometriendring (10 kallsteder).
  Indeksen er stabil og overlever lagring. **Valgt:** `{roomId, wallIdx}` i svaret, ingen egen vegg-id.
- **Ingen ctxbar-gren fantes for målelinjer** — `S.ui.selectedAnnot` hadde bare dra-håndtak.
  **Valgt:** ny ctxbar-gren med «⚠ Usikkert mål»-chip, framfor å bygge en ny høyreklikkmeny.
- **Kundesiden gjenbruker IKKE `_restoreProject`.** Den ville dratt inn produkter, utlegg og
  kundeopplysninger fra prosjektfila. **Valgt:** minimalt `S` bygget fra RPC-svaret — eneste måten
  spec regel 1 faktisk holder.
- **«Send på e-post» står deaktivert** med tooltip til 029 er kjørt, som prompten ba om.

## 028

-

## 029

- Resend: er `varmeplan.no` verifisert som avsenderdomene? Hvis ikke beholdes `noreply@arqely.no`
  som avsender til Kenneth har verifisert — skriv her hva som ble brukt.

## 030

-

## Til senere (ikke i v1 — fra spec)

- Åpen «tegn selv»-side uten prosjekt (f.eks. fra cenika.no). Trenger misbruksvern (rate limit,
  CAPTCHA eller e-postbekreftelse) før den lages.
- Elektriker med egen Varmeplan-konto deler prosjekt mellom organisasjoner.
- Bilder fra kunden i svaret.
