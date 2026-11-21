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
- Built in towns, cities and megalopolises (base `town = yes` kept: Oxford, Cambridge, Salamanca, Coimbra were towns). Development and literacy prevent spam.
- `allow` adds: `development >= 30`, a **clergy pop with literacy > 85**, and a **burgher pop with literacy > 25**.
  These thresholds were re-tuned for the lower literacy: Catholic cities qualify from age 2, Orthodox only from
  age 5, Sunni from age 3.
- Modifiers: burghers and nobles +10 (base; +15 in v0.1–0.2), clergy +10, monthly literacy 0.1 (base; 0.25 in v0.1–0.2 was wonder tier), cultural influence 0.75, promotion and
  institution growth ×2.
- Maintenance ×2.
- Construction cost `lo_university_construction` (about ×2, plus glass).

**Loophole: event `orthodox_flavor.101` option b** ("sponsor monastery") built a university at 20% cost in any town or city.
`construct_building` ignores the `allow` gate. The script generates `in_game/events/religion/orthodox_flavor.txt` as a
same-path override: the current base file with only that option removed. If the option disappears from base, the
override is deleted.

**Loophole: parliament issue `sponsor_a_university`** (burghers). When passed, it builds a university at 50% cost in the
most populous core town or city. The script generates `05_burghers_estate_parliament_issues.txt` (base file, only this
issue edited). Both its `allow` and the location it picks now require the scripted trigger `lo_university_site`:
town/city/megalopolis, dev ≥ 30, clergy > 85, burghers > 25, no university yet. So the burghers can only sponsor a
university where we could build one ourselves.

The thresholds live in ONE place: `$UNI_DEV`, `$UNI_CLERGY` and `$UNI_BURGHERS` at the top of
`tools/regen_from_base.ps1`. The script writes them into the university building `allow` and into
`scripted_triggers/lo_university_triggers.txt`.

### Orthodox clergy rebalance (v0.2, 2026-11-20)
Rus' parish clergy were barely literate until the Stoglav council (1551): Archbishop Gennady complained in 1499,
and the council itself ordered schools.

| Change | Clergy |
|---|---|
| Orthodox definition (as above) | +5 (upper classes 5, lower 0) |
| `anagignoskomena` | 10 → 5 |
| `orthodox_monastery` | 10 → 5 |
| New `lo_stoglav` (age 4, requires `national_rites`, Orthodox + `russian_group`) | +10 |

In RSF, `russian_group` covers ALL East Slavs: Great Russians, Ruthenians, Belarusians, Cossacks and Rusyns.

With the patriarchate tenet "christological debates" (leader +5, members +3), a city without a university reaches
the university clergy threshold (> 85) in **age 3 for the Greeks** and **age 4 for Moscow**.

### Lower-class pass (v0.3, 2026-11-20)
Flat "all classes" bonuses that are really elite phenomena were split. Before, Catholic peasants jumped from about 4 to
34–44 in age 5.

