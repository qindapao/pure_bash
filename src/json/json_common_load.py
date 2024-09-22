#! /usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import re
import subprocess
import os
import sys
import getopt
import shlex
# :TODO: 后面要支持配置允许空键和不允许空键
# :TODO: 后面脚本中要加入更多的错误处理
# :TODO: 整数和浮点有没有必要单独处理?我觉得没有必要,bash中都当成字符串处理比较简单

def end_char(data):
    # 叶子普通字符串,1个空格
    if isinstance(data, (str, int, float)):
        return ' '
    # 叶子空元素null,2个空格
    elif data is None:
        return '  '
    # 叶子空数组,3个空格
    elif isinstance(data, list) and not data:
        return '   '
    # 叶子空字典,4个空格
    elif isinstance(data, dict) and not data:
        return '    '
    else:
        return ''


# :TODO: 每次都开启新的bash进程可能比较慢,可以持久化一个bash进程,每次和它通信
# 或者使用python3的内置方法来实现字符串的解包与压包(替代eval 和 printf "%q"功能)
#
# {
# import subprocess
#
# # 启动一个持久的 Bash 进程
# bash_process = subprocess.Popen(
#     ['bash'],
#     stdin=subprocess.PIPE,
#     stdout=subprocess.PIPE,
#     stderr=subprocess.PIPE,
#     text=True
# )
#
# def run_bash_command(command):
#     # 发送命令到 Bash 进程
#     bash_process.stdin.write(command + '\n')
#     bash_process.stdin.flush()
    
#     # 读取输出
#     output = bash_process.stdout.readline().strip()
#     return output
#
# # 示例用法
# json_value = 'some_value'
# command = f'eval "json_value={json_value}" ; printf "%s" "$json_value"'
# result = run_bash_command(command)
# print(f"Result: {result}")
#
# # 记得在脚本结束时关闭 Bash 进程
# bash_process.terminate()
# }



def custom_print(data, indent=0, output=None):

    if output is None:
        output = []

    spacing = '    ' * indent

    if isinstance(data, dict):
        if not data:
            spacing = '    ' * (indent - 1)
            output.append(spacing + r'declare\ -A\ _json_set_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev1=\(\)')
        else:
            for key, value in sorted(data.items()):
                q_key = bash_q_str(key)
                output.append(f"{spacing}{q_key} ⇒{end_char(value)}")
                custom_print(value, indent + 1, output)
    elif isinstance(data, list):
        if not data:
            spacing = '    ' * (indent - 1)
            output.append(spacing + r'declare\ -a\ _json_set_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev1=\(\)')
        else:
            for index, item in enumerate(data):
                output.append(f"{spacing}{index} ⩦{end_char(item)}")
                custom_print(item, indent + 1, output)
    else:
        spacing = '    ' * (indent - 1)
        q_data = bash_q_str(data)
        output.append(f"{spacing}{q_data}")

    return output

# 不能传递[] {}进来,那个是一个对象,函数中都append它,会有循环引用问题
def list_setdefault(lst, index, is_dict):
    while len(lst) <= index:
        lst.append({} if is_dict else [])
    return lst[index]


def set_value(container, keys, value):
    current = container
    for i, (is_dict, key) in enumerate(keys[:-1]):
        is_next_dict, next_key = keys[i + 1]
        if is_dict:
            current = current.setdefault(key, {} if is_next_dict else [])
        else:
            key = int(key)
            current = list_setdefault(current, key, is_next_dict)

    last_is_dict, last_key = keys[-1]
    if last_is_dict:
        current[last_key] = value
    else:
        last_key = int(last_key)
        while len(current) <= last_key:
            current.append(None)
        current[last_key] = value


def bash_eval_str(ori_str):
    quoted_str = shlex.quote(ori_str)
    command = ['bash', '-c', f'eval print_str={quoted_str};' + r'printf "%s" "$print_str"']
    return subprocess.run(command, capture_output=True, text=True).stdout


def bash_q_str(ori_str):
    quoted_str = shlex.quote(str(ori_str))
    command = ['bash', '-c', f'print_str={quoted_str};' + r'printf "%q" "$print_str"']
    return subprocess.run(command, capture_output=True, text=True).stdout


def json_load(json_str):
    json_lines = json_str.split(os.linesep)

    json_out = {} if '⇒' in json_lines[1] else []

    json_key, json_value, json_leaf_key = None, None, None
    json_ori_str, json_key_stack, json_line_cnt = None, [], 1
    json_lines_size = len(json_lines)

    # 叶子节点映射关系(和空格数量)
    leaf_node_map = {2: None, 3: [], 4: {}}
    json_lev, json_pop_cnt = 0, 0

    while (json_line_cnt < json_lines_size):
        json_lev, json_line_content = 0, json_lines[json_line_cnt]

        match = re.match(r'^( *)', json_line_content)
        if match:
            json_lev = match.group(1)
            json_lev = len(json_lev) // 4
            json_lev -= 1

        if json_lev < len(json_key_stack):
            # 先弹出多余的键
            json_pop_cnt = len(json_key_stack) - json_lev
            json_key_stack = json_key_stack[:len(json_key_stack)-json_pop_cnt]

        json_key = json_line_content.lstrip()
        # 获取箭头后面空格数量
        space_num = 0
        match = re.search(r'([⇒⩦])(\s*)', json_line_content)
        if match:
            space_num, json_leaf_key = len(match.group(2)), match.group(1)

        json_ori_str = bash_eval_str(json_key[0:-2-space_num])
        if space_num != 0:
            # 取key字符,和栈里面组合成的键一起设置数据结构
            json_value = json_lines[json_line_cnt+1].lstrip()
            # key和value需要从Q字符串转换成常规字符串
            json_value = bash_eval_str(json_value) if space_num == 1 else leaf_node_map[space_num]
            json_leaf_key = (1 if json_leaf_key == '⇒' else 0, json_ori_str)
            set_value(json_out, json_key_stack + [json_leaf_key], json_value)
            json_line_cnt += 2
        else:
            # key从Q字符串转换成常规字符串(最后两个字符不能转它们不属于Q字符串)
            json_key_stack.append((1 if json_key[-1:] == '⇒' else 0, json_ori_str))
            json_line_cnt += 1

    return json_out


if __name__ == "__main__":

    argv = sys.argv[1:]
    opts, args = getopt.getopt(
        argv, "m:i:o:", longopts=["mode=", "input_file=", "output_file="])

    mode, input_file, output_file = None, None, None
    for opt, arg in opts:
        if opt in ['--mode', '-m']:
            mode = arg
        elif opt in ['--input_file', '-i']:
            input_file = arg
        elif opt in ['--output_file', '-o']:
            output_file = arg

    if mode == 'standard_to_bash':
        with open(input_file, encoding='utf-8', mode='r') as f:
            input_file_content = f.read()

        json_obj = json.loads(input_file_content)
        tree_list = custom_print(json_obj)
        TREE_STR = os.linesep.join(tree_list)
        print(os.linesep.join(tree_list))
        with open(output_file, encoding='utf-8', mode='w') as f:
            f.write(TREE_STR)
    elif mode == 'bash_to_standard':
        with open(input_file, encoding='utf-8', mode='r') as f:
            input_file_content = f.read()
        json_obj = json_load(input_file_content)
        formatted_str = json.dumps(
                json_obj, indent=4, sort_keys=True, ensure_ascii=False)
        print(formatted_str)
        with open(output_file, encoding='utf-8', mode='w') as f:
            f.write(formatted_str)

