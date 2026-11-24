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

### Leftover country-wide modifiers (v0.18, 2026-11-21)
| Modifier | Before | Now |
|---|---|---|
| `plc_zaluski_library_modifier` (Poland, event) | all 10 | upper 10 / lower 3 |
| `mian_mir`, `aftermath_of_the_scientific_revolution`, `increased_literacy_from_religious_sects` (static) | all 5 | upper 5 / lower 2 |
| `kbo_sharia_courts` (cabinet action), `odin_god` (Norse god), `stargazer` (religious figure trait) | all 5 | upper 5 / lower 2 |
| `enlightened_leadership_reform_town_right` (town right from the reform) | lower 10 | laborers / soldiers 5, peasants 3 |

Kept: institution-birth location bonuses (printing press 5, scientific revolution 10, one location only),
blue_stockings_society (lower 5, late), and the tiny magnet_for_scholars / pol_excellent_noble_education / por_estudo_geral.

### Learned-elite research bonus + education laws (v0.19, 2026-11-21)
Vanilla research from literacy is `average_literacy` (research_speed_modifier 1 x country average literacy). The
average is ~95% lower classes, so stratified caps cut it 3-4x (Portugal 1511: 6.1%) and an estate's education barely
mattered (+10 noble literacy = +0.05% research), while burgher city-states (Hamburg 13.7%) led everyone.

New: **Learned Elite** static modifier (`lo_learned_elite`, research_speed_modifier 0.01 x size), size =
0.4 x (0.4 nobles + 0.35 clergy + 0.25 burghers literacy). Each estate's literacy is its own
pop-weighted average and the three are weighted by fixed weights, NOT by headcount. An estate without pops drops
out and its weight is shared. The vanilla average-literacy term (x1) is kept. Recomputed yearly
(`yearly_country_pulse`) and at game start. Files: `scripted_effects/lo_research_effects.txt` (one pass over the pops, local variables),
`static_modifiers/lo_static_modifiers.txt`, `on_action/lo_on_actions.txt`.

Expected 1511 (caps, pops at cap): Hamburg 13.7 + 20.3 = 34%, Florence 28, Brabant 26, Castile 25, Portugal 24,
Yuan 24, Morocco 23, England 19, Muscovy 19, Great Horde 14 (vanilla age 3 is about 20-25%).

| Law / policy | Before | Now |
|---|---|---|
| `education_elites_law` → `education_of_the_people` | B5, lower 5 | B5, lower 3 |
| `education_elites_law` → `education_of_the_court` | N5 | N10 |
| `education_elites_law` → `confucian_academies_education` | N5 | N10, B5 |
| `education_masses_law` → `apprenticeships_education` | N10 C10 B10 | N10 C10 B15, laborers 3 |

### Average control research halved (v0.20, 2026-11-21)
`average_control_50` (static) gives research 0.5 x (average control - 50%), so a one-location state such as Hamburg
always got a flat +25%. The Learned Elite bonus now rewards an educated elite, so this is halved: research 0.5 → 0.25
(+12.5% at 100% control; an empire at 30% control: -10% → -5%). `crown_power_from_population` is unchanged.
Clergy-satisfaction research (0.5 x (satisfaction - 50%), Catholics high via the tax exemption) is kept.

### Standalone: no RSF dependency (v0.21, 2026-11-21)
LO no longer ships `RSF_christian.txt`, which carried RSF's religion edits to players without RSF. Orthodox (upper 5 /
lower 0) and Miaphysite (clergy +5) are generated from vanilla `christian.txt` as REPLACE_OR_CREATE like everything
else. RSF's `TRY_REPLACE` of those religions wins over that, so for RSF players the regen script also writes a
separate mod **`mod/Literacy overhaul - RSF compatibility`**: a same-path override of RSF's `RSF_christian.txt` with
the same literacy lines. Load it after RSF and LO. It is skipped if RSF is not installed.

### Mesoamerica and Hellenism (v0.22, 2026-11-21)
| What | Before | Now |
|---|---|---|
| Religion `mayan` | — | clergy +10, nobles +5 (glyphic writing: ah k'in priests, ah tz'ib scribes, codices) |
| Religion `nahuatl` | — | clergy +5 (temple tlacuilo scribes, tlamatinime) |
| Religion `mesoamerican` (Mixtec / Zapotec) | — | clergy +5, nobles +5 (genealogical codices) |
| `calmecac` (Nahua capital) | nobles +20 local / +10 country | + clergy +10 local / +5 country (it trained the priests too) |
| `epic_poetry_advance` (Hellenism) | all 5 | upper 5 / lower 2 |

