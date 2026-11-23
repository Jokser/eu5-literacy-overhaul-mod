# Observer-run analysis (save parsing)

These are awk scripts that read an EU5 **text** save (`.eu5`, ~450-600 MB) and produce the tables used to tune the mod.
They are not part of the mod itself. Each pass reads the whole save in about 1 minute.

Run them in Git Bash. Python is not available on this machine, so everything is awk.

## Lookup tables (`data/`)
- `locnames.txt`: location names, one per line. **Location id = line number.** It comes from line 29 of the save
  metadata (`compatibility ... locations={...}`). Rebuild it after a game patch that changes the map:
  `head -40 SAVE | grep -a -m1 $'^\t\tlocations={' | sed 's/.*={//; s/}.*//' | tr ' ' '\n' | grep . > data/locnames.txt`
- `locmap.tsv`: `name \t province \t area \t region`, keyed by NAME. It is built from
  `game/in_game/map_data/definitions.txt` (nesting continent > subcontinent > region > area > province > locations).
- To get from a location id to its area: `nm[id]` from locnames, then `ar[nm]` from locmap.
- The German lands, as counted: `north_german_region` + `south_german_region` (they include the Low Countries,
  Switzerland, Austria and Bohemia), plus `silesia_area` (which belongs to `baltic_region`).

## Scripts
| script | output |
|---|---|
| `cty2.awk SAVE > out.tsv` | one row per country with ≥100 pop: tag, GP rank, religion, pop, class literacy (nobles, clergy, burghers, peasants, laborers, soldiers), capital literacy N/C/B/P, universities, elite law, mass law, censorship, press law, key advances, university location ids (col 21), average literacy (22), embraced institutions (23). The header goes to stderr. |
| `uni.awk -v DEV=dev.tsv -v UNI=uni.tsv SAVE` | `dev.tsv` = location id, development; `uni.tsv` = location id, owner tag of every university |
| `site.awk -v W=ids.txt SAVE` | for the location ids in `ids.txt`: development, max clergy literacy, max burgher literacy, rank. Use it to check the university gate (clergy > 85, burghers > 40, dev ≥ 30) |
| `clsat.awk SAVE` | clergy estate satisfaction per tag (research bonus = 0.25 × (sat − 0.5) since v0.47) |
| `hist.awk -v W=TAG1,TAG2 SAVE` | peasant literacy histogram per tag |

## Save format notes (gotchas)
- The top-level sections are `name={` at column 0: `countries`, `population`, `locations`, `building_manager`,
  `religion_manager`, `estate_manager`, `institution_manager`, `international_organization_manager`.
- `estate_manager` comes **before** `countries`, so print its results in `END`.
- Countries: `^[0-9]+=\{` at depth 0 inside the section. The tag map is `\ttags={ id=TAG ... }`, the capital is
  `\tcapital=`. Embraced institutions are one line `\t\tfeudalism=yes ... confessionalism=yes`, right after
  `\tinstitutions={`. Laws: `\t\t\t<law_group>={` then `\t\t\t\tobject=<policy>`. Religious aspects:
  `religious_aspects={...}` in the country block.
- Population: `^[0-9]+=\{` then `\ttype=`, `\tsize=`, `\tliteracy=`. In locations, pops are listed in `\t\t\t\tpops={ ids }`.
- Locations: `\t\t<id>={`, `\t\t\towner=<country id>`, `\t\t\tdevelopment=`, `\t\t\trank=`.
- Buildings: `building_manager` entries have `\ttype=`, `\tlocation=`, `\towner=`.
- `institution_manager`: per institution `active`, `months`, `origin=<location id>`. The spawn date is not stored.
- The country-count denominators include dead tags, so shares are understated.
- gawk reserves `RT`, so don't use it as a variable name. The first key of a block may carry a BOM.

## Historical benchmarks we used
- Universities, German lands (broad): ~17 (1500), ~20 (1550), ~30 (1600), ~40 (1700), ~45 (1790). Italy ~16-20,
  France ~17-22. Europe overall: ~60 (1500), ~105 (1600), ~120 (1700), ~140 (1790). Boom = age 4 (1520-1620,
  confessional wave), slowdown in age 5, stagnation in age 6.
- Ages start: 3 discovery 1437, 4 reformation 1537, 5 absolutism 1637, 6 revolutions 1737.
