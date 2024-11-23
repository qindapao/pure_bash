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
    local -A bash_json=()

    {
    IFS= read -r -d '' json_str <<'    EOF'

     {
    "person": {
        "n:am,[]{}e": "John",
        "ag\n \t\"e": "30",
        "habbit": ["xxoo", "ccccccccccccccc", "kkyy"],
        "other": [],
        "other": {},
        "otheragain": [[], {},
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
    json_load bash_json "$standard_json_file" >/dev/null 2>&1
    
    #3. json_dump
    # declare -p bash_json
    # json_dump_ho bash_json

    #4. json_get
    local project_name=
    json_get project_name bash_json project_in_process "pr > oject2" name

    local -A ret=()
    [[ "$project_name" == 'good' ]] && {
        ret[json_get]=0
    } || ret[json_get]=1

    #5. json_set
    json_set bash_json [project_in_process] "[pr > oject2]" [extra] - 'no expect'
    local get_new
    json_get get_new bash_json project_in_process "pr > oject2" extra

    [[ "$get_new" == 'no expect' ]] && {
        ret[json_set]=0
    } || ret[json_set]=1

    #6. json_del
    json_del bash_json project_in_process project1
    local -A get_after_del=()
    json_get get_after_del bash_json project_in_process project1

    if ((${#get_after_del[@]})) ; then
        ret[json_del]=1
    else
        ret[json_del]=0
    fi

    #7. json_del_de
    json_del_de bash_json [habbit] 1
    local -a get_after_del_de get_after_del_de_spec=(xxoo kkyy)
    json_get get_after_del_de bash_json habbit

    if assert_array 'a' get_after_del_de get_after_del_de_spec ; then
        ret[json_del_de]=0
    else
        ret[json_del_de]=1
    fi

    #8. json_del_de_ke
    json_del_de_ke bash_json [otheragain] 15
    json_del_de_ke bash_json [habbit] 0
    json_del_de_ke bash_json [habbit] 0
    # json_dump_ho bash_json
    
    local -a other_indexs=({0..16})
    local -a other
    local -a habit=() habit_spec=()
    json_get habit bash_json habbit
    json_get other bash_json otheragain

    if [[ "${!other[*]}" == "${other_indexs[*]}" ]] &&
        assert_array 'a' habit habit_spec ; then
        ret[json_del_de_ke]=0
    else
        ret[json_del_de_ke]=1
    fi
    
    #9. json_del_ke
    json_set bash_json [work] [main] 0 - teaher
    json_set bash_json [work] [main] 1 - seller
    json_set bash_json [work] [main] 2 - 'animal
main'
    json_del_ke bash_json work main 1
    local -a get_main=() main_spec=([0]=teaher [2]='animal
main') 
    json_get get_main bash_json work main
    if ! assert_array 'a' get_main main_spec ; then
        ret[json_del_ke]=1
    fi

    json_del_ke bash_json work main 0
    json_del_ke bash_json work main 2
    # json_dump_ho bash_json
    local main_spec=()
    json_get get_main bash_json work main
    if assert_array 'a' get_main main_spec ; then
        ret[json_del_ke]=0
    else
        ret[json_del_ke]=1
    fi

    #10. json_extract_de
    # json_dump_ho bash_json
    local json_extract_str
    local indexs=({0..15})
    local -a json_extract_str_after=()
    json_extract_de json_extract_str bash_json [otheragain] 9
    json_get json_extract_str_after bash_json otheragain

    # declare -p json_extract_str json_extract_str_after
    if [[ "$json_extract_str" == 'null' ]] &&
        [[ "${!json_extract_str_after[*]}" == "${indexs[*]}" ]] ; then
        ret[json_extract_de]=0
    else
        ret[json_extract_de]=1
    fi

    #11. json_extract_de_ke
    json_set bash_json [extra] 0 - tobedelete1
    json_set bash_json [extra] 1 - tobedelete2
    json_set bash_json [extra] 2 - tobedelete3
    json_set bash_json [extra] 3 - tobedelete4
    # json_dump_ho bash_json
    local get_exp
    json_extract_de_ke get_exp bash_json [extra] 2
    # json_dump_ho bash_json
    local -a get_array=() get_array_spec=(tobedelete1 tobedelete2 tobedelete4)
    json_get get_array bash_json extra
    if [[ "$get_exp" != "tobedelete3" ]] || ! assert_array 'a' get_array get_array_spec ; then
        ret[json_extract_de_ke]=1
    fi
    json_extract_de_ke get_exp bash_json [extra] 2
    json_extract_de_ke get_exp bash_json [extra] 1
    json_extract_de_ke get_exp bash_json [extra] 0
    # json_dump_ho bash_json
    json_get get_array bash_json extra
    local get_array_spec=()
    if assert_array 'a' get_array get_array_spec ; then
        ret[json_extract_de_ke]=0
    else
        ret[json_extract_de_ke]=1
    fi

    #12. json_insert
    # 先挂接一个空数组
    json_overlay bash_json PURE_BASH_NULL_ARRAY [extra] [happy]
    json_insert bash_json [extra] [happy] 0 - haha
    json_insert bash_json [extra] [happy] 1 - heihei
    json_insert bash_json [extra] [happy] 1 - xx
    local -a liwai_after=(haha xx heihei)
    local -a liwai
    json_get liwai bash_json extra happy
    if assert_array 'a' liwai liwai_after ; then
        ret[json_insert]=0
    else
        ret[json_insert]=1
    fi

    #13. json_o_insert
    local -A insert_dict=([hah]=1 [kaixk]=2)
    json_o_insert bash_json insert_dict [extra] [happy] 3
    local -A get_dict=()
    json_get get_dict bash_json extra happy 3
    if assert_array 'A' get_dict insert_dict ; then
        ret[json_o_insert]=0
    else
        ret[json_o_insert]=1
    fi
    # json_dump_ho bash_json

    #14. json_o_push
    local my_array=(1 2 34)
    json_o_push bash_json my_array [extra] [happy]
    # json_dump_ho bash_json
    local -a get_array=()
    json_get get_array bash_json extra happy 4
    if assert_array 'a' get_array my_array ; then
        ret[json_o_push]=0
    else
        ret[json_o_push]=1
    fi
    #15 json_o_unshift
    local my_array=(1 2 34)
    json_o_unshift bash_json my_array [extra] [happy]
    # json_dump_ho bash_json
    local -a get_array=()
    json_get get_array bash_json extra happy 0
    if assert_array 'a' get_array my_array ; then
        ret[json_o_push]=0
    else
        ret[json_o_push]=1
    fi
    #16. json_pop
    local -a pop_array=() pop_array_spec=(1 2 34)
    json_pop pop_array bash_json [extra] [happy]
    if assert_array 'a' pop_array pop_array_spec ; then
        ret[json_pop]=0
    else
        ret[json_pop]=1
    fi
    # json_dump_ho bash_json

    #17. json_attr_get
    local attr attr1 attr2 attr3
    json_attr_get attr bash_json project_in_process "pr > oject2"
    json_attr_get attr1 bash_json otheragain
    json_attr_get attr2 bash_json otheragain 2
    json_attr_get attr3 bash_json otheragain 2 3

    if [[ "$attr" == 'A' ]] && [[ "$attr1" == 'a' ]] && [[ "$attr2" == 's' ]] &&
        [[ -z "$attr3" ]]; then
        ret[json_attr_get]=0
    else
        ret[json_attr_get]=1
    fi

    #18. json_pop_ke
    local pop_e
    local null_array=()
    json_pop_ke pop_e bash_json [extra] [happy] 0
    json_pop_ke pop_e bash_json [extra] [happy] 0
    json_pop_ke pop_e bash_json [extra] [happy] 0
    # json_dump_ho bash_json
    json_get null_array bash_json extra happy 0
    if assert_array 'a' null_array PURE_BASH_NULL_ARRAY && 
        [[ "$pop_e" == '1' ]] ; then
        ret[json_pop_ke]=0
    else
        ret[json_pop_ke]=1
    fi
    # json_dump_ho bash_json

    #19. json_push
    json_push bash_json [otheragain] - 'new value'
    local new_value=
    json_get new_value bash_json otheragain 16
    if [[ "$new_value" == 'new value' ]] ; then
        ret[json_push]=0
    else
        ret[json_push]=1
    fi
    # json_dump_ho bash_json
    
    #20. json_shift
    local -a shift_e
    json_shift shift_e bash_json [extra] [happy]
    unset shift_e ; local shift_e
    json_shift shift_e bash_json [extra] [happy]

    if [[ "$shift_e" == 'haha' ]] ; then
        ret[json_shift]=0
    else
        ret[json_shift]=1
    fi
    # json_dump_ho bash_json
    
    #21. json_shift_ke
    local shift_e
    json_shift_ke shift_e bash_json [extra] [happy]
    json_shift_ke shift_e bash_json [extra] [happy]
    local -A shift_e shift_e_spec=([hah]=1 [kaixk]=2)
    json_shift_ke shift_e bash_json [extra] [happy]
    if assert_array 'A' shift_e shift_e_spec ; then
        ret[json_shift_ke]=0
    else
        ret[json_shift_ke]=1
    fi
    # json_dump_ho bash_json

    #22. json_unshift
    json_unshift bash_json [extra] [happy] - '1'
    json_unshift bash_json [extra] [happy] - '2'
    local get_array=()
    json_get get_array bash_json extra happy
    local -a spec=(2 1)
    if assert_array 'a' spec get_array ; then
        ret[json_unshift]=0
    else
        ret[json_unshift]=1
    fi

    # json_dump_ho bash_json
    #23. json_has_key
    local ret_v=''
    json_has_key bash_json project_in_process "pr > oject2" "proc essdatay> " 4 ; ret_v="$?$ret_v"
    json_has_key bash_json project_in_process "pr > oject2" "proc essdatay> " ; ret_v="$?$ret_v"
    json_has_key bash_json otheragain ; ret_v="$?$ret_v"
    json_has_key bash_json otheragain 8 ; ret_v="$?$ret_v"
    json_has_key bash_json otheragain 8 12 13 ; ret_v="$?$ret_v"
    json_has_key bash_json paart ; ret_v="$?$ret_v"
    
    if [[ "$ret_v" == '02100021' ]] ; then
        ret[json_has_key]=0
    else
        ret[json_has_key]=1
    fi

    if cntr_all ret '[[ "$1" == "0" ]]' ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
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
test_case_all 1 '' &&
test_case_all 0 "my_son" &&
test_case_all 1 "my_father" &&
test_case_all 0 '' 'mock_python_fail' &&
test_case_all 1 '' 'mock_python_fail' &&
test_case_all 0 "my_son" 'mock_python_fail' &&
test_case_all 1 "my_father" 'mock_python_fail'

