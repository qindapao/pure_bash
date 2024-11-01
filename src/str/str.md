# str

字符串相关的备份和废弃函数备份

## 废弃函数备份

### str_trim

下面的实现和别名都没用了

```bash
# 使用shopt -s extglob
# :TODO: $(str_trim x str1) 进程替换后会丢失结尾换行符,如果介意用printf -v
str_trim ()
{
    local tmp_str=${2##+([[:space:]])}
    printf "%s" "${tmp_str%%+([[:space:]])}"
}

alias str_trim_s='str_trim ""'
```

### str_basename

`extglob`的实现备份起来。

```bash
# 另外一种使用extglob的实现
# shopt -s extglob
# str_basename () { printf "%s" "${2//@(*\/|.*)}" ; }

# 带s的是直接使用的,上面的是在高阶函数中的
alias str_basename_s='str_basename ""'
```

### str_endswith

下面的函数没有必要，直接使用bash的接片和相关的操作更好更直观。

```bash
# 字符串以什么结尾(满足返回true,否则返回false,大小写敏感)
# 1: 如果字符串在一个数组中,那么这个数组的索引(主要是为了高阶函数)
# 2: 需要检查的字符串
# 3: 需要检查的后缀
# 4: 是否忽略大小写(默认不忽略)
# 5: 字符串开始索引[可选,如果没有就是从0开始]
# 6: 字符串结束索引[可选,如果没有就是在最大结束]
str_endswith ()
{
    local index=$1 in_str=$2 suffix=$3 is_ignore_case=$4
    ((is_ignore_case)) && {
        in_str=${in_str,,}
        suffix=${suffix,,}
    }
    local start_pos="${5:-0}"
    local str_len=${#in_str}
    local end_pos="${6:-${str_len}}"

    # 如果开始或结束位置是负数，则从字符串末尾开始计算
    ((start_pos<0)) && ((start_pos+=str_len))
    ((end_pos<0))   && ((end_pos+=str_len))

    # 检查索引范围是否有效
    ((start_pos>=str_len || start_pos < 0)) && return 1

    # 调整结束索引，如果超出字符串长度则设置为字符串长度
    ((end_pos>str_len)) && ((end_pos=str_len))

    # 如果结束索引小于开始索引，返回假
    ((end_pos<start_pos)) && return 1

    # 提取子字符串
    local sub_str="${in_str:start_pos:end_pos-start_pos}"

    # 检查子字符串是否以后缀结束
    [[ "$sub_str" == *"$suffix" ]]
}

alias str_endswith_s='str_endswith ""'
```

### str_is_black_or_empty

下面的实现过于复杂，现在有更简单实现，下面的先备份。

```bash
str_is_black_or_empty ()
{
    # 陷阱中$_值不准确,所以放弃使用:这种形式
    # : "${2#"${2%%[![:space:]]*}"}"
    local tmp_str="${2#"${2%%[![:space:]]*}"}"
    local deal_str="${tmp_str%"${_##*[![:space:]]}"}"
    
    [[ -z "$deal_str" ]]
}

alias str_is_black_or_empty_s='str_is_black_or_empty ""'
```

### str_startswith

```bash
# 字符串以什么开头(满足返回true,否则返回false,大小写敏感)
# 1: 如果字符串在一个数组中,那么这个数组的索引(主要是为了高阶函数)
# 2: 需要检查的字符串
# 3: 需要检查的前缀
# 4: 是否忽略大小写(默认不忽略)
# 5: 字符串开始索引[可选,如果没有就是从0开始]
# 6: 字符串结束索引[可选,如果没有就是在最大结束]
str_startswith () 
{
    # 这里赋值不需要用双引号保护(只有位置参数有效),并且这里大括号是必须保留的
    my {index,in_str,prefix,is_ignore_case}=\${$((i++))}
    
    ((is_ignore_case)) && { in_str=${in_str,,} ; prefix=${prefix,,} ; }
    local start_pos="${5:-0}"
    local str_len=${#in_str}
    local end_pos="${6:-${str_len}}"

    # 如果开始或结束位置是负数，则从字符串末尾开始计算
    ((start_pos<0)) && ((start_pos+=str_len))
    ((end_pos<0))   && ((end_pos+=str_len))

    # 检查索引范围是否有效
    ((start_pos>=str_len || start_pos<0)) && return 1

    # 调整结束索引，如果超出字符串长度则设置为字符串长度
    ((end_pos>str_len)) && ((end_pos=str_len))

    # 如果结束索引小于开始索引，返回假
    ((end_pos<start_pos)) && return 1

    # 提取子字符串
    local sub_str="${in_str:start_pos:end_pos-start_pos}"

    # 检查子字符串是否以前缀开始
    [[ "$sub_str" == "$prefix"* ]]
}

alias str_startswith_s='str_startswith ""'
```

