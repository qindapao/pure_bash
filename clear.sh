#! /usr/bin/bash

now_dir=$(pwd)

[[ "/mnt/e/code/pure_bash" == "$now_dir" ]] && {
    rm -f *.{txt,log}
}

