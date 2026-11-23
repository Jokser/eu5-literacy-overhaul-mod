# one pass: countries(tags, gp rank, religion, laws, advances), pops, locations, universities, religion names
/^religion_manager=\{/{sec="r";next} /^countries=\{/{sec="c";next} /^population=\{/{sec="p";next} /^locations=\{/{sec="l";next} /^building_manager=\{/{sec="b";next}
/^[a-z_]+=\{/{sec="";next}
sec=="r"&&/^[0-9]+=\{/{rid=substr($0,1,index($0,"=")-1);next} sec=="r"&&/^\tkey=/{k=substr($0,6);gsub(/"/,"",k);rn[rid]=k;next}
sec=="c"&&/^\ttags=\{/{it=1;next} sec=="c"&&it&&/^\t\}/{it=0;next} sec=="c"&&it{split($1,a,"=");tg[a[1]]=a[2];next}
sec=="c"&&/^[0-9]+=\{/{cid=substr($0,1,index($0,"=")-1);next}
sec=="c"&&/^\tgreat_power_rank=/{gp[cid]=substr($0,19)+0;next}
sec=="c"&&/^\tprimary_religion=/{cr[cid]=substr($0,19);next}
sec=="c"&&/^\tcapital=/{cap[cid]=substr($0,10);next}
sec=="c"&&/^\tinstitutions=\{/{gi=1;next} sec=="c"&&gi{INS[cid]=gsub(/=yes/,"");gi=0;next}
sec=="c"&&/^\t\t\t[a-z_]+=\{$/{lk=$0;gsub(/[\t={]/,"",lk);next}
sec=="c"&&/^\t\t\t\tobject=/{if(lk=="education_elites_law"||lk=="education_masses_law"||lk=="censorship"||lk=="press_law") LW[cid,lk]=substr($0,12);next}
sec=="c"&&/printing_press_advance=yes|renaissance_advance=yes/{ s=$0; ad[cid]=""; n=split("printing_press_advance lo_printed_primers lo_stoglav lo_kyiv_mohyla_learning lo_church_reading_examinations lo_teaching_orders university_advance",A," "); for(i=1;i<=n;i++) if(index(s,A[i]"=yes")) ad[cid]=ad[cid] A[i] " "; next}
sec=="p"&&/^[0-9]+=\{/{pid=substr($0,1,index($0,"=")-1);next}
sec=="p"&&/^\ttype=/{T[pid]=substr($0,7);next} sec=="p"&&/^\tsize=/{Z[pid]=substr($0,7)+0;next} sec=="p"&&/^\tliteracy=/{L[pid]=substr($0,11)+0;next}
sec=="l"&&/^\t\t[0-9]+=\{/{lid=$0;gsub(/[\t={]/,"",lid);own="";next} sec=="l"&&/^\t\t\towner=/{own=substr($0,10);lo[lid]=own;next}
sec=="l"&&/^\t\t\t\tpops=\{/{ s=$0; sub(/.*pops=\{ */,"",s); sub(/ *\}.*/,"",s); m=split(s,ids," "); for(i=1;i<=m;i++){p=ids[i]; ty=T[p]; S[own,ty]+=Z[p]; LL[own,ty]+=Z[p]*L[p]; TOT[own]+=Z[p]; TL[own]+=Z[p]*L[p]; if(lid==cap[own]){CS[own,ty]+=Z[p]; CL[own,ty]+=Z[p]*L[p]}} next}
sec=="b"&&/^[0-9]+=\{/{bt="";next} sec=="b"&&/^\ttype=/{bt=substr($0,7);next} sec=="b"&&/^\tlocation=/{bl=substr($0,11);next}
sec=="b"&&/^\towner=/{ if(bt=="university"){U[substr($0,8)]++; UL[substr($0,8)]=UL[substr($0,8)] bl ","} ; if(bt=="lo_latin_school"||bt=="jesuit_college") X[substr($0,8),bt]++; next}
END{ split("nobles clergy burghers peasants laborers soldiers",C," ");
 printf "tag\tgp\trel\tpop_k\tnob\tcler\tburg\tpeas\tlab\tsold\tcapN\tcapC\tcapB\tcapP\tuni\telite_law\tmass_law\tcensor\tpress\tadv\tunilocs\n" > "/dev/stderr"
 for(c in TOT){ if(TOT[c]<100) continue; t=tg[c]; printf "%s\t%d\t%s\t%.0f", t, gp[c], rn[cr[c]], TOT[c];
  for(i=1;i<=6;i++){k=C[i]; printf "\t%s", (S[c,k]>0? sprintf("%.1f",LL[c,k]/S[c,k]):"-")}
  for(i=1;i<=4;i++){k=C[i]; printf "\t%s", (CS[c,k]>0? sprintf("%.1f",CL[c,k]/CS[c,k]):"-")}
  printf "\t%d\t%s\t%s\t%s\t%s\t%s\t%s\t%.2f\t%d\n", U[c], LW[c,"education_elites_law"], LW[c,"education_masses_law"], LW[c,"censorship"], LW[c,"press_law"], ad[c], UL[c], TL[c]/TOT[c], INS[c] } }
