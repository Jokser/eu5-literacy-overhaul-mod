# Literacy overhaul audit helper: prints "src rel topkey inner modifier value" for every *max_literacy line of one file.
# input: one file; vars src, rel. Prints src rel topkey inner modifier value
FNR==1 { d=0; sub(/^\xef\xbb\xbf/, "") }
{
  line=$0; sub(/#.*/, "", line)
  if (d==0 && match(line, /^[A-Za-z0-9_:.\-]+[ \t]*=[ \t]*\{/)) { top=substr(line, RSTART, RLENGTH); sub(/[ \t]*=.*/, "", top); inner="" }
  else if (d==1 && match(line, /^[ \t]+[A-Za-z0-9_]+[ \t]*=[ \t]*\{/)) { inner=substr(line, RSTART, RLENGTH); gsub(/[ \t]|=|\{/, "", inner) }
  if (match(line, /(global|local)_[a-z_]*max_literacy[ \t]*=[ \t]*-?[0-9.]+/)) {
    s=substr(line, RSTART, RLENGTH); split(s, kv, "="); m=kv[1]; gsub(/[ \t]/, "", m); v=kv[2]+0
    print src "\t" rel "\t" top "\t" inner "\t" m "\t" v
  }
  n=gsub(/\{/, "{", line); c=gsub(/\}/, "}", line); d+=n-c; if (d<0) d=0
}
