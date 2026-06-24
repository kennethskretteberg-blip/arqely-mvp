-- ============================================================================
-- Migrasjon: EL-nummer (el_no) for InSnow utendors-kabler 20T/30T/40T
-- Kjores manuelt i Supabase SQL Editor. Idempotent (trygg a re-kjore).
--
-- Kilde: Cenika-prisliste (Bok1.xlsx), kryssvalidert mot skraping av cenika.no
-- (100% match, 85/85). Kun de 5 seriene som manglet el_no oppdateres;
-- InSnow 30T 230V hadde allerede el_no og rores ikke.
-- Match pa article_no. Skriver kun nar verdien faktisk endres (idempotent).
-- ============================================================================

-- --- InSnow 20T 230V ---
update heating_products set el_no = '1004181' where article_no = 'CVA10340' and el_no is distinct from '1004181';
update heating_products set el_no = '1004182' where article_no = 'CVA10341' and el_no is distinct from '1004182';
update heating_products set el_no = '1004183' where article_no = 'CVA10342' and el_no is distinct from '1004183';
update heating_products set el_no = '1004184' where article_no = 'CVA10343' and el_no is distinct from '1004184';
update heating_products set el_no = '1004185' where article_no = 'CVA10344' and el_no is distinct from '1004185';
update heating_products set el_no = '1004186' where article_no = 'CVA10345' and el_no is distinct from '1004186';
update heating_products set el_no = '1004187' where article_no = 'CVA10346' and el_no is distinct from '1004187';
update heating_products set el_no = '1004188' where article_no = 'CVA10347' and el_no is distinct from '1004188';
update heating_products set el_no = '1004189' where article_no = 'CVA10348' and el_no is distinct from '1004189';
update heating_products set el_no = '1004190' where article_no = 'CVA10349' and el_no is distinct from '1004190';
update heating_products set el_no = '1004191' where article_no = 'CVA10350' and el_no is distinct from '1004191';
update heating_products set el_no = '1004192' where article_no = 'CVA10351' and el_no is distinct from '1004192';
update heating_products set el_no = '1004193' where article_no = 'CVA10352' and el_no is distinct from '1004193';
update heating_products set el_no = '1004194' where article_no = 'CVA10353' and el_no is distinct from '1004194';
update heating_products set el_no = '1004195' where article_no = 'CVA10354' and el_no is distinct from '1004195';
update heating_products set el_no = '1004196' where article_no = 'CVA10355' and el_no is distinct from '1004196';
update heating_products set el_no = '1004197' where article_no = 'CVA10356' and el_no is distinct from '1004197';

-- --- InSnow 20T 400V ---
update heating_products set el_no = '1017939' where article_no = 'CVA10361' and el_no is distinct from '1017939';
update heating_products set el_no = '1017940' where article_no = 'CVA10362' and el_no is distinct from '1017940';
update heating_products set el_no = '1017941' where article_no = 'CVA10363' and el_no is distinct from '1017941';
update heating_products set el_no = '1017942' where article_no = 'CVA10364' and el_no is distinct from '1017942';
update heating_products set el_no = '1017943' where article_no = 'CVA10365' and el_no is distinct from '1017943';
update heating_products set el_no = '1017944' where article_no = 'CVA10366' and el_no is distinct from '1017944';
update heating_products set el_no = '1017945' where article_no = 'CVA10367' and el_no is distinct from '1017945';
update heating_products set el_no = '1017946' where article_no = 'CVA10368' and el_no is distinct from '1017946';
update heating_products set el_no = '1017947' where article_no = 'CVA10369' and el_no is distinct from '1017947';
update heating_products set el_no = '1017948' where article_no = 'CVA10370' and el_no is distinct from '1017948';
update heating_products set el_no = '1017949' where article_no = 'CVA10371' and el_no is distinct from '1017949';
update heating_products set el_no = '1017950' where article_no = 'CVA10372' and el_no is distinct from '1017950';
update heating_products set el_no = '1017951' where article_no = 'CVA10373' and el_no is distinct from '1017951';
update heating_products set el_no = '1017952' where article_no = 'CVA10374' and el_no is distinct from '1017952';
update heating_products set el_no = '1017953' where article_no = 'CVA10375' and el_no is distinct from '1017953';
update heating_products set el_no = '1017954' where article_no = 'CVA10376' and el_no is distinct from '1017954';
update heating_products set el_no = '1017955' where article_no = 'CVA10377' and el_no is distinct from '1017955';

