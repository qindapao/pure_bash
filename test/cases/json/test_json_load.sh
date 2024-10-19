#!/usr/bin/bash

_test_json_load_old_dir="$PWD"
root_dir="${_test_json_load_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./json/json_init.sh || return 1
. ./json/json_load.sh || return 1


cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_json_load_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    json_init
    declare -p JSON_COMMON_STANDARD_JSON_PARSER
    local -A dict_python=()  dict_awk=()
    json_load dict_python 'standard_json.txt'
    ldebug_bp 'show dict python' dict_python
}

test_case2 ()
{
    json_init
    declare -p JSON_COMMON_STANDARD_JSON_PARSER
    local -A dict_awk=()
    json_load dict_awk 'standard_json.txt'
    ldebug_bp 'show dict awk' dict_awk
}

exec_json_file ()
{
cat <<EOF >standard_json.txt
{
    "person": {
        "n:am,[]{}e": "John",
        "ag\n \t\"e": "30",
        "爱好": ["打\"乒乓球", "打羽毛,.{}[]/\\\\,/球", "发呆"],
        "其它": [],
        "other": {},
        "别的": [[], {},
                "\b\f\n\r\t/\\\\,\"agegg123344",
                true,
                "\\\\",
                false,
                "",
                " x",
                "",
                null,
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                ""
                ],
        "部门": "测试与装备部",
        "进行中的项目": {
            "项目1": {"名字": "自动化测试", "进度": "10%"},
            "项目2": {"名字": "性能优化", "进度": "40%"}
        }
    }
}
EOF
}

exec_json_file
# test_case1
test_case2

