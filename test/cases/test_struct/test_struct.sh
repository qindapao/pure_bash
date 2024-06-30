#!/usr/bin/bash

_test_struct_old_dir="$(pwd)"
root_dir="${_test_struct_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./struct/struct_load.sh || return 1
. ./struct/struct_push.sh || return 1
. ./struct/struct_dump.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_struct_old_dir"

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
struct_load my_dict 'test1.txt'
struct_dump my_dict

struct_push my_dict 4 [hahahah] 1 '' 'qq'
struct_push my_dict 4 [hahahah] 1 '' 'qq'
struct_push my_dict 4 [hahahah] 1 '' 'qq'
struct_push my_dict 4 [hahahah] 1 '' 'qq'
struct_push my_dict 4 [hahahah] 1 '' 'qq'
struct_dump my_dict

}
test_case1

