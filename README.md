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
- Static files: `lo_regional_literacy_advances.txt`, `zz_lo_orthodox_literacy_advances.txt` (zz_: its requires = national_rites must load after religion_orthodox.txt), `lo_university_cost.txt`, and the
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

### Indian religions and Theravada (v0.8, 2026-11-21)
| Source | Before | Now |
|---|---|---|
| Hindu definition | — | clergy +15 (Brahmins), burghers +5 (scribal and merchant castes) |
| law `vedic_education` (Hindu, unlocked by event) | upper 5 / lower 2 (v0.3) | clergy 15 / nobles + burghers 5 / lower 2: now stronger than basic religious education for clergy |
| Jain definition | monthly +0.03 | + burghers +10, clergy +5 (merchant community, bhandara libraries) |
| Sikh definition | — | clergy 5 / burghers 5 / lower 3 (Gurmukhi, lay scripture reading) |
| Theravada, Sammitiya | — | lower +3 (village monastery schools), clergy +5 (Pali monastic learning, added the same day) |

Hindu and Jain religious schools are `religious_schools_for_characters_only`, so their country modifiers do not act on the
country. They are left unchanged.

### Miaphysites: Armenians and Ethiopians (v0.9, 2026-11-21)
| Source | Before | Now |
|---|---|---|
| Miaphysite definition (re-emitted from RSF's `TRY_REPLACE`, Kotyk's goods demand kept) | — | clergy +5 (vardapets, monastic book culture) |
| New `lo_armenian_scriptoria` (age 1, Armenian culture) | — | clergy +5, burghers +5 (Mashtots' script, Gladzor / Tatev, diaspora merchants) |
| New `lo_armenian_printing` (age 3, after printing press) | — | burghers +5, lower +2 (Hakob Meghapart, Venice 1512) |
| `regnal_chronicles` (all of Africa) | clergy 10 | clergy 5 (court chronicles, not schooling) |

### Discriminated cultures (v0.10, 2026-11-21)
`loading_screen/common/defines/zz_lo_defines.txt`: `NPop.DISCRIMINATED_CULTURE_MAX_LITERACY` −15 → **−5**. With our
stratified caps, −15 would wipe out a discriminated culture's peasant literacy for most of the game.
`IGNORED_CULTURE_MAX_LITERACY` (culture with no policy set) −5 → **−2**, so discriminating stays worse than ignoring.

### Small Near-East and Balkan faiths (v0.11, 2026-11-21)
Definitions get clergy literacy; in all of them the learned layer was priestly or initiated:

| Religion | Added |
|---|---|
| Nestorianism (Church of the East) | clergy +10 |
| Zoroastrianism (mobeds) | clergy +10 |
| Druzism (uqqal) | clergy +10 |
| Mandaeism (tarmide) | clergy +10 |
| Bosnian Church | clergy +5 |

Unchanged: Yazidism (oral tradition), Bogomils, Manichaeism and Samaritanism (already clergy +10).

### Government reforms (v0.12, 2026-11-21)
| Reform | Before | Now |
|---|---|---|
| `noblesse_oblige_reform` (age 1) | nobles 10 | nobles 5 |
| `of_noble_bearing` (age 2, monarchy) | nobles 10 | nobles 5. Together with the one above, +20 → +10 |
| `diwan_i_bandagan`, `tughlaq_slave_army_reform` (Delhi) | slaves 5 | slaves 1 (an elite few, as the Ottoman harem) |
| `school_of_first_letters_reform` (Iberian, age 4) | all 10 | upper 5 / lower 5 (monthly growth kept). Spanish primary schools spread in the 18th c. |

Already done earlier: `the_education_act`, `visionary_thinkers`, `ottoman_imperial_harem`. The other literacy reforms
(citizenship_through_service, enlightened_aristocracy, nautical_education_act, peasant_labor_rights) are unchanged.

### Laws and privileges pass (v0.13, 2026-11-21)
| Law → option | Before | Now |
|---|---|---|
| `press_law` → `censored_press` | all 5 | upper 5 / lower 2 (it gave peasants more than free press) |
| `divine_cause_law` → `pursuit_of_knowledge_policy` (theocracy) | all 5 | upper 5 / lower 2 |

The other literacy laws and all 8 literacy privileges were reviewed and kept, see the review in the commit history.

### Buildings pass (v0.14, 2026-11-21)
| Building | Before | Now |
|---|---|---|
| `fortress_church` (Orthodox, built instead of a monastery) | clergy 10 | clergy 5 (= `orthodox_monastery`) |
| `local_schools` (peasants estate) | peasants 1, needs average country literacy > 20 | laborers / soldiers / peasants 3, needs > 10 (with stratified caps 20 was out of reach for most countries) |
| `bardic_school` (Celtic reform) | peasants 5 | nobles 5 / burghers 3 (the fili served noble patrons) |
| `gymnasium_building` (capital) | country-wide all 5 | country-wide upper classes 5 (local nobles 10 kept) |
| `jesuit_college` | nobles 10 | nobles 5 / burghers 5 |
| `confucian_academy` | burghers 10 | nobles 5 / burghers 5 (scholar-gentry = nobles) |
| `merchant_guild_chapel` | all 2 | burghers 3 |
| `globe_theatre`, `teatro_san_cassiano` (event) | country-wide lower classes 10 | country-wide lower classes 2 (local growth kept) |
| `papal_archives` (event) | country-wide all 5 | country-wide upper classes 5 |
| `greek_latin_academy` (Moscow) | country-wide nobles + lower classes 5 | country-wide clergy / nobles / burghers 5, lower 0 |

Kept: temple / cathedral / monastery / sufi lodge (clergy 10), madrasa (5), chanceries, modern council hall, and the
one-location wonders (Vatican libraries, Corviniana, al-Azhar, Bavarian buildings, calmecac, Moscow orphanage...).

### Literacy growth speed (v0.15, 2026-11-21)
Pop literacy grows by local + global `monthly_literacy` per month up to its cap, at the same rate for every class.
The background rate is only written_alphabet + educated_bureaucrats = 0.02/month (+10 points in ~42 years).

| Source | Before | Now |
|---|---|---|
| `invited_foreign_cleric_modifier` (action invite_foreign_cleric, 20 religious influence, decaying, 5 years; AI re-invites as soon as it can) | 0.33 | 0.1 (was ~8x the whole background rate) |

All other growth sources were reviewed and kept, pending a test run.

### Fix: Orthodox / Miaphysite literacy not applied (v0.16, 2026-11-21)
In game the Orthodox still gave all classes +5: RSF's `TRY_REPLACE:orthodox` (RSF_christian.txt) beat both a TRY_INJECT
and our `zz_` REPLACE_OR_CREATE. Now LO ships a **same-path override of RSF's `in_game/common/religions/RSF_christian.txt`**
(LO mounts after RSF), generated from RSF's current file. Only the Orthodox (upper 5 / lower 0) and Miaphysite
(clergy +5) literacy lines differ. RSF's Romuva opinion inject is untouched. **Re-run the regen after every RSF update.**
The Stoglav advance file is renamed to `zz_lo_orthodox_literacy_advances.txt`: its `requires = national_rites` failed
("Failed to read key reference"), because an advance can only reference advances from files that load earlier.

### Holy sites + Hussite clergy (v0.17, 2026-11-21)
`holy_site_types` location modifiers are **multiplied by the site's importance (1-5)**, so a base clergy 10 meant
+50 in Constantinople, Jerusalem, Mecca or Baghdad (user saw the +50 from an episcopal see in game).

| Holy site type | Before (x importance) | Now (x importance) |
|---|---|---|
| `episcopal_see` (Orthodox/Miaphysite, Nestorian sees) | clergy 10 → up to +50 | clergy 2 → up to +10 |
| `orthodox_church_holy_site` (Athos, Sinai, Kyiv...) | clergy 10 → up to +30 | clergy 2 → up to +6 |
| `islam_holy_site` (Mecca, Medina, Kufa, Karbala...) | clergy 10 → up to +50 | clergy 2 → up to +10 |
| `mayan_holy_site` | clergy 10 → up to +40 | clergy 2 → up to +8 |
| `mountain` (Fuji, Emei, Jain hills...) | all classes 2 → up to +10 | clergy 1 → up to +5 |

Hussite clergy 10 → 15 (= Lutheran / Calvinist): Hussites have no monasteries (-10) and no Catholic +25, so a Hussite
city clergy capped at 75 in age 3 and could never pass the university gate (clergy > 85).
