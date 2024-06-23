# 这里变量的名字不能随便取,不然容易和外部的变量混淆
_assert_array_old_dir="$(pwd)" ; root_dir="${_assert_array_old_dir%%/pure_bash*}/pure_bash"
cd "$root_dir"/test ; . ./lib/test_meta.sh ; cd "$_assert_array_old_dir"

((TEST_DEFENSE_VARIABLES[assert_array]++)) && return 0

cd "$root_dir"/src/
. ./log/log_dbg.sh || return 1
cd "$_assert_array_old_dir"

# 判断参数给出的数组引用对应的数组索引和值是否完全匹配
# 返回值:
#   0: pass
#   1: fail
# :TODO: 断言失败是应该直接退出还是返回失败?
assert_array ()
{
    if (($#<3)) ; then
        log_dbg 0d0 "param num:${#}, need >= 3"
        return 1
    fi

    # 如果参数任意一个为空都失败
    local _assert_array_param=''
    for _assert_array_param in "${@}" ; do
        if [[ -z "$_assert_array_param" ]] ; then
            log_dbg 0d0 "param can not be null"
            return 1
        fi
    done
    
    # a or A
    local _assert_array_type="${1}"
    local -n _assert_array_first="${2}"
    shift 2
    local _assert_array_index
    while (($#)) ; do
        local -n _assert_array_second="${1}"

        # 判断元素数量
        if [[ "${#_assert_array_first[@]}" != "${#_assert_array_second[@]}" ]] ; then
            return 1
        fi

        # 判断类型
        if [[ "${_assert_array_first@a}" != "$_assert_array_type" ]] || [[ "${_assert_array_second@a}" != "$_assert_array_type" ]] ; then
            return 1
        fi

        for _assert_array_index in "${!_assert_array_second[@]}" ; do
            # 判断索引
            if [[ ! -v '_assert_array_first[$_assert_array_index]' ]] ; then
                return 1
            fi

            # 判断值
            if [[ "${_assert_array_first["$_assert_array_index"]}" != "${_assert_array_second["$_assert_array_index"]}" ]] ; then
                return 1
            fi
        done

        # 双向判断
        for _assert_array_index in "${!_assert_array_first[@]}" ; do
            # 判断索引
            if [[ ! -v '_assert_array_second[$_assert_array_index]' ]] ; then
                return 1
            fi

            # 判断值
            if [[ "${_assert_array_first["$_assert_array_index"]}" != "${_assert_array_second["$_assert_array_index"]}" ]] ; then
                return 1
            fi
        done

        shift
    done
    return 0
}

return 0

