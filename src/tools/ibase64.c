// bash 可加载模块, base64编码与解码
// :TODO: 要支持从标准输入中读取处理字符串进行处理,这样才能转码二进制文件
//
// 其实使用命令行工具速度已经很快了,而且可以处理二进制
// [root@localhost loadables]# x=$(base64 -w 0 <ibase64)
// [root@localhost loadables]# time x=$(base64 -w 0 <ibase64)
// 
// real    0m0.004s
// user    0m0.003s
// sys     0m0.002s
// [root@localhost loadables]# printf "%s" "$x" | base64 -d >ibase64_2
// [root@localhost loadables]# diff ibase64_2 ibase64
// [root@localhost loadables]# echo $?
// 0

#include <config.h>

#if defined (HAVE_UNISTD_H)
#  include <unistd.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "bashansi.h"
#include "shell.h"
#include "builtins.h"
#include "common.h"
#include "bashgetopt.h"

// Base64编码表
static const char base64_table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

// Base64解码表
static const unsigned char base64_reverse_table[256] = {
    [0 ... 255] = 0x80, // 默认值为无效字符
    ['A'] = 0, ['B'] = 1, ['C'] = 2, ['D'] = 3, ['E'] = 4, ['F'] = 5, ['G'] = 6, ['H'] = 7,
    ['I'] = 8, ['J'] = 9, ['K'] = 10, ['L'] = 11, ['M'] = 12, ['N'] = 13, ['O'] = 14, ['P'] = 15,
    ['Q'] = 16, ['R'] = 17, ['S'] = 18, ['T'] = 19, ['U'] = 20, ['V'] = 21, ['W'] = 22, ['X'] = 23,
    ['Y'] = 24, ['Z'] = 25, ['a'] = 26, ['b'] = 27, ['c'] = 28, ['d'] = 29, ['e'] = 30, ['f'] = 31,
    ['g'] = 32, ['h'] = 33, ['i'] = 34, ['j'] = 35, ['k'] = 36, ['l'] = 37, ['m'] = 38, ['n'] = 39,
    ['o'] = 40, ['p'] = 41, ['q'] = 42, ['r'] = 43, ['s'] = 44, ['t'] = 45, ['u'] = 46, ['v'] = 47,
    ['w'] = 48, ['x'] = 49, ['y'] = 50, ['z'] = 51, ['0'] = 52, ['1'] = 53, ['2'] = 54, ['3'] = 55,
    ['4'] = 56, ['5'] = 57, ['6'] = 58, ['7'] = 59, ['8'] = 60, ['9'] = 61, ['+'] = 62, ['/'] = 63,
    ['='] = 0
};

// Base64编码填充表
static const int mod_table[] = {0, 2, 1};

// Base64编码函数
char *base64_encode(const char *data, size_t input_length, size_t *output_length) {
    char *encoded_data;

    *output_length = 4 * ((input_length + 2) / 3);
    encoded_data = malloc(*output_length + 1);  // +1 用于空终止符
    if (encoded_data == NULL) return NULL;

    for (size_t i = 0, j = 0; i < input_length;) {
        uint32_t octet_a = i < input_length ? (unsigned char)data[i++] : 0;
        uint32_t octet_b = i < input_length ? (unsigned char)data[i++] : 0;
        uint32_t octet_c = i < input_length ? (unsigned char)data[i++] : 0;

        uint32_t triple = (octet_a << 0x10) + (octet_b << 0x08) + octet_c;

        encoded_data[j++] = base64_table[(triple >> 3 * 6) & 0x3F];
        encoded_data[j++] = base64_table[(triple >> 2 * 6) & 0x3F];
        encoded_data[j++] = base64_table[(triple >> 1 * 6) & 0x3F];
        encoded_data[j++] = base64_table[(triple >> 0 * 6) & 0x3F];
    }

    for (size_t i = 0; i < mod_table[input_length % 3]; i++)
        encoded_data[*output_length - 1 - i] = '=';

    encoded_data[*output_length] = '\0';  // 添加空终止符

    return encoded_data;
}

