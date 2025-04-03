#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import re
import subprocess
import os
import sys
import getopt
import shlex
import base64
import unicodedata
# :TODO: 后面要支持配置允许空键和不允许空键
# :TODO: 后面脚本中要加入更多的错误处理
# :TODO: 整数和浮点有没有必要单独处理?我觉得没有必要,bash中都当成字符串处理比较简单

# 默认的 bstab 表，对应 Bash 中:
#   static const char bstab[256] = { ... };
# 表中 1 表示该字符需要被反斜杠转义，0 表示不需要。
# 此处我们仅针对 ASCII 范围（0～255）给出实现，后面的项全部为0。
default_bstab = [
    #  0 - 31
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,

    # 32 - 39  (SPACE, '!', DQUOTE, DOL, AMP, SQUOTE, and two more)
    1, 1, 1, 0, 1, 0, 1, 1,
    # 40 - 47 (LPAR, RPAR, STAR, COMMA, etc.)
    1, 1, 1, 0, 1, 0, 0, 0,
    # 48 - 55
    0, 0, 0, 0, 0, 0, 0, 0,
    # 56 - 63 (包括 SEMI, LESSTHAN, GREATERTHAN, QUEST)
    0, 0, 0, 1, 1, 0, 1, 1,

    # 64 - 71
    0, 0, 0, 0, 0, 0, 0, 0,
    # 72 - 79
    0, 0, 0, 0, 0, 0, 0, 0,
    # 80 - 87
    0, 0, 0, 0, 0, 0, 0, 0,
    # 88 - 95 (LBRACK, BS, RBRACK, CARAT)
    0, 0, 0, 1, 1, 1, 1, 0,

    # 96 - 103 (BACKQ 及后面几个)
    1, 0, 0, 0, 0, 0, 0, 0,
    # 104 - 111
    0, 0, 0, 0, 0, 0, 0, 0,
    # 112 - 119
    0, 0, 0, 0, 0, 0, 0, 0,
    # 120 - 127 (LBRACE, BAR, RBRACE)
    0, 0, 0, 1, 1, 1, 0, 0
] + [0] * (256 - 128)  # 后面的全部为 0



JSON_COMMON_SERIALIZATION_ALGORITHM = "0"
JSON_COMMON_MAGIC_STR = '_json_set_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev'

def str_to_base64(in_str) ->str:
    text_bytes = in_str.encode('utf-8')
    encoded_bytes = base64.b64encode(text_bytes)
    return encoded_bytes.decode('utf-8')


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
            if JSON_COMMON_SERIALIZATION_ALGORITHM == "0":
                output.append(spacing + r'declare\ -A\ ' + JSON_COMMON_MAGIC_STR + r'1=\(\)')
            elif JSON_COMMON_SERIALIZATION_ALGORITHM == "1":
                output.append(spacing + r'declare\ -A\ ' + JSON_COMMON_MAGIC_STR + r'1=' + str_to_base64(r'()'))
        else:
            for key, value in sorted(data.items()):
                q_key = bash_q_str(key)
                output.append(f"{spacing}{q_key} >{end_char(value)}")
                custom_print(value, indent + 1, output)
    elif isinstance(data, list):
        if not data:
            spacing = '    ' * (indent - 1)
            if JSON_COMMON_SERIALIZATION_ALGORITHM == "0":
                output.append(spacing + r'declare\ -a\ ' + JSON_COMMON_MAGIC_STR + r'1=\(\)')
            elif JSON_COMMON_SERIALIZATION_ALGORITHM == "1":
                output.append(spacing + r'declare\ -a\ ' + JSON_COMMON_MAGIC_STR + r'1=' + str_to_base64(r'()'))
        else:
            for index, item in enumerate(data):
                output.append(f"{spacing}{index} ={end_char(item)}")
                custom_print(item, indent + 1, output)
    else:
        spacing = '    ' * (indent - 1)
        if data is True:
            q_data = 1
        elif data is False:
            q_data = 0
        elif data is None:
            q_data = 'null'
        else:
            q_data = bash_q_str(data)
        # :TODO: 还是没法处理null,因为null和空字符串是两个概念,暂时先不处理吧
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


# :TODO: 转换到标准json的时间也很长,需要优化,自己实现不要调用bash的内置功能
def bash_eval_str(ori_str):
    quoted_str = shlex.quote(ori_str)
    command = ['bash', '-c', f'eval print_str={quoted_str};' + r'printf "%s" "$print_str"']
    return subprocess.run(command, capture_output=True, text=True).stdout


