#! /usr/bin/bash



. ./struct/struct_dump.sh
. ./struct/struct_set_field.sh
. ./struct/struct_del_field.sh

test_case1 ()
{
    local -A my_dict=()
    struct_set_field my_dict 'key1' '' 'valuex1'
    struct_set_field my_dict 'key2' 0 '' 'value0'
    struct_set_field my_dict 'key2' 1 '' 'value1'
    struct_set_field my_dict 'key3' 0 '' 'k3value0'
    struct_dump my_dict
    struct_del_field my_dict 'key2' 0
    struct_del_field my_dict 'key3'
    struct_dump my_dict
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
    struct_dump my_dict
    struct_del_field my_dict 'key2' 1
    struct_del_field my_dict 'key2' 0 3
    struct_dump my_dict
    struct_del_field my_dict 'key2' 0 2
    struct_dump my_dict
    struct_del_field my_dict 'key2' 0 1
    struct_dump my_dict
    struct_del_field my_dict 'key3'
    struct_dump my_dict
    struct_del_field my_dict 'key1'
    struct_dump my_dict
}

test_case3 ()
{
    local -A my_dict=()
    struct_set_field my_dict '[key1]' '' 'valuex1'
    struct_set_field my_dict '[key2]' 0 1 '' 'value0'
    struct_set_field my_dict '[key2]' 0 2 '' 'value0'
    struct_set_field my_dict '[key2]' 0 3 '' 'value0'
    struct_set_field my_dict '[key2]' 0 4 5 '' 'value0'
    struct_set_field my_dict '[key2]' 1 '' 'value1'
    struct_set_field my_dict '[key3]' '' 'k3value0'
    struct_dump my_dict
    struct_del_field my_dict 'key2' 0 4 5
    struct_dump my_dict
}

# test_case1
# test_case2
test_case3

# declare -A k=(["(xx:yy)"]="6" ["xxx->xxx->xxx->xx:xx.x-/dev/fd/61-/dev/fd/60"]="1" ["xxx xxx->xxx->xxx->xx:xx.x-/dev/fd/61-/dev/fd/60"]="1" ["xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"]="2" )
# cnt=0
# tmp_key=("xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)")
# if [[ -v 'k[${tmp_key[cnt]}]' ]] ; then echo xx; fi
#
