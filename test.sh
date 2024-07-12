#! /usr/bin/bash

exec_all_test_case ()
{
    # 保证当前不论在哪里都能正常执行
    local old_dir="$PWD"
    local root_dir="${old_dir%%/pure_bash*}/pure_bash"
    cd "${root_dir}"/src

    local -a import_funcs=(
        ./log/log_dbg.sh
        ./file/file_traverse.sh
        ./array/array_grep.sh
        ./str/str_endswith.sh
        )
    local i
    for i in "${import_funcs[@]}" ; do
        . "$i" || {
            printf "\033[31m%s\033[0m\n" "import fatal error!"
            return 1 
        }
    done

    local test_report="$root_dir"/test_report_$(date_log).txt
    local -a test_case_files_tmp=() test_case_files=() 
    cd "${root_dir}/test/cases"
    local IFS=$'\n' ; test_case_files_tmp=($(file_traverse '.')) ; unset IFS
    array_grep test_case_files_tmp test_case_files str_endswith '.sh'

    local test_case

    for test_case in "${test_case_files[@]}" ; do
        cd "${root_dir}/test/cases"
        cd "${test_case%/*}"
        bash "${test_case##*/}" | tee -a "$test_report"
    done

    cd "$old_dir"
}

exec_all_test_case
exit 0



# :TODO: 这个脚本的意义是跑所有的测试用例
# 注意: 库和测试用例函数的目录依赖

# :TODO: 递归进入测试用例的所有目录，然后执行所有用例并且上报执行情况，生成日志


: :TODO: 后面的代码后面都要删除


cd ./src
. ./struct/struct_dump.sh
. ./struct/struct_set_field.sh
. ./struct/struct_get_field.sh
. ./struct/struct_del_field.sh
. ./struct/struct_overlay_subtree.sh
. ./struct/struct_load.sh
. ./log/log_dbg.sh
. ./struct/struct_pack.sh
. ./struct/struct_unpack.sh
. ./str/str_pack.sh
. ./date/date_get_date_from_second.sh
. ./array/array_join.sh
cd ..

test_case1 ()
{
    local -A my_dict=()
    struct_set_field my_dict 'key1' '' 'valuex1'
    struct_set_field my_dict 'key2' 0 '' 'value0'
    struct_set_field my_dict 'key2' 1 '' 'value1'
    struct_set_field my_dict 'key3' 0 '' 'k3value0'
    struct_dump_hq my_dict
    struct_del_field my_dict 'key2' 0
    struct_del_field my_dict 'key3'
    struct_dump_hq my_dict
}

test_case2 ()
{
    local -A my_dict=()
    struct_set_field my_dict 'key1' '' 'valuex1'
    struct_set_field my_dict 'key2' 0 1 '' 'value0'
    struct_set_field my_dict 'key2' 0 2 '' 'value0'
    struct_set_field my_dict 'key2' 0 3 '' 'value0'
    struct_set_field my_dict 'key2' 1 '' 'value1'
    struct_set_field my_dict 'key3' '' 'k3value0'
    struct_dump_hq my_dict
    struct_del_field my_dict 'key2' 1
    struct_del_field my_dict 'key2' 0 3
    struct_dump_hq my_dict
    struct_del_field my_dict 'key2' 0 2
    struct_dump_hq my_dict
    struct_del_field my_dict 'key2' 0 1
    struct_dump_hq my_dict
    struct_del_field my_dict 'key3'
    struct_dump_hq my_dict
    struct_del_field my_dict 'key1'
    struct_dump_hq my_dict
}

