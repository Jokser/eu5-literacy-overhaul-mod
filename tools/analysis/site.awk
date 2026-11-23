# per location: dev, max clergy lit, max burgher lit, rank -> stdout for lids in W file
BEGIN{while((getline l < W)>0) want[l]=1}
/^population=\{/{sec="p";next} /^locations=\{/{sec="l";next} /^[a-z_]+=\{/{sec="";next}
sec=="p"&&/^[0-9]+=\{/{pid=substr($0,1,index($0,"=")-1);next}
sec=="p"&&/^\ttype=/{T[pid]=substr($0,7);next} sec=="p"&&/^\tliteracy=/{L[pid]=substr($0,11)+0;next}
sec=="l"&&/^\t\t[0-9]+=\{/{lid=$0;gsub(/[\t={]/,"",lid);next}
sec=="l"&&!(lid in want){next}
sec=="l"&&/^\t\t\tdevelopment=/{dv[lid]=substr($0,16)+0;next}
sec=="l"&&/^\t\t\trank=/{rk[lid]=substr($0,9);next}
sec=="l"&&/^\t\t\t\tpops=\{/{ s=$0; sub(/.*pops=\{ */,"",s); sub(/ *\}.*/,"",s); m=split(s,ids," "); for(i=1;i<=m;i++){p=ids[i]; if(T[p]=="clergy"&&L[p]>C[lid])C[lid]=L[p]; if(T[p]=="burghers"&&L[p]>B[lid])B[lid]=L[p]}}
END{for(l in want) printf "%s\t%.1f\t%.1f\t%.1f\t%s\n", l, dv[l], C[l], B[l], rk[l]}