Kept at 0: Inti (khipu accounting, no writing), Chichimec. telpochcalli (commoners' military school) gives no literacy.

### Institution spread compensation (v0.23, 2026-11-21)
Institution spread (`script_values/institution_spread.txt`) is ~proportional to the receiving location's
`average_location_literacy`, which is ~the lower-class cap. Stratification cut it ~x2.5-3.3 in every age (vanilla saves
1416-1707 vs an LO model, `tools/vanilla_vs_lo_average_literacy.md`), so institutions spread and were embraced 2-4x later
(Muscovy without age-2 institutions in 1488, Ottomans late to embrace professional armies).
Same-path override generated from vanilla: `multiply = 3` right after each of the 18 `value = average_location_literacy`
lines (tiers early / mid / late, all x3 as a starting value; `$INST_F` in the regen script). The development part of
trade spread is unchanged. Other mods that override this file conflict.

### Lower classes in ages 3-6 (v0.24, 2026-11-21)
An observer run (saves 1450-1740 parsed with `tools/save_literacy.awk`) showed peasant/laborer literacy sitting AT
its cap and barely moving for 300 years: France 5.1 (1508) -> 6.6 (1740), Britain 10, Muscovy 2.5. Catholic France in
1740 had only written alphabet 2 + scientific revolution 2 + basic religious education 2 + innovative ~1 = 7; the AI
rarely takes humanism, free press or the education act. Historically, overall literacy c. 1740 was roughly France 25%,
England 40%. Only generic advances that every country gets are raised:
| What | Before | Now |
|---|---|---|
| `printing_press_advance` (age 3) | upper 5 / lower 0 | upper 5 / lower 4 (primers, chapbooks) |
| `scientific_revolution_advance` (age 5) | upper 10 / lower 2 | upper 10 / lower 3 |
| `newspapers_advance` (age 5) | — | lower 4 (cheap press, almanacs) |
| `enlightened_court` (age 6) | upper 5 / lower 2 | upper 5 / lower 3 |

Model, lower cap in 1740: France 7 -> 16, Britain 10 -> 19, Castile ~7 -> ~16, Ottomans ~6 -> ~15 (the Ottoman
printing ban is not modelled), Muscovy 2.5 -> 6.5-11.5 depending on how far behind in advances it is. 1555 (printing
only): France ~5 -> ~9. Vanilla/LO average then drops from ~x3-4 to ~x2.4-2.7, so the institution-spread x3 may now be
slightly high (to re-check in the next run before touching it).

### Muscovy and church schools (v0.25, 2026-11-21)
In the 1337-1740 observer run Catholic Lithuania left `uneducated_masses` on its own, but Muscovy never did (the default
first option; the nobles outweigh the clergy). It also never took `lo_stoglav`, which gives only clergy literacy and
which the AI values at ~0.
- `lo_stoglav`: `ai_weight = { add = 100 }`.
- `basic_religious_education`: `ai_will_do` +100 with `lo_stoglav` (the Stoglav council of 1551 ordered schools at
  the churches). The AI law score is otherwise hardcoded (modifier utility + estate_preferences); `ai_will_do` is the
  only scripted lever, so this is a nudge and may still lose to strong nobles.

### Cardinal seat (v0.26, 2026-11-21)
| What | Before | Now |
|---|---|---|
| `seat_of_cardinal` (building) | local all 2.5 | local clergy 5 / burghers 2 (the cardinal's familia of clerics, secretaries and notaries, not a town school) |

### Burghers and the printing press (v0.27, 2026-11-21)
France in the observer run: nobles 44 -> 57, clergy 70 -> 84 (much of it at the 100 ceiling), burghers 34 -> 46
(1605 -> 1740). Burghers were the lowest elite; printing was a burgher trade and a burgher market.
| What | Before | Now |
|---|---|---|
| `printing_press_advance` (age 3) | nobles / clergy / burghers 5, lower 4 | nobles / clergy 5, **burghers 10**, lower 4 |

Expected France burghers ~39 (1605) / ~51 (1740). Clergy is left as is: late Catholics reach the 100 ceiling, so more
clergy bonuses do little there.

### Elites around 1800 (v0.28, 2026-11-21)
France 1800 country caps, decomposed from the save to the decimal: nobles 68.44 (advances 40 + basic religious
education 10 + education of the court 10 + enlightened aristocracy 5 + innovative 3.44), burghers 48.44 (advances 40 +
law 5 + innovative), clergy 78.44, lower 17.03, plus global 2. Historically (rough) nobles ~85-90%, the urban bourgeoisie
~65-75%. France, Castile, Sweden and Milan never took `global_nobles_max_literacy_advance` although they had its
prerequisite.
| What | Before | Now |
|---|---|---|
| `global_nobles_max_literacy_advance` (age 2, nobles 10) | no AI weight | `ai_weight = { add = 50 }` |
| `newspapers_advance` (age 5) | lower 4 | nobles 5, burghers 5, lower 4 (journals, salons, coffee houses) |
| `enlightened_court` (age 6) | upper 5 / lower 3 | nobles + clergy 5, burghers 10, lower 5 (Enlightenment school reforms) |

Expected France 1800: nobles ~85, burghers ~60 + town buildings, lower ~21 (mass schooling stays with the age-6 laws
and the Protestant aspects).

### Protestant literacy in the religion itself (v0.29, 2026-11-21)
The AI never picks the literacy aspects: in the 1605 / 1687 / 1800 saves no Lutheran country had `translated_bibles` or
`pietism` (aspects are bought for 50 religious influence and chosen by `modifier_utility`, which values literacy at ~0),
and Anglican countries had no aspects at all (the Anglican church spends its influence on church-power actions). So an
AI Protestant only had its religion base: Britain 1800 clergy 74 vs France 91, lower classes 22 vs 19. The guaranteed
part moves into `definition_modifier`; the aspects stay as extras.
| Religion | Before | Now |
|---|---|---|
| `lutheran` | clergy 15, lower 3 | clergy 20, nobles 5, burghers 5, **lower 8** (catechism, school church orders, Swedish church law 1686) |
| `calvinist` | clergy 15, lower 3 | clergy 20, burghers 5, lower 6 (Geneva, Scottish and Dutch parish schools) |
| `anglican` | clergy 15, nobles + burghers 5, lower 2 | clergy 25, nobles + burghers 10, lower 5 (Oxbridge clergy, grammar schools, Prayer Book, SPCK charity schools) |

Lutherans are now the strongest mass-literacy church, as Sweden and northern Germany were historically.

### Education of the court (v0.30, 2026-11-21)
| What | Before | Now |
|---|---|---|
| `education_elites_law` → `education_of_the_court` | nobles 10 (vanilla 5) | nobles 15 |

### Research balance and institution spread (v0.31, 2026-11-21)
Research from 18 embraced institutions (+5% each = +90%) dwarfed literacy (France 1800: +21% average + 29% Learned Elite).
Simulated on the observer saves 1450-1800 (11 big countries; institutions, average literacy and elite index per save):
| Variant (per institution / elite k) | Avg research bonus 1450 → 1800 | Literacy share |
|---|---|---|
| 0.05 / 0.4 (before) | +43% → +132% | ~30-36% |
| **0.04 / 0.6 (now)** | +46% → +129% | ~43-50% |
| 0.035 / 0.7 | +47% → +127% | ~50-56% |

No age gets faster or slower by more than a few points (elite literacy grows roughly like the institution count).
- `num_embraced_institutions` (static): research 0.05 -> 0.04 per institution.
- `lo_learned_elite` size: 0.4 -> 0.6 x the weighted elite index.
- Institution spread compensation (`$INST_F`): ages 1-2 x3, ages 3-4 and 5-6 x3 -> x2.5 (printing press, newspapers and
  the Protestant religions raised the lower caps; observer saves 1760-1800 vs vanilla 1707 give ~x2.3-2.5).

### Observer run to 1500: AI choices, burghers, Orthodoxy, Islam, growth (v0.32, 2026-11-21)
A new observer run (cuts 1375 / 1400 / 1450 / 1500, parsed with `tools/save_literacy.awk` and
`tools/save_institutions.awk`) showed:
- the AI skips the age-2 burgher literacy advance for 100+ years (1375: 1 of 17 big countries; France, Austria and Milan
  still without it in 1500) and often the clergy one;
- burghers far below history (1500: Florence 44, France 21);
- Muscovite nobles above every Western nobility (start cap 37 vs 32): the Orthodox profile gave the nobles +5;
- the ulema had no religion base (Ottoman clergy 42 vs Catholic 56-86 in 1500);
- growth in ages 1-2 is only written_alphabet's 0.01/month, so a +10 cap takes 60-80 years to fill.

| What | Before | Now |
|---|---|---|
| `global_burghers_max_literacy_advance`, `global_clergy_max_literacy_advance` | no AI weight | `ai_weight = { add = 50 }` |
| `banking_advance` (needs banking → Italy first) | — | burghers 10 (abacus schools, double-entry bookkeeping) |
| `renaissance_advance` | — | nobles 5, burghers 5 (humanist schools) |
| `printing_press_advance` | — | `global_monthly_literacy` 0.01 (doubles the growth) |
| `orthodox` (+ the RSF compatibility patch) | upper 5 | clergy 10, burghers 5, nobles 0 (monastic book culture) |
| `sunni`, `shia`, `ibadi` | — | clergy 10 (madrasa ulema); the school bonuses stay on top |
| `sanjiao` | upper 8, lower 3 | nobles 13 (scholar-gentry), clergy / burghers 8, lower 3 |
| `borough_customals` (British town right) | local all 5 | local burghers 5, laborers 2 |

Kept: early institution spread x3 (slower spread left e.g. Muscovy with nothing to research before 1450); Learned
Elite k 0.6 (the late game has leftover early advances to research).

### Greek nobility (v0.33, 2026-11-21)
v0.32 took the nobles +5 out of the Orthodox profile; the Byzantine aristocracy (grammar and rhetoric from private
teachers and the Constantinople schools, Attic Greek in office) gets it back via its culture:
| What | Before | Now |
|---|---|---|
| new advance `lo_byzantine_paideia` (age 1, culture group `greek_group`, requires written_alphabet, ai_weight 50) | — | nobles 5 |

### Print, Lutherans and madrasas (v0.34, 2026-11-21)
Observer cuts 1550 / 1600 (run c03b841a): Ottoman and Moroccan peasants (8.9 / 10.4) were above Catholic France (8.6),
Sweden was massively literate right after the Reformation (peasants 15.5 in 1550).
| What | Before | Now |
|---|---|---|
| `printing_press_advance` | nobles/clergy 5, burghers 10, lower 4, growth 0.01 | nobles/clergy 5, burghers 10 |
| new `lo_printed_primers` (age 3, requires the printing press, research cost x0.5, ai_weight 50) | — | lower 4, `global_monthly_literacy` 0.01; Muslims only from age 5 (Muteferrika 1727) |
| `lutheran` | lower 8 | lower 4 (catechism, school church orders) |
| new `lo_church_reading_examinations` (age 5, Lutherans, research cost x0.5, ai_weight 50) | — | lower 4 (Swedish church law 1686, Pietist schools) |
| `freedom_of_interpretation` (Muslim clergy privilege) | upper 5, lower 2 | clergy 10, burghers 5, nobles 2.5, lower 0 |
| madrasa academy advances (`mor_marinid_madrasas`, `fez_qarawiyyin_school`, `bah_madrasa_of_mahmud_gawan`, `hassaniya_shinqit_libraries`, `tunisian_maliki_heartland`) | academy rule upper X / lower X/3 | upper X / lower 0 |
| `monument_qarawiyyin` (Fez) | local all 2.5 | local clergy 10, burghers 2.5, nobles 2.5 |
| `monument_bou_inania_madrasa` (Fez) | local all 2.5 | local clergy 5 |
| `al_azhar_madrasa` (event) | local all 5, growth 0.1 | local clergy 10, burghers 2.5, growth 0.1 |
| `mahmud_gawan_madrasa` (event) | local all 5, growth 0.15 | local clergy 10, nobles 2.5, growth 0.15 |

Madrasas trained the ulema and the urban elite; the village kuttab / msid taught Quran recitation, not reading.

### TRY_INJECT experiment failed - RSF compatibility patch restored (v0.36, 2026-11-21)
v0.35 replaced the Orthodox / Miaphysite redefinition with `TRY_INJECT` deltas to make the RSF patch unnecessary. In game
(RSF + LO, LO last) the Orthodox "+5 Max Literacy" was still there: RSF's `TRY_REPLACE:orthodox` is applied after (and
wipes) an inject from a later-sorting file of a later mod, just as it beat `REPLACE_OR_CREATE`. v0.35 is reverted: LO
generates orthodox / miaphysite from vanilla again and the separate **Literacy overhaul - RSF compatibility** patch
(same-path override of RSF's file) is generated again. Only a same-path file override beats another mod's `TRY_REPLACE`.

### RSF with TRY_INJECT confirmed (2026-11-21)
If RSF defines `orthodox` / `miaphysite` with `TRY_INJECT` instead of `TRY_REPLACE` (the author's choice; tested with a
locally patched RSF), LO needs no compatibility patch: LO's literacy applies and RSF's own changes (opinions, goods
demand) survive on top of LO's redefinition. The regen script detects this and skips the patch. With the official RSF
(`TRY_REPLACE`) the **Literacy overhaul - RSF compatibility** patch is still required.

### Other mechanics that read literacy (v0.37, 2026-11-21)
Stratification lowers the country / location average ~2-2.5x (and peasant literacy to ~40% of vanilla). Vanilla
mechanics that read it, and what LO does:
| Mechanic | Vanilla | LO |
|---|---|---|
| `paper`, `books` demand (`literacy_demand_factor`) | 1 | **2** (keeps the vanilla market size) |
| peasants' `literacy_impact`: pop promotion speed at 100 literacy | +200% | **+400%** |
| `eng_royal_society_decision`: capital average literacy | > 50 (London ~22 in LO: unreachable) | **> 25** |
| `aspiration_for_liberty`: country average literacy (or great power + absolutism) | > 50 | **> 22** |
| `revolution_disaster`: country average literacy (or great power + absolutism) | > 55 | **> 25** |
| Catholic `zeal_literate_realm` (scholars' zeal) | average / 12 | **average / 5** |

Left as is: the other pop types' `literacy_impact` (nobles: cultural tradition and control, clergy: conversion and
assimilation, burghers: development, trades and establishment speed - all higher in LO; laborers: production
efficiency +2.5% at 100 and RGO size +10%; soldiers: defence and manpower +10% - small); literacy raising pops' sensitivity
to market prices (LO peasants are slightly calmer); the Reformation movements' `literacy = positive` spread weight; the
plausible birthplaces of the scientific revolution and the Enlightenment (university + location literacy > 30: 75
locations qualified in a 1740 LO run, Cambridge among them).

### Sola scriptura events (v0.38, 2026-11-21)
`church_aspects.12` (sola scriptura + printing press, country average literacy > 30: religious influence / clergy /
stability bonus) and `church_aspects.13` (< 30: penalties). With stratified literacy Protestants sit at ~15-25, so they
always got the penalty. Threshold 30 -> **13** in both (vanilla/LO average ~x2.3), via a generated same-path override of
`in_game/events/religion/church_aspects.txt` (only those two lines differ; removed with a warning if they change).
No trigger in the game reads MAX literacy; the other current-literacy uses (Chinese examinations, succession-crisis
chronicle, a mission research bonus, town-rights event penalty x literacy, "most literate" orderings) are small or
relative and left as is.

### Audit of every remaining "all classes" source (v0.39, 2026-11-21)
`tools/audit_literacy.sh` builds the EFFECTIVE set (vanilla shadowed by same-path files of RSF / Legacy of Timur / Urban
limit / Latin East fixes, every key LO redefines replaced by LO's version) and lists (A) all-class max literacy still in
effect and (B) anything >= 20. Fixed now:
| What | Before | Now |
|---|---|---|
| `bavarian_academy_of_sciences` (event building) | local all 20 | upper 20 |
| `munich_residenz_baroque_expansion` / `_renaissance_expansion` | local all 20 / 10 | nobles 20 + burghers 10 / nobles 10 + burghers 5 |
| `herrenchiemsee_abbey` | local all 15 | clergy 15, nobles 5 |
| `usa_academy_of_arts_and_sciences` | local all 10 | upper 10 |
| `adm/dip/mil_vatican_library` | local all 5 | clergy 10, nobles 5 |
| `bibliotheca_corviniana`, `library_of_vijayanagar`, `usa_philosophical_society`, `city_of_victory` | local all 5 | upper 5 |
| `royal_audience_and_chancery` | local all 5 | nobles 5, burghers 5 |
| `adu_jewish_community` | local all 5 | burghers 5, clergy 5, lower 2 |
| `academy_of_sciences` | local all 1 | upper 1 |
| static `scientific_revolution_birth` / `printing_press_birth` | local all 10 / 5 | upper 10 / upper 5, lower 2 |
| static `greek_administrative_center_modifier` | local all 5 | nobles 5, burghers 5 |
| static `MLO_library_research`, `lettered_cloister_modifier`, `por_estudo_geral`, `magnet_for_scholars` | local all 5 / 5 / 1 / 0.1 | upper 5 / clergy 5 / upper 1 / upper 0.1 |
| law `keju_examination` (`new_keju_formats_policy`) | all 5 / 3 | nobles + burghers 5 / 3 |
| law `sect_school_law` (`kadam_policy`) | all 5 | upper 5, lower 2 |
| religious order `scholars_calling` | local clergy 5 + all 5 | local clergy 10, burghers 2.5 |
| aspect `worship_odin_god` | all 5 | upper 5, lower 2 |
| advance `quipu` (Inca) | clergy 20 | clergy 5, nobles 5 (khipu = knot records, not writing) |

Deliberately kept for all classes: mass-schooling advances (terakoya, hangeul, gurmukhi, Albanian alphabet, Komisja
Edukacji Narodowej, Dutch / Scottish / Slovak education, colonial free thinkers), `secular_education`,
`written_alphabet`, Judaism, `sola_scriptura`, Sikh `young_humility`, `rama_avatar` (2), `dev_educated_women` (2).
>= 20 left: `feudalism_advance` nobles 20, Catholic clergy 25, Anglican 25 / Lutheran / Calvinist clergy 20, `calmecac`
nobles 20 (local), and the new upper-class values above.

### Growth-speed outliers and guilds (v0.40, 2026-11-22)
Literacy grows toward the cap by `global_monthly_literacy` + `local_monthly_literacy` per month. The background is
~0.02-0.04 (written_alphabet + 1-2 advances), one advance gives 0.01-0.02, so a country-wide +0.1 brought every pop
below its cap (new elite pops start at ~7-9) up to it decades earlier. Local growth (one location: wonders, orders,
centres of learning) is kept.

| What | Before | Now |
|---|---|---|
| trait `reverend_teacher` (Muslim scholars and gurus only; stacks per figure, ~100 alive in 1400) | 0.1 | 0.02 |
| static `invited_foreign_cleric_modifier` (decaying, 5 years, AI re-invites) | 0.33 (LO 0.1) | 0.05 |
| static `community_schools` / `literacy_drive` (societal values events, 5-10 years) | 0.1 | 0.04 |
| static `melantrichs_efforts` (Bohemia, 10 years) | 0.1 | 0.04 |
| building `papal_archives` (country-wide, permanent) | 0.1 | 0.03 |
| parliament issue `compulsory_education_nobles` (while in debate; same-path override of `01_country_specific_parliament_issues.txt`) | 0.2 | 0.05 |

Advance `guilds` (age 1, burghers +5 and burgher city pop) has no vanilla `ai_weight`; in the 1400 cut of the new run
19 of 170 countries with >= 300k pops still lacked it with 100+ advances (Milan, Genoa, Naples, Aragon, Sicily,
England, the Ottomans) -> `ai_weight = { add = 50 }`.

### Universities without monasteries; Russia's universities in age 5 (v0.41, 2026-11-22)
Run 3 (v0.40), 1600-1650: a Lutheran city could never build a university (Lund: clergy cap 80 < gate 85), because
Protestants have no monasteries (+10) and no cardinal seats (+5); a Catholic city without a monastery sat at exactly 85
and passed only on the innovative societal value. Meanwhile Muscovy/Russia had 6 universities by 1650 (Moscow, Tver,
Vladimir, Novgorod, Pskov, Smolensk; clergy 90-100: Stoglav 10 + anagignoskomena 5 + Orthodox 10 + Orthodox monastery 5).
The Ottoman ones (Constantinople, Athens, Kaffa, Dubrovnik...) were mostly conquered, not built - left as is.

Clergy cap without a university, temple + cathedral + library, gate > 85 (fortress church not counted):

| Catholic (30) | without monastery | + monastery | + monastery + cardinal seat |
|---|---|---|---|
| age 1 | 75 | 85 | 90 |
| age 2 | 85 | 95 | 100 |
| age 3+ (printing) | 90 | 100 | 100 |

| Change | Before | Now |
|---|---|---|
| Catholic definition clergy (also in the RSF compatibility patch: RSF `TRY_REPLACE:catholic`) | 25 | 30 |
| Lutheran / Calvinist / Anglican / Hussite definition clergy | 20 / 20 / 25 / 15 | 30 |
| `lo_stoglav` (Russians, age 4) | clergy 10 | burghers 5, lower 2 (the priest-house schools it ordered) |
| new `lo_kyiv_mohyla_learning` (Orthodox, age 5, requires national_rites) | - | clergy 10, nobles 5 |
| university gate: burghers | > 25 | > 40 (25 never binding after 1454) |
| `lo_church_reading_examinations` ai_weight | 50 | 200 (Sweden, Brunswick, Bohemia, Brandenburg skipped it) |
| `lo_printed_primers` | Muslims from age 5 | Muslims and Orthodox from age 5 |

Russian city in age 4: 37 common + Orthodox 10 + anagignoskomena 5 + local 28 = 80 (83-85 with the patriarchate tenet)
-> no university; age 5 with Kyiv-Mohyla learning: 90. Gate clergy stays > 85: a gate of 80 tested on the saves would
have opened 53 Chinese, 44 Sunni and 13 Theravada candidate cities by 1650.

### Orthodox clergy 10 -> 5 (v0.42, 2026-11-22)
The v0.41 estimate missed two Muscovite sources: the uneducated_masses law also gives clergy +10 (as
basic_religious_education does), and the patriarchate tenet Allow Christological Debates +5 was already there in 1500.
Moscow clergy cap in 1500 was 81 (screenshot), + printing 5 = 86 > 85 -> a university in age 3. Orthodox definition
clergy 10 -> 5: Moscow 76, 81 with printing (no university), 91 in age 5 with lo_kyiv_mohyla_learning.

### Observer run 4 (1500-1800) package (v0.43, 2026-11-22)
Findings from run 4 (v0.42, cuts 1566-1800) and what changed:

| Area | Change | Why (run 4) |
|---|---|---|
| `gurgaddi` (Sikh foreign building) | local clergy 10 -> burghers 5, lower 2 | spread 4 -> 384 buildings; every Hindu and half the Chinese universities sat on one |
| `free_thinkers` (colonies) | all 5 -> nobles 5, burghers 5, lower 2 | freedom of speech = merchants, planters, pamphleteers |
| `komisja_edukacji_narodowej` (Poland) | all 10 -> upper 10, lower 5 | 1773 commission reformed academies; parish schools barely reached serfs |
| new building `lo_latin_school` (Lutheran / Calvinist / Anglican) | nobles 5, burghers 5, growth 0.1 (= LO Jesuit college) | Stockholm burghers 69 vs Florence 91 at the same country cap |
| Protestant definitions | burghers Lutheran/Calvinist 5 -> 10, Anglican 10 -> 15; Lutheran lower 4 -> 5 | Northern merchant towns; Lutherans stay ahead of the Catholic teaching orders |
| `lo_church_reading_examinations` | lower 4 -> 5 | same |
| `lo_kyiv_mohyla_learning` | ai_weight 100 -> 200 | Russia had not taken it by 1700 |
| `lo_printed_primers` | from age 3 only in print cultures (`lo_print_culture`: Western churches, sanjiao, mahayana, shinto), others age 6 | 1800 peasant caps of Turkey and Britain were identical (20) |
| new `lo_popular_press` (split off `newspapers_advance`) | lower +4; Muslims and Orthodox only from age 6 | first Ottoman newspaper 1831 |
| new `lo_enlightened_pedagogy` (split off `enlightened_court`) | lower +5, Western churches only | Prussia 1763, Austria 1774, Felbiger, Pestalozzi |
| new `lo_teaching_orders` (Catholic, age 5) | lower +5 | Ursulines, Piarists, La Salle; France 1800 lower cap 20 -> 25 (Lutheran 30) |
| `basic_religious_education` | ai_will_do +100 with `printing_press_advance` | 62 of 205 big countries still on uneducated masses in 1751 |
| `secular_education` | ai_will_do +100 with Enlightenment and crown > clergy | enlightened absolutism |
| `education_elites_law` | mixed +10% / people +15% institution growth; estate-gated ai_will_do for mixed, people, clerical | 1500-1751: mixed 0, people 0, clerical 0-1 countries |
| `press_law` | censored +100 (Catholic/Protestant with printing institution), free +150 (burghers > crown) | 1751: state-only 531, censored 8, free 9 |
| university | max 2 per area (`$UNI_AREA_CAP`), local institution growth 0.66 -> 1.0 | 1800: 915 universities (HRE 140, Wu 138); per-area cap sim: Italy ~21, Germany ~50, France ~18 |
| `lo_university_research` (yearly, `lo_research_effects.txt`) | +2% research per university, max 5 | vanilla universities give no country research |
| institution spawn (same-path overrides of 4 institution files) | renaissance, printing press, sci rev, enlightenment `promote_chance` x2 in university towns | rarer universities should matter |

Estimated 1800 peasant caps after the package: Turkey / Morocco / Punjab 20 -> ~11, Russia ~15, France 25, Lutheran
Prussia 30 (38 with secular education). Not tested in a run - check error.log after loading (new: scripted_triggers
`lo_print_culture_triggers.txt`, building `lo_latin_school` + icon, institution overrides, law ai_will_do blocks).

### error.log fixes (v0.43.1, 2026-11-22)
- `lo_latin_school` `remove_if`: `owner = {` -> `owner ?= {` (thousands of "Event target link 'owner' returned an invalid
  object" for unowned locations).
- An advance's requirement must be of the same age ("not in the same age as its requirement"): `lo_teaching_orders`
  (age 5) required `printing_press_advance` (age 3), and `lo_kyiv_mohyla_learning` (age 5) has required `national_rites`
  (age 4) since v0.41 - probably why Russia barely took it. Both now require `sanitation_advance` (age-5 root, like
  `lo_church_reading_examinations`).
- Checked clean in the same log: print-culture triggers, institution overrides, law AI blocks, the per-area university
  cap, the new advances and localisation. (A one-off batch of "Scoped object of type 'country' is not valid" in
  building `country_potential`s also hits vanilla buildings - an engine check on a dead country, not LO.)

### Elite-education laws (v0.44, 2026-11-22; observer run 5 from 1337 with v0.43.1, cuts 1500-1650)
- `education_of_the_people` is now an Enlightenment law: `allow = { has_embraced_institution = institution:enlightenment }`
  (the AI took it in 1500-1640 - Spain, Portugal, the Pope, Bavaria, Metz). As a late law it is worth more: burghers
  5 -> 10, lower classes 3 -> 5 (the vanilla value again). Growth 0.15 and the nobles/clergy penalty stay.
- AI weights: "the strongest of nobles, clergy and burghers picks the law", mutually exclusive:
  `education_of_the_court` +100 (new) if nobles beat burghers and clergy; `clerical_institutions` +100 (Catholic age
  4-5 / Orthodox with Kyiv-Mohyla) if clergy beat nobles and burghers; `mixed_institutions` +100 (Renaissance, before
  age 5) if burghers beat nobles and clergy. Before, mixed and clerical only compared with the nobles, so both could
  fire and Spain and Naples left the clerical law for mixed. With no winner the vanilla AI decides (mostly forums of
  thought: Protestants, non-Christians, burgher states in age 5).
- Every estate gate is sticky (`OR = { has_policy = <this law> ... }`): a held law keeps its +100 when the estates
  are close, so the AI does not switch back and forth. (Run 5 showed the opposite problem - strong inertia: Poland
  kept forums of thought from 1425, Great Britain from 1412.)
- Run 5 checks without changes: 67 universities in 1500, 87 in 1550, 110 in 1600, 122 in 1650 (Italy 21, Germany 28,
  France 17 in 1650); Lutheran burghers 68 / peasants 17 vs Catholic 56 / 11.5 in 1650. Peasants slightly above their
  maximum (Milan 12.2 > 11.1) are the vanilla innovative societal value (lower +3 scaled by the slider) drifting back -
  literacy above the cap does not decay.

### Mass-education ladder (v0.45, 2026-11-23)
- AI weights now form a ladder, so a country climbs when it qualifies: `basic_religious_education` +100 (printing press /
  Stoglav, unchanged) < `apprenticeships_education` +150 (new: burghers stronger than nobles and clergy, sticky) <
  `personal_religious_education` +200 (new: Protestant with the printing press) < `secular_education` +300 (was +100;
  Enlightenment and crown stronger than clergy).
- `personal_religious_education` (vanilla: all classes 5; Protestants or the clergy's printing privilege) is now a step
  above basic religious education: nobles / clergy / burghers 5 -> 10, lower classes keep 5 (basic: N10 C10 B5 L2).
- Why (run 5, 1650): Land of Commerce (the burgher privilege that unlocks apprenticeships) was held by 236 countries,
  including Venice, Poland, Portugal, Nuremberg and the Fuggers, but only 19 Asian countries took apprenticeships -
  the +100 for the printing press on basic beat it; personal religious education had 0 holders in every cut.

### Run 5, 1700 cut (v0.46, 2026-11-23)
- **Protestant double counting.** v0.29 put the Protestant literacy into the religions because the AI never took the
  aspects; in run 5 (1700) `sola_scriptura` was held by 98 countries (most German Lutherans, Holland, Austria, Bohemia)
  and `translated_bibles` by 8, on top of the definitions. Olomouc Lutheran burghers without a university had 103 of
  cap sources (Catholic town ~78). Now: `sola_scriptura` (vanilla all 5) and `translated_bibles` (LO upper 5 / lower 5)
  give the lower classes 5 only; `personal_religious_education` burghers 10 -> 5 (nobles/clergy 10, lower 5). Lutheran
  town ~88 (London, Anglican, no university: 89), university town ~98; Protestant peasants unchanged.
- `apprenticeships_education` clergy 10 -> 0 (vanilla value; guild apprenticeship does not teach monks). Indochina
  went from 2 to 15 universities in 1650-1700: Angkor clergy cap 87.8 = 77.8 + apprenticeships 10, gate 85.
- `epic_tradition_education(_sects)` (vanilla: artists only, 1 holder) is now the literate tribes' and hordes' school:
  nobles 10, burghers 5, lower 2 (court epic and chronicles - Shahnameh, Dede Korkut, Manas, Jangar), AI +100 for
  tribes and steppe hordes (beats oral_tradition, which gives no literacy).
- Kept: Learned Elite 0.6. Against vanilla saves (1502, 1527, 1707) the West researches 10-20% faster from 1500 on
  (vanilla literacy is nearly flat worldwide: Ottomans 22 = France 19 in 1500), the rest of the world -5..+3%.

### Run 5, 1750-1800 cuts (v0.47, 2026-11-23)
- **Clergy satisfaction research bonus halved** (`in_game/common/estates/zz_lo_estate_injects.txt`,
  `TRY_INJECT:clergy_estate = { satisfaction = { research_speed_modifier = -0.25 } }`, vanilla 0.5 -> 0.25, up to
  +12.5%). The AI keeps Catholic clergy content (34 of 53 Catholic countries above 75% in 1800, +16.6% research on
  average) and taxes the other churches to ~50% (Protestants -0.8%), which cancelled the whole Protestant literacy lead:
  1800 research Catholic 173% vs Protestant 167% -> 165% vs 168%.
- **University area cap 3 in the German lands** (`north_german_region`, `south_german_region`), 2 elsewhere. Germany
  had ~14 universities in 1750 (historically ~35-40) with its areas full at 2. Region rather than HRE membership, which
  varies by game and disappears with the Empire.
- **Sola Scriptura** + `monthly_religious_influence = 0.1` (like parish registers, soli deo gloria, pietism): the AI
  picks aspects by modifier utility, and after v0.46 (lower classes only) the holders fell from 98 (1700) to 2 (1800).
- `ruthenia_commoner_education` lower classes 10 -> 5 by a TRY_INJECT delta (`advances/zz_lo_advance_injects.txt`) - RSF
  redefines it for the UKR tag only, and a delta keeps either potential.
- `ser_the_transcribers_of_resava` (Serbia, age 3) all 5 -> clergy 10, nobles 5, burghers 5 (monastic copyists).
- Left as is after review: East Asian, Lithuanian and Russian universities (academies, Jesuit colleges, seminaries - by
  ages 5-6 clergy of every developed church reaches ~100, so the late limiters are development, burghers and the area
  cap); the steppe successor states lagging (expected).

### University places by development; Sola Scriptura again (v0.48, 2026-11-23)
- **University places per area = area development / 400, at least 1, at most 3** (`script_values/lo_university_values.txt`:
  `lo_area_university_places`, `lo_area_university_count`, `lo_area_university_room`, area scope; the university allow
  and `lo_university_site` check `area = { lo_area_university_room > 0 }` in a custom tooltip). Replaces "2 per area,
  3 in the German lands". Run 5 places in 1500/1600/1700: Italy 19/21/23 (history ~17/20/20), Germany + Low Countries +
  Switzerland 48/53/56, France 21/26/30, Iberia 19/24/28; Russia, Lithuania and Sweden mostly one per area. 500 and 600
  per place were rejected: in 1500 they leave Tuscany (954), Languedoc (850) and Provence (592) one place each.
- **Sola Scriptura** + `tolerance_own = 0.5`: with only `monthly_religious_influence = 0.1` (v0.47) the holders still
  fell from 98 (1700) to 24 (1725), the AI preferring war sermons and adult baptism.

### University places follow the confessional wave (v0.49, 2026-11-23)
- **Every area has 1 university place; a builder whose country embraced Confessionalism (age 4) may use up to 2
  places (one per 400 area development), with the Scientific Revolution (age 5) up to 3.** New script values
  `lo_area_university_places_2/3`, `lo_area_university_room_1/2/3`; the university allow and `lo_university_site`
  pick the tier by the owner's institutions. Why: the v0.48 rerun of run 5 from 1500 gave the German lands
  43 universities by 1550 (old run 23, history ~20; ~27 by 1600, ~33 by 1700) - their towns had already passed the
  literacy gate in 1500, so only the cap paced them. Confessionalism starts in Augsburg around 1540 and reaches about
  three quarters of the German states by 1600, much less of Italy, France and Iberia - the confessional university
  wave 1520-1620 (Marburg, Jena, Leiden, Dillingen, Olomouc, Graz). Small states still compete for the places.

### Two more university loopholes closed (v0.50, 2026-11-23)
- **`church_aspects.7`** (religious aspect `usury_allowed`: Lutheran, Calvinist, Anglican, Hussite, Lollard) option a
  built a free university in any town without a university or cathedral. It now builds the university only on a
  `lo_university_site` (literacy gate + area places), otherwise the cathedral of option b
  (`in_game/events/religion/church_aspects.txt`, already overridden for `.12/.13`).
- **`building.1`** ("scholars set up a rival university", `country_yearly` weight 10) built a free university in any
  core town of a province without one. Its trigger `building_1_new_university_trigger` now also needs
  `lo_university_site` (same-path override `in_game/events/economy/building_events.txt`, generated).
- Why: the v0.49 rerun had Provence's third university (Sisteron) built past the area cap. Historical flavour events
  (Leiden 1575, Frankfurt an der Oder, Uppsala, Copenhagen...) still bypass the cap on purpose.
- Run 5 rerun with v0.49, 1608: German lands 43 universities (1550: 35; run 5 1600: 28; history ~30 incl. the Low
  Countries, Switzerland, Austria and Bohemia) - the areas are nearly full, only 8 new in 1550-1608.
  Confessionalism 375 countries (run 5, 1600: 336) - same pace.

### Liturgical language halved in research; the Grand Embassy pays off (v0.51, 2026-11-24)
- **`liturgical_language_power` research_speed 0.2 -> 0.1** (generated `REPLACE_OR_CREATE`). The base research rate is
  `1 + k x language power`. Language power is stored in the save (`language_manager`, 1.0 = strongest) and is made of
  the political power of the pops in countries where the language is the court language, plus the clergy of the
  primary religion x20 where it is liturgical (verified: Church Slavonic 96.2 clergy x 20 = 1925 = 0.01824 x 105 435).
  Arabic is always 1.0, mostly from the Arab courts (court part ~78k of 105k), so every Muslim got +20% regardless of
  literacy: run 5, 1750, Ottomans 445 advances = France 444 at 8-13% literacy. Latin is 0.45-0.53, German ~0.21 (most
  Protestants switched to it), Church Slavonic ~0.02. Model of the change: world -3.5..-4%, Muslims -8.3%,
  Latin users -4..-5%, German-liturgy Protestants -2%, Orthodox ~0. Against the vanilla 1707 save, the leading West
  stays at or above vanilla. Run 5, 1750, advances by group: Catholic 441, Protestant 423, Muslim 393, Orthodox 355;
  size barely matters (small 423, medium 415, large 422); literacy <15 384, 15-30 427, >=30 434. City-states lead
  (Lubeck 502, Papacy 471).
- **Grand Embassy -> "Modernization on the Western Model"** (`government_reforms/lo_reforms.txt`,
  `lo_western_modernization_reform`).
  - Unique, age 5, **free**: it adds its own reform slot.
  - Effects: research +15%, nobles and burghers literacy +5, clergy target satisfaction -5%.
  - Available once the ruler has actually left on the vanilla Grand Embassy, whatever the outcome. The flag
    `lo_grand_embassy_undertaken` is set by the yearly `lo_grand_embassy_pulse` (`on_action/lo_on_actions.txt`) when
    `grand_embassy` is set but `grand_embassy_setup` (removed only by the expedition's on_start) is gone, or when the
    ruler has `on_grand_embassy`.
  - Why: the vanilla end reward is only +5..10 (of 100) progress of one missing institution and +1..2 army tradition.
    Russia lags far behind (366 advances in 1750 vs the Ottomans' 445).
  - History: Great Embassy 1697-98, Navigation School 1701, the 1714 schooling decree for noble sons, Academy of
    Sciences 1724, patriarchate abolished 1721.
- **The AI always goes**: generated same-path `expedition_types/grand_embassy.txt` with `ai_chance_to_check` 1 (was
  default x0.25 x dip/25) and `utility` 1000 (was 5; other expeditions 3-20). Observer runs 4 and 5 had 0 embassies by
  1800; in run 5 Russia unlocked it and never left. `lo_grand_embassy_pulse` also tops an AI's political influence up to
  100 while the embassy is unlocked but not started, for at most 10 years. Reason: the global
  `AI_PI_START_EXPEDITION_THRESHOLD = 99` blocks every AI expedition below 99 political influence.
- Note: a new tag inherits the old tag's events, so `flavor_mos.90` (`tag = MOS`) also fires for Russia.

### The modernization reform: Russian-only, with an AI weight (v0.51.1, 2026-11-24)
- `lo_western_modernization_reform` potential adds `OR = { has_or_had_tag = RUS has_or_had_tag = MOS }`, so the reform
  list shows it as a Russian national reform, like the Japanese `jap_rangaku`. Only Muscovy/Russia get the Grand Embassy
  anyway.
- `ai_will_do = 1000`. In the observer run (playthrough 6a819256, from 1700) Russia completed the embassy and the reform
  was available from about 1705, yet it was not adopted by 1740: Russia's 8 reforms included `oprichnina` and
  `cultural_recognition_act`. The AI values a free reform slot at only `AI_GOVERNMENT_REFORM_SLOT_UTILITY = 0.1`.
  The AI does swap reforms (it reviews them every 24 months; in run 5, 49 countries replaced reforms in 1700-1750), so
  the weight makes it replace one of its reforms with this one. The reform's own extra slot then lets it restore the
  replaced one.
- Correction (2026-11-24): an earlier note here reported an engine bug ("No suitable leaders available" for every
  ruler-led expedition). It was an artifact of observer mode: the country had been taken with the console `tag` command
  while still observing. After leaving observer mode and playing the country properly, Pilgrimage/Grand Embassy can be
  started normally. The AI is not affected.

### The AI gets the modernization reform directly (v0.51.2, 2026-11-24)
- `lo_grand_embassy_pulse` (yearly) runs `add_reform = government_reform:lo_western_modernization_reform` for an AI that has
  `lo_grand_embassy_undertaken` and lacks the reform. Why: even with `ai_will_do = 1000`, AI Russia had not adopted it by
  1750 (run 6a819256). Removing a reform to free a slot costs **20 stability** (`prices/00_hardcoded.txt`,
  `remove_government_reform`), and Russia sat at ~14; its reforms had not changed since 1586. `add_reform` needs neither a
  slot nor a price, and the reform brings its own slot, so nothing is displaced. A player still picks it from the list.
