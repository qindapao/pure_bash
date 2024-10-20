#!/usr/bin/bash

_test_json_old_dir="$PWD"
root_dir="${_test_json_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./json/json_del.sh || return 1
. ./json/json_del_ke.sh || return 1
. ./json/json_dump.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_attr_get.sh || return 1
. ./json/json_init.sh || return 1
. ./json/json_load.sh || return 1
. ./json/json_overlay.sh || return 1
. ./json/json_pack.sh || return 1
. ./json/json_pop.sh || return 1
. ./json/json_pop_ke.sh || return 1
. ./json/json_push.sh || return 1
. ./json/json_set.sh || return 1
. ./json/json_shift.sh || return 1
. ./json/json_shift_ke.sh || return 1
. ./json/json_unpack.sh || return 1
. ./json/json_unshift.sh || return 1

. ./json/json_extract_de.sh || return 1
. ./json/json_extract_de_ke.sh || return 1
. ./json/json_del_de.sh || return 1
. ./json/json_del_de_ke.sh || return 1
. ./json/json_insert.sh || return 1

. ./json/json_o_push.sh || return 1
. ./json/json_o_unshift.sh || return 1
. ./json/json_o_insert.sh || return 1


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
        "address": {
            "city": "'New York\ngeg geg\n?*中文"
        },
        "other": {
            "xx": ["OO", {}, [null, null, 1, 2]],
            "mm": []
        },
        "others": {
            "132": ["gge", "geg", "1223"]
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

    json_common_load.py -i json_bash.txt -o json_standard2.txt -m 'bash_to_standard'

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

    # json_del_ke
    json_del_ke 'bash_json' 'other' 'yy' '不是'
    json_del_ke 'bash_json' 'other' 'yy' '就是'
    json_set 'bash_json' '[other]' '[yy]' '[当然是]' - '234 441'
    json_del_ke 'bash_json' 'other' 'yy' '当然是'
    json_dump_vq 'bash_json'
    json_del_ke 'bash_json' 'others' '132' '0'
    json_del_ke 'bash_json' 'others' '132' '1'
    json_del_ke 'bash_json' 'others' '132' '2'
    json_set 'bash_json' '[others]' '[132]' '[tst]' '[tst2]' '[tst3]' - 'aggin'
    json_del_ke 'bash_json' 'others' '132' 'tst' 'tst2' 'tst3'
    json_dump_vq 'bash_json'

    # 测试json_get 
    local -A bash_json_get
    time json_get 'bash_json_get' 'bash_json' 'other' 'yy'
    echo $?
    declare -p bash_json_get
    unset bash_json_get ; local -a bash_json_get
    time json_get 'bash_json_get' 'bash_json' 'other' 'xx'
    echo $?
    declare -p bash_json_get
    
    # 测试json_overlay
    json_overlay 'bash_json' 'bash_json2' '[other]' '[geg不对]'
    json_dump_vq 'bash_json'

    # 测试json_push
    json_dump_vq 'bash_json2'
    json_push 'bash_json2' '[other]' '[xx]' - 'xxhh' 
    json_dump_vq 'bash_json2'
    json_del_ke 'bash_json2' 'other' 'xx' 0
    json_del_ke 'bash_json2' 'other' 'xx' 1
    json_del_ke 'bash_json2' 'other' 'xx' 2
    json_del_ke 'bash_json2' 'other' 'xx' 3
    json_dump_vq 'bash_json2'
    json_push 'bash_json2' '[other]' '[xx]' - 'xxhh' 
    json_dump_vq 'bash_json2'


    # 测试json_unshift
    json_del_ke 'bash_json2' 'other' 'xx' 0
    json_dump_vq 'bash_json2'
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh' 
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh2' 
    json_dump_vq 'bash_json2'

    # 测试json_pop
    json_pop xx 'bash_json2' '[other]' '[xx]'
    json_pop xx 'bash_json2' '[other]' '[xx]'
    json_dump_vq 'bash_json2'


    # 测试json_pop_ke
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh' 
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh2' 
    json_dump_vq 'bash_json2'
    json_pop_ke xx 'bash_json2' '[other]' '[xx]'
    json_pop_ke xx 'bash_json2' '[other]' '[xx]'
    json_pop xx 'bash_json2' '[other]' '[xx]'
    echo $?
    json_dump_vq 'bash_json2'
    
    # 测试json_shift & json_shift_ke
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh' 
    json_unshift 'bash_json2' '[other]' '[xx]' - 'xxhh2' 
    json_dump_vq 'bash_json2'
    json_shift_ke xx 'bash_json2' '[other]' '[xx]'
    json_dump_vq 'bash_json2'
    json_shift_ke xx 'bash_json2' '[other]' '[xx]'
    json_dump_vq 'bash_json2'
    json_shift xx 'bash_json2' '[other]' '[xx]'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 0 0 - 'x'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 0 1 - 'y'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 0 2 0 - '11_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 0 3 1 - '11_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 0 6 1 - '11_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 0 7 1 - '11_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 2 0 1 - 'x1'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 2 1 2 - 'y1'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 2 2 - '1_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 2 3 - '1_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 2 6 - '1_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 2 7 - '1_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 11 0 - '11_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 11 1 - '11_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 11 2 - '11_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 11 5 - '11_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 11 6 - '12_value'
    time json_set 'bash_json2' '[other]' '[xx]' 0 0 0 0 0 0 0 0 11 7 - '13_value'
    time json_get xx 'bash_json2' 'other' 'xx' 0 0 0 0 0 0 0 0 11 4
    echo $?

    json_dump_vq 'bash_json2'
    declare -p xx
    length=$(declare -p bash_json2)
    echo "length:${#length}"


    # json_overlay 空数组场景
    local -a bash_son=()
    json_set 'bash_json2' '[other]' '[pp]' '[kk]' - 'kk_value'
    json_dump_vq 'bash_json2' | tee json_bash_after.txt
    json_overlay 'bash_json2' 'bash_son' '[other]' '[pp]' '[kk]'

    json_dump_vq 'bash_json2' | tee json_bash_after.txt

    # :TODO: json_insert 删除元素保持数组连续


    # json_pack
    # json_unpack

    json_common_load.py -i json_bash_after.txt -o json_standard2.txt -m 'bash_to_standard'

    # rm -f ./{json_file,json_bash}.txt
}

