#! /usr/bin/bash
# 计算当前所有的函数的数量(节点数量,需要和依赖关系图中的节点数量一致)

# 首先需要进入源码目录
cd ./src
# 如果文件太多要这样(:TODO: 如何支持文件名中有换行或者其它特殊字符?)
# file_count=$(find . -type f -name "*.sh" -print0 | xargs -0 -I {} echo | wc -l)
file_count=$(find . -type f -name "*.sh" | wc -l)
printf "%s\n" "$file_count"

