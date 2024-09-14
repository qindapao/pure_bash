#!/usr/bin/bash

_test_json_old_dir="$PWD"
root_dir="${_test_json_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./json/json_load.sh || return 1
. ./json/json_push.sh || return 1
. ./json/json_dump.sh || return 1
. ./json/json_pop.sh || return 1
. ./json/json_unshift.sh || return 1
. ./json/json_shift.sh || return 1
. ./json/json_set.sh || return 1
. ./json/json_get.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_json_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

alias xx="date +'%Y_%m_%d_%H_%M_%S'"

test_case1 ()
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
json_load my_dict 'test1.txt'
json_dump_hq my_dict

json_push my_dict 4 '[hahah
geg
ah]' 1 '' 'qq1'
json_push my_dict 4 [hahahah] 1 '' 'qq2'
json_push my_dict 4 [hahahah] 1 '' 'qq3'
json_push my_dict 4 [hahahah] 1 '' 'qq4'
json_push my_dict 4 [hahahah] 1 '' 'qq5'
json_dump_hq my_dict

json_pop xx my_dict 4 [hahahah] 1
json_pop xx my_dict 4 [hahahah] 1
json_pop xx my_dict 4 [hahahah] 1
json_pop xx my_dict 4 [hahahah] 1
json_pop xx my_dict 4 [hahahah] 1
json_pop xx my_dict 4 [hahahah] 1
json_push my_dict 4 [hahahah] 1 '' 'qq
ge 5 gge  
geg geg'
json_push my_dict 4 [hahahah] 1 '' 'qq4'
json_pop xx my_dict 4 [hahahah] 1
json_pop xx my_dict 4 [hahahah] 1
json_dump_hq my_dict
json_unshift my_dict 4 [hahahah] 1 '' 123
json_unshift my_dict 4 [hahahah] 1 'u' abc
json_set my_dict 4 [hahahah] 1 50 '' abc
json_unshift my_dict 4 [hahahah] 1 'l' ABC
json_dump_hq my_dict
echo $?
json_push my_dict 4 [hahahah2] 1 '' 'qq5'
json_push my_dict 4 [hahahah2] 1 '' 'qq5'
json_push my_dict 4 [hahahah2] 1 '' 'qq5'
json_push my_dict 4 [hahahah2] 1 '' 'qq5'
json_dump_hq my_dict
json_shift xx my_dict 4 [hahahah]
json_dump_hq my_dict

local a='gge
geg geg gge
ggg'
printf -v a "%q" "$a"
b+="$a"$'\n'
b+="$a"$'\n'
b+="$a"$'\n'

json_push my_dict 4 [hahahah2] 2 1 3 '' "$b"
json_unshift my_dict 4 [hahahah2] 2 2 3 '' 'qq5'
json_dump_hq my_dict
json_dump_ho my_dict

date

json_set my_dict 4 [hahahah] 1 50 [不开张] [dkdk] [gge] [kkk] [对不起] - '测试'
json_set my_dict 4 [hahahah] 1 50 [开张] [dkdk] [gge] [kkk] [对不起] [1] [2] [3] [4] [5] [6] - '测试2'
json_set my_dict 4 [hahahah] 1 50 [开张2] [dkdk] [gge] [kkk] [对不起] [1] [2] [3] [4] [5] [6] - '测试2'
json_set my_dict 4 [hahahah] 1 50 [开张3] [dkdk] [gge] [kkk] [对不起] [1] [2] [3] [4] [5] [6] - '测试2'
json_set my_dict 4 [hahahah] 1 50 [开张4] [dkdk] [gge] [kkk] [对不起] [1] [2] [3] [4] [5] [6] - '测试2'
json_set my_dict 4 [hahahah] 1 50 [开张5] [dkdk] [gge] [kkk] [对不起] [1] [2] [3] [4] [5] [6] - '测试2gegge'
json_set my_dict 4 [hahahah] 1 50 [开张5] [dkdk] [gge] [kkk] [对不起] [1] [2] [3] [4] [5] [6] - '测试2gegge
   ggeg
 gegeg'
json_dump_ho my_dict

date
json_get 'my_dict_value' my_dict 4 hahahah 1 50 开张5 dkdk gge kkk 对不起 1 2 3 4 5 6
json_get 'my_dict_value' my_dict 4 hahahah 1 50 开张5 dkdk gge kkk 对不起 1 2 3 4 5 6
json_get 'my_dict_value' my_dict 4 hahahah 1 50 开张5 dkdk gge kkk 对不起 1 2 3 4 5 6
json_get 'my_dict_value' my_dict 4 hahahah 1 50 开张5 dkdk gge kkk 对不起 1 2 3 4 5 6
json_get 'my_dict_value' my_dict 4 hahahah 1 50 开张5 dkdk gge kkk 对不起 1 2 3 4 5 6
json_get 'my_dict_value' my_dict 4 hahahah 1 50 开张5 dkdk gge kkk 对不起 1 2 3 4 5 6
json_get 'my_dict_value' my_dict 4 hahahah 1 50 开张5 dkdk gge kkk 对不起 1 2 3 4 5 6
json_get 'my_dict_value' my_dict 4 hahahah 1 50 开张5 dkdk gge kkk 对不起 1 2 3 4 5 6
json_get 'my_dict_value' my_dict 4 hahahah 1 50 开张5 dkdk gge kkk 对不起 1 2 3 4 5 6
json_get 'my_dict_value' my_dict 4 hahahah 1 50 开张5 dkdk gge kkk 对不起 1 2 3 4 5 6
dict_get_str=$(declare -p my_dict)
declare -p my_dict_value
echo "length:${#dict_get_str}"


date


rm -f ./test1.txt

}
test_case1

