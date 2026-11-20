# Literacy overhaul - regenerate the REPLACE_OR_CREATE overrides from the CURRENT vanilla files.
# Each block = the current base definition with ONLY its literacy lines (and, for the university, our listed
# fields) swapped. If an anchor is missing (base changed), that block is SKIPPED with a warning and the base
# definition is used - nothing stale gets shipped. Run after every EU5 patch:
#   powershell -ExecutionPolicy Bypass -File tools\regen_from_base.ps1
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$mod  = Split-Path -Parent $here
$game = 'c:\Program Files (x86)\Steam\steamapps\common\Europa Universalis V\game'
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

# Each target: source file, key, list of (regex -> replacement). Every regex must match exactly once.
$targets = @(
  # ---------- advances (Flavorium) ----------
  @{ f='advances\0_age_of_traditions.txt'; k='written_alphabet'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', "${T1}global_max_literacy = 2`t# LO: 5 -> 2 (Flavorium)") ) },
  @{ f='advances\0_age_of_discovery.txt'; k='printing_press_advance'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 10[ \t]*\r?$', "${T1}# LO: global 10 -> upper classes 5 (Flavorium)`n" + (Strat $T1 'global' 5 $null)) ) },
  @{ f='advances\4_choices_adm.txt'; k='innovativeness'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', "${T1}# LO: global 5 -> upper classes 5 (Flavorium)`n" + (Strat $T1 'global' 5 $null)) ) },
  @{ f='advances\country_nov.txt'; k='birch_bark_manuscript'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 2\.5[ \t]*\r?\n\tglobal_burghers_max_literacy = 10[ \t]*\r?$', "${T1}# LO: all 2.5 + burghers 10 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T1 'global' 5 2)) ) },
  @{ f='advances\country_chi.txt'; k='baihua'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', "${T1}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T1 'global' 5 2)) ) },
  @{ f='advances\culture_group_romanian.txt'; k='romanian_the_letter_of_neacsu'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', "${T1}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T1 'global' 5 2)) ) },
  @{ f='advances\culture_sicilian.txt'; k='sic_studium_generale'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', "${T1}# LO: 5 -> upper 5 / lower 3 (Flavorium)`n" + (Strat $T1 'global' 5 3)) ) },
  @{ f='advances\culture_emilian.txt'; k='fer_studio_di_ferrara'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 10[ \t]*\r?$', "${T1}# LO: 10 -> upper 8 / lower 3 (Flavorium)`n" + (Strat $T1 'global' 8 3)) ) },
  @{ f='advances\culture_venetian.txt'; k='ven_state_inquisition'; out='advances'
     e=@( ,@('(?m)^\tglobal_max_literacy = 5[ \t]*\r?$', "${T1}# LO: 5 -> upper 5 / lower 3 (Flavorium)`n" + (Strat $T1 'global' 5 3)) ) },
  # ---------- buildings ----------
  @{ f='building_types\culture_buildings.txt'; k='library'; out='building_types'
     e=@( ,@('(?m)^\t\tlocal_max_literacy = 5[ \t]*\r?\n\t\tlocal_monthly_literacy = 0\.1[ \t]*\r?$',
             "${T2}# LO: all 5 -> nobles 3 / clergy 3 / burghers 2, monthly 0.1 -> 0.03 (Flavorium)`n${T2}local_nobles_max_literacy = 3`n${T2}local_clergy_max_literacy = 3`n${T2}local_burghers_max_literacy = 2`n${T2}local_monthly_literacy = 0.03") ) },
  @{ f='building_types\culture_buildings.txt'; k='confucian_school'; out='building_types'
     e=@( ,@('(?m)^\t\tlocal_max_literacy = 5[ \t]*\r?$', "${T2}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T2 'local' 5 2)) ) },
  @{ f='building_types\culture_buildings.txt'; k='university'; out='building_types'
     e=@(
       @('(?m)^\ttown = yes[ \t]*\r?$', "${T1}town = no`t# LO: elite urban institution - city/megalopolis only"),
       @('(?m)^(\t\tis_core_of = owner)[ \t]*\r?$', "`$1`n${T2}# LO: developed city with literate clergy (cathedral schools) and burghers (educated laity)`n${T2}development >= 30`n${T2}any_pop = { pop_type = pop_type:clergy   pop_literacy > 85 }`n${T2}any_pop = { pop_type = pop_type:burghers pop_literacy > 25 }"),
       @('(?m)^\t\tlocal_cultural_influence = 0\.5[ \t]*\r?$', "${T2}local_cultural_influence = 0.75`t# LO: 0.5 -> 0.75"),
       @('(?m)^\t\tlocal_burghers_max_literacy = 10[ \t]*\r?\n\t\tlocal_nobles_max_literacy = 10[ \t]*\r?$', "${T2}local_burghers_max_literacy = 15`t# LO: 10 -> 15`n${T2}local_nobles_max_literacy = 15`t# LO: 10 -> 15`n${T2}local_clergy_max_literacy = 10`t# LO: new"),
       @('(?m)^\t\tlocal_monthly_literacy = 0\.1[ \t]*\r?$', "${T2}local_monthly_literacy = 0.25`t# LO: 0.1 -> 0.25"),
       @('(?m)^\t\tlocal_pop_promotion_speed = 0\.001[ \t]*\r?$', "${T2}local_pop_promotion_speed = 0.002`t# LO: x2"),
       @('(?m)^\t\tlocal_institution_growth_modifier = 0\.33[ \t]*\r?$', "${T2}local_institution_growth_modifier = 0.66`t# LO: x2"),
       @('(?m)^\t\tpaper = 0\.5[ \t]*\r?\n\t\tbooks = 0\.25[ \t]*\r?\n\t\tglass = 0\.25[ \t]*\r?\n\t\tbeeswax = 0\.05[ \t]*\r?$', "${T2}paper = 1.0`t# LO: maintenance x2`n${T2}books = 0.5`n${T2}glass = 0.5`n${T2}beeswax = 0.1"),
       @('(?m)^\tconstruction_demand = university_construction[ \t]*\r?$', "${T1}construction_demand = lo_university_construction`t# LO: ~x2 cost + glass (goods_demand/lo_university_cost.txt)")
     ) },
  # ---------- privileges / reforms / laws ----------
  @{ f='estate_privileges\clergy_estate.txt'; k='freedom_of_interpretation'; out='estate_privileges'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', "${T2}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T2 'global' 5 2)) ) },
  @{ f='government_reforms\common.txt'; k='the_education_act'; out='government_reforms'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', "${T2}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T2 'global' 5 2)) ) },
  @{ f='laws\01_common.txt'; k='education_masses_law'; out='laws'
     e=@( ,@('(?m)^\t\t\tglobal_laborers_max_literacy = 5[ \t]*\r?\n\t\t\tglobal_soldiers_max_literacy = 5[ \t]*\r?\n\t\t\tglobal_peasants_max_literacy = 5[ \t]*\r?$',
             "${T3}# LO: basic_religious_education lower classes 5 -> 2 (Flavorium)`n${T3}global_laborers_max_literacy = 2`n${T3}global_soldiers_max_literacy = 2`n${T3}global_peasants_max_literacy = 2") ) },
  # ---------- religions (Flavorium) ----------
  @{ f='religions\buddhist.txt'; k='sanjiao'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 10[ \t]*\r?$', "${T2}# LO: 10 -> upper 8 / lower 3 (Flavorium)`n" + (Strat $T2 'global' 8 3)) ) },
  @{ f='religions\buddhist.txt'; k='shinto'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 10[ \t]*\r?$', "${T2}# LO: 10 -> upper 8 / lower 3 (Flavorium)`n" + (Strat $T2 'global' 8 3)) ) },
  @{ f='religions\buddhist.txt'; k='tibetan_buddhism'; out='religions'
     e=@( ,@('(?m)^\t\tglobal_max_literacy = 5[ \t]*\r?$', "${T2}# LO: 5 -> upper 5 / lower 2 (Flavorium)`n" + (Strat $T2 'global' 5 2)) ) }
)

$outs = @{}
$warn = 0
foreach ($t in $targets) {
    $src = Join-Path $game ('in_game\common\' + $t.f)
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
    $b = 'REPLACE_OR_CREATE:' + $b.TrimStart()
    if (-not $outs.ContainsKey($t.out)) { $outs[$t.out] = New-Object System.Collections.Generic.List[string] }
    $outs[$t.out].Add("# --- from base $($t.f) ---`n" + ($b -replace "`r`n", "`n"))
    Write-Host "  ok  $($t.k)"
}
foreach ($dir in $outs.Keys) {
    $p = Join-Path $mod ("in_game\common\$dir\zz_lo_generated_$dir.txt")
    $d = Split-Path $p -Parent; if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    $hdr = "# GENERATED by tools\regen_from_base.ps1 from the CURRENT vanilla files - do not edit here, edit the script.`n# 'zz_' sorts after vanilla and RSF files so these definitions win.`n`n"
    [IO.File]::WriteAllText($p, $hdr + ($outs[$dir] -join "`n`n") + "`n", $utf8bom)
    Write-Host "wrote $p ($($outs[$dir].Count) blocks)"
}
if ($warn) { Write-Warning "$warn block(s) skipped - check the anchors against the new base files." } else { Write-Host 'All blocks generated.' }
