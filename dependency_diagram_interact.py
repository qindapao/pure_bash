import os
import re
import json

# 设置你的 Bash 文件目录
bash_files_dir = './src'

# 初始化数据结构
nodes = []
edges = []

# 运行html的方式
# cd /path/to/your/project
# python -m http.server 8000
# http://localhost:8000/dependency_diagram_interact.html

# https://d3js.org/getting-started

# 定义一组颜色
colors = ['red', 'blue', 'green', 'orange', 'purple', 'brown', 'pink', 'gray', 'cyan', 'magenta']
color_index = 0

if __name__ == "__main__":
    # 递归遍历所有子目录和文件
    for root, dirs, files in os.walk(bash_files_dir):
        for filename in files:
            if filename.endswith('.sh'):
                func_name = filename[:-3]  # 去掉 .sh 后缀
                nodes.append({"id": func_name, "label": func_name, "color": "lightblue"})

                with open(os.path.join(root, filename), 'r', encoding='utf-8') as file:
                    content = file.read()
                    # 查找依赖关系
                    matches = re.findall(r'^\. \.?(/(\w+))*/(\w+)\.sh', content, re.MULTILINE)
                    for match in matches:
                        dep_func_name = match[2]
                        edges.append({
                            "source": func_name,
                            "target": dep_func_name,
                            "color": colors[color_index % len(colors)]
                        })
                        color_index += 1  # 更新颜色索引

    # 保存为 JSON 文件
    with open('bash_dependency_graph.json', 'w', encoding='utf-8') as f:
        json.dump({"nodes": nodes, "edges": edges}, f, ensure_ascii=False, indent=4)

