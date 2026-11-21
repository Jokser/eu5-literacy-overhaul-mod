#!/usr/bin/env bash
# Literacy overhaul - audit of the EFFECTIVE literacy modifiers (Git Bash). Effective = vanilla, shadowed by same-path
# files of the active mods (in this order), and every key LO redefines replaced by LO's version.
# Prints: (A) remaining "all classes" sources (global_/local_max_literacy > 0), (B) any literacy modifier >= 20.
# usage: bash tools/audit_literacy.sh            (edit the mod roots below if the playset changes)
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"; LO="$(dirname "$HERE")"
G="/c/Program Files (x86)/Steam/steamapps/common/Europa Universalis V/game"
W="/c/Program Files (x86)/Steam/steamapps/workshop/content/3450310"
SRC=( "0vanilla|$G" "1RSF|$W/3608237308" "2LoT|$W/3604169106" "3Urban|$W/3688963094"
      "4LatinEast|$(dirname "$LO")/Latin East fixes" "5LO|$LO" )
T="$(mktemp -d)"; : > "$T/files.tsv"
for pair in "${SRC[@]}"; do src=${pair%%|*}; root=${pair#*|}; [ -d "$root" ] || continue
  (cd "$root" && find in_game/common main_menu/common -name "*.txt" 2>/dev/null) | while read -r rel; do
    printf "%s\t%s\t%s\n" "$rel" "$src" "$root/$rel"; done >> "$T/files.tsv"; done
sort -t$'\t' -k1,1 -k2,2 "$T/files.tsv" | awk -F'\t' '{last[$1]=$0} END{for(k in last) print last[k]}' > "$T/eff.tsv"
: > "$T/lines.tsv"
while IFS=$'\t' read -r rel src path; do awk -v src="$src" -v rel="$rel" -f "$HERE/audit_literacy_parse.awk" "$path" >> "$T/lines.tsv"; done < "$T/eff.tsv"
awk -F'\t' '$1=="5LO"{k=$3; sub(/^[A-Z_]+:/,"",k); print k}' "$T/lines.tsv" | sort -u > "$T/lo_keys.txt"
awk -F'\t' 'NR==FNR{lo[$1]=1; next} {k=$3; sub(/^[A-Z_]+:/,"",k); if ($1=="5LO" || !(k in lo)) print}' "$T/lo_keys.txt" "$T/lines.tsv" > "$T/effective.tsv"
echo "=== (A) all-class max literacy still in effect"
awk -F'\t' '($5=="global_max_literacy"||$5=="local_max_literacy") && $6>0 {printf "%-9s %-46s %-42s %s=%s\n",$1,$2,$3,$5,$6}' "$T/effective.tsv" | sort -k3
echo "=== (B) any literacy modifier >= 20"
awk -F'\t' '$6>=20 {printf "%-9s %-46s %-42s %s=%s\n",$1,$2,$3,$5,$6}' "$T/effective.tsv" | sort -u -k3
rm -rf "$T"