test_case2 ()
{
cat <<EOF >json_standard.txt
{
    "person": {
        "name": "John",
        "age": "30",
        "age2": 33,
        "kind": ["对这部", "dkkge", "是否有空元素"]
    }
}
EOF

    json_init   

    json_common_load.py -i json_standard.txt -o json_bash.txt -m 'standard_to_bash'
    # 测试json_load
    local -A bash_json=()

    json_load 'bash_json' './json_bash.txt'
    # 测试json_dump
    json_dump_vq 'bash_json'
    
    json_extract_de_ke xx 'bash_json' '[kind]' 1
    json_dump_vq 'bash_json'
    declare -p xx
    json_extract_de_ke xx 'bash_json' '[kind]' 1
    json_dump_vq 'bash_json'
    declare -p xx
    json_extract_de_ke xx 'bash_json' '[kind]' 0
    json_dump_vq 'bash_json'
    declare -p xx
    json_extract_de_ke xx 'bash_json' '[kind]' 0
    json_dump_vq 'bash_json'
    declare -p xx


}

test_case3 () {
cat <<EOF >json_standard.txt
{
    "person": {
        "name": "John",
        "age": "30",
        "age2": 33,
        "kind": ["对这部", "dkkge", "是否有空元素"]
    }
}
EOF

    json_init   

    json_common_load.py -i json_standard.txt -o json_bash.txt -m 'standard_to_bash'
    # 测试json_load
    local -A bash_json=()

    json_load 'bash_json' './json_bash.txt'
    # 测试json_dump
    json_dump_vq 'bash_json'
    
    json_del_de 'bash_json' '[kind]' 1
    json_dump_vq 'bash_json'
    json_del_de 'bash_json' '[kind]' 1
    json_dump_vq 'bash_json'
    json_del_de 'bash_json' '[kind]' 0
    json_dump_vq 'bash_json'
    json_del_de 'bash_json' '[kind]' 0
    json_dump_vq 'bash_json'


}

