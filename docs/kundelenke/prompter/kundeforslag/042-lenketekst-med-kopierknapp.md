# 042 · Lenketekst med Kopier-knapp: «PRESENTASJON» og «FYLL INN MÅL» som ferdig hyperlenke rett inn i e-posten

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Normal** · **Størrelse: liten**
**Meldt av Kenneth 08.10.2026.** Linjenumre fra `2147753` — **symbolnavnene er fasit.** Krever 041.

---

## Kenneths ord

> «Når jeg skal sende en presentasjon vil jeg ha en fast tekst med lenken som jeg kan kopiere —
> f.eks. PRESENTASJON med kopierknapp bak — og lime inn i e-posten. Kunden trykker på
> PRESENTASJON og får opp presentasjonen.»

## Hva som finnes

- `_presentShareLink` (:9204): lager `present_token`, bygger URL og legger **ren URL** på
  utklippstavla (`navigator.clipboard.writeText`), toast «Delelenke kopiert». Ingen dialog.
- Kundelenke-modalen (027/034, `_kundeCreateLink` :≈7430): viser URL i et felt med «Kopier» (ren
  URL) og «Send på e-post».
- Formatert kopiering (hyperlenke med tekst) krever `ClipboardItem` med både `text/html` og
  `text/plain` — Chrome/Edge/Safari støtter det; Firefox delvis (faller tilbake til ren URL).

## Gjør

### 1. Én felles funksjon

```js
// Legger «TEKST» som hyperlenke på utklippstavla (text/html) + ren URL (text/plain) som fallback.
async function _copyLinkRich(label, url) { … ClipboardItem … ; return 'rich' | 'plain' }
```
Toast: «Lenken «PRESENTASJON» er kopiert — lim inn i e-posten» (rich) eller «Lenken er kopiert
(ren adresse)» (plain).

### 2. Presentasjon: liten dialog i stedet for stille kopiering

`_presentShareLink` → etter at token finnes: modal «Del presentasjon»:
- Linje 1: **PRESENTASJON** (vist som blå understreket hyperlenke) · `[Kopier]` → `_copyLinkRich('PRESENTASJON', url)`.
- Linje 2 (liten, grå): selve URL-en · `[Kopier adresse]` (ren).
- Linje 3: «Åpne» (ny fane, for å sjekke selv) · «Lukk».
- Hjelpetekst: «Lim inn i e-posten — kunden trykker på PRESENTASJON.»
- Teksten «PRESENTASJON» kan redigeres i feltet (standard står) så Kenneth kan skrive
  «Se presentasjonen her» om han vil.

### 3. Kundelenke-modalen: samme mønster

I resultatet etter «Lag lenke» (`#kunde-result`): legg til rad **FYLL INN MÅL** · `[Kopier]`
over dagens URL-rad; e-postknappen uendret (029 sender med knapp i e-posten allerede).

### 4. Hvor lenkene peker

Begge via `_PUBLIC_BASE_URL` (027). Ingen endring.

## Skal IKKE

- Endre e-postfunksjonen eller hva lenkene gjør.
- Fjerne ren-URL-kopieringen (fallback og «Kopier adresse» må finnes).

## Test

1. Presentasjon → Del lenke → modal; Kopier → lim i Gmail/Outlook/Apple Mail → «PRESENTASJON»
   som klikkbar lenke; i et rent tekstfelt (Notater) → URL-en.
2. Rediger teksten til «Se løsningen» → Kopier → lenketeksten følger med.
3. Kundelenke → «FYLL INN MÅL» likedan. Firefox → toast om ren adresse, lim inn gir URL.
4. Regresjon grønn; sjekk at `_copyLinkRich` finnes og brukes begge steder (kildekode-sjekk).

## Rapport

Nettlesere testet, om Firefox-fallbacken slo inn. Endringslogg. Commit: «042: Del presentasjon/kundelenke — ferdig hyperlenketekst (PRESENTASJON / FYLL INN MÅL) med Kopier som formatert tekst + ren URL».
