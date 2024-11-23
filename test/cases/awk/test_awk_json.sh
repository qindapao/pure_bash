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
        "X1": ["hit\"pingpang", "hityumao,.{}[]/\\,/qiu", "fadai"],
        "X2": [],
        "other": {},
        "X3": [[], {},
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
        "X4": "X5",
        "X6": {
            "X\"7": {"X9": "X10", "X12": "10%"},
            "X8": {"X9": "X11", "X12": "40%"}
        }
    }
}
    EOF
    } || true
    
    printf "%s" "$json_str" > "$tmp_file"

    local tmp_out_file=$(mktemp)
    
    local -A awk_json_dict=()
    awk_json awk_json_dict "$tmp_out_file" "$tmp_file"
    
    declare -A awk_json_dict_after=(["'person','X6','X8','X12'"]="40%" [''\''person'\'','\''X6'\'','\''X"7'\'','\''X12'\''']="10%" ["'person','X3',9"]="null" ["'person','X3',8"]="" ["'person','X3',5"]="0" ["'person','X3',4"]="\\" ["'person','X3',7"]=" x" ["'person','X3',6"]="" ["'person','X3',1"]="{}" ["'person','X3',0"]="[]" ["'person','X3',3"]="1" ["'person','X3',2"]=$'\b\f\n\r\t/\\,"agegg123344' ["'person','X6','X8','X9'"]="X11" ["'person','X1',2"]="fadai" ["'person','X1',1"]="hityumao,.{}[]/\\,/qiu" ["'person','X1',0"]="hit\"pingpang" ["'person','X4'"]="X5" [''\''person'\'','\''X6'\'','\''X"7'\'','\''X9'\''']="X10" ["'person','other'"]="{}" ["'person','n:am,[]{}e'"]="John" ["'person','X3',14"]="" ["'person','X2'"]="[]" ["'person','X3',15"]="" ["'person','X3',16"]="" ["'person','X3',17"]="" ["'person','X3',10"]="" ["'person','X3',11"]="" ["'person',\$'ag\\n \\t\"e'"]="30" ["'person','X3',12"]="" ["'person','X3',13"]="" )
    
    rm -f "$tmp_file" "$tmp_out_file"

    lsdebug_bp '' awk_json_dict awk_json_dict_after

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

