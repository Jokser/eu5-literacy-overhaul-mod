# out: dev.tsv (lid dev), uni.tsv (lid ownertag)
/^countries=\{/{sec="c";next} /^locations=\{/{sec="l";next} /^building_manager=\{/{sec="b";next}
/^[a-z_]+=\{/{sec="";next}
sec=="c"&&/^\ttags=\{/{it=1;next} sec=="c"&&it&&/^\t\}/{it=0;next} sec=="c"&&it{split($1,a,"=");tg[a[1]]=a[2];next}
sec=="l"&&/^\t\t[0-9]+=\{/{lid=$0;gsub(/[\t={]/,"",lid);next}
sec=="l"&&/^\t\t\tdevelopment=/{print lid "\t" substr($0,16)+0 > DEV;next}
sec=="b"&&/^[0-9]+=\{/{bt="";next} sec=="b"&&/^\ttype=/{bt=substr($0,7);next} sec=="b"&&/^\tlocation=/{bl=substr($0,11);next}
sec=="b"&&/^\towner=/{ if(bt=="university") UO[bl]=substr($0,8); next}
END{for(l in UO) print l "\t" tg[UO[l]] > UNI}
