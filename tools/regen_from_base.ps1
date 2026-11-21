# Literacy overhaul - regenerate the REPLACE_OR_CREATE overrides from the CURRENT vanilla files.
# Each block = the current base definition with ONLY its literacy lines (and, for the university, our listed
# fields) swapped. If an anchor is missing (base changed), that block is SKIPPED with a warning and the base
# definition is used - nothing stale gets shipped. Run after every EU5 patch:
#   powershell -ExecutionPolicy Bypass -File tools\regen_from_base.ps1
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$mod  = Split-Path -Parent $here
$game = 'c:\Program Files (x86)\Steam\steamapps\common\Europa Universalis V\game'
$rsf  = 'c:\Program Files (x86)\Steam\steamapps\workshop\content\3450310\3608237308'   # RSF (for its Orthodox TRY_REPLACE)
$utf8bom = New-Object System.Text.UTF8Encoding($true)

function Get-Block([string]$t, [string]$key) {        # top-level "key = { ... }" by brace matching
    $m = [regex]::Match($t, '(?m)^' + [regex]::Escape($key) + '\s*=\s*\{')
    if (-not $m.Success) { return $null }
    $i = $m.Index + $m.Length; $d = 1
    while ($i -lt $t.Length -and $d -gt 0) { $c = $t[$i]; if ($c -eq '{') { $d++ } elseif ($c -eq '}') { $d-- }; $i++ }
    if ($d -ne 0) { return $null }
    return $t.Substring($m.Index, $i - $m.Index)
}
# class-stratified literacy lines: upper = nobles/clergy/burghers, lower = laborers/soldiers/peasants
function Strat([string]$ind, [string]$scope, $up, $low) {
    $l = @()
    foreach ($c in 'nobles','clergy','burghers') { $l += "$ind${scope}_${c}_max_literacy = $up" }
    if ($null -ne $low) { foreach ($c in 'laborers','soldiers','peasants') { $l += "$ind${scope}_${c}_max_literacy = $low" } }
    return ($l -join "`n")
}
$T1 = "`t"; $T2 = "`t`t"; $T3 = "`t`t`t"

# ---------- university site rules: ONE place for the numbers ----------
# used by the university building allow (explicit lines, for a per-condition tooltip) and by the scripted
# trigger lo_university_site (parliament issue sponsor_a_university - may only sponsor where we could build).
$UNI_DEV = 30; $UNI_CLERGY = 85; $UNI_BURGHERS = 25

