#!/usr/bin/bash

_test_function_levels_old_dir="$PWD"
root_dir="${_test_function_levels_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./date/date_log.sh || return 1
. ./atom/atom_my.sh || return 1
. ./log/log_dbg.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_function_levels_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="
# https://www.gnu.org/software/bash/manual/html_node/index.html#SEC_Contents
# 这个变量不要乱定义(如果不定义就没有嵌套深度限制)
# 限制嵌套和递归调用深度,默认情况下是没有限制的
FUNCNEST=100

test_case1 () { test_case2 ; }
test_case2 () { test_case3 ; }
test_case3 () { test_case4 ; }
test_case4 () { test_case5 ; }
test_case5 () { test_case6 ; }
test_case6 () { test_case7 ; }
test_case7 () { test_case8 ; }
test_case8 () { test_case9 ; }
test_case9 () { test_case10 ; }
test_case10 () { test_case11 ; } 
test_case11 () { test_case12 ; }
test_case12 () { test_case13 ; }
test_case13 () { test_case14 ; }
test_case14 () { test_case15 ; }
test_case15 () { test_case16 ; }
test_case16 () { test_case17 ; }
test_case17 () { test_case18 ; }
test_case18 () { test_case19 ; }
test_case19 () { test_case20 ; }
test_case20 () { test_case21 ; }
test_case21 () { test_case22 ; }
test_case22 () { test_case23 ; }
test_case23 () { test_case24 ; }
test_case24 () { test_case25 ; }
test_case25 () { test_case26 ; }
test_case26 () { test_case27 ; }
test_case27 () { test_case28 ; }
test_case28 () { test_case29 ; }
test_case29 () { test_case30 ; }
test_case30 () { test_case31 ; }
test_case31 () { test_case32 ; }
test_case32 () { test_case33 ; }
test_case33 () { test_case34 ; }
test_case34 () { test_case35 ; }
test_case35 () { test_case36 ; }
test_case36 () { test_case37 ; }
test_case37 () { test_case38 ; }
test_case38 () { test_case39 ; }
test_case39 () { test_case40 ; }
test_case40 () { test_case41 ; }
test_case41 () { test_case42 ; }
test_case42 () { test_case43 ; }
test_case43 () { test_case44 ; }
test_case44 () { test_case45 ; }
test_case45 () { test_case46 ; }
test_case46 () { test_case47 ; }
test_case47 () { test_case48 ; }
test_case48 () { test_case49 ; }
test_case49 () { test_case50 ; }
test_case50 () { test_case51 ; }
test_case51 () { test_case52 ; }
test_case52 () { test_case53 ; }
test_case53 () { test_case54 ; }
test_case54 () { test_case55 ; }
test_case55 () { test_case56 ; }
test_case56 () { test_case57 ; }
test_case57 () { test_case58 ; }
test_case58 () { test_case59 ; }
test_case59 () { test_case60 ; }
test_case60 () { test_case61 ; }
test_case61 () { test_case62 ; }
test_case62 () { test_case63 ; }
test_case63 () { test_case64 ; }
test_case64 () { test_case65 ; }
test_case65 () { test_case66 ; }
test_case66 () { test_case67 ; }
test_case67 () { test_case68 ; }
test_case68 () { test_case69 ; }
test_case69 () { test_case70 ; }
test_case70 () { test_case71 ; }
test_case71 () { test_case72 ; }
test_case72 () { test_case73 ; }
test_case73 () { test_case74 ; }
test_case74 () { test_case75 ; }
test_case75 () { test_case76 ; }
test_case76 () { test_case77 ; }
test_case77 () { test_case78 ; }
test_case78 () { test_case79 ; }
test_case79 () { test_case80 ; }
test_case80 () { test_case81 ; }
test_case81 () { test_case82 ; }
test_case82 () { test_case83 ; }
test_case83 () { test_case84 ; }
test_case84 () { test_case85 ; }
test_case85 () { test_case86 ; }
test_case86 () { test_case87 ; }
test_case87 () { test_case88 ; }
test_case88 () { test_case89 ; }
test_case89 () { test_case90 ; }
test_case90 () { test_case91 ; }
test_case91 () { test_case92 ; }
test_case92 () { test_case93 ; }
test_case93 () { test_case94 ; }
test_case94 () { test_case95 ; }
test_case95 () { test_case96 ; }
test_case96 () { test_case97 ; }
test_case97 () { test_case98 ; }
test_case98 () { test_case99 ; }
test_case99 () { test_case100 ; }
test_case100 () { test_case101 ; }
test_case101 () { test_case102 ; }
test_case102 () { test_case103 ; }
test_case103 () { test_case104 ; }
test_case104 () { test_case105 ; }
test_case105 () { test_case106 ; }
test_case106 () { test_case107 ; }
test_case107 () { test_case108 ; }
test_case108 () { test_case109 ; }
test_case109 () { test_case110 ; }
test_case110 () { test_case111 ; }
test_case111 () { test_case112 ; }
test_case112 () { test_case113 ; }
test_case113 () { test_case114 ; }
test_case114 () { test_case115 ; }
test_case115 () { test_case116 ; }
test_case116 () { test_case117 ; }
test_case117 () { test_case118 ; }
test_case118 () { test_case119 ; }
test_case119 () { test_case120 ; }
test_case120 () { test_case121 ; }
test_case121 () { test_case122 ; }
test_case122 () { test_case123 ; }
test_case123 () { test_case124 ; }
test_case124 () { test_case125 ; }
test_case125 () { test_case126 ; }
test_case126 () { test_case127 ; }
test_case127 () { test_case128 ; }
test_case128 () { test_case129 ; }
test_case129 () { test_case130 ; }
test_case130 () { test_case131 ; }
test_case131 () { test_case132 ; }
test_case132 () { test_case133 ; }
test_case133 () { test_case134 ; }
test_case134 () { test_case135 ; }
test_case135 () { test_case136 ; }
test_case136 () { test_case137 ; }
test_case137 () { test_case138 ; }
test_case138 () { test_case139 ; }
test_case139 () { test_case140 ; }
test_case140 () { test_case141 ; }
test_case141 () { test_case142 ; }
test_case142 () { test_case143 ; }
test_case143 () { test_case144 ; }
test_case144 () { test_case145 ; }
test_case145 () { test_case146 ; }
test_case146 () { test_case147 ; }
test_case147 () { test_case148 ; }
test_case148 () { test_case149 ; }
test_case149 () { test_case150 ; }
test_case150 () { test_case151 ; }
test_case151 () { test_case152 ; }
test_case152 () { test_case153 ; }
test_case153 () { test_case154 ; }
test_case154 () { test_case155 ; }
test_case155 () { test_case156 ; }
test_case156 () { test_case157 ; }
test_case157 () { test_case158 ; }
test_case158 () { test_case159 ; }
test_case159 () { test_case160 ; }
test_case160 () { echo '161' ; }

temp_file=$(mktemp)

test_case1 2>"$temp_file"

if [[ -s "$temp_file" ]] ; then
    echo "test_case1 test pass"
    ret=0
else
    echo "test_case1 test fail"
    ret=1
fi

rm -f "$temp_file"

exit $ret

