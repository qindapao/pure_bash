#!/usr/bin/bash

# :TODO: 中文的用例删除了,但是其实支持中文的,只是有些环境可能不支持中文
# 后面把中文的用例单独做出来
# :TODO: 用例中的递归删除json的逻辑都没做
# 都验证的是keep empty的动作

_test_json_old_dir="$PWD"
root_dir="${_test_json_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./cntr/cntr_all.sh || return 1

. ./json/json_attr_get.sh || return 1
. ./json/json_awk_load.sh || return 1
. ./json/json_base64_pack.sh || return 1
. ./json/json_common.sh || return 1
. ./json/json_cp.sh || return 1
. ./json/json_del.sh || return 1
. ./json/json_del_de.sh || return 1
. ./json/json_del_de_ke.sh || return 1
. ./json/json_del_ke.sh || return 1
. ./json/json_dump.sh || return 1
. ./json/json_extract_de.sh || return 1
. ./json/json_extract_de_ke.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_init.sh || return 1
. ./json/json_insert.sh || return 1
. ./json/json_load.sh || return 1
. ./json/json_o_insert.sh || return 1
. ./json/json_o_push.sh || return 1
. ./json/json_o_unshift.sh || return 1
. ./json/json_overlay.sh || return 1
. ./json/json_pack.sh || return 1
. ./json/json_pop.sh || return 1
. ./json/json_pop_ke.sh || return 1
. ./json/json_push.sh || return 1
. ./json/json_set.sh || return 1
. ./json/json_set_params_check.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1
. ./json/json_shift.sh || return 1
. ./json/json_shift_ke.sh || return 1
. ./json/json_unpack.sh || return 1
. ./json/json_unshift.sh || return 1
. ./json/json_has_key.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_json_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case_all ()
{
    local param3="$3"
    if [[ "$param3" == 'mock_python_fail' ]] ; then
        json_init_check_python3 ()
        {
            echo "mock python3 check"
            return 1
        }
    fi

    local standard_json_file=$(mktemp)
    local json_str

    {
    IFS= read -r -d '' json_str <<'    EOF'

     {
    "person": {
        "n:am,[]{}e": "John",
        "ag\\n \\t\\\"e\\n": "30",
        "habbit": ["xxoo", "ccccccccccccccc", "kkyy"],
        "other": [],
        "other": {},
        "otheragain": [[], {},
                "\b\f\n\r\t/\\,\"agegg123344",
                "\b\f\n\r\t/\\,\"agegg123344",
                "中文的情况？是不是没有处理啊",
                "中文的2情况？是不是没\\\"有处理啊",
                true,
                "\\",
                false,
                "",
                " x",
                "",
                null,
                "",
                ""
                ],
        "paart": "part2",
        "project_in_process": {
            "project1": {"name": "auto test", "proc essdatay> ": "10%"},
            "pr > oject2": {"name": "good", "proc essdatay> ": "40%"}
        }
    }
}     
     
    EOF
    } || true
    
    printf "%s" "$json_str" > "$standard_json_file"

    #1. json_init
    json_init "$1" "$2" >/dev/null 2>&1
    
    #2. json_load
    local -A bash_json=()
    time json_load bash_json "$standard_json_file" 'balance'

    #3. json_dump
    # declare -p bash_json
    # json_dump_ho bash_json

    local -a to_overlay_array=('geg ' [3]='geg111' [7]='wwe2233' 'w223' '%%^&' 'gege1234' '5645'
            'geg ' 'geg111' 'wwe2233' 'w223' '%%^&' 'gege1234' '5645'
            'geg ' 'geg111' 'wwe2233' 'w223' '%%^&' 'gege1234' '5645'
            'geg ' 'geg111' 'wwe2233' 'w223' '%%^&' 'gege1234' '5645'
            'geg ' 'geg111' 'wwe2233' 'w223' '%%^&' 'gege1234' '5645'
            'geg ' 'geg111' 'wwe2233' 'w223' '%%^&' 'gege1234' '5645'
            )
    json_overlay bash_json to_overlay_array [project_in_process] [project1] [extra]
    json_dump_ho bash_json

    local -A to_overlay_dict=([xx]='geg ' [oo]='geg111' [kk]='wwe2233' [zz]='w223' [mm]='%%^&' [2343]='gege1234' [gege23]='5645'
            [xx1]='geg ' [oo1]='geg111' [kk1]='wwe2233' [zz0]='w223' [mm0]='%%^&' [23430]='gege1234' [gege230]='5645'
            [xx2]='geg ' [oo2]='geg111' [kk2]='wwe2233' [zz1]='w223' [mm1]='%%^&' [23431]='gege1234' [gege231]='5645'
            [xx3]='geg ' [oo3]='geg111' [kk3]='wwe2233' [zz2]='w223' [mm2]='%%^&' [23432]='gege1234' [gege232]='5645'
            [xx4]='geg ' [oo4]='geg111' [kk4]='wwe2233' [zz3]='w223' [mm3]='%%^&' [23433]='gege1234' [gege233]='5645'
            [xx5]='geg ' [oo5]='geg111' [kk5]='wwe2233' [zz4]='w223' [mm4]='%%^&' [23434]='gege1234' [gege234]='5645'
            [xx6]='geg ' [oo6]='geg111' [kk6]='wwe2233' [zz5]='w223' [mm5]='%%^&' [23435]='gege1234' [gege235]='5645'
            [xx7]='geg ' [oo7]='geg111' [kk7]='wwe2233' [zz6]='w223' [mm6]='%%^&' [23436]='gege1234' [gege236]='5645'
            [xx8]='geg ' [oo8]='geg111' [kk8]='wwe2233' [zz7]='w223' [mm7]='%%^&' [23437]='gege1234' [gege237]='5645'
            )
    json_overlay bash_json to_overlay_dict [project_in_process] [project1] [extra2]
    json_dump_ho bash_json
}

# 需要验证的场景
# 解码算法
#   0:
#     内置
#   1:
#     base64(这两个不需要单独测试)
#           ibase64
#           base64
#  标准json解析器
#    python3
#    awk
# 魔法字符串
#   默认
#   指定
#
test_case_all 0 '' &&
test_case_all 1 ''
test_case_all 0 '' 'mock_python_fail'