// Base64解码函数
unsigned char *base64_decode(const char *data, size_t input_length, size_t *output_length) {
    if (input_length % 4 != 0) return NULL;

    *output_length = input_length / 4 * 3;
    if (data[input_length - 1] == '=') (*output_length)--;
    if (data[input_length - 2] == '=') (*output_length)--;

    unsigned char *decoded_data = malloc(*output_length + 1);  // +1 用于空终止符
    if (decoded_data == NULL) return NULL;

    for (size_t i = 0, j = 0; i < input_length;) {
        uint32_t sextet_a = data[i] == '=' ? 0 & i++ : base64_reverse_table[(unsigned char)data[i++]];
        uint32_t sextet_b = data[i] == '=' ? 0 & i++ : base64_reverse_table[(unsigned char)data[i++]];
        uint32_t sextet_c = data[i] == '=' ? 0 & i++ : base64_reverse_table[(unsigned char)data[i++]];
        uint32_t sextet_d = data[i] == '=' ? 0 & i++ : base64_reverse_table[(unsigned char)data[i++]];

        uint32_t triple = (sextet_a << 3 * 6) + (sextet_b << 2 * 6) + (sextet_c << 1 * 6) + (sextet_d << 0 * 6);

        if (j < *output_length) decoded_data[j++] = (triple >> 2 * 8) & 0xFF;
        if (j < *output_length) decoded_data[j++] = (triple >> 1 * 8) & 0xFF;
        if (j < *output_length) decoded_data[j++] = (triple >> 0 * 8) & 0xFF;
    }

    decoded_data[*output_length] = '\0';  // 添加空终止符

    return decoded_data;
}

// Bash可加载模块的入口函数
int ibase64_builtin(WORD_LIST *list) {
    if (list == NULL) {
        fprintf(stderr, "Usage: ibase64 [-v var] encode|decode <string>\n");
        return EXECUTION_FAILURE;
    }

    char *operation = NULL;
    char *input = NULL;
    SHELL_VAR *var = NULL;

    while (list) {
        if (strcmp(list->word->word, "-v") == 0) {
            list = list->next;
            if (list == NULL) {
                fprintf(stderr, "Usage: ibase64 [-v var] encode|decode <string>\n");
                return EXECUTION_FAILURE;
            }
            var = find_variable(list->word->word);
        } else if (operation == NULL) {
            operation = list->word->word;
        } else {
            input = list->word->word;
        }
        list = list->next;
    }

    if (operation == NULL || input == NULL) {
        fprintf(stderr, "Usage: ibase64 [-v var] encode|decode <string>\n");
        return EXECUTION_FAILURE;
    }

    if (strcmp(operation, "encode") == 0) {
        size_t output_length;
        char *encoded = base64_encode(input, strlen(input), &output_length);
        if (encoded == NULL) {
            fprintf(stderr, "Error encoding base64\n");
            return EXECUTION_FAILURE;
        }
        if (var) {
            bind_variable(var->name, encoded, 0);
        } else {
            printf("%s\n", encoded);
        }
        free(encoded);
    } else if (strcmp(operation, "decode") == 0) {
        size_t output_length;
        unsigned char *decoded = base64_decode(input, strlen(input), &output_length);
        if (decoded == NULL) {
            fprintf(stderr, "Error decoding base64\n");
            return EXECUTION_FAILURE;
        }
        if (var) {
            bind_variable(var->name, (char *)decoded, 0);
        } else {
            printf("%.*s\n", (int)output_length, decoded);
        }
        free(decoded);
    } else {
        fprintf(stderr, "Invalid operation: %s\n", operation);
        return EXECUTION_FAILURE;
    }

    return EXECUTION_SUCCESS;
}

char *ibase64_doc[] = {
    "ibase64 [-v var] encode|decode <string>",
    "Encode or decode a string using base64.",
    (char *)NULL
};

struct builtin ibase64_struct = {
    "ibase64",
    ibase64_builtin,
    BUILTIN_ENABLED,
    ibase64_doc,
    "ibase64 [-v var] encode|decode <string>",
    0
};

