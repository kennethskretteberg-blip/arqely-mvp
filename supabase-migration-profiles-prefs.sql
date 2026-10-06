-- 023 (Kenneth 06.10.2026): egne standardverdier per bruker for avstand mellom varmefolier
-- og avstand til vegg. ADDITIV og idempotent — kan kjøres flere ganger uten skade.
--
-- Verdiene er FRO for NYE rom. De rorer aldri rom som allerede har utlegg, og de kan bare OKE
-- avstanden over produktets minimum (handheves i klienten, _effectiveMarginCm/_effectiveGapCm).
--
-- Form: {"foilGapCm": 2.0, "wallMarginCm": 2.5}  — begge kan vaere null (ingen preferanse).

alter table public.profiles
  add column if not exists prefs jsonb not null default '{}'::jsonb;

comment on column public.profiles.prefs is
  '023: brukerens prosjekteringsvalg, f.eks. {"foilGapCm":2.0,"wallMarginCm":2.5}. Fro for nye rom.';

-- RLS: brukeren maa kunne oppdatere sin EGEN rad. Policyen finnes sannsynligvis fra for
-- (profilen skriver allerede full_name/initials), men opprettes her hvis den mangler.
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles'
      and cmd = 'UPDATE' and qual like '%auth.uid()%'
  ) then
    create policy "profiles_update_own" on public.profiles
      for update using (auth.uid() = id) with check (auth.uid() = id);
  end if;
end $$;
