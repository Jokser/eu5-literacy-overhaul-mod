/^countries=\{/{sec="c";next} /^estate_manager=\{/{sec="e";next} /^[a-z_]+=\{/{sec="";next}
sec=="c"&&/^\ttags=\{/{it=1;next} sec=="c"&&it&&/^\t\}/{it=0;next} sec=="c"&&it{split($1,a,"=");tg[a[1]]=a[2];next}
sec=="e"&&/^[0-9]+=\{/{et="";cc="";next} sec=="e"&&/^\testate_type=/{et=substr($0,14);next} sec=="e"&&/^\tcountry=/{cc=substr($0,10);next}
sec=="e"&&/^\tsatisfaction=/{ if(et=="clergy_estate") SAT[cc]=substr($0,15); next}
END{for(c in SAT) print tg[c]"\t"SAT[c]}