test_case4 () {
cat <<EOF >json_standard.txt
{
    "person": {
        "name": "John",
        "age": "30",
        "age2": 33,
        "kind": ["对这部", "dkkge", "是否有空元素"]
    }
}
EOF

    json_init   

    json_common_load.py -i json_standard.txt -o json_bash.txt -m 'standard_to_bash'
    # 测试json_load
    local -A bash_json=()

    json_load 'bash_json' './json_bash.txt'
    # 测试json_dump
    json_dump_vq 'bash_json'
    
    json_del_de_ke 'bash_json' '[kind]' 1
    json_dump_vq 'bash_json'
    json_del_de_ke 'bash_json' '[kind]' 1
    json_dump_vq 'bash_json'
    json_del_de_ke 'bash_json' '[kind]' 0
    json_dump_vq 'bash_json'
    json_del_de_ke 'bash_json' '[kind]' 0
    json_dump_vq 'bash_json'


}

test_case5 ()
{
    local -a null_array=()

    declare -a json_unpack=('ce shi1' 'ce shi2')
    json_set 'json_unpack' '0' '[dick_key1]' - 'xx'
    local -a json_pack=$(json_pack_o 'json_unpack')

    json_push 'null_array' - "$json_pack"
    json_push 'null_array' - "$json_pack"
    # json_push 'null_array' - "$json_pack"

    json_set 'null_array' 0 1 2 - 'value1'
    json_push 'null_array' 0 1 - 'value2'
    # json_push 'null_array' 0 1 - 'value2'
    json_dump_vq 'null_array'
    json_del 'null_array' 0
    json_del 'null_array' 1
    json_dump_vq 'null_array'

    local -A null_dict=(['a bc']=1)
    json_dump_vq 'null_dict'
    json_del 'null_dict' 'a bc'
    json_dump_vq 'null_dict'
}


test_case6 ()
{
    local -a null_array=()

    declare -a json_unpack=('ce shi1' 'ce shi2')
    json_set 'json_unpack' '0' '[dick_key1]' - 'xx'
    local -a json_pack=$(json_pack_o 'json_unpack')

    json_push 'null_array' - "$json_pack"
    json_push 'null_array' - "$json_pack"
    # json_push 'null_array' - "$json_pack"

    json_dump_vq 'null_array'
    json_unshift 'null_array' - 'rt'
    json_dump_vq 'null_array'

}

test_case7 ()
{
    local -a null_array=()

    declare -a json_unpack=('ce shi1' 'ce shi2')
    json_set 'json_unpack' '0' '[dick_key1]' - 'xx'
    local -a json_pack=$(json_pack_o 'json_unpack')

    json_push 'null_array' - "$json_pack"
    json_push 'null_array' - "$json_pack"
    # json_push 'null_array' - "$json_pack"

    json_dump_vq 'null_array'
    json_unshift 'null_array' - 'rt'
    json_dump_vq 'null_array'
    json_unshift 'null_array' - 'rt'
    json_dump_vq 'null_array'
    json_push 'null_array' - 'rt2'
    json_dump_vq 'null_array'
}

test_case8 ()
{
    local -a null_array=()

    declare -a json_unpack=('ce shi1' 'ce shi2')
    json_set 'json_unpack' '0' '[dick_key1]' - 'xx'
    local -a json_pack=$(json_pack_o 'json_unpack')

    json_push 'null_array' - "$json_pack"
    json_push 'null_array' - "$json_pack"
    # json_push 'null_array' - "$json_pack"

    json_dump_vq 'null_array'
    json_unshift 'null_array' - 'rt'
    json_dump_vq 'null_array'
    json_unshift 'null_array' - 'rt'
    json_dump_vq 'null_array'
    json_push 'null_array' - 'rt2'
    json_dump_vq 'null_array'
    json_insert 'null_array' '4' - 'insert_4'
    json_dump_vq 'null_array'
    json_set 'null_array' 2 5 - 'insert 5'
    json_set 'null_array' 2 9 - 'insert 9'
    json_dump_vq 'null_array'
    json_insert 'null_array' 2 0 - 'insert 100'
    json_set 'null_array' 20 - 'insert 20'
    json_dump_vq 'null_array'
    json_insert 'null_array' 0 - 'insert top 0'
    json_dump_vq 'null_array'
}

test_case9 ()
{
    local -a test_json=(0 1 2 3 4)
    json_dump_ho 'test_json'
    json_shift xx 'test_json'
    json_dump_ho 'test_json'

}


