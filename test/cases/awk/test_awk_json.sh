#!/usr/bin/bash

_test_awk_json_old_dir=$PWD
root_dir="${_test_awk_json_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./date/date_log.sh || return 1
. ./awk/awk_json.sh || return 1
. ./log/log_s_dbg.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_awk_json_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local tmp_file=$(mktemp)
    local json_str

    {
    IFS= read -r -d '' json_str <<'    EOF'
{
    "person": {
        "n:am,[]{}e": "John",
        "ag\n \t\"e": "30",
        "爱好": ["打\"乒乓球", "打羽毛,.{}[]/\\,/球", "发呆"],
        "其它": [],
        "other": {},
        "别的": [[], {},
                "\b\f\n\r\t/\\,\"agegg123344",
                true,
                "\\",
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
    } || true
    
    printf "%s" "$json_str" > "$tmp_file"

    local tmp_out_file=$(mktemp)
    
    local -A awk_json_dict=()
    awk_json awk_json_dict "$tmp_out_file" "$tmp_file"
    
    # lsdebug_bp '' awk_json_dict

    declare -A awk_json_dict_after=(["'person','进行中的项目','项目2','进度'"]="40%" ["'person','进行中的项目','项目1','进度'"]="10%" ["'person','别的',9"]="null" ["'person','别的',8"]="" ["'person','别的',5"]="0" ["'person','别的',4"]="\\" ["'person','别的',7"]=" x" ["'person','别的',6"]="" ["'person','别的',1"]="{}" ["'person','别的',0"]="[]" ["'person','别的',3"]="1" ["'person','别的',2"]=$'\b\f\n\r\t/\\,"agegg123344' ["'person','进行中的项目','项目2','名字'"]="性能优化" ["'person','爱好',2"]="发呆" ["'person','爱好',1"]="打羽毛,.{}[]/\\,/球" ["'person','爱好',0"]="打\"乒乓球" ["'person','部门'"]="测试与装备部" ["'person','进行中的项目','项目1','名字'"]="自动化测试" ["'person','other'"]="{}" ["'person','n:am,[]{}e'"]="John" ["'person','别的',14"]="" ["'person','其它'"]="[]" ["'person','别的',15"]="" ["'person','别的',16"]="" ["'person','别的',17"]="" ["'person','别的',10"]="" ["'person','别的',11"]="" ["'person',\$'ag\\n \\t\"e'"]="30" ["'person','别的',12"]="" ["'person','别的',13"]="" )
    
    rm -f "$tmp_file" "$tmp_out_file"

    if assert_array 'A' awk_json_dict awk_json_dict_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
    

}

awk_json_init
test_case1