test_case3 ()
{
    local a='gege'
    # struct_dump_hq a
    local -A my_dict=()
    struct_set_field my_dict '[key1]' '' 'valuex1'
    struct_set_field my_dict '[key2]' 0 1 '' 'value0'
    struct_set_field my_dict '[key2]' 0 2 '' 'value0'
    struct_set_field my_dict '[key2]' 0 3 '' 'value0'
    struct_set_field my_dict '[key2]' 0 4 [yy1] 0 '' 'value0'
    struct_set_field my_dict '[key2]' 0 5 6 '' 'value0'
    struct_set_field my_dict '[key2]' 1 '' 'value1'
    # struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 10 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 11 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 12 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 13 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 14 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 15 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 16 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 17 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 18 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 19 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 20 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 21 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 22 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 23 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 24 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 25 0 1 '' 'k3value0'

# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# _struct_get_field_tmp_var=([25]=xx)
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# _struct_get_field_param="
# geg
# geg-4"
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# [[ ! -v _struct_get_field_tmp_var['${_struct_get_field_param}'] ]] && echo xx
# -bash: 
# geg
# geg-4: syntax error in expression (error token is "geg-4")
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 





    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 25 0 1 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 25 0 2 '' 'k3value0'
    struct_set_field my_dict '[key3]' 0 1 2 3 4 5 6 7 8 9 25 1 1 '' 'k3value0'
    x="
geg
geg"
    # x="geg"
    struct_set_field my_dict "[$x]" 0 1 2 3 4 5 6 7 8 9 25 1 2 '' "$x"
    struct_set_field my_dict "[$x-1]" 0 1 2 3 4 5 6 7 8 9 25 1 2 '' "$x-1"
    struct_set_field my_dict "[$x-2]" 0 1 2 3 4 5 6 7 8 9 25 1 2 '' "$x-2"
    struct_set_field my_dict "[$x-3]" 0 1 2 3 4 5 6 7 8 9 25 1 2 '' "$x-3"
    struct_set_field my_dict "[$x-4]" 0 1 2 3 4 5 6 7 8 9 25 1 2 '' "$x-4"
    struct_set_field my_dict "[$x-5]" "[$x-6]" "[$x-7]" "[$x-8]" 0 '' "$x-4"
    struct_set_field my_dict "[$x-5]" "[$x-6]" "[$x-7]" "[$x-8]" 1 '' "$x-4"
    # 设置的时候强转关联数组为索引数组是会出异常的
    struct_set_field my_dict "[$x-5]" "[$x-6]" "[$x-7]" "[$x-8]" [other1] '' "xx1"
    struct_set_field my_dict "[$x-5]" "[$x-6]" "[$x-7]" "[$x-8]" [other2] '' "xx2"
    declare -A xx2
    struct_get_field xx2 my_dict "$x-5" "$x-6" 0

    # struct_dump_hq xx2

    declare -A xx2=()
    struct_get_field xx2 my_dict "$x-5" "$x-6"
    struct_set_field xx2 "$x-2" '' 2
    struct_set_field xx2 "$x-3" '' 3
    struct_set_field xx2 "$x-3" 0 '' 3
    struct_set_field xx2 "$x-3" 1 '' 3
    struct_set_field xx2 "$x-4" '' 4
    struct_set_field xx2 "$x-5" '' 5
    # struct_dump_hq xx2

    


    struct_del_field xx2 "$x-7"
    # struct_dump_hq xx2

    struct_set_field my_dict '[xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)]' 2 [a] '' 'k3value0'
    struct_set_field my_dict '[xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)--]' 2 [a] 'i' "    "
    struct_dump_hq my_dict
    struct_del_field my_dict 'xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)' 2 a
    struct_set_field my_dict "key3" 0 1 2 3 4 5 7 7 8 9 25 "[$x]" '' 'value2'
    struct_set_field my_dict [key4] [x] [y] '' 'value2'
    struct_set_field my_dict [key4] [x] [z] '' 'value2'
    struct_dump_hq my_dict
    struct_del_field my_dict "key4"
    unset my_dict
    local -A my_dict=([xx]=1000 [yy]=2000)
    struct_del_field my_dict xx
    echo $?
    struct_dump_hq my_dict
    # declare -p qinqing
}

test_case4 ()
{
    local -A my_dict=()
    struct_set_field my_dict "[xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)]" 0 '' "xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"
    struct_set_field my_dict "[xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)]" 1 '' "xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"
    struct_dump_hq my_dict
    struct_del_field my_dict "xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)" 0
    struct_dump_hq my_dict
}

