. ./meta/meta.sh
((DEFENSE_VARIABLES[json_quote]++)) && return 0

# 字符串包裹成JSON字符串
json_quote ()
{
    local -n __json_quote_str="$1"
    __json_quote_str=${__json_quote_str//\\/\\\\}   # 替换 \ 为 \\
    __json_quote_str=${__json_quote_str//\"/\\\"}   # 替换 " 为 \"
    __json_quote_str=${__json_quote_str//$'\n'/\\n} # 替换换行符
    __json_quote_str=${__json_quote_str//$'\r'/\\r} # 替换回车符
    __json_quote_str=${__json_quote_str//$'\t'/\\t} # 替换制表符
    __json_quote_str=${__json_quote_str//$'\b'/\\b} # 替换退格符（可选）
    __json_quote_str=${__json_quote_str//$'\a'/\\a} # 替换响铃符（可选）

    # 最后双引号包裹字符串
    __json_quote_str="\"$__json_quote_str\""
}

return 0

