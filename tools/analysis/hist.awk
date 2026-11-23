BEGIN{n=split(W,a,","); for(i=1;i<=n;i++) want[a[i]]=1}
/^countries=\{/{sec="c";next} /^population=\{/{sec="p";next} /^locations=\{/{sec="l";next} /^[a-z_]+=\{/{sec="";next}
sec=="c"&&/^\ttags=\{/{it=1;next} sec=="c"&&it&&/^\t\}/{it=0;next} sec=="c"&&it{split($1,b,"=");tg[b[1]]=b[2];next}
sec=="p"&&/^[0-9]+=\{/{pid=substr($0,1,index($0,"=")-1);next}
sec=="p"&&/^\ttype=/{T[pid]=substr($0,7);next} sec=="p"&&/^\tsize=/{Z[pid]=substr($0,7)+0;next} sec=="p"&&/^\tliteracy=/{L[pid]=substr($0,11)+0;next}
sec=="l"&&/^\t\t\towner=/{own=tg[substr($0,10)];next}
sec=="l"&&/^\t\t\t\tpops=\{/{ if(!(own in want)) next; s=$0; sub(/.*pops=\{ */,"",s); sub(/ *\}.*/,"",s); m=split(s,ids," "); for(i=1;i<=m;i++){p=ids[i]; if(T[p]!="peasants") continue; v=int(L[p]+0.5); H[own,v]+=Z[p]; S[own]+=Z[p]; if(v>mx[own]) mx[own]=v} }
END{for(t in want){printf "%s peasants total %.0f:", t, S[t]; for(v=0;v<=mx[t];v++) if(H[t,v]/S[t]>0.01) printf " %d:%.0f%%", v, 100*H[t,v]/S[t]; print ""}}