test_case_struct_overlay_subtree ()
{
    local -a my_dict=()
    struct_set_field my_dict 0 0 '' "xx"
    struct_set_field my_dict 1 1 '' "yy"
    struct_set_field my_dict 2 2 '' "qq"
    struct_set_field my_dict 3 3 '' "mm"
    struct_set_field my_dict 4 4 '' "kk"
    
    struct_dump_hq my_dict
    local -A son_dict=()
    # struct_set_field son_dict '[qin1]' '' 'va1'
    # struct_set_field son_dict '[qin2]' 0 1 '' 'va1'
    # struct_set_field son_dict '[qin2]' 0 2 '' 'va1'
    # struct_set_field son_dict '[qin2]' 1 '' 'va1'
    # struct_set_field son_dict '[qin3]' '[xxhou]' '' 'va1'
    # time struct_set_field son_dict '[xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)]' '[xxxian]' 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 '' 'va2'
    
    struct_set_field son_dict '[xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)]' '[xxxian]' 2 3 '' "xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"
    struct_set_field son_dict '[xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)]' '[xxxian]' 2 4 '' "xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"
    struct_dump_hq son_dict

    # struct_overlay_subtree my_dict son_dict 0 0
    
    # 0 0 下面挂的已经是关联数组,把关联数组强制转换成普通数组是不允许的,因为会丢失掉键
    # 所以在使用过程中要明确每层的数据结构类型,不能乱用
    # struct_overlay_subtree my_dict son_dict 0 0 1 2 3
    # struct_overlay_subtree my_dict son_dict 0 0 [1] [2] [3]
    # struct_dump_hq my_dict

}