test_json_unpack ()
{
    local -a arr=(1 2 3 4 5)
    local str1 out_str1
    json_get 'str1' 'arr' 2
    
    json_unpack_o "$str1" 'out_str1'
    echo $?
    declare -p str1 out_str1

    json_set 'arr' 2 '[key1]' '[key2]' - 'value1'
    json_set 'arr' 2 '[key3]' '10' - 'value1'
    json_dump_ho 'arr'

    local -A get_dict=()
    json_get 'get_dict' arr 2
    json_dump_ho get_dict
    
    local arr_str=
    arr_str=$(json_pack_o arr)
    local -a unpack_obj
    json_unpack_o "$arr_str" 'unpack_obj'
    echo $?
    json_dump_ho 'unpack_obj'

    local -A dict=([key1]='value1' [key2]='value2')
}

test_json_pop ()
{
    local -a arr=(0 1 2 3 4 5)
    arr[10]=10
    arr[15]=15
    local str_out=
    json_pop 'str_out' 'arr'
    json_dump_ho 'arr'
    declare -p str_out

    # pop一个字典出来
    json_set 'arr' 10 '[key1]' 0 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 0 '[key3]' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 2 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 2 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 2 '0' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 2 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 2 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 5 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 5 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 5 '0' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 5 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 5 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 7 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 7 '[key3]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 3 - 'value3'
    json_dump_ho 'arr'

    unset arr_out ; local -A arr_out=()
    json_pop 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    unset arr_out ; local -a arr_out=()
    json_pop 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    unset arr_out ; local -a arr_out=()
    json_pop 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    unset arr_out ; local -A arr_out=()
    json_pop 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr'
    json_dump_ho 'arr_out'

}

test_json_pop_ke ()
{
    local -a arr=(0 1 2 3 4 5)
    arr[10]=10
    arr[15]=15
    local str_out=
    json_pop_ke 'str_out' 'arr'
    json_dump_ho 'arr'
    declare -p str_out

    # pop一个字典出来
    json_set 'arr' 10 '[key1]' 0 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 0 '[key3]' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 2 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 2 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 2 '0' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 2 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 2 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 5 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 5 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 5 '0' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 5 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 5 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 7 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 7 '[key3]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 3 - 'value3'
    json_dump_ho 'arr'

    unset arr_out ; local -A arr_out=()
    json_pop_ke 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    unset arr_out ; local -a arr_out=()
    json_pop_ke 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    unset arr_out ; local -a arr_out=()
    json_pop_ke 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    unset arr_out ; local -A arr_out=()
    json_pop_ke 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    unset arr_out ; local arr_out=''
    json_pop_ke 'arr_out' 'arr' 10 '[key1]'
    echo $?
    json_dump_ho 'arr'
    json_dump_ho 'arr_out'

}

test_json_shift ()
{
    local -a arr=(0 1 2 3 4 5)
    arr[10]=10
    arr[15]=15
    local str_out=
    json_shift 'str_out' 'arr'
    json_dump_ho 'arr'
    declare -p str_out

    # pop一个字典出来
    json_set 'arr' 10 '[key1]' 0 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 0 '[key3]' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 2 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 2 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 2 '0' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 2 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 2 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 5 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 5 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 5 '0' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 5 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 5 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 7 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 7 '[key3]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 3 - 'value3'
    json_dump_ho 'arr'

    unset arr_out ; local -A arr_out=()
    json_shift 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'


    unset arr_out ; local -a arr_out=()
    json_shift 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'

    unset arr_out ; local -a arr_out=()
    json_shift 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'

    unset arr_out ; local -A arr_out=()
    json_shift 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr'
    json_dump_ho 'arr_out'
}

test_json_shift_ke ()
{
    local -a arr=(0 1 2 3 4 5)
    arr[10]=10
    arr[15]=15
    local str_out=
    json_shift_ke 'str_out' 'arr'
    json_dump_ho 'arr'
    declare -p str_out

    # pop一个字典出来
    json_set 'arr' 10 '[key1]' 0 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 0 '[key3]' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 2 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 2 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 2 '0' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 2 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 2 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 5 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 5 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 5 '0' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 5 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 5 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 7 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 7 '[key3]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 3 - 'value3'
    json_dump_ho 'arr'

    unset arr_out ; local -A arr_out=()
    json_shift_ke 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'


    unset arr_out ; local -a arr_out=()
    json_shift_ke 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'

    unset arr_out ; local -a arr_out=()
    json_shift_ke 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'

    unset arr_out ; local -A arr_out=()
    json_shift_ke 'arr_out' 'arr' 10 '[key1]'
    json_dump_ho 'arr'
    json_dump_ho 'arr_out'
}

