# Spec: Prosjektlås — én redigerende bruker om gangen

**Oppgave 060 · meldt av Kenneth 12.10.2026** (Fredrik begynner i Varmeplan)
**Kode:** `index.html` (seksjonen «060 · PROSJEKTLÅS») + `supabase-migration-prosjektlaas.sql`
**Test:** `_prosjektlaasRegressionTest()` i konsollen (62 sjekker, klientsiden)

---

## Problemet, målt

> «Siden Fredrik nå skal begynne å jobbe i Varmeplan, kan det fort være at vi går inn på
> samme prosjekt samtidig. Kan vi få en sikkerhet på dette?» — Kenneth 12.10.2026

STEG 0.1, to nettleservinduer mot den **ekte** databasen, prosjekt «R-test»:

| Steg | Handling | Databasen etterpå |
|---|---|---|
| 1 | Begge vinduer åpner samme prosjekt | `['Område 1', 'Område 2']` |
| 2 | Vindu **A**: `rooms[0].name = 'A-ENDRET'` → lagre | `['A-ENDRET', 'Område 2']` |
| 3 | Vindu **B**: `rooms[1].name = 'B-ENDRET'` → lagre | `['Område 1', 'B-ENDRET']` ← **A er borte** |

Vindu B sin `data`-blob var bygget **før** A lagret. `_saveToSupabase` gjør
`update(row).eq('id', …)` og bytter **hele** blobben — det finnes ingen versjons- eller
tidssjekk. Autosaven fyrer av seg selv hvert 5. sekund etter en endring, så dette skjer
uten at noen trykker «Lagre». **Ingen feilmelding i noen av vinduene**, og begge
lagre-indikatorene sto på grønt «Lagret».

---

## Reglene

1. **Én redigerende bruker per prosjekt.** Den som åpner først får låsen. Andre får
   prosjektet **skrivebeskyttet**, med beskjed om hvem som er inne og siden når.
2. **Låsen holdes bare så lenge vinduet er aktivt.** Hjerteslag hvert 60. sekund mens
   fanen er synlig. Skjult fane, lukket vindu, eller 30 minutter uten endringer → ingen
   hjerteslag → låsen regnes som **sovende** etter 3 minutter og kan tas av en annen.
   *Et prosjekt som står åpent over natta sperrer altså ingen.*
3. **Å ta over er lov bare når låsen sover.** Den gamle eieren får beskjed i sitt vindu
   neste gang det blir aktivt, og går over til skrivebeskyttet med ulagrede endringer
   bevart lokalt.
4. **Skrivebeskyttet betyr:** ingenting skrives til skyen (autosave, manuell lagring,
   versjonssnapshot, duplisering av *dette* prosjektet). Visning, PDF, Excel, Romoversikt,
   presentasjon og kopiering av lenker virker. Verktøy som endrer prosjektet er deaktivert.
5. **Databasen håndhever det også.** En oppdatering av `data` fra en annen bruker enn
   låseieren avvises på serveren mens låsen er våken. UI-gaten er førstelinje, triggeren
   er sikringen.
6. **Samme bruker, to vinduer** behandles som to brukere (lås per **vindu-økt**), men
   teksten sier «Du har prosjektet åpent i et annet vindu», og «Ta over her» er alltid lov.
7. **Låsen frigis** når brukeren går til prosjektlista, åpner et annet prosjekt, logger ut
   eller lukker fanen.

---

## To lag — og hvorfor begge trengs

```
Vindu B vil skrive
   │
   ├─ 1. UI-gaten (index.html)            ← førstelinje. Den brukeren SER.
   │     _scheduleAutoSave / _performAutoSave / _saveToSupabase /
   │     _createVersionSnapshot / saveProject / _restoreVersion / _duplicateProject
   │     alle returnerer tidlig (eller kaster) når S.ui.readOnly
   │
   └─ 2. Triggeren (databasen)            ← sikringen. Står selv om vinduet
         before update of data                kjører gammel kode.
         raise exception 'PROJECT_LOCKED'
```

