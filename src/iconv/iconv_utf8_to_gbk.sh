. ./meta/meta.sh
((DEFENSE_VARIABLES[iconv_utf8_to_gbk]++)) && return 0

alias iconv_utf8_to_gbk="iconv -f utf-8 -t gbk"

return 0