def sh_backslash_quote(in_string, table=None, flags=0):
    """
    模仿 Bash 中的 sh_backslash_quote():
    
    对字符串中的每个字符按照以下规则处理：
      1. 如果 (table or default_bstab)[ord(c)] 为 1，表示该字符需要反斜杠转义；
      2. 如果字符是 '#' 且位于字符串首部（防止注释），则加反斜杠；
      3. 如果 flags & 1 非零，且字符为 '~' 且处于字符串开头或前一个字符为 ':' 或 '='，则加转义；
      4. 如果 flags & 2 非零，且字符是空格或制表符（shell blank），也加转义。
    
    返回转义后的字符串。
    """
    if table is None:
        table = default_bstab

    result = []
    for idx, c in enumerate(in_string):
        # 条件 1：根据默认转义表
        if ord(c) < 256 and table[ord(c)] == 1:
            result.append('\\' + c)
        # 条件 2：如果第一个字符为 '#'，则加转义
        elif c == '#' and idx == 0:
            result.append('\\' + c)
        # 条件 3：根据 flags & 1 对 '~' 的处理
        elif (flags & 1) and c == '~' and (idx == 0 or in_string[idx - 1] in (':', '=')):
            result.append('\\' + c)
        # 条件 4：根据 flags & 2 对空格和制表符的处理
        elif (flags & 2) and c in (' ', '\t'):
            result.append('\\' + c)
        else:
            result.append(c)
    return ''.join(result)


def ansic_quote(in_string):
    """
    模仿 Bash 中的 ansic_quote():
    将字符串转换为 ANSI C 风格的 quoted 形式（格式为 $'…'），
    对特殊控制字符进行如下转换：
      - ESC (ASCII 27) 输出为 \E
      - \a, \v, \b, \f, \n, \r, \t 分别转换为相应的转义序列
      - 对 '\\' 和 ''' 总是输出转义后的形式
      - 对于不可打印字符（ASCII 码不在 32～126 之间），采用三位八进制转义
    """

    # 定义特殊字符到转义序列的映射字典
    special_mapping = {
        '\x1b': r'\E',
        '\a': r'\a',
        '\v': r'\v',
        '\b': r'\b',
        '\f': r'\f',
        '\n': r'\n',
        '\r': r'\r',
        '\t': r'\t'
    }

    pieces = ["$'"]  # 收集各个片段
    for c in in_string:
        # 使用字典进行快速匹配
        if c in special_mapping:
            pieces.append(special_mapping[c])
        # 对于反斜杠和单引号，总是输出转义形式
        elif c in ("\\", "'"):
            pieces.append('\\' + c)
        # 对于不可打印的字符（这里简单定义为 ASCII 32～126 外的字符）
        else:
            o = ord(c)  # 预先计算字符的 ASCII 码
            # 对于不可打印的字符（这里简单定义为 ASCII 32～126 外的字符）
            if o < 32 or o == 127:
                pieces.append("\\" + format(o, "03o"))
            # 对于非 ASCII 字符，如果不可打印则用八进制转义
            elif o >= 128 and not is_printable_unicode(c):
                pieces.append("\\" + format(o, "03o"))
            else:
                pieces.append(c)

    pieces.append("'")
    return "".join(pieces)


def is_printable_unicode(c):
    # 如果字符分类为 Cc（控制字符）、Cf（格式字符）等，则认为不可打印，
    # 否则很多 Unicode 字符应该算作可打印。
    cat = unicodedata.category(c)
    return not (cat.startswith("C") or cat in ("Zl", "Zp"))  # 可以根据需要调整


def ansic_shouldquote(in_string):
    """
    判断字符串是否需要用 ANSI C quoting 来表示，即是否包含需要转义的控制字符：
      如果字符串中含有下列字符，则返回 True：
        \a, \b, \f, \n, \r, \t, \v   以及其它非可打印字符。
      否则返回 False。
    """
    for c in in_string:
        o = ord(c)
        # 针对 ASCII 字符，32 ～ 126 是可打印字符
        if o < 128:
            if o < 32 or o == 127:
                return True
        else:
            # 对于扩展字符，只调用一次 is_printable_unicode(c)
            if not is_printable_unicode(c):
                return True
    return False


