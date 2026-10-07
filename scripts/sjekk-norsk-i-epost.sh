#!/usr/bin/env bash
# ============================================================================
# 031: all tekst som sendes til en mottaker skal skrives med æ, ø og å.
#
# Bakgrunn: ASCII-regelen i docs/kundelenke/prompter/000-KJØR-MEG.md gjelder
# SQL-KOMMENTARER (de limes inn i Supabase SQL Editor). Den ble feilaktig dratt
# over på e-posttekst i 029, så kunden fikk «Apne lenken under, sa ser du
# tegningen og kan rette maalene». Fila var UTF-8 hele tiden — tankestreken «—»
# kom riktig fram — så det var aldri et tegnsett-problem, bare feil ordvalg.
#
# Kjør:  bash scripts/sjekk-norsk-i-epost.sh
# Exit 1 hvis noe er skrevet med ASCII-erstatninger utenfor kommentarer.
# ============================================================================
set -u
cd "$(dirname "$0")/.."

MONSTER='(^|[^a-zA-Z])(maal|gaar|paa|aa|saa|naar|ogsaa|foer|oensk|vere|apne|Apne|aapen|noedv|hoey|loes|stoer|toem|gjoer|foelg|soek|noekkel)([^a-zA-Z]|$)'
feil=0

for f in supabase/functions/*/index.ts; do
  # Kommentarlinjer er greit — de leses ikke av noen mottaker.
  treff=$(grep -nE "$MONSTER" "$f" | grep -vE '^[0-9]+:[[:space:]]*(//|\*|/\*)')
  if [ -n "$treff" ]; then
    echo "✗ $f"
    echo "$treff" | sed 's/^/    /' | cut -c1-140
    feil=1
  fi
done

# Hver HTML-e-post mangler <head>; da må <meta charset> stå i selve kroppen,
# ellers gjetter noen e-postklienter på tegnsettet.
for f in supabase/functions/*/index.ts; do
  grep -q 'html' "$f" || continue
  if ! grep -q 'meta charset="utf-8"' "$f"; then
    echo "✗ $f mangler <meta charset=\"utf-8\"> i e-post-HTML-en"; feil=1
  fi
  if ! grep -q 'application/json; charset=utf-8' "$f"; then
    echo "✗ $f sender til Resend uten charset=utf-8"; feil=1
  fi
done

# ASCII-regelen gjelder SQL-kommentarer i KUNDELENKE-serien (000-KJØR-MEG.md).
# ⚠ Målt 07.10.2026: 24 av 26 supabase-migration-*.sql inneholder allerede æøå og har kjørt
# fint i SQL Editor. Regelen er altså en konvensjon for denne serien, ikke repoets praksis —
# derfor sjekkes bare kundelenke-filene, ellers ville skriptet flagget 24 filer som virker.
for f in supabase-migration-kundelenke*.sql; do
  [ -e "$f" ] || continue
  if LC_ALL=C grep -qn '[^ -~]' "$f"; then
    echo "✗ $f inneholder ikke-ASCII — kundelenke-seriens SQL skal være ren ASCII"; feil=1
  fi
done

if [ "$feil" -eq 0 ]; then
  echo "✓ E-posttekst bruker æøå, charset er satt, og SQL-filene er ren ASCII."
fi
exit "$feil"