test_json_extract_de ()
{
    local -a arr=(0 1 2 3 4 5)
    arr[10]=10
    arr[15]=15
    local str_out=
    json_extract_de 'str_out' 'arr' '3'
    json_dump_ho 'arr'
    declare -p str_out

    # pop一个字典出来
    json_set 'arr' 10 '[key1]' 0 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 0 '[key3]' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 2 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 2 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 2 '0' 14 - 'value4'
    json_set 'arr' 10 '[key1]' 2 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 2 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 5 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 5 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 5 '0' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 5 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 5 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 7 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 7 '[key3]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 3 - 'value3'
    json_dump_ho 'arr'

    unset arr_out ; local -a arr_out=()
    json_extract_de 'arr_out' 'arr' 10 '[key1]' 2
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'
    

    unset arr_out ; local -a arr_out=()
    json_extract_de 'arr_out' 'arr' 10 '[key1]' 1
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'

    unset arr_out ; local -A arr_out=()
    json_extract_de 'arr_out' 'arr' 10 '[key1]' 1
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'

    unset arr_out ; local -A arr_out=()
    json_extract_de 'arr_out' 'arr' 10 '[key1]' 0
    json_dump_ho 'arr'
    json_dump_ho 'arr_out'
}

test_json_extract_de_ke ()
{
    local -a arr=(0 1 2 3 4 5)
    arr[10]=10
    arr[15]=15
    local str_out=
    json_extract_de_ke 'str_out' 'arr' '3'
    json_dump_ho 'arr'
    declare -p str_out

    # pop一个字典出来
    json_set 'arr' 10 '[key1]' 0 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 0 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 0 '[key3]' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 2 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 2 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 2 '0' 14 - 'value4'
    json_set 'arr' 10 '[key1]' 2 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 2 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 5 '0' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 5 '0' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 5 '0' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 5 '0' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 5 '5' 3 - 'value3'

    json_set 'arr' 10 '[key1]' 7 '[key2]' 0 - 'value0'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 1 - 'value1'
    json_set 'arr' 10 '[key1]' 7 '[key3]' 4 - 'value4'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 5 - 'value5'
    json_set 'arr' 10 '[key1]' 7 '[key2]' 3 - 'value3'
    json_dump_ho 'arr'

    unset arr_out ; local -a arr_out=()
    json_extract_de_ke 'arr_out' 'arr' 10 '[key1]' 2
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'
    

    unset arr_out ; local -a arr_out=()
    json_extract_de_ke 'arr_out' 'arr' 10 '[key1]' 1
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'

    unset arr_out ; local -A arr_out=()
    json_extract_de_ke 'arr_out' 'arr' 10 '[key1]' 1
    json_dump_ho 'arr_out'
    json_dump_ho 'arr'

    unset arr_out ; local -A arr_out=()
    json_extract_de_ke 'arr_out' 'arr' 10 '[key1]' 0
    json_dump_ho 'arr'
    json_dump_ho 'arr_out'

    unset arr_out ; local -A arr_out=()
    json_extract_de_ke 'arr_out' 'arr' 10 '[key1]' 0
    json_dump_ho 'arr'
    json_dump_ho 'arr_out'
}

test_json_overlay ()
{
    local -a arr=(0 2 3 4)
    local str1=" new info"
    json_overlay 'arr' 'str1' 2
    json_dump_ho 'arr'

    local arr2=(5 6 7)
    json_overlay 'arr' 'arr2' 3
    json_dump_ho 'arr'
}

test_json_o_push ()
{
    local -a arr=(0 1 2 3)
    local str1=" new info"
    json_o_push 'arr' 'str1'
    json_dump_ho 'arr'

    local -A dict1=([test_key1]='value1' [test_key2]='value2')
    json_o_push 'arr' 'dict1'
    json_dump_ho 'arr'

    local arr2=(5 6 7)
    json_o_push 'arr' 'arr2' 7
    echo $?
    local arr2=(5 6 7)
    json_o_push 'arr' 'arr2' 7
    echo $?
    json_dump_ho 'arr'

}

test_json_o_unshift ()
{
    local -a arr=(0 1 2 3)
    local str1=" new info"
    json_o_unshift 'arr' 'str1'
    json_dump_ho 'arr'

    local -A dict1=([test_key1]='value1' [test_key2]='value2')
    json_o_unshift 'arr' 'dict1'
    json_dump_ho 'arr'

    local arr2=(5 6 7)
    json_o_unshift 'arr' 'arr2' 7
    local arr2=(x 6 7)
    json_o_unshift 'arr' 'arr2' 7
    echo $?
    json_dump_ho 'arr'
    # local arr2=(5 6 7)
    # json_o_unshift 'arr' 'arr2' 7
    # echo $?
    # json_dump_ho 'arr'

}