def bash_q_str(in_string):
    """
    根据 Bash 的 printf "%q" 逻辑转换字符串：
      - 如果 in_string 为空字符串，则返回 "''"
      - 否则，如果 ansic_shouldquote(in_string) 返回 True，则返回 ansic_quote(in_string)
      - 否则返回 sh_backslash_quote(in_string, flags=3)
    
    这里 flags=3(1|2) 表示同时开启 flags 的位 1 和位 2，即：
      - 对 '~' 的特殊处理
      - 对空格和制表符的额外转义处理
    """
    s = str(in_string)
    if s == "":
        return "''"
    elif ansic_shouldquote(s):
        # 如果遇到需要 ANSI C quoting 的情况，返回 $'...' 格式
        return ansic_quote(s)
    else:
        return sh_backslash_quote(s, flags=1|2)


# # :TODO: 注释掉的函数是低效率版本的最安全的实现,如果遇到特殊字符有问题,可以打开下面的函数来定位问题
# def bash_q_str(in_string):
#     quoted_str = shlex.quote(str(in_string))
#     command = ['bash', '-c', f'print_str={quoted_str};' + r'printf "%q" "$print_str"']
#     return subprocess.run(command, capture_output=True, text=True).stdout

def json_load(json_str):
    json_lines = json_str.split(os.linesep)

    json_out = {} if '>' in json_lines[1] else []

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
        match = re.search(r'([>=])(\s*)$', json_line_content)
        if match:
            space_num, json_leaf_key = len(match.group(2)), match.group(1)

        json_ori_str = bash_eval_str(json_key[0:-2-space_num])
        if space_num != 0:
            # 取key字符,和栈里面组合成的键一起设置数据结构
            json_value = json_lines[json_line_cnt+1].lstrip()
            # key和value需要从Q字符串转换成常规字符串
            json_value = bash_eval_str(json_value) if space_num == 1 else leaf_node_map[space_num]
            json_leaf_key = (1 if json_leaf_key == '>' else 0, json_ori_str)
            set_value(json_out, json_key_stack + [json_leaf_key], json_value)
            json_line_cnt += 2
        else:
            # key从Q字符串转换成常规字符串(最后两个字符不能转它们不属于Q字符串)
            json_key_stack.append((1 if json_key[-1:] == '>' else 0, json_ori_str))
            json_line_cnt += 1

    return json_out


def parse_key_format(key):
    """
    如果键用 [] 包裹，则标记为“dict”类型访问，否则标记为“list”类型访问。
    注意：这里仅作提示，具体如何处理还得看当前数据的实际类型。
    """
    if key.startswith('[') and key.endswith(']'):
        # 这里不使用 strip，因为可能影响内部字符，直接切片处理
        return key[1:-1], "dict"
    else:
        return key, "list"

def extract_json_keys(json_obj, keys):
    """
    根据键列表依次提取 JSON 数据。
    每一步先检查当前数据类型：
      - 如果是字典，使用 dict.get(name)
      - 如果是列表，并且预期“list”，则尝试将键转换为索引访问；
        如果转换失败，则认为每个元素可能都是字典，尝试映射提取。
      - 如果既不是 dict 也不是 list，则无法继续提取，直接返回 None。
    """
    for key in keys:
        parsed_key, expected = parse_key_format(key)

        # 如果当前对象是字典，直接用字典访问
        print(key)
        if expected == "list":
            if isinstance(json_obj, list):
                json_obj = json_obj[int(parsed_key)]
            else:
                json_obj = None
                break
        else:
            if isinstance(json_obj, dict):
                json_obj = json_obj.get(parsed_key)
            else:
                json_obj = None
                break
    return json_obj


if __name__ == "__main__":

    argv = sys.argv[1:]
    opts, args = getopt.getopt(
        argv, "m:i:o:a:s:", longopts=["mode=", "input_file=", "output_file=", "algorithm=", "magic_str="])

    mode, input_file, output_file = None, None, None
    for opt, arg in opts:
        if opt in ['--mode', '-m']:
            mode = arg
        elif opt in ['--input_file', '-i']:
            input_file = arg
        elif opt in ['--output_file', '-o']:
            output_file = arg
        elif opt in ['--algorithm', '-a']:
            JSON_COMMON_SERIALIZATION_ALGORITHM = arg
        elif opt in ['--magic_str', '-s']:
            JSON_COMMON_MAGIC_STR = arg

    # args 里面是未被 getopt 解析的 位置参数，即 -- 之后的部分
    keys_to_extract = args

    if mode == 'standard_to_bash':
        with open(input_file, encoding='utf-8', mode='r') as f:
            input_file_content = f.read()

        json_obj = json.loads(input_file_content)

        if keys_to_extract:
            json_obj = extract_json_keys(json_obj, keys_to_extract)
            json_obj = { "demo": json_obj }

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

