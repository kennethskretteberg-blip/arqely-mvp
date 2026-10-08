# 041 · Presentasjonslenken (`?present=`) havner på dashbordet — RPC-en returnerer en liste, klienten leser den som én rad

**Repo:** `arqely-mvp` · **Fil:** `index.html` (+ evt. `supabase-migration-presentation.sql`) · **Prioritet: Høy** · **Størrelse: liten**
**Meldt av Kenneth 08.10.2026.** Linjenumre fra `2147753` — **symbolnavnene er fasit.**

---

## Kenneths ord

> «Presentasjonsfunksjonen genererer en lenke, men den virker ikke. Jeg kommer rett inn på
> dashbordet og ikke på prosjektet. Kunden skal se det samme som jeg ser når jeg trykker
> Presentasjon.»

## Hva som (mest sannsynlig) skjer

`_presentLoadByToken` (:9231) kaller `rpc('get_present_project', { p_token })` og sjekker
`if (error || !data || !data.data) return false;`. Men migrasjonen (`supabase-migration-presentation.sql`
:27) definerer funksjonen som **`returns table (id uuid, name text, data jsonb)`** — og en
`returns table` kommer tilbake fra supabase-js som en **liste** `[ { id, name, data } ]`. Da er
`data.data` `undefined`, funksjonen returnerer `false`, og `initSupabase` (:≈63890) går videre til
«finnes det en sesjon?» → Kenneth er innlogget → dashbordet. For en kunde uten sesjon ville det
blitt innloggingsskjermen.

Kundelenken (027) ble skrevet riktig: `kundelenke_get` **`returns jsonb`** (én verdi). Det er
samme feil som ble unngått der.

Andre kandidater, hvis STEG 0 motsier dette: migrasjonen er ikke kjørt (RPC finnes ikke →
`error`), `present_token`-kolonnen mangler (lenken lages, men `update` feiler stille), eller
`_restoreProject` kaster på et felt som er nytt siden presentasjonen ble laget.

## STEG 0

1. Åpne en presentasjonslenke i **inkognito** og i innlogget vindu; les konsollen. Forventet:
   «Presentasjon: fant ikke prosjekt for token.» uten `error`-tekst → bekrefter liste-teorien.
   Kommer det en `error` → rapportér den (migrasjon/kolonne).
2. I konsollen: `await _db.rpc('get_present_project', { p_token: '<token>' })` → er `data` en
   array?
3. Finnes andre `rpc(...)`-kall som leser `.data`/`.id` rett av resultatet uten `.single()` eller
   `[0]`? (`grep -n "_db.rpc("`.) List dem.

## Gjør

1. **Klient, robust uansett form:** `const row = Array.isArray(data) ? data[0] : data;` og bruk
   `row.data`/`row.id`. Så virker det både med dagens `returns table` og en framtidig
   `returns jsonb`.
2. **Migrasjon (valgfritt, ryddigst):** ny fil `supabase-migration-presentation-v2.sql` som
   erstatter funksjonen med `returns jsonb` (`select to_jsonb(p) …` eller `jsonb_build_object`),
   samme `security definer`, samme grants — så den ser ut som `kundelenke_get`. Idempotent. Hvis
   STEG 0.1 viste at migrasjonen ikke var kjørt i det hele tatt, er dette den Kenneth skal kjøre.
3. **Lenken:** `_presentShareLink` (:≈9208) bruker `_PUBLIC_BASE_URL` (027) — bekreft. Vis en
   tydelig feil (ikke bare konsoll) hvis `update present_token` feiler: toasten finnes, men
   sjekk at den faktisk vises (den er i `catch`, mens supabase-js returnerer `{error}` uten å kaste).
4. **Innlogget bruker som åpner presentasjonslenken:** skal også se presentasjonen (ikke
   dashbordet), som i dag når `_presentLoadByToken` lykkes. Ingen endring utover punkt 1.
5. Regresjon: `_presentRegressionTest` (finnes den? ellers legg sjekken i
   `_kundelenkeRegressionTest`): mock `rpc` som returnerer array → `_presentLoadByToken` gir `true`.

## Skal IKKE

- Endre hva presentasjonen viser (read-only, `presentPublic`).
- Røre kundelenke-RPC-ene.

## Test

1. Lenken fra Kenneth → inkognito: presentasjonen vises (rom, utlegg, romkort), ingen Del/Avslutt.
   Innlogget: samme.
2. Ugyldig token → innloggingsskjerm (anon) / dashbord (innlogget) som før, med konsollvarsel.
3. STEG 0.3-lista: alle `rpc`-kall leser riktig form.

## Rapport

STEG 0.1–0.3 (konsollteksten, `Array.isArray`-svaret, lista), om migrasjon måtte kjøres.
Endringslogg. Commit: «041: presentasjonslenke — get_present_project returnerer liste; klienten leser første rad (og migrasjon v2 med jsonb)».
