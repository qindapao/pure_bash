. ./meta/meta.sh
((DEFENSE_VARIABLES[base64_common]++)) && return 0

BASE64_USE_BUILTIN_TOOL=0

base64_common_test ()
{
    local test_var=
    local -n test_var_ref1=test_var
    local -n test_var_ref2=test_var_ref1
    local -n test_var_ref3=test_var_ref2
    local test_ret=0

    ibase64 -v test_var_ref3 encode "hello world!"
    if [[ "$test_var_ref3" != 'aGVsbG8gd29ybGQh' ]] ||
        [[ "$test_var_ref2" != 'aGVsbG8gd29ybGQh' ]] ||
        [[ "$test_var_ref1" != 'aGVsbG8gd29ybGQh' ]] ||
        [[ "$test_var" != 'aGVsbG8gd29ybGQh' ]] ; then
        test_ret=1
    fi

    ibase64 -v test_var_ref3 decode 'aGVsbG8gd29ybGQh'
    if [[ "$test_var_ref3" != 'hello world!' ]] ||
        [[ "$test_var_ref2" != 'hello world!' ]] ||
        [[ "$test_var_ref1" != 'hello world!' ]] ||
        [[ "$test_var" != 'hello world!' ]] ; then
        test_ret=1
    fi
    
    return $test_ret
}

base64_common ()
{
    local os_info=$(uname -a)
    os_info=${os_info,,}

    if [[ "$os_info" == *aarch64* ]] ; then
        # 实际部署的时候路径可能也要改
        if enable -f "${PURE_BASH_TOOLS_DIR}/ibase64_aarch64" ibase64 ; then
            BASE64_USE_BUILTIN_TOOL=1
            # 还需要运行用例检测多级引用变量是否能正常拿到值,如果无法拿到内置工具也是错误的
            base64_common_test || BASE64_USE_BUILTIN_TOOL=0
        fi
    elif [[ "$os_info" == *"x86_64 cygwin"* ]] ; then
        # cygwin编译出现问题,暂时留空
        :
    elif [[ "$os_info" == *"x86_64"* ]] ; then
        if enable -f "${PURE_BASH_TOOLS_DIR}/ibase64_x86" ibase64 ; then
            BASE64_USE_BUILTIN_TOOL=1
            # 还需要运行用例检测多级引用变量是否能正常拿到值,如果无法拿到内置工具也是错误的
            base64_common_test || BASE64_USE_BUILTIN_TOOL=0
        fi
    fi
}

base64_common

return 0

