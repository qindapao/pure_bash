. ./meta/meta.sh
((DEFENSE_VARIABLES[json_common]++)) && return 0

declare -gA JSON_COMMON_ERR_DEFINE=()

# 每一种操作留8个状态码
# set       8~ 15
# get       16~23
# del       24~31
# pop       32~39
# shift     40~47
# push      48~55
# unshift   56~63
# extract   64~71
# unpack    72~79
# pack      80~87
# insert    88~95
# overlay   96~103

# set
JSON_COMMON_ERR_DEFINE[ok]=0
# 传入键或者索引有空
JSON_COMMON_ERR_DEFINE[set_null_key]=8
JSON_COMMON_ERR_DEFINE[set_key_but_not_dict]=9
# 字典键的右边界不对
JSON_COMMON_ERR_DEFINE[set_key_right_side_wrong]=10
# 数组索引不是10进制数
JSON_COMMON_ERR_DEFINE[set_index_not_decimal]=11
# 想设置普通数组索引,但是JSON中是字典(把字典转换成普通数组)
JSON_COMMON_ERR_DEFINE[set_convert_dict_to_array]=12
# 参数检查键不存在
JSON_COMMON_ERR_DEFINE[set_no_params]=13

# get
JSON_COMMON_ERR_DEFINE[get_null_key]=16
JSON_COMMON_ERR_DEFINE[get_key_but_not_dict]=17
JSON_COMMON_ERR_DEFINE[get_key_not_found]=18
JSON_COMMON_ERR_DEFINE[get_dict_but_not_declare_outside]=19
JSON_COMMON_ERR_DEFINE[get_str_but_declare_not_str_outside]=20

# del
JSON_COMMON_ERR_DEFINE[del_null_key]=24
JSON_COMMON_ERR_DEFINE[del_key_but_not_dict]=25
JSON_COMMON_ERR_DEFINE[del_key_not_fount]=26
JSON_COMMON_ERR_DEFINE[del_null_array_not_need_handle]=27

# pop
JSON_COMMON_ERR_DEFINE[pop_not_array]=32
JSON_COMMON_ERR_DEFINE[pop_null_array]=33

# shift
JSON_COMMON_ERR_DEFINE[shift_not_array]=40
JSON_COMMON_ERR_DEFINE[shift_null_array]=41

# extract
JSON_COMMON_ERR_DEFINE[extract_not_array]=64
JSON_COMMON_ERR_DEFINE[extract_null_array]=65

# unpack
JSON_COMMON_ERR_DEFINE[unpack_type_err]=72

# pack
# JSON_COMMON_ERR_DEFINE[pack_not_dict_array]=80
# JSON_COMMON_ERR_DEFINE[pack_not_define_dict_array]=81

# insert
JSON_COMMON_ERR_DEFINE[insert_type_err]=88


# overlay





return 0

