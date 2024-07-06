. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_extend]++)) && return 0

# 一个字典合并到另外一个字典
# :TODO: 并不是bash5.2引入的要确认下
if ((__META_BASH_VERSION>=5002000)) ; then
    dict_extend ()
    {
        # 不能用小写的k操作符,但是在printf中可以用小写的k操作符
        # 注意这里需要两层展开
        eval "eval $1+=(\"\${$2[@]@K}\")"
    }
else
    # :TODO: 待测试
    dict_extend ()
    {
        local _dict_extend_script='
            local i'$1$2'
            for i'$1$2' in "${!'$2'[@]}"; do
              '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
            done'
        eval -- "$_dict_extend_script"
    }
fi

return 0

