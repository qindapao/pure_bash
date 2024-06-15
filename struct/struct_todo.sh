. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_todo]++)) && return 0

# :TODO: 以下的内容可能是备忘
# 通过declare -p 可以把一个数据保存到一个文件中,然后在需要使用的地方直接
# Storage:~/qinqing # struct_dump 'my_dict' >1.txt
# Storage:~/qinqing # declare -p my_my_dict >2.txt
# Storage:~/qinqing # source 2.txt 
# Storage:~/qinqing # declare -p my_dict
# declare -A my_dict=([last_key1]="declare -a _struct_set_field_data_lev2=([0]=\"v0\" [1]=\"x1\" [2]=\"x2\" [3]=\"x3\" [4]=\"declare -A _struct_set_field_data_lev3=([other_key]=\\\"other6\\\" [other_key2]=\\\"other2\\\" [other_key3]=\\\"declare -a _struct_set_field_data_lev4=([0]=\\\\\\\"other3-0\\\\\\\" [1]=\\\\\\\"other3-1\\\\\\\" [2]=\\\\\\\"other3-2\\\\\\\" [3]=\\\\\\\"other3-3\\\\\\\")\\\" )\" [10]=\"v10\")" [last_key]="declare -A _struct_set_field_data_lev2=([z4]=\"x4\" [z5]=\"x5\" [z2]=\"x2\" [z3]=\"x3\" [z1]=\"x1\" [xxx]=\"0\" [xxx2]=\"value2\" [xxx3]=\"value3\" )" )
# Storage:~/qinqing # . ./struct/struct_dump.sh
# Storage:~/qinqing # struct_dump my_dict
# my_dict =>
#     last_key => 
#         xxx => 0
#         xxx2 => value2
#         xxx3 => value3
#         z1 => x1
#         z2 => x2
#         z3 => x3
#         z4 => x4
#         z5 => x5
#     last_key1 => 
#         0 = v0
#         1 = x1
#         2 = x2
#         3 = x3
#         4 = 
#             other_key => other6
#             other_key2 => other2
#             other_key3 => 
#                 0 = other3-0
#                 1 = other3-1
#                 2 = other3-2
#                 3 = other3-3
#         10 = v10
# Storage:~/qinqing # 


# 本质上这个函数不需要,结构体的顶级就是一个数组或者关联数组,直接创建即可
struct_todo ()
{
    :
}

return 0

