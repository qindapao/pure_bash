#! /usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
from graphviz import Digraph

# 设置你的 Bash 文件目录
bash_files_dir = './src'

# 初始化 Graphviz 图
dot = Digraph(comment='Bash Function Dependency Graph')
# TB是从上到下
dot.attr(rankdir='LR')  # 设置图的方向为从左到右
# 定义一组颜色
colors = ['red', 'blue', 'green', 'orange', 'purple', 'brown', 'pink', 'gray', 'cyan', 'magenta']
color_index = 0


if __name__ == "__main__":
    # 递归遍历所有子目录和文件
    for root, dirs, files in os.walk(bash_files_dir):
        for filename in files:
            if filename.endswith('.sh'):
                func_name = filename[:-3]  # 去掉 .sh 后缀
                # dot.node(func_name, func_name)  # 添加函数节点
                # 设置节点的形状为方框，填充颜色为浅蓝色
                dot.node(func_name, func_name, shape='box', style='filled', color='lightblue')

                with open(os.path.join(root, filename), 'r', encoding='utf-8') as file:
                    content = file.read()
                    # 查找依赖关系
                    matches = re.findall(r'^\. \.?(/(\w+))*/(\w+)\.sh', content, re.MULTILINE)
                    for match in matches:
                        dep_func_name = match[2]
                        # 添加依赖关系边,使用不同颜色的边，并调整箭头大小
                        dot.edge(func_name, dep_func_name, color=colors[color_index % len(colors)], arrowsize='0.5')
                        color_index += 1

    # 保存并渲染图
    dot.render('bash_dependency_graph', format='svg')

