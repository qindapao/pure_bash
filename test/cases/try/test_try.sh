#!/usr/bin/bash

set +E

_test_trap_try_old_dir="$PWD"
root_dir="${_test_trap_try_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
# . ./log/log_dbg.sh || return 1
# . ./date/date_log.sh || return 1
. ./try/try.sh || return 1
. ./trap/trap_set.sh || return 1

cd "$root_dir"/test/lib
# . ./assert/assert_array.sh || return 1

cd "$_test_trap_try_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case_disable ()
{
    echo "${FUNCNAME[0]} is disabled."
}

test_case_disable
exit $?


IS_ALLOW_TRAP_SET=1
eval $(trap_set 1 ERR)

func_test ()
{
    echo "func_test:$(trap -p)"
    try {
        set +E
        echo "3" | grep '1'    
    } catch {
        echo "inter>"
        printf "%s" "$(<$TRY_RESTORE_FILE)"
        echo "inter<"
        echo "$TRY_RESTORE_FILE"
    }
    finally {
        :
    }
    return 1
}

try {
    set +E
    # echo '' | grep "2"
    # echo '' | grep "2"
    # echo '' | grep "2"
    echo '2' | grep '1'
    func_test
    echo '2' | grep '4'
    # ls -l
    # echo '' | grep "2"
} catch {
    printf "%s" "$(<$TRY_RESTORE_FILE)"
    echo "$TRY_RESTORE_FILE"
}
finally {
    :
}

if {
    echo '1' | grep '2'
    echo '1' | grep '2'
    echo '1' | grep '2'
    echo '2' | grep '2'
} ; then
    echo "if pass"
else
    echo "if fail"
fi



echo "$TRAP_ERR_FILE"

echo "-:$-"
echo "-:$-"
echo "4" | grep "yy" | grep "xx"

echo "nested alias"


unalias -a
alias lx='ls -l '
alias lz='-s'
lx lz


