# Average literacy: vanilla vs Literacy overhaul (for the institution-spread compensation)

Source: the "Average Literacy" line of the research-progress tooltip (= country average literacy, %).
Vanilla = user's old saves (game 1.4, RSF, no LO). LO = LO runs ("calc" = from the per-class caps in screenshots,
pops assumed at cap; "game" = read in game).

Institution spread (`in_game/common/script_values/institution_spread.txt`) is ~proportional to the RECEIVING
location's `average_location_literacy`; tiers: `_early` = institutions of ages 1-2, `_mid` = 3-4, `_late` = 5-6.
Goal: one multiplier per tier = median(vanilla / LO) at matching dates.

## Vanilla
| Country | 1416 (age 2) | 1483 (age 3) | 1527 (age 3) | 1584 (age 4) | 1656 (age 5) | 1707 (age 5) |
|---|---|---|---|---|---|---|
| Castile / Spain | 11.0 | 11.4 | 13.2 | 25.0 | 30.6 | 35.4 |
| France | — | 16.9 | 21.8 | 33.4 | 34.3 | 43.2 |
| England | 10.7 | 11.4 | 16.9 | 27.2 (Great Britain) | 35.6 | 52.0 |
| Milan | 15.6 | 23.3 | 27.3 | 35.1 | 39.7 | 51.0 |
| Florence | 15.0 | 20.5 | 25.4 | 41.4 | 38.9 | 47.9 |
| Bohemia | 14.3 | 18.5 | 24.0 | 28.7 | 34.4 | 43.3 |
| Ottomans | 15.5 | 20.2 | 25.3 | 34.9 | 36.9 | 37.2 |
| Muscovy | 10.8 | 11.0 | 12.8 | (player) | (player) | (player) |
| Ming | 26.2 | 32.6 | 33.5 | 32.1 | 36.5 (Xi an) | 38.5 |
| Brandenburg | — | — | — | 20.3 | 21.4 (Prussia) | 29.0 |
| Lithuania | — | — | — | 21.5 | 26.4 | 34.4 |
| Sweden | — | — | — | 22.2 | 22.8 | — |
| Morocco | — | — | — | 32.9 | 32.7 | 42.6 |
| Goryeo | — | — | — | — | — | 38.8 |
| Punjab | — | — | — | — | — | 32.4 |
| Alodia | — | — | — | 34.5 | — | — |

Vanilla 1416 lower-class caps (own + global): England 10, Castile 10, Muscovy 10, Bohemia 12.6, Florence 11.2,
Milan 11.8, Ottomans 15, Ming 30.2 -> the average ~ the lower-class cap.

## Literacy overhaul
| Country | ~1511 calc | game |
|---|---|---|
| Portugal | 5.9 | 6.1 (1511) |
| Castile | 5.9 | |
| England | 3.0 | | 35.6 | 52.0 |
| Muscovy | 3.1 | | (player) | (player) |
| Florence | 7.8 | |
| Brabant | 6.3 | |
| Bulgaria | 7.7 | |
| Morocco | 6.2 | |
| Hamburg | 13.7 | 14.7 (~1511) |
| Yuan (China) | 7.3 | |
| Great Horde | 2.3 | |

## Ratios so far (vanilla 1483 / LO ~1511)
Castile 1.9, Florence 2.6, Muscovy 3.5, England 3.8, China 4.5 -> median ~3.5 (mid tier).
Still needed: LO in-game values ~1416 and ~1483-1527 for the same countries; vanilla 16th-17th c. (late tier).

Note (1656): vanilla Lutherans are the LOWEST (Prussia 21.4, Sweden 22.8): vanilla `lutheran` has no literacy bonus,
while Catholics (+25 clergy), Muslims (`freedom_of_interpretation` all +5) and the Chinese (+25 all) have one. LO already
fixes this (Lutheran clergy 15 + lower 3, translated_bibles 5/5, pietism lower 5 in ages 5-6, personal_religious
all 5; freedom_of_interpretation -> 5/2), so in LO the vanilla/LO ratio is SMALLER for Lutherans than for Catholics.

## Model (LO cannot be measured at the same dates: without the compensation the whole LO world lags)
avg ≈ lower-class cap (95% of pops). Recompute the vanilla lower cap with LO values:
- France 1707 vanilla: global 45.22 (innovative 5.22, sci rev 10, printing press 10, written alphabet 5, education act 5,
  free press 10) + class lower 5 (religious teachings) = peasants 50.2. LO: innovative 3x52% = 1.6, sci rev 2, printing 0,
  alphabet 2, education act 2, free press 3 (laborers 5), religious teachings 2 = peasants 12.6 / laborers 14.6
  -> avg ~13 vs vanilla 43.2 = x3.3.
