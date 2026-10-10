# 055 · Kundedialog-logg: hele historikken med kunden per prosjekt — når presentasjon/målforespørsel gikk ut, når svar kom, hva kunden endret og skrev, hva Cenika gjorde, runde for runde

**Repo:** `arqely-mvp` · **Fil:** `index.html` + liten migrasjon · **Prioritet: Normal** · **Størrelse: middels**
**Meldt av Kenneth 10.10.2026.** Linjenumre fra `e2bb6f4` — **symbolnavnene er fasit.**
**Spec:** `docs/kundelenke/spec-kundelenke.md` (ny regel 11) + `spec-kundeforslag.md` regel 16 (se 000).
**Forutsetning:** 053 (beslutninger per rom ligger i `applied_result` med tidspunkt).

---

## Kenneths ord

> «Jeg ønsker en knapp hvor jeg kan se logg av hele dialogen med meg og kunden: når sendte jeg ut
> presentasjon, når fikk jeg tilbake, hva endret kunden, hva skrev han, mm. Går det flere runder,
> har vi full historikk i denne loggen.»

## Hva som finnes

Nesten alt ligger allerede i `kundelenker` — én rad per lenke, begge moduser:

| Hendelse | Felt i dag | Mangler |
|---|---|---|
| Lenke laget (mål / forslag) | `created_at`, `created_by`, `mode`, `asked_walls`, `note` | — |
| Invitasjon sendt på e-post | `invite_sent_at`, `invite_sent_to` (029/031) | — |
| Lenke **kopiert** til e-post selv (042-dialogen) | **ingenting** — `_presentShareModal` (:10492) og `_copyLinkRich` lagrer ikke | tidspunkt + hvilken tekst |
| Kunden svarte | `answered_at`, `answered_by_name`, `answer` (mål: walls/points; forslag: rooms + comment) | — |
| Kunden godkjente hele prosjektet | `approve_all_at`, `approve_all_name` | — |
| Cenika behandlet | 028: mål innarbeidet → `status='applied'` (uten tidspunkt per vegg); 053: `applied_result[].at/by/resultat` | mål-siden mangler `applied_at`? (STEG 0) |
| Svar sendt til kunden | 053: `svar_sendt_at` | — |
| Lenke trukket | `status='revoked'` (`_kundeRevokeLink` :8826) | tidspunkt |
| Varsel-e-post til Cenika | `last_notified_at` | — |

**Konklusjon:** loggen kan **avledes** av radene. Det som mangler er et sted for hendelser uten
egen kolonne (kopiert, trukket, påminnelse). Ikke en ny tabell: én additiv kolonne.

## STEG 0

1. `kundelenker` for et prosjekt med både mål- og forslagsrunde: list kolonnene over og bekreft
   hvilke som er fylt. Har mål-veien (028) `applied_at`? Hvis ikke — brukes `applied_result` der?
2. Finn hvor 042s Kopier-knapp kalles (`_copyLinkRich` + `_presentShareModal`) og 034s
   «Be kunde om mål»-modal: ett sted per lenke-type å logge «kopiert».
3. `_renderSbProjInfo` (:55098): hvor radene `#spi-kundelenke`, `#spi-kundesvar`, `#spi-forslag`
   står — loggknappen skal inn på samme sted.

## Gjør

### 1. Datamodell: `hendelser jsonb default '[]'`

Migrasjon `supabase-migration-kundelenke-055.sql` (idempotent): `alter table kundelenker add
column if not exists hendelser jsonb not null default '[]'::jsonb;`. Appen **legger til** én
hendelse `{ kind, at, by?, data? }` med `update … set hendelser = hendelser || $1` via en liten
RPC `kundelenke_logg(p_id uuid, p_hendelse jsonb)` (security invoker, RLS gjelder — bare
org-medlemmer) så to vinduer ikke overskriver hverandre. Kinds som skrives av appen:
`kopiert` (data: `{tekst:'PRESENTASJON'|'FYLL INN MÅL'}`), `trukket`, `paaminnelse` (hvis 029 har
«Send påminnelse» — STEG 0), `svar_sendt` (053 kan flytte `svar_sendt_at` hit, eller beholde begge).
Kundens handlinger logges **ikke** her — de står alt i `answer`/`answered_at`.

### 2. `_kundeLoggHent(projectId)` → tidslinje

Henter alle `kundelenker` for prosjektet (alle statuser, også `applied`/`revoked`/`expired`),
sorterer og **flater ut** til hendelser:

```
[runde = én lenke]
  created_at         → «Du laget forslagslenke» / «Du ba om mål for 3 vegger (Stue V2, V3; Bad V1)»
  hendelser.kopiert  → «Du kopierte «PRESENTASJON» til e-post»
  invite_sent_at     → «Invitasjon sendt til ola@firma.no»
  answered_at        → «Ola Nordmann sendte forslag» + liste:
                         «Stue: InFloor 10T 600W → 800W · 92 W/m² · «Varmere ved vinduet»»
                         «Bad: OK som det er»   «Kommentar: «…»»
                       mål: «Vegg 2: 320 → 345 cm», «Hjørne 1 flyttet +50/0», kommentar
  approve_all_at     → «Ola Nordmann godkjente hele prosjektet»
  applied_result[]   → «Du godkjente Stue → ble InFloor 10T 800W · 94 W/m² · CC 10,8» /
                       «Du avslo Bad: «Beholder dagens — gir jevnere varme»»
  svar_sendt_at      → «Du sendte svar til kunden»
  mål applied        → «Du innarbeidet målene»
  hendelser.trukket  → «Du trakk lenken tilbake»
  expires_at < nå    → «Lenken utløp» (bare når status open)
```
Produktnavn via `_forslagProduktNavn`; tall via `_forslagRadTall`-logikken der rommet finnes,
ellers lagrede tall fra `resultat`. Rom som er slettet: navnet fra `roomName`.

### 3. Visning

- **Knapp «Logg»** i prosjektinfo (ved kundelenke-radene, STEG 0.3) og i 053-vinduets tittellinje
  (ikon 🕘). Åpner et **vindu av samme type som 053** (flyttbart, ikke-modalt, høyre side,
  bredde 480).
- Innhold: tidslinje **nyeste øverst**, gruppert per runde med overskrift
  «Runde 2 · Forslag · 9.–10. okt» / «Runde 1 · Mål · 2.–3. okt». Hver hendelse: tidspunkt
  (dd. mmm HH:MM) · ikon (→ ut fra oss, ← inn fra kunde, ✓ godkjent, ✕ avslått) · tekst.
  Kundens kommentarer i kursiv med sitattegn, aldri avkortet under 2000 tegn.
- Klikk på et romnavn i loggen → `S.ui.selectedRoomId`, `fitRoom`, som i 053.
- **«Kopier som tekst»** (ren tekst, kronologisk, til e-post/Visma-notat) og **«Skriv ut»**
  (print av vinduet) nederst.
- 053s rad «✓ Forslag behandlet 10. okt · Se forslaget» i prosjektinfo blir
  «… · **Se logg**» → åpner loggen med den runden utvidet.
- Tomt prosjekt: «Ingen kundedialog ennå — del en presentasjon eller be om mål.»

### 4. Logging av «kopiert»

I 042s Kopier-knapp (`_presentShareModal`) og 034s «Kopier lenke» for mål: etter vellykket
`_copyLinkRich` → `kundelenke_logg(id, {kind:'kopiert', data:{tekst}})`. For presentasjon **uten**
forslagslenke (migrasjon ikke kjørt) logges ikke noe — det finnes ingen rad.

## Skal IKKE

- Lage ny tabell eller endre `kundelenke_get`/`kundelenke_answer` (anonyme veier er urørt).
- Logge for kunden — loggen er intern hos Cenika.
- Vise e-postadresser til kunden i PDF eller presentasjon (loggen er bare i appen).

## Test

1. Prosjekt med mål-runde (027–028) + forslagsrunde (043–044/053): «Logg» viser to runder, nyeste
   øverst, alle hendelsene i tabellen over med riktige tidspunkt og navn.
2. Kopier «PRESENTASJON» → hendelsen «Du kopierte …» dukker opp med klokkeslett. To vinduer
   kopierer samtidig → begge hendelsene finnes (RPC-append).
3. Godkjenn/Avslå i 053 → loggen oppdateres (re-hent ved åpning; ikke live).
4. «Kopier som tekst» gir kronologisk ren tekst med æøå; «Skriv ut» gir lesbar side.
5. Rom slettet etter svar → loggen viser navnet fra `roomName`, uten feil.
6. `_kundelenkeRegressionTest`: `_kundeLoggHent` flater en syntetisk rad med alle felt til riktig
   antall hendelser i riktig rekkefølge; `kopiert` logges fra Kopier-knappen (kildesjekk);
   ingen anonym vei rører `hendelser`.

## Rapport

STEG 0.1–0.3 (hvilke kolonner mål-veien faktisk fyller), om `svar_sendt_at` ble flyttet inn i
`hendelser`, og hva som ikke kunne rekonstrueres for **gamle** runder (før 055). Endringslogg,
`STATUS.md` oppdatert, spec-kundelenke regel 11. Commit: «055: kundedialog-logg — tidslinje per
runde fra kundelenker + hendelser-kolonne, Logg-knapp i prosjektinfo og forslagsvinduet, kopier som
tekst».