test_json_o_insert ()
{
    local -a arr=(0 1 2 3)
    local str1="new info"
    json_o_insert 'arr' 'str1' 1
    json_dump_ho 'arr'

    local -A dict1=([test_key1]='value1' [test_key2]='value2')
    json_overlay 'arr' dict1 '10' '[key2]' '[key3]' 0
    json_dump_ho 'arr'

    local -a arr2=(7 8 9 10)
    json_o_insert arr arr2 '10' '[key2]' '[key3]' '4'
    json_dump_ho 'arr'
    local -a arr2=(x 8 9 10)
    json_o_insert arr arr2 '10' '[key2]' '[key3]' '1'
    json_dump_ho 'arr'
    local -a arr2=(y 8 9 10)
    json_o_insert arr arr2 '10' '[key2]' '[key3]' '2'
    json_dump_ho 'arr'
    local -a arr2=(z 8 9 10)
    json_o_insert arr arr2 '10' '[key2]' '[key3]' '1'
    json_dump_ho 'arr'
}

test_base_64 ()
{
cat <<EOF >json_standard.txt
{
    "person": {
        "name": "John",
        "age": "30",
        "爱好": ["打乒乓球", "打羽毛球", "发呆"],
        "其它": [],
        "other": {},
        "别的": [[], {}],
        "部门": "测试与装备部",
        "进行中的项目": {
            "项目1": {"名字": "自动化测试", "进度": "10%"},
            "项目2": {"名字": "性能优化", "进度": "40%"}
        }
    }
}
EOF

    json_init 1 'hahaha' 
    json_common_load.py -i json_standard.txt -o json_bash.txt -m 'standard_to_bash' -a 1 -s 'hahaha'

    # base64字符串的膨胀基数是
    # 测试json_load
    local -A person=()

    json_load 'person' './json_bash.txt'

    # 测试json_dump
    json_dump_ho 'person'
    return  

    local project1_name
    json_get project1_name 'person' '进行中的项目' '项目1' '名字'
    declare -p project1_name
    
    json_insert person '[爱好]' 2 - "跑步"
    json_dump_ho 'person'

    local -A project3=([名字]="代码开发" [进度]="50%" [备注]="紧急项目")
    json_dump_ho 'project3'
    json_overlay person project3 [进行中的项目] [项目3]
    json_dump_ho 'person'

    # return

    local -A bash_json=()
    json_load 'bash_json' './json_bash.txt'
    declare -p bash_json


    # 298
    time json_set 'bash_json' '[key1]' - 'error'
    m=$(declare -p bash_json)
    echo ${#m}
    # 313
    time json_set 'bash_json' '[key2]' - 'error'
    m=$(declare -p bash_json)
    echo ${#m}
    # 328
    time json_set 'bash_json' '[key1]' '[key3]' - 'error'
    m=$(declare -p bash_json)
    echo ${#m}
    # 416
    time json_set 'bash_json' '[key1]' '[key4]' - 'error'
    m=$(declare -p bash_json)
    echo ${#m}
    # 436
    time json_set 'bash_json' '[key1]' '[key5]' - 'error'
    m=$(declare -p bash_json)
    echo ${#m}
    # 456
    time json_set 'bash_json' '[key1]' '[key5]' 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 - 'error'
    m=$(declare -p bash_json)
    echo ${#m}
    # 60152

    json_push bash_json '[null_arr]' 0 - 'xx'
    json_push bash_json '[null_arr]' 1 - 'yy'
    json_dump_vo bash_json

    json_get xx bash_json 'null_arr'
    echo $?
    declare -p xx


    json_dump_ho 'bash_json'


}

# test_case1
# test_case2
# test_case3
# test_case4
# test_case5
# test_case6
# test_case7
# test_case8
# test_case9

# test_json_unpack
# test_json_pop
# test_json_pop_ke
# test_json_shift
# test_json_shift_ke
# test_json_extract_de
# test_json_extract_de_ke

# test_json_overlay
# test_json_o_push
# test_json_o_unshift
# test_json_o_insert




# base64算法的用例
test_base_64