- 1416 (age 2): vanilla lower ~10 (alphabet 5 + religious teachings 5), LO ~4-4.5 -> x2.3-2.5 (Italy/Ottomans ~x2.6-3).
- ~1511-1527 (age 3): Portugal LO 6.1 (game) vs Castile vanilla 13.2 / median 24 -> x2.2-4, ~x3.
Earlier calc expected LO late-game lower ~25-35 (x1.5): WRONG, LO late lower ~13-15 -> late tier also ~x3.

## LO observer run v0.23 (institution spread x3), parsed from the saves with `tools/save_literacy.awk`
Cell = average literacy (all pops, size-weighted) / Learned Elite index (0.4 N + 0.35 C + 0.25 B).
| Country | 1450 | 1508 | 1555 | 1605 | 1687 | 1740 |
|---|---|---|---|---|---|---|
| Castile | 4.85/35.0 | 5.54/40.2 | 6.00/45.3 | 6.28/49.2 | 7.09/52.8 | 9.34/62.5 |
| France | 4.91/33.5 | 6.34/42.7 | 6.77/46.9 | 7.54/50.7 | 8.06/55.4 | 9.61/63.7 |
| Great Britain | 4.92/33.3 | 5.24/39.4 | 6.32/40.6 | 8.54/43.6 | 10.22/46.8 | 11.83/55.2 |
| Milan | 6.01/40.5 | 6.94/51.0 | 7.02/55.4 | 7.02/54.7 | 7.36/54.3 | 10.64/62.4 |
| Bohemia | 7.92/44.4 | 7.94/45.1 | 7.86/47.9 | 9.47/46.8 | 9.92/50.8 | 10.28/60.9 |
| Ottomans | 4.77/32.8 | 4.82/31.8 | 5.25/39.0 | 7.12/42.1 | 7.40/49.1 | 7.60/49.7 |
| Muscovy | 2.87/27.2 | 3.32/28.2 | 3.63/36.4 | 3.88/40.1 | 4.71/51.8 | 4.49/46.9 |
| Lithuania | 2.29/19.0 | 2.90/25.7 | 5.36/32.7 | 5.94/39.9 | 6.85/44.9 | 7.33/49.0 |
| Brandenburg | 4.95/36.4 | 5.73/45.4 | 7.46/39.1 | 8.29/41.8 | 8.69/50.9 | 9.95/59.2 |
| Sweden | 5.31/32.3 | 5.66/34.5 | 8.31/36.8 | 8.49/40.7 | 8.19/43.7 | 13.61/48.4 |
| Morocco | 4.16/38.5 | 4.94/41.4 | 5.55/45.1 | 5.61/45.4 | 5.74/46.1 | 9.41/59.1 |
| Korea | 8.22/53.3 | 9.56/57.2 | 10.46/58.7 | 10.68/63.5 | 10.82/64.4 | 13.69/76.8 |
| China | 8.11/33.7 | 9.10/46.6 | 10.00/51.9 | 10.03/52.0 | 10.43/53.3 | 10.42/55.7 |
| Hamburg | 12.82/53.4 | 18.50/70.1 | 19.83/69.8 | 19.29/70.5 | 22.27/72.2 | - |

Vanilla / LO (nearest dates; LO dates are later, so the true ratio is a bit higher):
- age 3 (vanilla 1483-1527 vs LO 1508-1555): FRA 2.7-3.2, ENG 2.2-2.7, CAS 2.1-2.2, BOH 2.3-3.0, TUR 4.2-4.8, MOS 3.3-3.5 -> ~3.
- age 4 (vanilla 1584 vs LO 1605): FRA 4.4, GBR 3.2, CAS 4.0, BOH 3.0, TUR 4.9, LIT 3.6, BRA 2.4, SWE 2.6, MOR 5.9 -> median ~3.6.
- age 5 (vanilla 1656/1707 vs LO 1687/1740): FRA 4.2/4.5, ENG 3.5/4.4, CAS 4.3/3.8, BOH 3.5/4.2, TUR 5.0/4.9,
  LIT 3.8/4.7, PRU 2.5/2.9, MOR 5.7/4.5, CHI 3.5/3.7, KOR 2.8, PUN 4.0 -> median ~4.
Lower classes are AT THEIR CAP (1740 peasant/laborer literacy clusters on integers: France 7, Britain 10,
Brandenburg 6-7) -> the late average is cap-limited, not growth-limited. The 1707 model (France lower 12.6) was too
optimistic: the AI does not get all the sources by 1740.