UI-gaten alene er ikke nok: et vindu som ble lastet før en deploy kjører gammel kode.
Triggeren alene er ikke nok: den gir en rå feilmelding i stedet for en forklaring, og den
hindrer ikke at brukeren bruker en time på arbeid som aldri kan lagres.

### Fail-open, med vilje
Er migrasjonen ikke kjørt (`project_lock_acquire` finnes ikke → PostgREST `PGRST202`),
eller svarer ikke nettet, settes `_lockDisabled = true` og appen oppfører seg **nøyaktig
som før 060**. En lås som ikke kan leses skal ikke sperre arbeid — da ville en
nettverksblipp blitt en arbeidsstans. Triggeren finnes uansett bare etter at migrasjonen
er kjørt, så de to lagene slås på samtidig.

---

## Datamodellen

Fem kolonner på `romtegner_projects`:

| Kolonne | Hva |
|---|---|
| `locked_by` | `auth.uid()` til den som har låsen |
| `locked_by_name` | Visningsnavn, snapshot fra `profiles.full_name` |
| `locked_at` | «åpnet 14:02» — hopper **ikke** framover ved hvert hjerteslag |
| `lock_seen_at` | Siste hjerteslag → sovende etter 3 min |
| `lock_session` | Tilfeldig uuid **per sidelasting** (regel 6) |

Fire funksjoner: `project_lock_is_stale`, `project_lock_acquire`, `project_lock_heartbeat`,
`project_lock_release`. Alle `security invoker`, så RLS gjelder — bare org-medlemmer kan
låse et prosjekt.

### Hvorfor `stable` og ikke `immutable`
`project_lock_is_stale` leser `now()`. En `immutable` funksjon kan foldes ved
planlegging, og da ville svaret vært regnet ut på et annet tidspunkt enn spørringen
faktisk kjørte på. Prompten sa `immutable`; det er rettet til `stable`.

### Hvorfor `for update` i `acquire`
Uten radlåsen kunne to samtidige forsøk begge lest «fri» og begge skrevet seg inn som eier.

### Hvorfor navnet ikke hentes fra `auth.users`
Den `authenticated`-rollen har ikke tilgang (→ 42501), se RLS-mønsteret i `CLAUDE.md`.
Navnet hentes fra `profiles.full_name`, med `auth.jwt() ->> 'email'` før `@` som fallback,
og «En kollega» til slutt.

### Hjerteslag via triggeren, ikke et eget kall
Prompten åpnet for to løsninger. **Valgt: triggeren.** Den fyrer uansett på hver
`data`-skriving, og den som lagrer er aktiv per definisjon — så den setter
`lock_seen_at = now()` når `locked_by = auth.uid()`. Alternativet (et eget
`project_lock_heartbeat`-kall etter hver vellykkede autosave) ville doblet antall
nettverkskall uten å gi noe ekstra. Ingen rekursjon: triggeren endrer bare `NEW`-raden.

### Hvorfor `OLD` og ikke `NEW` avgjør i triggeren
Det er låsen **som den står** som bestemmer om skrivingen er lov. Satte en tyv
`locked_by` = seg selv i samme UPDATE som `data`, ville `NEW` sett lovlig ut mens `OLD`
fortsatt viser offeret.

### Hva triggeren IKKE rører
- **INSERT** — feltappen (`varmeplan-app/src/db/writeRepo.ts:117`) oppretter prosjekter.
- **Andre kolonner** — `before update of data` fyrer bare når `data` er med i UPDATE-ens
  kolonneliste. Statusendringer og kundelenke-oppdateringer slipper gjennom.
- **`?present=` / `?kunde=`** — anonyme, leser bare, tar aldri en lås.

---

## Hva brukeren ser

**Nummer to inn** får modalen «Prosjektet er opptatt»:
> **Fredrik Hansen** arbeider i **Okkenhaugvegen 20B** — åpnet 11:19, sist aktiv for 22 sek siden.
> `[Åpne skrivebeskyttet]` `[Tilbake til lista]`

