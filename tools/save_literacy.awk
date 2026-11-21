# Literacy overhaul - per-country literacy from an EU5 TEXT save (no install needed: Git Bash awk).
# usage: awk -f save_literacy.awk "<save>.eu5" > out.tsv
# Chain: countries.tags (id->TAG) ; locations.locations (<id>={ owner=  pops={ ids } }) ;
#        population.database (<id>={ type= size= literacy= }).
# Output per country: total pops, size-weighted average literacy (all pops), per class literacy and share,
# and LO's Learned Elite index (0.4 N + 0.35 C + 0.25 B, missing estates drop out).
function flush_pop() { if (pid != "") { ptype[pid]=ty; psize[pid]=sz; plit[pid]=li }; pid=""; ty=""; sz=0; li=0 }
BEGIN { sec="" }
# ---------- section switches (top level = column 0) ----------
/^countries=\{/            { sec="countries"; next }
/^population=\{/           { sec="pop"; next }
/^locations=\{/            { sec="loc"; next }
/^[a-z_]+=\{/              { if (sec=="pop") flush_pop(); sec=""; next }
# ---------- country tags ----------
sec=="countries" && /^\ttags=\{/ { intags=1; next }
sec=="countries" && intags && /^\t\}/ { intags=0; sec=""; next }
sec=="countries" && intags { split($1, a, "="); tag[a[1]]=a[2]; next }
# ---------- pops ----------
sec=="pop" && /^[0-9]+=\{/ { flush_pop(); pid=substr($0, 1, index($0, "=")-1); next }
sec=="pop" && /^\ttype=/     { ty=substr($0, 7); next }
sec=="pop" && /^\tsize=/     { sz=substr($0, 7)+0; next }
sec=="pop" && /^\tliteracy=/ { li=substr($0, 11)+0; next }
# ---------- locations ----------
sec=="loc" && /^\t\t[0-9]+=\{/ { own="" ; next }
sec=="loc" && /^\t\t\towner=/   { own=substr($0, 10); next }
sec=="loc" && /^\t\t\t\tpops=\{/ {
  if (own == "") next
  s=$0; sub(/.*pops=\{ */, "", s); sub(/ *\}.*/, "", s)
  n=split(s, ids, " ")
  for (i=1; i<=n; i++) locpop[own]=locpop[own] " " ids[i]
  next
}
END {
  ncl=split("nobles clergy burghers peasants laborers soldiers slaves tribesmen", cl, " ")
  printf "tag\tpop_k\tavg_lit"
  for (j=1; j<=ncl; j++) printf "\t%s_lit\t%s_share", substr(cl[j],1,4), substr(cl[j],1,4)
  printf "\telite_idx\n"
  for (c in locpop) {
    delete S; delete L; tot=0; totl=0
    n=split(locpop[c], ids, " ")
    for (i=1; i<=n; i++) { p=ids[i]; if (!(p in psize)) continue
      t=ptype[p]; S[t]+=psize[p]; L[t]+=psize[p]*plit[p]; tot+=psize[p]; totl+=psize[p]*plit[p] }
    if (tot <= 0) continue
    t = (c in tag) ? tag[c] : ("id" c)
    printf "%s\t%.1f\t%.2f", t, tot, totl/tot
    for (j=1; j<=ncl; j++) { k=cl[j]
      if (S[k] > 0) printf "\t%.1f\t%.3f", L[k]/S[k], S[k]/tot; else printf "\t-\t0" }
    es=0; ew=0
    if (S["nobles"]>0)   { es+=0.40*L["nobles"]/S["nobles"];     ew+=0.40 }
    if (S["clergy"]>0)   { es+=0.35*L["clergy"]/S["clergy"];     ew+=0.35 }
    if (S["burghers"]>0) { es+=0.25*L["burghers"]/S["burghers"]; ew+=0.25 }
    printf "\t%.1f\n", (ew>0 ? es/ew : 0)
  }
}
