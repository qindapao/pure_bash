. ./meta/meta.sh
((DEFENSE_VARIABLES[awk_json]++)) && return 0

# https://github.com/step-/JSON.awk
awk_json_init ()
{
    local tool_exec_dir=
    meta_get_tool_dir tool_exec_dir
    [[ -s ${tool_exec_dir}/JSON.awk ]] || {  
        local exec_cp=(cp)
        local exec_chmod=(chmod)

        which sudo && {
            exec_cp=('sudo' 'cp')
            exec_chmod=('sudo' 'chmode')
        }
        "${exec_cp[@]}" -f "$PURE_BASH_TOOLS_DIR"/JSON.awk "${tool_exec_dir}"
        "${exec_chmod[@]}" +x ${tool_exec_dir}/JSON.awk
    }
}

# :TODO: 利用JSON.awk可以替换python3实现标准json到bash json的转换
# 唯一的弱点是要把bash json转换成标准json目前不行
# 但是在没有python3的环境下这样的解决方案也比较能接受了
# 目前的OS中都有包含python3,所以暂时不造轮子,如果要移植到嵌入式系统中没有python3的环境
# 以后可以考虑使用这个解决方案
# 另外还有一个很牛逼的特性是,如果BRIEF的值为0,那么可以提取出子对象,而不仅仅是叶子
# 节点,如下:
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/src/tools# awk -f ./JSON.awk -v BRIEF=0 json_standard.txt
# ["person","name"]       "John"
# ["person","age"]        "30"
# ["person","爱好",0]     "打乒乓球"
# ["person","爱好",1]     "打羽毛球"
# ["person","爱好",2]     "发呆"
# ["person","爱好"]       ["打乒乓球","打羽毛球","发呆"]
# ["person","其它"]       []
# ["person","other"]      {}
# ["person","别的",0]     []
# ["person","别的",1]     {}
# ["person","别的",2]     ""
# ["person","别的",3]     ""
# ["person","别的",4]     ""
# ["person","别的",5]     ""
# ["person","别的",6]     ""
# ["person","别的",7]     ""
# ["person","别的",8]     ""
# ["person","别的",9]     ""
# ["person","别的",10]    ""
# ["person","别的",11]    ""
# ["person","别的",12]    ""
# ["person","别的",13]    ""
# ["person","别的",14]    ""
# ["person","别的",15]    ""
# ["person","别的",16]    ""
# ["person","别的",17]    ""
# ["person","别的"]       [[],{},"","","","","","","","","","","","","","","",""]
# ["person","部门"]       "测试与装备部"
# ["person","进行中的项目","项目1","名字"]        "自动化测试"
# ["person","进行中的项目","项目1","进度"]        "10%"
# ["person","进行中的项目","项目1"]       {"名字":"自动化测试","进度":"10%"}
# ["person","进行中的项目","项目2","名字"]        "性能优化"
# ["person","进行中的项目","项目2","进度"]        "40%"
# ["person","进行中的项目","项目2"]       {"名字":"性能优化","进度":"40%"}
# ["person","进行中的项目"]       {"项目1":{"名字":"自动化测试","进度":"10%"},"项目2":{"名字":"性能优化","进度":"40%"}}
# ["person"]      {"name":"John","age":"30","爱好":["打乒乓球","打羽毛球","发呆"],"其它":[],"other":{},"别的":[[],{},"","","","","","","","","","","","","","","",""],"部门":"测试与装 
# 备部","进行中的项目":{"项目1":{"名字":"自动化测试","进度":"10%"},"项目2":{"名字":"性能优化","进度":"40%"}}}
# []      {"person":{"name":"John","age":"30","爱好":["打乒乓球","打羽毛球","发呆"],"其它":[],"other":{},"别的":[[],{},"","","","","","","","","","","","","","","",""],"部门":"测试与 
# 装备部","进行中的项目":{"项目1":{"名字":"自动化测试","进度":"10%"},"项目2":{"名字":"性能优化","进度":"40%"}}}}
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/src/tools# 
# 详细见项目的说明文档
# https://github.com/step-/JSON.awk/blob/master/doc/usage.md
#
# :TODO: 其实利用这个JSON.awk完全可以实现另外一套json的解决方案,但是我已经有一个解决方案了,所以这个不用去实现
# 大致思路是这里已经打印出来了叶子节点和所有的非叶子节点,可以转换成数组或者关联数组
# :TODO: 还有两个全局变量的设置后续也可以考虑
# STREAM
# STRICT