-- --- InSnow 30T 400V ---
update heating_products set el_no = '1020483' where article_no = 'CVA10700' and el_no is distinct from '1020483';
update heating_products set el_no = '1020484' where article_no = 'CVA10701' and el_no is distinct from '1020484';
update heating_products set el_no = '1020485' where article_no = 'CVA10702' and el_no is distinct from '1020485';
update heating_products set el_no = '1020486' where article_no = 'CVA10703' and el_no is distinct from '1020486';
update heating_products set el_no = '1020487' where article_no = 'CVA10704' and el_no is distinct from '1020487';
update heating_products set el_no = '1020488' where article_no = 'CVA10705' and el_no is distinct from '1020488';
update heating_products set el_no = '1020489' where article_no = 'CVA10706' and el_no is distinct from '1020489';
update heating_products set el_no = '1020490' where article_no = 'CVA10707' and el_no is distinct from '1020490';
update heating_products set el_no = '1020491' where article_no = 'CVA10708' and el_no is distinct from '1020491';
update heating_products set el_no = '1020492' where article_no = 'CVA10709' and el_no is distinct from '1020492';
update heating_products set el_no = '1020493' where article_no = 'CVA10710' and el_no is distinct from '1020493';
update heating_products set el_no = '1020494' where article_no = 'CVA10711' and el_no is distinct from '1020494';
update heating_products set el_no = '1020495' where article_no = 'CVA10712' and el_no is distinct from '1020495';
update heating_products set el_no = '1020496' where article_no = 'CVA10713' and el_no is distinct from '1020496';
update heating_products set el_no = '1020497' where article_no = 'CVA10714' and el_no is distinct from '1020497';
update heating_products set el_no = '1020498' where article_no = 'CVA10715' and el_no is distinct from '1020498';
update heating_products set el_no = '1020499' where article_no = 'CVA10716' and el_no is distinct from '1020499';

-- --- InSnow 40T 230V ---
update heating_products set el_no = '1032638' where article_no = 'CVA10720' and el_no is distinct from '1032638';
update heating_products set el_no = '1032639' where article_no = 'CVA10721' and el_no is distinct from '1032639';
update heating_products set el_no = '1032640' where article_no = 'CVA10722' and el_no is distinct from '1032640';
update heating_products set el_no = '1032641' where article_no = 'CVA10723' and el_no is distinct from '1032641';
update heating_products set el_no = '1032642' where article_no = 'CVA10724' and el_no is distinct from '1032642';
update heating_products set el_no = '1032643' where article_no = 'CVA10725' and el_no is distinct from '1032643';
update heating_products set el_no = '1032644' where article_no = 'CVA10726' and el_no is distinct from '1032644';
update heating_products set el_no = '1032645' where article_no = 'CVA10727' and el_no is distinct from '1032645';
update heating_products set el_no = '1032646' where article_no = 'CVA10728' and el_no is distinct from '1032646';
update heating_products set el_no = '1032647' where article_no = 'CVA10729' and el_no is distinct from '1032647';
update heating_products set el_no = '1032648' where article_no = 'CVA10730' and el_no is distinct from '1032648';
update heating_products set el_no = '1032649' where article_no = 'CVA10731' and el_no is distinct from '1032649';
update heating_products set el_no = '1032650' where article_no = 'CVA10732' and el_no is distinct from '1032650';
update heating_products set el_no = '1032651' where article_no = 'CVA10733' and el_no is distinct from '1032651';
update heating_products set el_no = '1032652' where article_no = 'CVA10734' and el_no is distinct from '1032652';
update heating_products set el_no = '1032653' where article_no = 'CVA10735' and el_no is distinct from '1032653';
update heating_products set el_no = '1032654' where article_no = 'CVA10736' and el_no is distinct from '1032654';

