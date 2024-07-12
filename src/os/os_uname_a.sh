. ./meta/meta.sh
((DEFENSE_VARIABLES[os_uname_a]++)) && return 0

. ./str/str_split_pure.sh || return 1

os_uname_a ()
{
    local -n _os_uname_a_ref_hash="${1}"
    local uname_output ; uname_output=$(uname -a)

    _os_uname_a_ref_hash['raw_str']="$uname_output"
    # :TODO: 嵌入式环境中< <()语法可能失效,提示没有相关的文件描述符
    _os_uname_a_ref_hash['os_name']=$(str_split_pure ' ' 1 < <(printf "%s" "$uname_output"))
    _os_uname_a_ref_hash['host_name']=$(str_split_pure ' ' 2 < <(printf "%s" "$uname_output"))
    _os_uname_a_ref_hash['kernel_version']=$(str_split_pure ' ' 3 < <(printf "%s" "$uname_output"))
    # :TODO: 其它信息需要时再解析
}

return 0