# :TODO: null的处理,空字典和空数组的处理

# :TODO: 错误处理?
awk_json_files ()
{
    local tool_exec_dir=
    meta_get_tool_dir tool_exec_dir
    # BRIEF=7 启动打印所有空对象,但是屏蔽非叶子节点打印(0:打开所有 默认是1:不打印空字典和数组)
    awk -f ${tool_exec_dir}/JSON.awk -v BRIEF=7 "${@:2}" > "$1"
}

awk_json_value_deal ()
{
    if [[ "${!1}" == \"*\" ]] ; then
        eval $1="${!1}"
    elif [[ "${!1}" == true ]] ; then
        # bash不支持true/false,转换成1/0
        eval $1=1
    elif [[ "${!1}" == false ]] ; then
        eval $1=0
    fi
    printf -v $1 "%b" "${!1}"
}

# :TODO: 当前有一个限制是必须bash4.4及其以上才能用下面
awk_json () 
{ 
    # 关联数组
    local -n _awk_json_json_ref=$1
    _awk_json_json_ref=()
    local _awk_json_json_out_file=$2
    shift 2
    local -a _awk_json_json_in_files=("${@}")
    local -a _awk_json_json_array
    local _awk_json_json_{item=,value=,key=,q_key=,key_tmp=}
    local -i _awk_json_json_has_comma=0

    awk_json_files "$_awk_json_json_out_file" "${_awk_json_json_in_files[@]}"
    mapfile -t _awk_json_json_array < "$_awk_json_json_out_file"
    # 保存到关联数组中
    for _awk_json_json_item in "${_awk_json_json_array[@]}" ; do
        if [[ "$_awk_json_json_item" =~ ^\[(([0-9]+,|\"([^\"]|\\\")*\",)*([0-9]+|\"([^\"]|\\\")*\"))\]$'\t'(.*)$ ]] ; then
            _awk_json_json_value="${BASH_REMATCH[-1]}"
            awk_json_value_deal _awk_json_json_value
            
            _awk_json_json_q_key=''
            # 使用@Q字符串转换键确保安全(单纯的数字不要转换只针对有双引号的转换)
            # 用于确保逗号不会出现在闭合的单引号内
            # @Q操作后的字符串都会加上闭合的单引号
            _awk_json_json_key="${BASH_REMATCH[1]}"

            while [[ "$_awk_json_json_key" =~ ^([0-9]+,|\"([^\"]|\\\")*\",)(.+)$ ]] ||
                  [[ "$_awk_json_json_key" =~ ^([0-9]+|\"([^\"]|\\\")*\")$  ]] ; do
                _awk_json_json_key="${BASH_REMATCH[3]}"
                _awk_json_json_has_comma=0
                _awk_json_json_key_tmp="${BASH_REMATCH[1]}"
                if [[ ',' == "${_awk_json_json_key_tmp: -1:1}" ]] ; then
                    # 暂时去掉逗号
                    _awk_json_json_key_tmp="${_awk_json_json_key_tmp:0:-1}"
                    _awk_json_json_has_comma=1
                fi

                awk_json_value_deal _awk_json_json_key_tmp

                # 转换q字符串
                if [[ "$_awk_json_json_key_tmp" =~ ^[0-9]+$ ]] ; then
                    _awk_json_json_q_key+="$_awk_json_json_key_tmp"
                else
                    _awk_json_json_q_key+="${_awk_json_json_key_tmp@Q}"
                fi
                ((_awk_json_json_has_comma)) && _awk_json_json_q_key+=','
            done

            # a='"打\"乒乓球"'
            _awk_json_json_ref[$_awk_json_json_q_key]="$_awk_json_json_value"
        fi
    done
    
    return 0
}

# :TODO: 简单的场景下直接读取和设置更方便,复杂场景可以考虑增加两个函数
awk_json_dict_get ()
{
    :
}

awk_json_dict_set ()
{
    :
}

# :TODO: 后面还可以做一个关于这种关联数组的排序,按照从前往后优先级,然后是数字键
# 用数字排序，字符串键按照字典排序
# :TODO: 其实还有一个简单的方法是,增加一个方法,可以获取每级后面的键列表,如果是数字
# 就是数组,如果是安全字符串就是字典,返回一个数组和一个返回值,数组用于保存键列表,
# 返回值用于确认返回的是数组的索引还是字典的键

return 0