-- --- InSnow 40T 400V ---
update heating_products set el_no = '1042646' where article_no = 'CVA10740' and el_no is distinct from '1042646';
update heating_products set el_no = '1042647' where article_no = 'CVA10741' and el_no is distinct from '1042647';
update heating_products set el_no = '1042648' where article_no = 'CVA10742' and el_no is distinct from '1042648';
update heating_products set el_no = '1042649' where article_no = 'CVA10743' and el_no is distinct from '1042649';
update heating_products set el_no = '1042650' where article_no = 'CVA10744' and el_no is distinct from '1042650';
update heating_products set el_no = '1042651' where article_no = 'CVA10745' and el_no is distinct from '1042651';
update heating_products set el_no = '1042652' where article_no = 'CVA10746' and el_no is distinct from '1042652';
update heating_products set el_no = '1042653' where article_no = 'CVA10747' and el_no is distinct from '1042653';
update heating_products set el_no = '1042654' where article_no = 'CVA10748' and el_no is distinct from '1042654';
update heating_products set el_no = '1042655' where article_no = 'CVA10749' and el_no is distinct from '1042655';
update heating_products set el_no = '1042656' where article_no = 'CVA10750' and el_no is distinct from '1042656';
update heating_products set el_no = '1042657' where article_no = 'CVA10751' and el_no is distinct from '1042657';
update heating_products set el_no = '1042658' where article_no = 'CVA10752' and el_no is distinct from '1042658';
update heating_products set el_no = '1042659' where article_no = 'CVA10753' and el_no is distinct from '1042659';
update heating_products set el_no = '1042660' where article_no = 'CVA10754' and el_no is distinct from '1042660';
update heating_products set el_no = '1042661' where article_no = 'CVA10755' and el_no is distinct from '1042661';
update heating_products set el_no = '1042662' where article_no = 'CVA10756' and el_no is distinct from '1042662';

-- --- VERIFISER ---
select
  count(*) filter (where el_no is not null) as med_elno,
  count(*)                                  as totalt_85,
  count(*) filter (where el_no is null)     as mangler_skal_vaere_0
from heating_products where article_no in ('CVA10340','CVA10341','CVA10342','CVA10343','CVA10344','CVA10345','CVA10346','CVA10347','CVA10348','CVA10349','CVA10350','CVA10351','CVA10352','CVA10353','CVA10354','CVA10355','CVA10356','CVA10361','CVA10362','CVA10363','CVA10364','CVA10365','CVA10366','CVA10367','CVA10368','CVA10369','CVA10370','CVA10371','CVA10372','CVA10373','CVA10374','CVA10375','CVA10376','CVA10377','CVA10700','CVA10701','CVA10702','CVA10703','CVA10704','CVA10705','CVA10706','CVA10707','CVA10708','CVA10709','CVA10710','CVA10711','CVA10712','CVA10713','CVA10714','CVA10715','CVA10716','CVA10720','CVA10721','CVA10722','CVA10723','CVA10724','CVA10725','CVA10726','CVA10727','CVA10728','CVA10729','CVA10730','CVA10731','CVA10732','CVA10733','CVA10734','CVA10735','CVA10736','CVA10740','CVA10741','CVA10742','CVA10743','CVA10744','CVA10745','CVA10746','CVA10747','CVA10748','CVA10749','CVA10750','CVA10751','CVA10752','CVA10753','CVA10754','CVA10755','CVA10756');
