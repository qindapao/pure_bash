. ./meta/meta.sh
(DEFENSE_VARIABLES[json_todo]++)) && return 0

# :TODO: base64编码的数据膨胀率还是有点高,后续可以考虑使用base91编码,但是没有现成的
# 二进制工具可以用,所以可能需要自己实现,暂时还是先实现base64的bash builtin
# bash的官方下载地址
# https://ftp.gnu.org/gnu/bash/


# gcc -fPIC -shared -o ibase_64.so ibase_64.c -lbash
# enable -f ./ibase_64.so ibase_64


#   内置命令最好是改一个名字,不要和系统的命令冲突了
#
#   base64的实现
#   更甚一步，后续可以使用这种方式开发bash的C扩展程序(bash loadable)，在C语言的层
#   面上来支持json
#   在C语言层面上来支持可能就不需要base64编码了,用C语言的数据结构来实现
#         Bash 可加载模块是一种更灵活的方法，可以在运行时动态加载新功能，而无需重新编译整个 Bash。以下是基本步骤：
#         
#         创建模块文件：
#         创建一个新的 C 文件，例如 base64_loadable.c。
#         实现 base64 编码和解码功能。
#         编写模块代码：
#         #include <stdio.h>
#         #include <stdlib.h>
#         #include <string.h>
#         #include "builtins.h"
#         #include "shell.h"
#         
#         int base64_builtin(WORD_LIST *list) {
#             // 实现 base64 编码和解码逻辑
#             return EXECUTION_SUCCESS;
#         }
#         
#         char *base64_doc[] = {
#             "Base64 encoding and decoding",
#             NULL
#         };
#         
#         struct builtin base64_struct = {
#             "base64",
#             base64_builtin,
#             BUILTIN_ENABLED,
#             base64_doc,
#             "base64",
#             0
#         };
#         
#         编译模块：
#         gcc -fPIC -shared -o base64.so base64_loadable.c
#         
#         加载模块：
#         enable -f ./base64.so base64

# 参考的文件是这个: https://github.com/wertarbyte/coreutils/blob/master/src/base64.c
# 或者内核中的这个: https://github.com/torvalds/linux/blob/master/lib/base64.c


# :TODO: 一篇极客文章
# https://stackoverflow.com/questions/11325617/how-can-i-run-a-command-at-read-time-for-a-named-pipe-in-linux
# https://www.linusakesson.net/programming/pipelogic/index.php

# 创建命名管道：
# mkfifo mypipe

# 启动持久化进程并将其输出重定向到命名管道：
# my_long_running_process > mypipe &

# 从命名管道读取数据：
# while read line < mypipe; do
#     echo "Received: $line"
# done

# 向命名管道写入数据：
# echo "command" > mypipe


#
# :TODO: 后续可以实现多元素的一些方法,举个例子
# json_push -i 'json_name' -k 3 '4' '0' '[key1]' -v 2 '' "value" i "value2"
# 或者(不执行数据的属性,都当成字符串处理)
# json_push -i 'json_name' -k 3 '4' '0' '[key1]' -v 2 "value" "value2"
#
# 上面的-k 3 -v 2是一种特殊的处理,表示-k选项的后面跟3个参数,-v 2表示-v选项的后面
# 跟2个(或者2组)参数
# 使用这种方式来明确跟多参数的选项后面的参数数量

# :TODO: 部署json库的时候就可以跑自动化用例，如果用例执行失败，TU直接报失败了


# :TODO: 如何判断两个结构是否相等?
# 不能直接判断,需要json_dump 后判断字符串
# 因为这个时候内部变量的名字已经去除并且关联数组和索引数组的键也已经排序,字符串判断是可靠的

# :TODO: 所有的函数检查下，是否需要把传入的变量(外部传入名称引用的)清空,以便使用?(不用每次在外面手动清空)

# :TODO: 以下的内容可能是备忘
# 通过declare -p 可以把一个数据保存到一个文件中,然后在需要使用的地方直接
# Storage:~/qinqing # json_dump_hq 'my_dict' >1.txt
# Storage:~/qinqing # declare -p my_my_dict >2.txt
# Storage:~/qinqing # source 2.txt 
# Storage:~/qinqing # declare -p my_dict
# declare -A my_dict=([last_key1]="declare -a ${JSON_COMMON_MAGIC_STR}2=([0]=\"v0\" [1]=\"x1\" [2]=\"x2\" [3]=\"x3\" [4]=\"declare -A ${JSON_COMMON_MAGIC_STR}3=([other_key]=\\\"other6\\\" [other_key2]=\\\"other2\\\" [other_key3]=\\\"declare -a ${JSON_COMMON_MAGIC_STR}4=([0]=\\\\\\\"other3-0\\\\\\\" [1]=\\\\\\\"other3-1\\\\\\\" [2]=\\\\\\\"other3-2\\\\\\\" [3]=\\\\\\\"other3-3\\\\\\\")\\\" )\" [10]=\"v10\")" [last_key]="declare -A ${JSON_COMMON_MAGIC_STR}2=([z4]=\"x4\" [z5]=\"x5\" [z2]=\"x2\" [z3]=\"x3\" [z1]=\"x1\" [xxx]=\"0\" [xxx2]=\"value2\" [xxx3]=\"value3\" )" )
# Storage:~/qinqing # . ./json/json_dump.sh
# Storage:~/qinqing # json_dump_hq my_dict
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


# :TODO: 数据反向序列化(有点危险的是如果键里面包含了=或者=>该如何处理?可能需要考虑使用索引层级来截取字符串,而不能通过=来分隔)
# 通过索引层级也无法安全拿到键,因为没有办法判断何使结束(键里面可能包含=或者=>) 所以可能的解决方案是把键和值分成两行打印(这也带来一个问题,如果区分空键？)
# 确实不好区分空键,因为字符串的结尾可能也是=或者=>,也许要这样,把=和=>换成不常用的很多符合字符,用这些字符来识别,但是也不是完全严谨
# 另外${JSON_COMMON_MAGIC_STR}这个名字也具有一定的危险性,如果字符串本身就包含它?要用不常用的unicode字符组合来表示?或者把这个名字取得更长,减少冲突的可能性
# 这里判断是否是字符串主要是为了判断是否到了叶子节点(如果不通过判断declare的方式判断是否到叶子,要怎么判断?)
# 所以重构比较有必要，解码后如果发现数组只有一个元素(或者也是两个元素,但是其中一个明确指定类型是字符串),认为到了叶子节点,否则就是还有层级,继续解压,前面说了,数据第一个元素是类型，第二个是待解压字符串
# 但是这也有一个缺点,就是普通的数组和字典就不是我们的结构体了(这样数据结构产生了割裂),这样我们的结构体的最小打包单位必须是2个数组的压缩字符串(解压后才知道是否是叶子节点!),保存的时候也必须压缩数组成字符串.
# 就是从打印树状图还原成原始数据
# 遍历倒是简单，就是用一个栈，一行一行读，遇到空键就压栈，知道遍历完。每遇到一个叶子节点，都用set_field设置值即可

# 为了防止键里面有=和=>，是否换符号打印?
# 上面要打印字符串,判断是孤键还是键值对,可以通过在每个打印字符后面加尾部字符来搞定,如果是对,加空格结尾,如果是孤键,那么是=或者=>结尾，这样拆分成两行，就能精确打印了



# %q的数据还原成字符串即可
# :TODO: 后续甚至可以考虑把json的数据转换成我们需要的需求

# 本质上这个函数不需要,结构体的顶级就是一个数组或者关联数组,直接创建即可
json_todo ()
{
    :
}

return 0