«Sist aktiv» tikker live hvert 10. sekund mens modalen står åpen. Sover låsen, kommer
`[Ta over]` i tillegg, med en ravgul forklaring om at ulagrede endringer hos den andre
ikke blir overskrevet. Er det samme bruker, heter modalen «Du har prosjektet åpent i et
annet vindu» og `[Ta over her]` er alltid med.

**Skrivebeskyttet** gir et ravgult banner øverst:
> 🔒 Skrivebeskyttet — **Fredrik Hansen** arbeider i prosjektet (sist aktiv 11:28) `[Prøv igjen]`

Lagre-indikatoren sier «Skrivebeskyttet» i stedet for en grønn prikk. «Prøv igjen» kjøres
også automatisk hvert 60. sekund mens fanen er synlig. Lykkes det, **lastes prosjektet på
nytt fra skyen** — visningens kopi kan være minutter gammel — og toasten sier «Fredrik er
ferdig — prosjektet er ditt. Lastet på nytt.»

**Prosjektlista** viser en grå brikke **🔒 Fredrik** mens han er inne, med fullt navn og
åpnet-tid i tooltipen. Egen lås i et annet vindu: **🔒 Deg (annet vindu)**. En *sovende*
lås gir **intet merke** — da er prosjektet i praksis ledig. Raden er fortsatt klikkbar.

**Mister man låsen** (noen tok over mens fanen var skjult), legges ulagret arbeid i
IndexedDB under nøkkelen `<id>__laast__<tid>` før modalen vises. Den vanlige
gjenopprettingsnøkkelen (`<id>`) røres ikke.

---

## Hvor gatene faktisk ligger

Rangert etter hvor mye de garanterer:

1. **Gaten mot skyen** — `_scheduleAutoSave`, `_performAutoSave`, `_saveToSupabase`
   (kaster), `_createVersionSnapshot`, `saveProject`, `_restoreVersion`,
   `_duplicateProject`, `_wfKundeSave`, `_spiPickCustomer`, `_addBgToFloor`.
   *Ingenting en skrivebeskyttet fane gjør kan nå databasen.*
2. **Triggeren** — serversiden.
3. **Lerret og tastatur** — `canvas mousedown` faller til en ren panorerings-gren (samme
   form som den eksisterende `S.ui.present`-grenen), og `keydown` slipper bare en
   **hviteliste** gjennom: `Escape ? + - = 0` og Ctrl/Cmd-kombinasjoner. Piltastene er
   med vilje utelatt — de flytter valgt objekt.
4. **`body.readonly`** — `pointer-events:none; opacity:.45` på `#ctxbar`, `#ctx-menu`,
   `#rwp-manual-palette`, `#sb-detail-panel`, `#sb-obj-info`, `.sb-hdr`, `#draw-toolbar`,
   `#sb-tree button`, `#chip-tool-mode`, `#chip-transform`, `#chip-undo`, `#btn-save`.
5. **`pushUndo`** — bakstopp. Returnerer `false` og viser en toast.

### ⚠ Hvorfor `pushUndo` er nr. 5 og ikke nr. 1
Prompten foreslo å stoppe muterende snarveier *i* `pushUndo`. **Målt: det holder ikke
alene.** Alle 230 kallstedene kaller `pushUndo()` som en bar setning og ser aldri på
returverdien — mutasjonen på neste linje skjer uansett. Gaten er beholdt fordi den sier
fra og holder angre-stabelen ren for en vei som er oversett, men den er et nett under
de fire lagene over, ikke garantien.

### ⚠ `#sb-hdr` fantes ikke
Første utkast dimmet `#sb-hdr`. Målt i nettleseren: elementet har `sb-hdr` som **klasse**,
ikke id, så «Nytt område» sto fullt klikkbar. Rettet til `.sb-hdr`. En ren kildesjekk
ville ikke funnet dette — CSS-en var «der», den pekte bare på et element som ikke finnes.
Samme måling tok antallet fortsatt-klikkbare mutasjonsknapper i skrivebeskyttet modus fra
**64 til 0**.
