# Average literacy: vanilla vs Literacy overhaul (for the institution-spread compensation)

Source: the "Average Literacy" line of the research-progress tooltip (= country average literacy, %).
Vanilla = user's old saves (game 1.4, RSF, no LO). LO = LO runs ("calc" = from the per-class caps in screenshots,
pops assumed at cap; "game" = read in game).

Institution spread (`in_game/common/script_values/institution_spread.txt`) is ~proportional to the RECEIVING
location's `average_location_literacy`; tiers: `_early` = institutions of ages 1-2, `_mid` = 3-4, `_late` = 5-6.
Goal: one multiplier per tier = median(vanilla / LO) at matching dates.

## Vanilla
| Country | 1416 (age 2) | 1483 (age 3) | 1527 (age 3) |
|---|---|---|---|
| Castile / Spain | 11.0 | 11.4 | 13.2 |
| France | — | 16.9 | 21.8 |
| England | 10.7 | 11.4 | 16.9 |
| Milan | 15.6 | 23.3 | 27.3 |
| Florence | 15.0 | 20.5 | 25.4 |
| Bohemia | 14.3 | 18.5 | 24.0 |
| Ottomans | 15.5 | 20.2 | 25.3 |
| Muscovy | 10.8 | 11.0 | 12.8 |
| Ming | 26.2 | 32.6 | 33.5 |

Vanilla 1416 lower-class caps (own + global): England 10, Castile 10, Muscovy 10, Bohemia 12.6, Florence 11.2,
Milan 11.8, Ottomans 15, Ming 30.2 -> the average ~ the lower-class cap.

## Literacy overhaul
| Country | ~1511 calc | game |
|---|---|---|
| Portugal | 5.9 | 6.1 (1511) |
| Castile | 5.9 | |
| England | 3.0 | |
| Muscovy | 3.1 | |
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
