. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_get_bash_version]++)) && return 0


atom_get_bash_version ()
{
    # 1: 主版本号
    # 2: 次版本号
    if [[ "$BASH_VERSION" =~ ([0-9]+)\.([0-9]+) ]]; then
        # 这和使用引用变量是一个效果
        printf -v "$1" "%s" "${BASH_REMATCH[1]}"
        printf -v "$2" "%s" "${BASH_REMATCH[2]}"
    fi
}

return 0

