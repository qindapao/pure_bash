#!/bin/bash
param=$1

print_help_info ()
{
    echo 'begin_bash_debuger "$1" "$2" "$3"'
    echo '$1: the filename that you want debug.'
    echo '    -h/--help: show this message'
    echo '$2: debug file name'
    echo '$3: debug date flag'
    echo '    0:debug file name with no date'
    echo '    1:debug file name with date'
    echo 'such as:'
    echo '    begin_bash_debuger xx.sh xx.debug 0'
    echo '    begin_bash_debuger xx.sh xx.debug 1'
    echo 'debug function:'
    echo '    such as: log_debug "b-debug" "n" "x"'
}

add_head_date ()
{
cat <<EOF >begin_bash_debuger_tmp_file.txt
export __logdir=\$(pwd)
# 如果是多线程或者重入,这两组文件不能删
rm -f \$(ls -l \${__logdir} | grep -E "*_${debug_file_name_prefix}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}.${debug_file_name_sufix}" | awk '{print \$NF}')
rm -f \$(ls -l \${__logdir} | grep -E "${debug_file_name_prefix}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}.${debug_file_name_sufix}" | awk '{print \$NF}')
export __logfile=${debug_file_name_prefix}_\$(date +"%y_%m_%d_%H_%M_%S").${debug_file_name_sufix}
source /usr/bin/bash_debuger.sh
__loglevel=0
__breakpointflag=1
__xlogdebugflag=0
EOF
    sed -i '1 r begin_bash_debuger_tmp_file.txt' ${file_name}
    rm -f begin_bash_debuger_tmp_file.txt
}

add_head_no_date ()
{
cat <<EOF >begin_bash_debuger_tmp_file.txt
export __logdir=\$(pwd)
rm -rf *_${debug_file_name}
export __logfile=${debug_file_name}
rm -rf \${__logfile}
source /usr/bin/bash_debuger.sh
__loglevel=0
__breakpointflag=1
__xlogdebugflag=0
EOF
    sed -i '1 r begin_bash_debuger_tmp_file.txt' ${file_name}
    rm -f begin_bash_debuger_tmp_file.txt
}


if [ '-h' = "$param" -o "--help" == "$param" -o -z "$param" ] ; then
    print_help_info
    exit 0
fi
file_name=$1
debug_file_name=$2
date_flag=$3

debug_file_name_prefix=`echo "$debug_file_name" | awk -F "." '{print $1}'`
debug_file_name_sufix=`echo "$debug_file_name" | awk -F "." '{print $2}'`

# 判断下文件是否已经处理过
secend_line=`sed -n '2 p' ${file_name}`
if echo "$secend_line" | grep -wqi "export __logdir=" ; then
    echo "we have deal,do not compeat."
    exit 0
fi

if [ "0" = "$date_flag" ] ; then
    add_head_no_date
else
    add_head_date
fi

echo "work done!"
exit 0