# Each target: source file, key, list of (regex -> replacement). Every regex must match exactly once.
$targets = @(
  # ---------- advances (Flavorium) ----------
  @{ f='advances\0_age_of_traditions.txt'; k='written_alphabet'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', "${T1}global_max_literacy = 2`t# LO: 5 -> 2 (Flavorium)") ) },
  @{ f='advances\0_age_of_discovery.txt'; k='printing_press_advance'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 10[ \t]*\r?$', ("${T1}# LO: global 10 -> upper classes 5 (Flavorium)`n" + (Strat $T1 'global' 5 $null))) ) },
  @{ f='advances\4_choices_adm.txt'; k='innovativeness'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', ("${T1}# LO: global 5 -> upper classes 5 (Flavorium)`n" + (Strat $T1 'global' 5 $null))) ) },
  @{ f='advances\country_nov.txt'; k='birch_bark_manuscript'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 2\.5[ \t]*\r?\n\tglobal_burghers_max_literacy = 10[ \t]*\r?$', ("${T1}# LO: all 2.5 + burghers 10 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T1 'global' 5 2))) ) },
  @{ f='advances\country_chi.txt'; k='baihua'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', ("${T1}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T1 'global' 5 2))) ) },
  @{ f='advances\culture_group_romanian.txt'; k='romanian_the_letter_of_neacsu'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', ("${T1}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T1 'global' 5 2))) ) },
  @{ f='advances\culture_sicilian.txt'; k='sic_studium_generale'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', ("${T1}# LO: 5 -> upper 5 / lower 3 (Flavorium)`n" + (Strat $T1 'global' 5 3))) ) },
  @{ f='advances\culture_emilian.txt'; k='fer_studio_di_ferrara'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 10[ \t]*\r?$', ("${T1}# LO: 10 -> upper 8 / lower 3 (Flavorium)`n" + (Strat $T1 'global' 8 3))) ) },
  @{ f='advances\culture_venetian.txt'; k='ven_state_inquisition'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', ("${T1}# LO: 5 -> upper 5 / lower 3 (Flavorium)`n" + (Strat $T1 'global' 5 3))) ) },
  # ---------- Orthodox clergy rebalance (ours, 2026-11-20) ----------
  # Rus' parish clergy were barely literate until the Stoglav council (1551). Orthodox keeps clergy +5 in its
  # definition (vs Catholic 25); the early advance and the monastery are halved; Russians get clergy +10 from
  # lo_stoglav (age 4). With the patriarchate tenet (christological debates) Greeks pass the university clergy
  # threshold in age 3, Rus' in age 4.
  @{ f='advances\religion_orthodox.txt'; k='anagignoskomena'; out='advances'
     e=@( ,@('(?m)^\tglobal_clergy_max_literacy = 10[ \t]*\r?$', "${T1}global_clergy_max_literacy = 5`t# LO: 10 -> 5 (Orthodox clergy rebalance)") ) },
  @{ f='building_types\religion_buildings.txt'; k='orthodox_monastery'; out='building_types'
     e=@( ,@('(?m)^\t\tlocal_clergy_max_literacy = 10[ \t]*\r?$', "${T2}local_clergy_max_literacy = 5`t# LO: 10 -> 5 (Orthodox clergy rebalance)") ) },
  # ---------- buildings ----------
  @{ f='building_types\culture_buildings.txt'; k='library'; out='building_types'
     e=@( ,@('(?m)^\t\tlocal_max_literacy = 5[ \t]*\r?\n\t\tlocal_monthly_literacy = 0\.1[ \t]*\r?$',
             "${T2}# LO: all 5 -> nobles 3 / clergy 3 / burghers 2, monthly 0.1 -> 0.03 (Flavorium)`n${T2}local_nobles_max_literacy = 3`n${T2}local_clergy_max_literacy = 3`n${T2}local_burghers_max_literacy = 2`n${T2}local_monthly_literacy = 0.03") ) },
  @{ f='building_types\culture_buildings.txt'; k='confucian_school'; out='building_types'
     e=@( ,@('(?m)^\t\tlocal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T2 'local' 5 2))) ) },
  @{ f='building_types\culture_buildings.txt'; k='university'; out='building_types'
     e=@(
       # town = yes kept (base): many historical universities sat in small towns (Oxford, Cambridge, Salamanca,
       # Coimbra, Tuebingen, Wittenberg); dev >= 30 + clergy/burgher literacy prevent spam. (town = no removed
       # 2026-11-20: it made 11 setup universities invalid.)
       @('(?m)^(\t\tis_core_of = owner)[ \t]*\r?$', "`$1`n${T2}# LO: developed city with literate clergy (cathedral schools) and burghers (educated laity)`n${T2}development >= $UNI_DEV`n${T2}any_pop = { pop_type = pop_type:clergy   pop_literacy > $UNI_CLERGY }`n${T2}any_pop = { pop_type = pop_type:burghers pop_literacy > $UNI_BURGHERS }"),
       @('(?m)^\t\tlocal_cultural_influence = 0\.5[ \t]*\r?$', "${T2}local_cultural_influence = 0.75`t# LO: 0.5 -> 0.75"),
       @('(?m)^\t\tlocal_burghers_max_literacy = 10[ \t]*\r?\n\t\tlocal_nobles_max_literacy = 10[ \t]*\r?$', "${T2}local_burghers_max_literacy = 10`t# LO: base 10 (was 15 in v0.1-0.2)`n${T2}local_nobles_max_literacy = 10`t# LO: base 10 (was 15 in v0.1-0.2)`n${T2}local_clergy_max_literacy = 10`t# LO: new"),
       # local_monthly_literacy: base 0.1 kept (0.25 = wonder tier, e.g. Bibliotheca Corviniana / Globe Theatre)
       @('(?m)^\t\tlocal_pop_promotion_speed = 0\.001[ \t]*\r?$', "${T2}local_pop_promotion_speed = 0.002`t# LO: x2"),
       @('(?m)^\t\tlocal_institution_growth_modifier = 0\.33[ \t]*\r?$', "${T2}local_institution_growth_modifier = 0.66`t# LO: x2"),
       @('(?m)^\t\tpaper = 0\.5[ \t]*\r?\n\t\tbooks = 0\.25[ \t]*\r?\n\t\tglass = 0\.25[ \t]*\r?\n\t\tbeeswax = 0\.05[ \t]*\r?$', "${T2}paper = 1.0`t# LO: maintenance x2`n${T2}books = 0.5`n${T2}glass = 0.5`n${T2}beeswax = 0.1"),
       @('(?m)^\tconstruction_demand = university_construction[ \t]*\r?$', "${T1}construction_demand = lo_university_construction`t# LO: ~x2 cost + glass (goods_demand/lo_university_cost.txt)"),
       # REPLACE_OR_CREATE re-registers unique production methods -> "duplicated production method name" error
       # with the base name, so our university maintenance gets its own name (loc in literacy_overhaul_l_english.yml)
       @('(?m)^(\t\t)university_maintenance = \{', "`${1}lo_university_maintenance = {`t# LO: unique name (base one is already registered)")
     ) },
  # ---------- privileges / reforms / laws ----------
  @{ f='estate_privileges\clergy_estate.txt'; k='freedom_of_interpretation'; out='estate_privileges'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T2 'global' 5 2))) ) },
  @{ f='government_reforms\common.txt'; k='the_education_act'; out='government_reforms'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T2 'global' 5 2))) ) },
  @{ f='laws\01_common.txt'; k='education_masses_law'; out='laws'
     e=@( @('(?m)^\t\t\tglobal_laborers_max_literacy = 5[ \t]*\r?\n\t\t\tglobal_soldiers_max_literacy = 5[ \t]*\r?\n\t\t\tglobal_peasants_max_literacy = 5[ \t]*\r?$',
             "${T3}# LO: basic_religious_education lower classes 5 -> 2 (Flavorium)`n${T3}global_laborers_max_literacy = 2`n${T3}global_soldiers_max_literacy = 2`n${T3}global_peasants_max_literacy = 2"),
       # LO (lower-class pass): theocratic_education lower 5 -> 2, like basic_religious_education (Flavorium missed it)
       @('(?s)(theocratic_education = \{.*?)global_peasants_max_literacy = 5([ \t]*\r?\n[ \t]*)global_soldiers_max_literacy = 5([ \t]*\r?\n[ \t]*)global_laborers_max_literacy = 5',
         '${1}global_peasants_max_literacy = 2${2}global_soldiers_max_literacy = 2${3}global_laborers_max_literacy = 2	# LO: theocratic lower 5 -> 2'),
       # LO: vedic_education = Brahmanical pathshala system: clergy 15 / nobles + burghers 5 / lower 2 (better than basic for clergy)
       @('(?m)^\t\t\tglobal_max_literacy = 5[ \t]*\r?$', "${T3}# LO: vedic all 5 -> clergy 15 / nobles + burghers 5 / lower 2 (Brahmin pathshalas)`n${T3}global_clergy_max_literacy = 15`n${T3}global_nobles_max_literacy = 5`n${T3}global_burghers_max_literacy = 5`n${T3}global_laborers_max_literacy = 2`n${T3}global_soldiers_max_literacy = 2`n${T3}global_peasants_max_literacy = 2")
     ) },
  # ---------- lower-class pass (ours, 2026-11-20): flat "all classes" bonuses that are really elite phenomena ----------
  @{ f='advances\0_age_of_absolutism.txt'; k='scientific_revolution_advance'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 10[ \t]*\r?$', ("${T1}# LO: all 10 -> upper 10 / lower 2 (science is an elite phenomenon)`n" + (Strat $T1 'global' 10 2))) ) },
  @{ f='advances\4_choices_adm.txt'; k='humanism'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 10[ \t]*\r?$', ("${T1}# LO: all 10 -> upper 10 only (humanism = culture of the educated)`n" + (Strat $T1 'global' 10 $null))) ) },
  @{ f='advances\0_age_of_revolutions.txt'; k='enlightened_court'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', ("${T1}# LO: all 5 -> upper 5 / lower 2`n" + (Strat $T1 'global' 5 2))) ) },
  @{ f='laws\01_common.txt'; k='press_law'; out='laws'
     e=@( ,@('(?m)^\t\t\tglobal_max_literacy = 10[ \t]*\r?$', ("${T3}# LO: free_press all 10 -> upper 10 / laborers+soldiers 5 / peasants 3 (newspapers were read in towns)`n" + (Strat $T3 'global' 10 $null) + "`n${T3}global_laborers_max_literacy = 5`n${T3}global_soldiers_max_literacy = 5`n${T3}global_peasants_max_literacy = 3")) ) },
  @{ f='societal_values\00_default.txt'; k='traditionalist_vs_innovative'; out='societal_values'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 10[ \t]*\r?$', ("${T2}# LO: innovative all 10 -> upper 10 / lower 3`n" + (Strat $T2 'global' 10 3))) ) },
  @{ f='government_reforms\common.txt'; k='visionary_thinkers'; out='government_reforms'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: all 5 -> upper 5 / lower 2`n" + (Strat $T2 'global' 5 2))) ) },
  @{ f='government_reforms\country_specific.txt'; k='ottoman_imperial_harem'; out='government_reforms'
     e=@( ,@('(?m)^\t\tglobal_slaves_max_literacy = 5[ \t]*\r?$', "${T2}global_slaves_max_literacy = 1`t# LO: 5 -> 1 (harem/palace school touched a few slaves, not all)") ) },
  @{ f='laws\10_reforms_from_events.txt'; k='monastic_reformation_movement'; out='laws'
     e=@( ,@('(?m)^\t\t\tglobal_peasants_max_literacy = 10[ \t]*\r?\n\t\t\tglobal_soldiers_max_literacy = 10[ \t]*\r?\n\t\t\tglobal_laborers_max_literacy = 10[ \t]*\r?$',
             "${T3}global_clergy_max_literacy = 10`t# LO: possessors (Josephites): monastic book culture -> clergy +10 (was peasants/soldiers/laborers +10)") ) },
  @{ f='building_types\estate_buildings.txt'; k='local_newspaper'; out='building_types'
     e=@( ,@('(?m)^\t\tlocal_max_literacy = 10[ \t]*\r?$', ("${T2}# LO: all 10 -> upper 10 / laborers+soldiers 5 / peasants 2`n" + (Strat $T2 'local' 10 $null) + "`n${T2}local_laborers_max_literacy = 5`n${T2}local_soldiers_max_literacy = 5`n${T2}local_peasants_max_literacy = 2")) ) },
  @{ f='religions\buddhist.txt'; k='mahayana'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: 5 -> upper 5 / lower 2 (as tibetan buddhism)`n" + (Strat $T2 'global' 5 2))) ) },
  @{ f='religions\buddhist.txt'; k='bon'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: 5 -> upper 5 / lower 2`n" + (Strat $T2 'global' 5 2))) ) },
  @{ f='religious_schools\hinduism.txt'; k='vaisheshika_school'; out='religious_schools'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: 5 -> upper 5 / lower 2 (Brahmin learning)`n" + (Strat $T2 'global' 5 2))) ) },
  @{ f='religious_schools\jain.txt'; k='mula_sangh_school'; out='religious_schools'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: 5 -> upper 5 / lower 2`n" + (Strat $T2 'global' 5 2))) ) },
  # ---------- Protestants (2026-11-20) ----------
  # translated_bibles (aspect of all reformed/heretic churches + miaphysites): vernacular bible = a layman's book
  @{ f='religious_aspects\common.txt'; k='translated_bibles'; out='religious_aspects'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 10[ \t]*\r?$', ("${T2}# LO: all 10 -> upper 5 / lower 5 (vernacular scripture is read by laymen)`n" + (Strat $T2 'global' 5 5))) ) },
  # pietism (Lutheran aspect): a late-17th/18th c. movement (Spener 1675, Francke's Halle schools) that pushed reading
  # down to the village -> lower classes only, and only from age 5
  @{ f='religious_aspects\protestant.txt'; k='pietism'; out='religious_aspects'
     e=@(
       @('(?m)^(\treligion = lutheran)[ \t]*\r?$', "`$1`n`n${T1}enabled = {`t# LO: Pietism is a movement of the Age of Absolutism (Spener 1675, Francke 1690s)`n${T2}OR = {`n${T3}current_age = age_5_absolutism`n${T3}current_age = age_6_revolutions`n${T2}}`n${T1}}"),
       @('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', "${T2}# LO: all 5 -> lower classes 5 only (village reading schools)`n${T2}global_laborers_max_literacy = 5`n${T2}global_soldiers_max_literacy = 5`n${T2}global_peasants_max_literacy = 5")
     ) },
  # university-trained pastors: Lutheran and Calvinist clergy (vs Catholic definition clergy +25)
  @{ f='religions\christian.txt'; k='lutheran'; out='religions'
     e=@( ,@('(?m)^(\tdefinition_modifier = \{)[ \t]*\r?$', "`$1`n${T2}global_clergy_max_literacy = 15`t# LO: university-trained pastors`n${T2}# LO: Luther's Small Catechism (1529) + church orders made lay catechism instruction a duty -> lower +3`n${T2}global_laborers_max_literacy = 3`n${T2}global_soldiers_max_literacy = 3`n${T2}global_peasants_max_literacy = 3") ) },
  @{ f='religions\christian.txt'; k='calvinist'; out='religions'
     e=@( ,@('(?m)^(\tdefinition_modifier = \{)[ \t]*\r?$', "`$1`n${T2}global_clergy_max_literacy = 15`t# LO: university-trained ministers`n${T2}# LO: catechism / parish schools (Geneva, Scotland 1560 + 1696, Dutch catechism schools) -> lower +3`n${T2}global_laborers_max_literacy = 3`n${T2}global_soldiers_max_literacy = 3`n${T2}global_peasants_max_literacy = 3") ) },
  # other Protestant / proto-Protestant churches (2026-11-20, user OK)
  @{ f='religions\christian.txt'; k='anglican'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', "${T2}# LO: all 5 -> clergy 15 (Oxford/Cambridge clergy) / nobles + burghers 5 / lower 2`n${T2}global_clergy_max_literacy = 15`n${T2}global_nobles_max_literacy = 5`n${T2}global_burghers_max_literacy = 5`n${T2}global_laborers_max_literacy = 2`n${T2}global_soldiers_max_literacy = 2`n${T2}global_peasants_max_literacy = 2") ) },
  @{ f='religions\christian.txt'; k='hussite'; out='religions'
     e=@( ,@('(?m)^(\tdefinition_modifier = \{)[ \t]*\r?$', "`$1`n${T2}# LO: Czech bible, lay reading (Aeneas Silvius 1451 on Taborite women), Unity of Brethren; Utraquist ordination was hard`n${T2}global_clergy_max_literacy = 10`n${T2}global_burghers_max_literacy = 5`n${T2}global_laborers_max_literacy = 3`n${T2}global_soldiers_max_literacy = 3`n${T2}global_peasants_max_literacy = 3") ) },
  @{ f='religions\christian.txt'; k='lollardy'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 10[ \t]*\r?$', "${T2}# LO: all 10 -> burghers 10 / nobles + clergy 5 / lower 3 (persecuted movement of literate artisans, Wycliffe bible)`n${T2}global_nobles_max_literacy = 5`n${T2}global_clergy_max_literacy = 5`n${T2}global_burghers_max_literacy = 10`n${T2}global_laborers_max_literacy = 3`n${T2}global_soldiers_max_literacy = 3`n${T2}global_peasants_max_literacy = 3") ) },
  @{ f='religions\christian.txt'; k='waldensian'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: all 5 -> upper 5 / lower 3 (Alpine peasants; barbes taught scripture by heart)`n" + (Strat $T2 'global' 5 3))) ) },
  @{ f='religions\christian.txt'; k='catharism'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: all 5 -> upper 5 / lower 2 (the perfecti were the bookish ones)`n" + (Strat $T2 'global' 5 2))) ) },
  # strigolniki: a small 14th-c. Novgorod/Pskov townsmen's movement (deacon Karp, posad scribes) reading scripture
  # without priests -> townsfolk literate, not the whole countryside
  @{ f='religions\christian.txt'; k='strigolniki'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 10[ \t]*\r?$', "${T2}# LO: all 10 -> burghers 10 / nobles + clergy 5 / lower 2 (urban lay movement)`n${T2}global_nobles_max_literacy = 5`n${T2}global_clergy_max_literacy = 5`n${T2}global_burghers_max_literacy = 10`n${T2}global_laborers_max_literacy = 2`n${T2}global_soldiers_max_literacy = 2`n${T2}global_peasants_max_literacy = 2") ) },
  # ---------- religions (Flavorium) ----------
  @{ f='religions\buddhist.txt'; k='sanjiao'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 10[ \t]*\r?$', ("${T2}# LO: 10 -> upper 8 / lower 3 (Flavorium)`n" + (Strat $T2 'global' 8 3))) ) },
  @{ f='religions\buddhist.txt'; k='shinto'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 10[ \t]*\r?$', ("${T2}# LO: 10 -> upper 8 / lower 3 (Flavorium)`n" + (Strat $T2 'global' 8 3))) ) },
  @{ f='religions\buddhist.txt'; k='tibetan_buddhism'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T2 'global' 5 2))) ) },
  # ---------- Orthodox: source is RSF's own TRY_REPLACE (keeps Kotyk's goods demand/opinions) ----------
  # A TRY_INJECT delta did NOT work in game (RSF's TRY_REPLACE wiped it), so we re-emit RSF's whole block
  # as REPLACE_OR_CREATE (our mod mounts after RSF) with literacy upper 5 / lower 0, and re-add the
  # Romuva opinion that RSF_religion_relations.txt injects (a replace would otherwise drop it).
  @{ root=$rsf; f='religions\RSF_christian.txt'; k='TRY_REPLACE:orthodox'; out='religions'
     e=@(
       @('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', ("${T2}# LO: all 5 -> upper classes 5, lower classes 0`n" + (Strat $T2 'global' 5 $null))),
       @('(?m)^(\t\tjudaism = positive[^\r\n]*)$', "`$1`n${T2}romuva = positive`t# LO: re-added from RSF_religion_relations.txt (TRY_INJECT)")
     ) }
)

# ---------- Muslim religious schools (2026-11-21, user OK) ----------
# Base: only hanafi gives literacy (clergy +10). Every major madhhab/school ran madrasas: Shafi'i (al-Azhar,
# Mamluk Cairo/Damascus), Maliki (Qarawiyyin, Timbuktu), Twelver Shia (Hilla, Najaf hawzas), Zaidi (Yemeni
# manuscript culture), Ibadi (halqa circles of Oman/Mzab) -> clergy +10. Theology schools / smaller ones: Hanbali,
# Ash'ari (madrasa theology of the Nizamiyya; keeps its research +5%), Maturidi (Hanafi theology - the Ottomans'
# start school) -> clergy +5. Isma'ili branches: clergy +5, burghers +5 (Bohra/Khoja merchant communities).
# Mevlevi order: burghers +5 (urban Persian literary culture). Each school keeps its own base flavour modifier.
$schoolEdits = @(
  @('sunni.txt','shafii_school',  @{clergy=10}), @('sunni.txt','maliki_school', @{clergy=10}),
  @('sunni.txt','hanbali_school', @{clergy=5}),  @('sunni.txt','ashari_school', @{clergy=5}), @('sunni.txt','maturidi_school', @{clergy=5}),
  @('shia.txt','jafari_school',   @{clergy=10}), @('shia.txt','imamiya_school', @{clergy=10}), @('shia.txt','zaidi_school', @{clergy=10}),
  @('shia.txt','ismaili_school',  @{clergy=5; burghers=5}), @('shia.txt','nizari_school', @{clergy=5; burghers=5}), @('shia.txt','mustali_school', @{clergy=5; burghers=5}),
  @('ibadi.txt','ibadi_school',   @{clergy=10}),
  @('sufi.txt','mevlevi_school',  @{burghers=5})
)
# ---------- Indian religions + Theravada (2026-11-21, user OK): definition_modifier additions ----------
# Hindu: Brahmins = hereditary learned caste (pathshalas, agraharas; Varanasi, Mithila, Navadvipa, Sringeri) -> clergy 15;
#        scribal (Kayastha, Karnam) and merchant castes (mahajani scripts) -> burghers 5.
# Jain: merchant community with great manuscript libraries (bhandaras of Patan, Jaisalmer) -> burghers 10, clergy 5.
# Sikh: Gurmukhi (Guru Angad) and lay reading of scripture -> clergy 5, burghers 5, lower 3.
# Theravada / Sammitiya: village monastery schools taught most boys to read (Burma, Siam, Ceylon) -> lower 3.
$defAdds = @(
  @('dharmic.txt','hindu',     @{clergy=15; burghers=5}),
  @('dharmic.txt','jain',      @{burghers=10; clergy=5}),
  @('dharmic.txt','sikhism',   @{clergy=5; burghers=5; laborers=3; soldiers=3; peasants=3}),
  @('buddhist.txt','theravada',@{laborers=3; soldiers=3; peasants=3}),
  @('buddhist.txt','sammitiya',@{laborers=3; soldiers=3; peasants=3})
)
# Miaphysites (2026-11-21, user OK): RSF TRY_REPLACEs miaphysite (beeswax/livestock demand) -> re-emit RSF's block
# with clergy +5 (learned celibate vardapets / monastic book culture), as for the Orthodox
$targets += @{ root=$rsf; f='religions\RSF_christian.txt'; k='TRY_REPLACE:miaphysite'; out='religions'
               e=@( ,@('(?m)^(\tdefinition_modifier = \{)[ \t]*\r?$', "`$1`n${T2}global_clergy_max_literacy = 5`t# LO: vardapets / monastic book culture") ) }
# regnal_chronicles (all of Africa): court chronicles were kept by a few court clerics -> clergy 10 -> 5
$targets += @{ f='advances\region_africa.txt'; k='regnal_chronicles'; out='advances'
               e=@( ,@('(?m)^\tglobal_clergy_max_literacy = 10[ \t]*\r?$', "${T1}global_clergy_max_literacy = 5`t# LO: 10 -> 5 (court chronicles, not mass schooling)") ) }
foreach ($da in $defAdds) {
    $lines = ($da[2].GetEnumerator() | Sort-Object Name | ForEach-Object { "${T2}global_$($_.Name)_max_literacy = $($_.Value)`t# LO: Indian religions / Theravada" }) -join "`n"
    $targets += @{ f=('religions\' + $da[0]); k=$da[1]; out='religions'
                   e=@( ,@('(?m)^(\tdefinition_modifier = \{)[ \t]*\r?$', ("`$1`n" + $lines)) ) }
}

foreach ($se in $schoolEdits) {
    $lines = ($se[2].GetEnumerator() | Sort-Object Name | ForEach-Object { "${T2}global_$($_.Name)_max_literacy = $($_.Value)`t# LO: Muslim school rebalance" }) -join "`n"
    $targets += @{ f=('religious_schools\' + $se[0]); k=$se[1]; out='religious_schools'
                   e=@( ,@('(?m)^(\tmodifier = \{)[ \t]*\r?$', ("`$1`n" + $lines)) ) }
}

# ---------- group rule: national/city ACADEMY advances (all X -> upper X / lower round(X/3)) ----------
# An academy, university or court library educates the elite, not the countryside. Alphabet / mass-school advances
# (terakoya, hangeul, gurmukhi, albanian alphabet, komisja edukacji, dutch/scottish/slovak education, colonial
# free thinkers, hellenist epic poetry) are deliberately NOT in this list and keep "all classes".
$academies = @(
  'academia_pontaniana','alv_sagres_school','amazigh_group_tifinagh_revival','aqu_patriarchate_of_aquileia','ara_valencian_golden_age',
  'bah_madrasa_of_mahmud_gawan','byz_ancient_greek_studies','cas_real_academia_espanola','cnr_guanche_renaissance','cor_u_ginnasiu_corsu',
  'cro_the_croatian_press','dalmatian_the_accademia_degli_oziosi','encouragement_of_philosophers','fez_qarawiyyin_school','galician_rexurdimento',
  'gra_a_new_golden_era','hassaniya_shinqit_libraries','imperatorskiy_moskovskiy_universitet','leonese_provincial_academies','luc_the_lucchese_constitution',
  'man_studium_mantovano','mod_estense_library','mor_marinid_madrasas','nav_a_renaissance_realm','pad_medical_school',
  'pad_paduan_commune','par_enlightened_duchy','pat_uniate_liturgical_printing_advance','pcz_collegium_placentinum','pea_the_old_university',
  'pie_enlightened_court','pis_academic_prestige','pis_medical_tradition','pis_the_university_of_pisa','revival_of_the_literary_schools',
  'rhaetian_the_national_revival','sar_enlightened_reforms','sar_university_of_cagliari','ser_the_transcribers_of_resava','sic_sicilian_enlightenment',
  'sie_artists','tet_andalusi_quarter','tunisian_maliki_heartland','urb_the_enlightened_university','urb_the_mathematical_school'
)
$warn = 0
$advDir = Join-Path $game 'in_game\common\advances'
$advTexts = @{}; foreach ($af in Get-ChildItem $advDir -Filter *.txt) { $advTexts[$af.Name] = [IO.File]::ReadAllText($af.FullName).TrimStart([char]0xFEFF) }
$rxAcad = '(?m)^[ \t]+global_max_literacy\s*=\s*(\d+(?:\.\d+)?)[ \t]*\r?$'
foreach ($k in $academies) {
    $fn = $null; foreach ($n in $advTexts.Keys) { if ($advTexts[$n] -match ('(?m)^' + [regex]::Escape($k) + '\s*=\s*\{')) { $fn = $n; break } }
    if ($null -eq $fn) { Write-Warning "${k}: academy advance not found in base - SKIPPED"; $warn++; continue }
    $blk = Get-Block $advTexts[$fn] $k
    $mm = if ($blk) { [regex]::Matches($blk, $rxAcad) } else { @() }
    if ($mm.Count -ne 1) { Write-Warning "${k}: expected 1 global_max_literacy line, found $($mm.Count) - SKIPPED"; $warn++; continue }
    $x = [double]$mm[0].Groups[1].Value; $low = [math]::Round($x / 3)
    $rep = "${T1}# LO academy rule: all $x -> upper $x / lower $low`n" + (Strat $T1 'global' $x $low)
    $targets += @{ f=('advances\' + $fn); k=$k; out='advances'; e=@( ,@($rxAcad, $rep) ) }
}

$outs = @{}
foreach ($t in $targets) {
    $root = if ($t.root) { $t.root } else { $game }
    $src = Join-Path $root ('in_game\common\' + $t.f)
    if (-not (Test-Path $src)) { Write-Warning "$($t.k): source $src not found - SKIPPED"; $warn++; continue }
    $txt = [IO.File]::ReadAllText($src).TrimStart([char]0xFEFF)
    $b = Get-Block $txt $t.k
    if ($null -eq $b) { Write-Warning "$($t.k): block not found in $($t.f) - SKIPPED (base used)"; $warn++; continue }
    $ok = $true
    foreach ($e in $t.e) {
        $n = ([regex]::Matches($b, $e[0])).Count
        if ($n -ne 1) { Write-Warning "$($t.k): anchor matched $n times (need 1): $($e[0]) - block SKIPPED"; $ok = $false; break }
        $b = ([regex]$e[0]).Replace($b, $e[1], 1)
    }
    if (-not $ok) { $warn++; continue }
    $b = 'REPLACE_OR_CREATE:' + ($b.TrimStart() -replace '^TRY_REPLACE:', '')
    if (-not $outs.ContainsKey($t.out)) { $outs[$t.out] = New-Object System.Collections.Generic.List[string] }
    $from = if ($t.root) { "RSF $($t.f)" } else { "base $($t.f)" }
    $outs[$t.out].Add("# --- from $from ---`n" + ($b -replace "`r`n", "`n"))
    Write-Host "  ok  $($t.k)"
}
foreach ($dir in $outs.Keys) {
    $p = Join-Path $mod ("in_game\common\$dir\zz_lo_generated_$dir.txt")
    $d = Split-Path $p -Parent; if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    $hdr = "# GENERATED by tools\regen_from_base.ps1 from the CURRENT vanilla files - do not edit here, edit the script.`n# 'zz_' sorts after vanilla and RSF files so these definitions win.`n`n"
    [IO.File]::WriteAllText($p, $hdr + ($outs[$dir] -join "`n`n") + "`n", $utf8bom)
    Write-Host "wrote $p ($($outs[$dir].Count) blocks)"
}

# ---------- university loophole: events/religion/orthodox_flavor.txt (same-path override) ----------
# Event orthodox_flavor.101 ("Patriarch delegation") option b built a university at 20% cost in ANY town/city
# (construct_building bypasses the university allow gate). Events cannot be TRY_INJECTed, so we ship the whole
# base file with only that option removed. If the option is not found, the override is deleted (base used).
$evRel = 'in_game\events\religion\orthodox_flavor.txt'
$evSrc = Join-Path $game $evRel; $evDst = Join-Path $mod $evRel
$ev = [IO.File]::ReadAllText($evSrc)
$m = [regex]::Match($ev, '(?m)^\toption = \{[^\r\n]*\r?\n\t\tname = orthodox_flavor\.101\.b\b')
$cut = $null
if ($m.Success) {
    $i = $ev.IndexOf('{', $m.Index) + 1; $d = 1
    while ($i -lt $ev.Length -and $d -gt 0) { $c = $ev[$i]; if ($c -eq '{') { $d++ } elseif ($c -eq '}') { $d-- }; $i++ }
    $opt = $ev.Substring($m.Index, $i - $m.Index)
    if ($d -eq 0 -and $opt -match 'building_type:university') {
        # drop the option plus the line break(s) after it, but keep the next line's indentation
        $rest = [regex]::Match($ev.Substring($i), '^[ \t]*(\r?\n[ \t]*)*?\r?\n(?=[ \t]*\S)')
        $end = if ($rest.Success) { $i + $rest.Length } else { $i }
        $cut = $ev.Substring(0, $m.Index) + $ev.Substring($end)
    }
}
if ($null -ne $cut) {
    $d2 = Split-Path $evDst -Parent; if (-not (Test-Path $d2)) { New-Item -ItemType Directory -Path $d2 -Force | Out-Null }
    $raw = [IO.File]::ReadAllBytes($evSrc)
    $hasBom = $raw.Length -ge 3 -and $raw[0] -eq 0xEF -and $raw[1] -eq 0xBB -and $raw[2] -eq 0xBF   # keep the base BOM state
    $enc = New-Object System.Text.UTF8Encoding($hasBom)
    [IO.File]::WriteAllText($evDst, $cut.TrimStart([char]0xFEFF), $enc)
    Write-Host "  ok  orthodox_flavor.101 option b (cheap university) removed -> $evRel"
} else {
    if (Test-Path $evDst) { Remove-Item $evDst -Force }
    Write-Warning "orthodox_flavor.101.b (university) not found in base - override removed, base used"; $warn++
}

# ---------- scripted trigger lo_university_site (location scope) ----------
$stDst = Join-Path $mod 'in_game\common\scripted_triggers\lo_university_triggers.txt'
$st = @"
# GENERATED by tools\regen_from_base.ps1 - the numbers live in the script (`$UNI_*), edit them there.
# A location where WE could build a university ourselves (same site rules as the university building allow).
# Used by the parliament issue sponsor_a_university (allow + on_debate_passed).
lo_university_site = {
	OR = {	# towns allowed again (Oxford, Cambridge, Salamanca, Coimbra...); dev + literacy stop the spam
		location_rank = location_rank:town
		location_rank = location_rank:city
		location_rank = location_rank:megalopolis
	}
	development >= $UNI_DEV
	any_pop = { pop_type = pop_type:clergy   pop_literacy > $UNI_CLERGY }
	any_pop = { pop_type = pop_type:burghers pop_literacy > $UNI_BURGHERS }
	NOT = { has_building = building_type:university }
}
"@
$d3 = Split-Path $stDst -Parent; if (-not (Test-Path $d3)) { New-Item -ItemType Directory -Path $d3 -Force | Out-Null }
[IO.File]::WriteAllText($stDst, ($st -replace "`r`n", "`n"), $utf8bom)
Write-Host "  ok  scripted trigger lo_university_site (dev >= $UNI_DEV, clergy > $UNI_CLERGY, burghers > $UNI_BURGHERS)"

# ---------- university loophole 2: parliament issue sponsor_a_university (same-path override) ----------
# Base: the passed issue builds a university at 50% cost in the most populous core town/city - bypassing the
# building allow (construct_building ignores it). Now both the issue's allow and the chosen location require
# lo_university_site, so the burghers can only sponsor a university where we could build one ourselves.
$piRel = 'in_game\common\parliament_issues\05_burghers_estate_parliament_issues.txt'
$piSrc = Join-Path $game $piRel; $piDst = Join-Path $mod $piRel
$pi = [IO.File]::ReadAllText($piSrc)
$blk = Get-Block $pi 'sponsor_a_university'
$rxSite = [regex]'(?m)(^\t+)OR = \{\s*location_rank = location_rank:town\s*location_rank = location_rank:city\s*location_rank = location_rank:megalopolis\s*\}'
if ($null -ne $blk -and $rxSite.Matches($blk).Count -eq 2) {
    $new = $rxSite.Replace($blk, { param($m) $m.Groups[1].Value + 'lo_university_site = yes' + "`t# LO: city/megalopolis, dev and clergy/burgher literacy as for building it ourselves" })
    $out = $pi.Replace($blk, $new)
    $raw = [IO.File]::ReadAllBytes($piSrc)
    $bom = $raw.Length -ge 3 -and $raw[0] -eq 0xEF -and $raw[1] -eq 0xBB -and $raw[2] -eq 0xBF
    $d4 = Split-Path $piDst -Parent; if (-not (Test-Path $d4)) { New-Item -ItemType Directory -Path $d4 -Force | Out-Null }
    [IO.File]::WriteAllText($piDst, $out, (New-Object System.Text.UTF8Encoding($bom)))
    Write-Host "  ok  sponsor_a_university requires lo_university_site -> $piRel"
} else {
    if (Test-Path $piDst) { Remove-Item $piDst -Force }
    Write-Warning "sponsor_a_university site anchors not found twice in base - override removed, base used"; $warn++
}

if ($warn) { Write-Warning "$warn block(s) skipped - check the anchors against the new base files." } else { Write-Host 'All blocks generated.' }