test_struct_load ()
{
cat <<EOF >test1.txt
son_dict ⩦
    4 ⩦
        hahahah ⇒
            0 ⩦
                0 ⩦ 
                kaixing
                1 ⩦ 
                对的
                2 ⩦ 
                不对
                3 ⩦ 
                可能对
EOF

local -a my_dict=()
struct_load my_dict 'test1.txt'

big_str=''
for i in {0..2} ; do
    big_str+="i am a big str."
done
echo ${#big_str}

local -a my_dict=()
# struct_set_field my_dict 4 [hahahah] 0   '' "$big_str"
# struct_set_field my_dict 4 [hahahah] 1   '' "$big_str"
# struct_set_field my_dict 4 [hahahah] 2   '' "$big_str"
# struct_set_field my_dict 4 [hahahah] 3   '' "$big_str"
# struct_set_field my_dict 4 [hahahah] 4   '' "$big_str"
# struct_set_field my_dict 4 [hahahah] 5   '' "$big_str"
# struct_set_field my_dict 4 [xxoo] [yykk]   '' "$big_str"
# struct_set_field my_dict 4 [$'这是一个包含非打印字符的字符串，例如：\n新行，\t制表符，和其他控制字符如警报。'] [yykk]   '' "$big_str"
struct_set_field my_dict 3 5 2  '' "$big_str"
struct_set_field my_dict 3 4 2  '' "$big_str"
struct_set_field my_dict 3 3 2  '' "$big_str"
struct_set_field my_dict 3 2 2  '' "$big_str"
struct_set_field my_dict 3 1 2  '' "$big_str"
struct_set_field my_dict 3 0 "[xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)]"  '' "xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"

big_lenth=0
for i in "${!my_dict[@]}" ; do
    ((big_lenth+="${#i}"))
    ((big_lenth+="${#my_dict[$i]}"))
done

echo $big_lenth


struct_dump_ho my_dict
# struct_dump_hq my_dict
# struct_dump_ho my_dict
# struct_dump_vq my_dict
# struct_dump_vo my_dict
}


test_struct_load2 ()
{
cat <<EOF >test1.txt
son_dict ⇒
    0 ⇒ 
    $'\n\nxx'
    1 ⇒ 
    xx
    2 ⇒ 
    yy
    3 ⇒ 
    qq
    4 ⇒ 
    11
    5 ⇒ 
    12
    \ \ \  ⇒ 
    12
EOF

local -A my_dict=()
struct_load my_dict 'test1.txt'
struct_dump_hq my_dict
struct_dump_ho my_dict
struct_dump_vq my_dict
# declare -p my_dict
}


test_cmd ()
{
    sleep 10000
}

test_struct_pack ()
{
cat <<EOF >test1.txt
son_dict ⩦
    4 ⩦
        hahahah ⇒
            0 ⇒
                0 ⩦ 
                kaixing
                1 ⩦ 
                对的
                2 ⩦ 
                不对
                3 ⩦ 
                可能对
EOF

local -a my_dict=()
struct_load my_dict test1.txt
struct_dump_hq my_dict


cat <<EOF >test2.txt
son_dict ⩦
    3 ⩦
        qinqing ⇒
            1 ⇒
                1 ⩦ 
                对的\ \ 
                2 ⩦ 
                不对
                3 ⩦ 
                可能对
    4 ⩦ 
    xxyy
EOF

local -a my_dict1=()
struct_load my_dict1 test2.txt
struct_dump_hq my_dict1
local -A my_dict2=()
struct_get_field my_dict2 my_dict1 3 qinqing
struct_dump_hq my_dict2

ori_str="$(struct_pack_o my_dict1)"
orq_str=$(struct_pack_q my_dict1)

local -a unpack=()
struct_unpack 0 "$ori_str" unpack
struct_dump_hq unpack


local -a unpack=()
struct_unpack 1 "$orq_str" unpack
struct_dump_hq unpack

}

my_func ()
{
    local -a xx=("1223 " "dggeg" "
    ggeg
    gege
    " 5 6 "8 9")
    str_pack xx
}

test_str_pack ()
{
    eval local -a yy="$(my_func)"

    declare -p yy
}

test_ifs ()
{
    local IFS=$'\n'
    m=""
    printf "%q\n" "" >1.txt
    printf "%q\n" "$m" >>1.txt
    printf "%q\n" "" >>1.txt

    for i in $(<1.txt) ; do
        eval "i=$i"
        echo xx
        echo "$i"
    done
}

test_key_v ()
{
    cnt="xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"
    declare -A tmp_key=(["xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"]="xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)" [0]="xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)" )
    declare -A k=(["xxx xxx->xxx->xxx->xx:xx.x-/dev/fd/61-/dev/fd/60"]="1" ["xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"]="2" ["xxx->xxx->xxx->xx:xx.x-/dev/fd/61-/dev/fd/60"]="1" ["(xx:yy)"]="6" [5]="4" )
    # 验证发现只有bash5.2下面可以用双引号包裹,其它版本都不行
    if [[ -v 'k[${tmp_key[$cnt]}]' ]] ; then echo xx; fi
    # 验证发现只有bash5.2可以处理unset中的多级嵌套,其它版本都最好用一个中间变量
    xx="${tmp_key[$cnt]}"
    unset 'k[$xx]'
    unset 'k[${tmp_key[$cnt]}]'
    # 下面这个语法是危险的
    if [[ -v 'k[${tmp_key[$cnt]}]' ]] ; then echo xx; fi
}

test_date_get_date_from_second ()
{
    date_get_date_from_second '1996' '3721'
}

test_array_join ()
{
    local -a a=(1 2 3 4 5)
    local a_str
    a_str=$(array_join '----' "${a[@]}")
    declare -p a_str
}

test_big_cmd_param ()
{
    test_case ()
    {
        local my_big_str="${1}"
        echo "success, str lenth:${#my_big_str}"
    }

    local i tmp_str

    # 生成一个10.5M的超大字符串
    date
    for((i=0;i<100000;i++)) ; do
        tmp_str+="i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str."
    done
    date

    test_case "$tmp_str"
}

test_big_cmd_param_array ()
{
    test_case ()
    {
        local my_big_str=("${@}")
        echo "success, array lenth:${#my_big_str[@]}"
        echo "each element length:${#my_big_str[0]}"
    }

    local i
    local -a tmp_str=()

    # 生成一个10.5M的超大数组
    date
    for((i=0;i<100000;i++)) ; do
        tmp_str+=("i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.")
    done
    date

    test_case "${tmp_str[@]}"
}

test_big_cmd_param_process ()
{
    # 内部函数在外部也是可见的，只是每次进test_big_cmd_param_process会被重新定义一次
    test_case ()
    {
        local my_big_str=("${@}")
        str_pack my_big_str 
    }

    local i
    local -a tmp_str=()

    # 生成一个105M的超大数组
    date
    for((i=0;i<1000000;i++)) ; do
        tmp_str+=("i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.")
    done
    date

    get_str=$(test_case "${tmp_str[@]}")
    echo "get_str length:${#get_str}"
    date
}



# yy=$(test_cmd)

# test_key_v
# test_case1
# test_case2
# test_case3
# test_case4
# test_case_struct_overlay_subtree
# test_struct_load
# test_struct_load2
# test_struct_pack
# test_str_pack
# test_ifs
# test_date_get_date_from_second
# test_array_join
# test_big_cmd_param
# test_big_cmd_param_array
# test_big_cmd_param_process

