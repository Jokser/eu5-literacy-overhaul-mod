# Literacy overhaul - institution spread from an EU5 TEXT save (Git Bash awk, nothing to install).
# usage: awk -v tags="FRA MOS TUR" -f save_institutions.awk "<save>.eu5" > out.txt
# Section 1 (WORLD): per institution - locations where it is present (progress >= 100), locations where it is spreading
#   (0 < progress < 100), and how many countries have embraced it.
# Section 2 (COUNTRY): for each tag in -v tags: embraced institutions and, per institution present anywhere, the share
#   of that country's locations where it is present.
BEGIN { nt = split(tags, T, " "); for (i = 1; i <= nt; i++) want[T[i]] = 1 }
NR < 60 && /^metadata=\{/ { }
NR < 60 && /^\tdate=/ { date = substr($0, 7) }
# ---------- countries: tags + embraced institutions ----------
/^countries=\{/ { sec = "c"; next }
/^locations=\{/ { sec = "l"; next }
/^[a-z_]+=\{/   { sec = ""; next }
sec == "c" && /^\ttags=\{/ { it = 1; next }
sec == "c" && it && /^\t\}/ { it = 0; next }
sec == "c" && it { split($1, a, "="); tag[a[1]] = a[2]; next }
sec == "c" && /^[0-9]+=\{/ { cid = substr($0, 1, index($0, "=") - 1); next }
sec == "c" && /^\tinstitutions=\{/ { ri = 1; next }
sec == "c" && ri {
  ri = 0; s = $0; t = tag[cid]
  while (match(s, /[a-z_]+=yes/)) {
    k = substr(s, RSTART, RLENGTH - 4); emb[k]++
    if (t in want) cemb[t] = cemb[t] " " k
    s = substr(s, RSTART + RLENGTH)
  }
  next
}
# ---------- locations: owner + institutions progress ----------
sec == "l" && /^\t\t[0-9]+=\{/ { own = ""; inl = 0; next }
sec == "l" && /^\t\t\towner=/   { own = tag[substr($0, 10)]; if (own != "") nloc[own]++; next }
sec == "l" && /^\t\t\tinstitutions=\{/ { inl = 1; next }
sec == "l" && inl && /^\t\t\t\}/ { inl = 0; next }
sec == "l" && inl {
  split($1, a, "="); k = a[1]; v = a[2] + 0; inst[k] = 1
  if (v >= 100) { pres[k]++; if (own != "") cpres[own, k]++ }
  else if (v > 0) spr[k]++
  next
}
END {
  print "date " date
  print "== WORLD: institution  present(locs)  spreading(locs)  embraced(countries)"
  for (k in inst) printf "%-24s %7d %7d %5d\n", k, pres[k], spr[k], emb[k] | "sort -k2,2nr"
  close("sort -k2,2nr")
  print "== COUNTRY: tag  locations  embraced | share of own locations where present"
  for (i = 1; i <= nt; i++) {
    t = T[i]; if (!(t in nloc)) { print t " (not present)"; continue }
    printf "%s locs=%d embraced:%s\n   ", t, nloc[t], (cemb[t] == "" ? " -" : cemb[t])
    for (k in inst) if (pres[k] > 0) printf " %s=%.0f%%", k, 100 * cpres[t, k] / nloc[t]
    printf "\n"
  }
}
