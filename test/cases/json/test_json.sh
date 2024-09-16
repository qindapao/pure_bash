#!/usr/bin/bash

_test_json_old_dir="$PWD"
root_dir="${_test_json_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./json/json_del.sh || return 1
. ./json/json_del_keep_empty.sh || return 1
. ./json/json_dump.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_init.sh || return 1
. ./json/json_load.sh || return 1
. ./json/json_overlay.sh || return 1
. ./json/json_overlay_keep_empty.sh || return 1
. ./json/json_pack.sh || return 1
. ./json/json_pop.sh || return 1
. ./json/json_pop_keep_empty.sh || return 1
. ./json/json_push.sh || return 1
. ./json/json_set.sh || return 1
. ./json/json_shift.sh || return 1
. ./json/json_shift_keep_empty.sh || return 1
. ./json/json_unpack.sh || return 1
. ./json/json_unshift.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_json_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

alias xx="date +'%Y_%m_%d_%H_%M_%S'"

test_case1 ()
{
cat <<EOF >json_standard.txt
{
    "person": {
        "name": "John",
        "age": "30",
        "age2": 33,
        "address": {
            "city": "New York\\ngeg geg\\n",
            "zipcode": "10001"
        },
        "other": {
            "xx": ["OO", {}, []],
            "yy": {"不是": "putong", "就是": "zhecichenggsng"},
            "mm": [],
            "geg不对": {}
        },
        "another": null,
        "hobbies": ["reading", "traveling", "swimming"],
        "others": {
            "132": ["gge", "geg", "1223"],
            "133": ["gge", "geg", "1223"],
            "gegeeg": {"geg": "geg", "kkk": "yyyyg"}
        }
    }
}
EOF
    json_init   

    json_common_load.py -i json_standard.txt -o json_bash.txt -m 'standard_to_bash'
    # 测试json_load
    local -A bash_json=()
    local -A bash_json2=()

    json_load 'bash_json' './json_bash.txt'
    json_load 'bash_json2' './json_bash.txt'
    # 测试json_dump
    json_dump_hq 'bash_json'
    json_dump_ho 'bash_json'
    json_dump_vq 'bash_json'
    json_dump_vo 'bash_json'

    # json_set
    json_set 'bash_json' '[other]' '[xx]' 0 - 'XX'
    json_dump_vo 'bash_json'
    json_set 'bash_json' '[other]' '[xx]' 1 '[new_key]' - 'new_value'
    json_dump_vo 'bash_json'
    json_set 'bash_json' '[other]' '[xx]' 2 '10' - '10_value'
    json_dump_vo 'bash_json'

    # json_del
    json_del 'bash_json' 'other' 'xx' 2 10
    json_dump_vo 'bash_json'
    json_del 'bash_json' 'other' 'mm'
    json_dump_vo 'bash_json'

    # json_del_keep_empty
    json_del_keep_empty 'bash_json' 'other' 'yy' '不是'
    json_del_keep_empty 'bash_json' 'other' 'yy' '就是'
    json_set 'bash_json' '[other]' '[yy]' '[当然是]' - '234 441'
    json_del_keep_empty 'bash_json' 'other' 'yy' '当然是'
    json_dump_vq 'bash_json'
    json_del_keep_empty 'bash_json' 'others' '132' '0'
    json_del_keep_empty 'bash_json' 'others' '132' '1'
    json_del_keep_empty 'bash_json' 'others' '132' '2'
    json_set 'bash_json' '[others]' '[132]' '[tst]' '[tst2]' '[tst3]' - 'aggin'
    json_del_keep_empty 'bash_json' 'others' '132' 'tst' 'tst2' 'tst3'
    json_dump_vq 'bash_json'

    # 测试json_get 
    local -A bash_json_get
    json_get 'bash_json_get' 'bash_json' 'other' 'yy'
    echo $?
    declare -p bash_json_get
    unset bash_json_get ; local -a bash_json_get
    json_get 'bash_json_get' 'bash_json' 'other' 'xx'
    echo $?
    declare -p bash_json_get
    
    # 测试json_overlay
    json_overlay 'bash_json' 'bash_json2' '[other]' '[geg不对]'
    json_dump_vq 'bash_json'

    # 测试json_push
    json_dump_vq 'bash_json2'
    json_push 'bash_json2' '[other]' '[xx]' - 'xxhh' 
    json_dump_vq 'bash_json2'
    json_del_keep_empty 'bash_json2' 'other' 'xx' 0
    json_del_keep_empty 'bash_json2' 'other' 'xx' 1
    json_del_keep_empty 'bash_json2' 'other' 'xx' 2
    json_del_keep_empty 'bash_json2' 'other' 'xx' 3
    json_dump_vq 'bash_json2'
    json_push 'bash_json2' '[other]' '[xx]' - 'xxhh' 
    json_dump_vq 'bash_json2'


    # 测试json_unshift
    json_del_keep_empty 'bash_json2' 'other' 'xx' 0
    json_dump_vq 'bash_json2'
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh' 
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh2' 
    json_dump_vq 'bash_json2'

    # 测试json_pop
    json_pop xx 'bash_json2' '[other]' '[xx]'
    json_pop xx 'bash_json2' '[other]' '[xx]'
    json_dump_vq 'bash_json2'


    # 测试json_pop_keep_empty
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh' 
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh2' 
    json_dump_vq 'bash_json2'
    json_pop_keep_empty xx 'bash_json2' '[other]' '[xx]'
    json_pop_keep_empty xx 'bash_json2' '[other]' '[xx]'
    json_pop xx 'bash_json2' '[other]' '[xx]'
    echo $?
    json_dump_vq 'bash_json2'
    
    # 测试json_shift & json_shift_keep_empty
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh' 
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh2' 
    json_dump_vq 'bash_json2'
    json_shift_keep_empty xx 'bash_json2' '[other]' '[xx]'
    json_dump_vq 'bash_json2'
    json_shift_keep_empty xx 'bash_json2' '[other]' '[xx]'
    json_dump_vq 'bash_json2'
    json_shift xx 'bash_json2' '[other]' '[xx]'
    json_set 'bash_json2' '[other]' '[xx]' 0 - '1_value'
    json_set 'bash_json2' '[other]' '[xx]' 5 - '5_value'
    json_set 'bash_json2' '[other]' '[xx]' 20 - '20_value'
    json_set 'bash_json2' '[other]' '[xx]' 6 - '6_value'
    json_set 'bash_json2' '[other]' '[xx]' 7 - '8_value'
    json_set 'bash_json2' '[other]' '[xx]' 8 - '8_value'
    json_set 'bash_json2' '[other]' '[xx]' 9 - '9_value'
    json_set 'bash_json2' '[other]' '[xx]' 10 - '10_value'
    json_set 'bash_json2' '[other]' '[xx]' 11 - '11_value'
    echo $?
    json_dump_vq 'bash_json2' | tee json_bash_after.txt

    # :TODO: json_insert 删除元素保持数组连续


    # json_pack
    # json_unpack

    json_common_load.py -i json_bash_after.txt -o json_standard2.txt -m 'bash_to_standard'

    # rm -f ./{json_file,json_bash}.txt
}
test_case1