| Source | Before | Now |
|---|---|---|
| `scientific_revolution_advance` (age 5) | all 10 | upper 10 / lower 2 |
| `humanism` (age 5, adm) | all 10 | upper 10 / lower 0 |
| law `free_press` (age 5) | all 10 | upper 10 / laborers + soldiers 5 / peasants 3 |
| societal value innovative (right) | all 10 | upper 10 / lower 3 |
| `enlightened_court` (age 6) | all 5 | upper 5 / lower 2 |
| reform `visionary_thinkers` (age 6) | all 5 | upper 5 / lower 2 |
| law `monastic_reformation_movement` → `possessors` (Rus' event law) | peasants / soldiers / laborers +10 | **clergy +10** |
| `theocratic_education` (masses law) | lower 5 | lower 2 (like basic; Flavorium missed it) |
| `vedic_education` (masses law) | all 5 | upper 5 / lower 2 |
| `local_newspaper` | all 10 | upper 10 / laborers + soldiers 5 / peasants 2 |
| religions mahayana, bon | all 5 | upper 5 / lower 2 |
| religious schools vaisheshika (Hindu), mula_sangh (Jain) | all 5 | upper 5 / lower 2 |
| reform `ottoman_imperial_harem` | slaves 5 | slaves 1 |

Kept on purpose:
- `secular_education` (age 6, all 10): Enlightenment mass schooling.
- The Protestant aspects (sola scriptura, translated bibles, pietism), lollardy, waldensians, anglicans and judaism:
  lay reading of scripture.
- National "school" advances: terakoya, komisja edukacji, dutch / scottish / Slovak education, school of first letters,
  ruthenia commoner education.

### Academies and strigolniki (v0.4, 2026-11-20)
- **Group rule for 45 national / city "academy" advances.** Their "all classes" bonus becomes upper X / lower round(X/3):
  all 5 → 5 / 2, all 10 → 10 / 3. Examples: Italian studia and academies, Spanish academies, Maghreb madrasas, the
  Moscow university, the Resava transcribers. The list is `$academies` in `tools/regen_from_base.ps1`. Alphabet and
  mass-school advances keep "all classes": terakoya, hangeul, gurmukhi, Albanian alphabet, komisja edukacji, Dutch,
  Scottish and Slovak education, colonial free thinkers, Hellenist epic poetry.
- **Strigolniki** (a 14th-c. Novgorod/Pskov urban lay movement): all 10 → burghers 10 / nobles and clergy 5 / lower 2.

### Protestants (v0.5, 2026-11-20)
| Source | Before | Now |
|---|---|---|
| aspect `translated_bibles` (Lutheran, Calvinist, Anglican, Hussite, Lollard, Waldensian, Cathar, Bogomil, Paulician, Miaphysite) | all 10 | upper 5 / lower 5 |
| aspect `pietism` (Lutheran) | all 5, any age | lower 5 only, `enabled` only in ages 5–6 (Spener 1675, Francke's Halle schools) |
| Lutheran / Calvinist definition | — | clergy +15 (university-trained pastors); Lutheran also lower +3 (Small Catechism 1529, v0.6) |

`sola_scriptura` (all 5) is unchanged.

Result for Brandenburg-Prussia vs France, capital for the upper classes and rural for the lower, no reforms and no
innovative society:

| Age | Country | Nobles / Clergy / Burghers | Peasants / Laborers / Soldiers |
|---|---|---|---|
| 4 | France (Catholic) | 57.5 / 100 / 41.5 | 9 / 9 / 14 |
| 4 | Prussia (Lutheran) | 67.5 / 90 / 51.5 | 19 / 19 / 24 |
| 5 | France | 97.5 / 100 / 81.5 | 14 / 16 / 21 |
| 5 | Prussia | 100 / 100 / 91.5 | 29 / 31 / 36 |
| 6 | France | 100 / 100 / 91.5 | 24 / 26 / 31 |
| 6 | Prussia | 100 / 100 / 100 | 39 / 41 / 46 |

Before this change, Prussia's peasants were at 29 in age 4 (×3 France) and its clergy at 85, below France.

### Other Protestant / proto-Protestant churches (v0.6, 2026-11-20)
| Religion | Before | Now (definition) |
|---|---|---|
| Anglican | all 5 | clergy 15 / nobles + burghers 5 / lower 2 |
| Calvinist | clergy 15 (v0.5) | + lower 3 (catechism and parish schools: Geneva, Scotland 1560 / 1696, Dutch) |
| Hussite | — | clergy 10 / burghers 5 / lower 3 (Czech bible, Taborites, Unity of Brethren) |
| Lollardy | all 10 | burghers 10 / nobles + clergy 5 / lower 3 (persecuted literate artisans) |
| Waldensian | all 5 | upper 5 / lower 3 |
| Catharism | all 5 | upper 5 / lower 2 |

Bogomils and Paulicians are unchanged.

### Muslim religious schools (v0.7, 2026-11-21)
In base, only Hanafi gives literacy (clergy +10). Every school keeps its own base flavour modifier and now also gets:

| School | Added |
|---|---|
| Shafi'i, Maliki, Ja'fari, Imamiya, Zaidi, Ibadi | clergy +10 |
| Hanbali, Ash'ari (keeps research +5%), Maturidi (the Ottoman start school) | clergy +5 |
| Isma'ili, Nizari, Mustali | clergy +5, burghers +5 (Bohra / Khoja merchant communities) |
| Mevlevi (Sufi order) | burghers +5 |

History: Shafi'i (al-Azhar, Mamluk Cairo and Damascus), Maliki (Qarawiyyin, Timbuktu), Twelvers (Hilla and Najaf),
Zaidis (Yemeni manuscripts), Ibadis (halqa circles), Ash'ari (theology of the Nizamiyya madrasas).
