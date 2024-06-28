#!/bin/bash
param1=$1
param2=$2

print_help_info ()
{
    echo 'full_bash_log_collect "$1" "$2"'
    echo '$1: the filename that you want debug.'
    echo '$2: debug file name.'
    echo 'after that,you need type below before debug script:'
    echo 'export ITESTINSIDE_TU_DEBUG_FLAG=TRUE'
}

# :TODO: 后面调试变量可以考虑设置为set -vx 更强大
add_full_log ()
{
cat <<EOF >full_bash_log_collect_tmp_file.txt
#设置调试开关,显示所有执行命令
if [ "\${ITESTINSIDE_TU_DEBUG_FLAG}" = "TRUE" ] ; then
    rm -f ${param2}
    #设置PS4环境变量，便于调试
    export PS4='{\${BASH_SOURCE[0]##*/}:\${LINENO}:\${BASH_LINENO}:\${FUNCNAME[0]}<\${FUNCNAME[1]}|\`date +'%H%M%S'\`}'
    set -x
    exec 100>&1
    exec 1>>${param2}
    exec 2>&1
fi
EOF
    sed -i '1 r full_bash_log_collect_tmp_file.txt' ${param1}
    rm -f full_bash_log_collect_tmp_file.txt   
}

if [ '-h' = "$param1" -o "--help" == "$param1" -o -z "$param1" ] ; then
    print_help_info
    exit 0
fi
if grep -q "export PS4=" "$param1" ; then
    echo "we have deal,do not compeat."
    exit 0
fi

add_full_log

echo "work done!"
exit 0

