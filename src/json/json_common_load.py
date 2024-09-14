#! /usr/bin/env python3

import json
import pprint
import re
import subprocess

# :TODO: 后面要支持配置允许空键和不允许空键
# :TODO: 后面脚本中要加入更多的错误处理

def end_char(data):
    # 叶子字符串,一个空格
    if not isinstance(data, (dict, list)):
        return ' '
    # 叶子字典,三个空格
    elif isinstance(data, dict) and not data:
        return '   '
    # 叶子数组,2个空格
    elif isinstance(data, list) and not data:
        return '  '
    else:
        return ''


def custom_print(data, indent=0, output=None):
    if output is None:
        output = []

    spacing = '    ' * indent

    if isinstance(data, dict):
        if not data:
            spacing = '    ' * (indent - 1)
            # :TODO: 空数组和空字典当前其实还不支持
            output.append(f"{spacing}{{}}")
        else:
            for key, value in sorted(data.items()):
                command = ['bash', '-c', f'printf "%q" "{key}"']
                q_key = subprocess.run(command, capture_output=True, text=True).stdout


                output.append(f"{spacing}{q_key} ⇒{end_char(value)}")
                custom_print(value, indent + 1, output)
    elif isinstance(data, list):
        if not data:
            spacing = '    ' * (indent - 1)
            # :TODO: 空数组和空字典当前其实还不支持
            output.append(f"{spacing}[]")
        else:
            for index, item in enumerate(data):
                output.append(f"{spacing}{index} ⩦{end_char(item)}")
                custom_print(item, indent + 1, output)
    else:
        spacing = '    ' * (indent - 1)
        command = ['bash', '-c', f'printf "%q" "{data}"']
        q_data = subprocess.run(command, capture_output=True, text=True).stdout
        output.append(f"{spacing}{q_data}")

    return output

def list_setdefault(lst, index, default):
    while len(lst) <= index:
        lst.append(default)
    return lst[index]


def set_value(container, keys, value):
    print(f"keys:{keys};value:{value}")

    current = container
    for i, key in enumerate(keys[:-1]):
        if key[0] == 1:
            next_key = keys[i + 1]
            if next_key[0] == 1:
                current = current.setdefault(key[1], {})
            else:
                current = current.setdefault(key[1], [])
        else:
            key[1] = int(key[1])
            next_key = keys[i + 1]
            if next_key[0] == 1:
                current = list_setdefault(current, key[1], {})
            else:
                current = list_setdefault(current, key[1], [])

    last_key = keys[-1]
    if last_key[0] == 1:
        current[last_key[1]] = value
    else:
        last_key[1] = int(last_key[1])
        while len(current) <= last_key[1]:
            current.append(None)
        current[last_key[1]] = value


def json_load(json_lines):
    if '⇒' in json_lines[1]:
        json_out = {}
    else:
        json_out = []

    json_key, json_value, json_leaf_key = None, None, None
    json_ori_str = None
    json_key_stack = []
    json_line_cnt = 1
    json_lines_size = len(json_lines)
    
    json_lev = 0
    json_pop_cnt = 0
    while (json_line_cnt < json_lines_size):
        json_lev = 0
        json_line_content = json_lines[json_line_cnt]

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
        # 判断最后一个字符是否空格确定叶子节点
        json_line_last_char = json_line_content[-1:]

        if json_line_last_char == ' ':
            # 取key字符,和栈里面组合成的键一起设置数据结构
            json_value = json_lines[json_line_cnt+1]
            json_value = json_value.lstrip()

            # key和value需要从Q字符串转换成常规字符串
            # print(f"json_key:{json_key}")
            command = ['bash', '-c', f'eval "json_ori_str={json_key[0:-3]}" ; printf "%s" "$json_ori_str"']
            json_ori_str = subprocess.run(command, capture_output=True, text=True).stdout
            # print(f"json_ori_key:{json_ori_str}")
            command = ['bash', '-c', f'eval "json_value={json_value}" ; printf "%s" "$json_value"']
            json_value = subprocess.run(command, capture_output=True, text=True).stdout

            json_leaf_key = json_key[-2:-1]

            if json_leaf_key == '⇒':
                json_leaf_key = [1, json_ori_str]
            else:
                json_leaf_key = [0, json_ori_str]

            set_value(json_out, json_key_stack + [json_leaf_key], json_value)
            json_line_cnt += 2
        else:
            # key从Q字符串转换成常规字符串(最后两个字符不能转它们不属于Q字符串)
            command = ['bash', '-c', f'eval "json_ori_str={json_key[0:-2]}" ; printf "%s" "$json_ori_str"']
            json_ori_str = subprocess.run(command, capture_output=True, text=True).stdout

            if json_key[-1:] == '⇒':
                # 1: 字典 0: 数组 
                json_key_stack.append([1, json_ori_str])
            else:
                json_key_stack.append([0, json_ori_str])

            json_line_cnt += 1

    return json_out


# :TODO: 暂时不支持空字典和空数组
if __name__ == "__main__":
    # 示例 JSON 数据
    json_data = '''
    {
        "person": {
            "name": "John",
            "age": 30,
            "address": {
                "city": "New York\\ngeg geg\\n",
                "zipcode": "10001"
            },
            "other": {
                "xx": ["a"],
                "yy": {"a": 1}
            },
            "hobbies": ["reading", "traveling", "swimming"],
            "ohters": {
                "132": ["gge", "geg", "1223"],
                "133": ["gge", "geg", "1223"],
                "gegeeg": {"geg": "geg", "kkk": "yyyyg"}
            }
        }
    }
    '''

    # 解析 JSON 数据
    data = json.loads(json_data)

    # 自定义打印
    tree_list = custom_print(data)

    print('\n'.join(tree_list))
    
    parsed_data = json_load(tree_list)
    pprint.pprint(parsed_data, indent=4)

    # 示例 JSON 数据
    json_data = '''
    {
    "person2": [{
            "name": "John",
            "age": 30,
            "address": {
                "city": "New York",
                "zipcode": "10001"
            },
            "other": {
                "xx": ["2"],
                "yy": {"xxa": 123}
            },
            "hobbies": ["reading", "traveling", "swimming"],
            "ohters": {
                "132": ["gge", "geg", "1223"],
                "133": ["gge", "geg", "1223"],
                "gegeeg": {"geg": "geg", "kkk": "yyyyg"}
            }
        },
        "bushi"
    ]
    }
    '''
    # 解析 JSON 数据
    data = json.loads(json_data)

    # 自定义打印
    tree_list = custom_print(data)

    print('\n'.join(tree_list))
    # with open('xx_xx_1.txt', encoding='utf-8', mode='w') as f:
    #     f.write('\n'.join(tree_list))

    parsed_data = json_load(tree_list)
    pprint.pprint(parsed_data, indent=4)

