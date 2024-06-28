# 这里变量的名字不能随便取,不然容易和外部的变量混淆
_assert_str_equal_old_dir="$(pwd)" ; root_dir="${_assert_str_equal_old_dir%%/pure_bash*}/pure_bash"
cd "$root_dir"/test ; . ./lib/test_meta.sh ; cd "$_assert_str_equal_old_dir"

((TEST_DEFENSE_VARIABLES[assert_str_equal]++)) && return 0

cd "$root_dir"/src/
. ./log/log_dbg.sh || return 1
cd "$_assert_str_equal_old_dir"

# 断言字符串相等
# :TODO: 待实现
assert_str_equal ()
{
    :
}

return 0

