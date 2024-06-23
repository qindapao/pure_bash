#! /usr/bin/bash

now_dir=$(pwd)

[[ "/mnt/e/code/pure_bash" == "$now_dir" ]] && {
    # 后面的\;是必不可少的
    find . -type f -name "*.txt" -exec rm -f {} \;
}