### str_split

感觉并没有什么用，先备份吧。

```bash
# 使用block的方式在高阶函数中使用该函数
# 字符串拆分函数,只是对awk的封装,功能多,支持连续分隔符和global
# 由于要开新进程,效率一般
# $ echo "1:xx;yy:12;kk:" | str_split_pipe ':' 2 ';' 2
# $ str_split_pipe xx.txt ':' 2 ';' 2
# yy
str_split ()
{
    local input_str=''
    case $1 in
        -i)
        # 从标准输入读取数据
        IFS= read -r -d '' input_str || true
        shift
        ;;
        -s)
        # 从字符串读取数据
        input_str=$2
        shift 2
        ;;
        -f)
        # 从文件读取数据
        IFS= read -r -d '' input_str < "$2" || true
        shift 2
        ;;
    esac

    local output="$input_str"

    while (($#)) ; do
        local delimiter=$1 field_number=$2
        
        # bash会自动处理<<<添加到末尾的换行符
        output=$(awk -F "$delimiter" "{print \$$field_number}" <<<$(printf "%s" "$output"))
        (($#)) && shift
        (($#)) && shift
    done
    
    # :TODO: 这里是会导致结尾换行符被删除
    printf "%s" "$output"
}

# 管道使用
alias str_split_i='str_split "-i"'
# 文件使用
alias str_split_f='str_split "-f"'
# 字符串
alias str_split_s='str_split "-s"'
```


## 其它备份

```bash
# 字符串操作集合(模拟perl5的行为)
# 注意:命令行参数大小限制,数组参数不能过大
# 为了保证引用变量不会重名,所有带引用变量的函数中的局部变量都带函数名字,不带引用变量的函数不受影响
# 如果不需要改变原数组,可以使用下面的方式获取数组内容
# array::merge() {
#     [[ $# -ne 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
#     declare -a arr1=("${!1}")
#     declare -a arr2=("${!2}")
#     declare out=("${arr1[@]}" "${arr2[@]}")
#     printf "%s\n" "${out[@]}"
# }
#
# 有一种临时保存变量的好方法，可以利用declare -p 把需要保存的变量打印到一个临时文件中
# 当需要还原变量的时候，直接source ./tmp_file 就可以在当前环境下加载这些变量

# :TODO: 根据业务需求来实现封装,尽量使纯bash实现


# :TODO: 当前的字符串函数如果要输出结果是通过printf值的方式执行，并且和高阶map函数
# 配合也是这种方式，后续如果想效率高,可以采用应用方式，被引用的变量名字可以好好设计
# 同时高阶函数也需要调整,比如重组数组不是使用变量替换的方式$(),而是获取某个约定的变量的
# 值，约定的变量名可以和函数名关联起来等等... ...

# :TODO: https://github.com/vlisivka/bash-modules/blob/master/bash-modules/src/bash-modules/string.sh
# 这里有一些有用的函数，空了可以整理下

. ./meta/meta.sh
((DEFENSE_VARIABLES[str_todo]++)) && return 0

# 如果一个函数返回一个数组,可以使用下面的方式取数组中的值,就像元组拆包一样
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/str# declare -p xa
# declare -a xa=([0]="a 1" [1]="b 2" [2]="c 3")
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/str# i=0
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/str# eval {x1,x2,x3}=\"${xa[i++]}\"
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/str# declare -p x1 x2 x3
# declare -- x1="a 1"
# declare -- x2="b 2"
# declare -- x3="c 3"
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/str# 

# 可以在函数中使用local修改全局IFS的值，退出函数后，值被还原，只在函数内生效
# 可以避免对全局IFS的变更
# test_1 ()
# {
# 	local IFS=':'
# 	read -r xx yy zz <<< "1:2:3"
# 	echo $xx
# 	echo $yy
# 	echo $zz
# }
# 
# test_1
# 
# read -r xx yy zz <<< "1 2 3"
# echo $xx
# echo $yy
# echo $zz

return 0

```

