-- ============================================================
-- Arqely — EcoMat legges nå i FORBANDT (Regel 19 revidert)
-- Run in Supabase SQL Editor
-- ============================================================
--
-- spec-matte-kabel-i-skjoten-halv-cc-like-bredder.md DEL C (Kenneth 02.09.2026), bekreftet med
-- ord etter at en tidligere runde målte at koden IKKE hadde noen deterministisk halv-CC-mekanisme
-- («ja, jeg vil ha forbandt for ecomat også — endre regel 19»).
--
-- Regel 19 (spec-matte-utlegg.md, tidligere LÅST) sa: EcoMat = FLUKT, InSnow = FORBANDT. Revidert
-- til: BEGGE legges i FORBANDT (annenhver bredde forskjøvet en halv CC langs lengdeaksen).
--
-- mat_stagger_half_cc er allerede den ENESTE bryteren _matCablePlan (auto) leser for dette — ingen
-- ny mekanisme, kun satt til true på EcoMat-radene. Frihånd (_drawMatPathCable) er utvidet i samme
-- commit til å lese det samme feltet (leste det aldri før — se romtegner.html).

UPDATE heating_products
SET mat_stagger_half_cc = true
WHERE product_family IN ('EcoMat 60T', 'EcoMat 100T', 'EcoMat 150T')
  AND mat_stagger_half_cc IS DISTINCT FROM true;

-- ─── VERIFY ────────────────────────────────────────────────────
SELECT product_family, count(*) AS n, bool_and(mat_stagger_half_cc) AS all_staggered
FROM heating_products
WHERE product_family IN ('EcoMat 60T', 'EcoMat 100T', 'EcoMat 150T')
GROUP BY product_family
ORDER BY product_family;
