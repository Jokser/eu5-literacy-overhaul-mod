# Literacy overhaul (EU5)

A standalone mod for class-stratified literacy: the upper classes (nobles, clergy, burghers) can become far more
literate than the lower classes (peasants, laborers, soldiers). It also holds our university building rules. It ports
the literacy part of **Flavorium Universalis – Balance** (Workshop 3738220283, v0.4.0) and is meant to run with RSF.
Calculation of the resulting caps: `C:\Users\user\Documents\EU5_RSF_patches\literacy_overhaul_calc.md`.

## How the files are built
- `zz_lo_generated_*.txt` are **generated** by `tools/regen_from_base.ps1` from the CURRENT vanilla files. Each block is
  the base definition with only its literacy lines (and our university fields) swapped, emitted as
  `REPLACE_OR_CREATE:`. If a base anchor is missing, that block is skipped with a warning. **Run the script after every
  EU5 patch.** Do not edit the generated files by hand.
- The `zz_` prefix sorts after vanilla and RSF files.
- Static files: `lo_regional_literacy_advances.txt`, `zz_lo_orthodox_literacy.txt`, `lo_university_cost.txt`, and the
  loc `literacy_overhaul_l_english.yml`.

## Changes (v0.1)
### From Flavorium (literacy values only)
| Object | Vanilla | Now |
|---|---|---|
| `written_alphabet` | all 5 | all 2 |
| `innovativeness` (adm) | all 5 | upper 5 |
| `printing_press_advance` | all 10 | upper 5 |
| `birch_bark_manuscript` (NOV) | all 2.5 + burghers 10 | upper 5 / lower 2 |
| `baihua` (CHI), `romanian_the_letter_of_neacsu` | all 5 | upper 5 / lower 2 |
| `sic_studium_generale`, `ven_state_inquisition` | all 5 | upper 5 / lower 3 |
| `fer_studio_di_ferrara` | all 10 | upper 8 / lower 3 |
| library | all 5, monthly 0.1 | nobles 3 / clergy 3 / burghers 2, monthly 0.03 |
| confucian school | all 5 | upper 5 / lower 2 |
| `freedom_of_interpretation` (Muslim privilege) | all 5 | upper 5 / lower 2 |
| `the_education_act` (reform) | all 5 | upper 5 / lower 2 |
| `basic_religious_education` (law) | lower 5 | lower 2 |
| sanjiao, shinto | all 10 | upper 8 / lower 3 |
| tibetan buddhism | all 5 | upper 5 / lower 2 |

**New regional advances** (`lo_*`, adm path):
- Western Europe, age 2: peasants 2, laborers 2, soldiers 5.
- Western Europe, age 4: burghers 5, soldiers 5, peasants 3, laborers 3.
- Colonial powers, age 4: burghers 2, soldiers 2.
- East Asia, age 4: nobles 5, burghers 5.

Not ported: Flavorium's own `east_asian_classical_revival` (an advance of the main Flavorium mod, not vanilla) and
`colonial_migration_center` (from another mod, no literacy).

### Orthodox (ours)
Upper classes 5, **lower classes 0**. Base and RSF (`RSF_christian.txt`, `TRY_REPLACE:orthodox`) give all classes 5.
This mod applies `TRY_INJECT` deltas (global −5, nobles/clergy/burghers +5), so RSF's own Orthodox edits are kept.

### University (ours, moved here from the RSF kit)
- Built in cities and megalopolises only (`town = no`).
- `allow` adds: `development >= 30`, a **clergy pop with literacy > 85**, and a **burgher pop with literacy > 25**.
  These thresholds were re-tuned for the lower literacy: Catholic cities qualify from age 2, Orthodox only from
  age 5, Sunni from age 3.
- Modifiers: burghers and nobles +15, clergy +10, monthly literacy 0.25, cultural influence 0.75, promotion and
  institution growth ×2.
- Maintenance ×2.
- Construction cost `lo_university_construction` (about ×2, plus glass).

**Loophole: event `orthodox_flavor.101` option b** ("sponsor monastery") built a university at 20% cost in any town or city.
`construct_building` ignores the `allow` gate. The script generates `in_game/events/religion/orthodox_flavor.txt` as a
same-path override: the current base file with only that option removed. If the option disappears from base, the
override is deleted. The second loophole fix, the sponsor-a-university parliament issue (city with dev ≥ 30), is
still in the RSF kit.
