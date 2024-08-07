#! /usr/bin/bash

now_dir="$PWD"

# 获取root_dir
root_dir=${now_dir#*/}
root_dir=${root_dir%%/*}

[[ "/${root_dir}/e/code/pure_bash" == "$now_dir" ]] && {
    # 后面的\;是必不可少的(文件不是很多的版本)
    # find . -type f \( -name "*.txt" -o -name "*.log" \) -exec rm -f {} \;
    # 如果文件过多下面的命令才安全
    find . -type f \( -name "*.txt" -o -name "*.log" -o -name "*.temp" \) | xargs rm -f
}

