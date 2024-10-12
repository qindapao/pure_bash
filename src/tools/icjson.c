#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <bash/builtins.h>
#include "cJSON.h"

// :TODO: 这个项目暂时放弃,实用性不大
// 除非bash的作者直接使用变量级的多级字典或者数据才有意义,不然操作都不方便
// 没有[][]{}这种语法糖

// 创建JSON对象并保存到指定的环境变量中
int create_json(const char *var_name) {
    cJSON *root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "name", "Example");
    cJSON_AddNumberToObject(root, "id", 1);

    char *json_str = cJSON_Print(root);
    setenv(var_name, json_str, 1);

    cJSON_Delete(root);
    free(json_str);

    printf("JSON object created and saved to %s\n", var_name);
    return 0;
}

// 打印JSON对象
int print_json(const char *var_name) {
    char *json_str = getenv(var_name);
    if (json_str) {
        cJSON *root = cJSON_Parse(json_str);
        if (root) {
            char *formatted_json = cJSON_Print(root);
            printf("JSON object: %s\n", formatted_json);
            cJSON_Delete(root);
            free(formatted_json);
        } else {
            printf("Failed to parse JSON\n");
        }
    } else {
        printf("No JSON object found in %s\n", var_name);
    }
    return 0;
}

// 添加键值对到JSON对象
int add_json_item(const char *var_name, const char *key, const char *value) {
    char *json_str = getenv(var_name);
    if (json_str) {
        cJSON *root = cJSON_Parse(json_str);
        if (root) {
            cJSON_AddStringToObject(root, key, value);
            char *new_json_str = cJSON_Print(root);
            setenv(var_name, new_json_str, 1);
            cJSON_Delete(root);
            free(new_json_str);
            printf("Added new item to JSON object in %s\n", var_name);
        } else {
            printf("Failed to parse JSON\n");
        }
    } else {
        printf("No JSON object found in %s\n", var_name);
    }
    return 0;
}

// 删除JSON对象并释放内存
int delete_json(const char *var_name) {
    char *json_str = getenv(var_name);
    if (json_str) {
        cJSON *root = cJSON_Parse(json_str);
        if (root) {
            cJSON_Delete(root);
            unsetenv(var_name);
            free(json_str); // 释放存储JSON字符串的内存
            printf("JSON object deleted from %s\n", var_name);
        } else {
            printf("Failed to parse JSON\n");
        }
    } else {
        printf("No JSON object found in %s\n", var_name);
    }
    return 0;
}

// 获取JSON字段的值
int get_json_value(const char *var_name, const char *key_path, const char *result_var_name) {
    char *json_str = getenv(var_name);
    if (!json_str) {
        printf("No JSON object found in %s\n", var_name);
        return 1;
    }

    cJSON *root = cJSON_Parse(json_str);
    if (!root) {
        printf("Failed to parse JSON\n");
        return 1;
    }

    cJSON *current = root;
    char *key = strtok(strdup(key_path), ".");
    while (key) {
        cJSON *next = cJSON_GetObjectItem(current, key);
        if (!next) {
            cJSON_Delete(root);
            printf("Key not found: %s\n", key);
            return 1;
        }
        current = next;
        key = strtok(NULL, ".");
    }

    if (cJSON_IsString(current)) {
        setenv(result_var_name, current->valuestring, 1);
        cJSON_Delete(root);
        return 0;
    } else if (cJSON_IsNumber(current)) {
        char buffer[20];
        snprintf(buffer, 20, "%g", current->valuedouble);
        setenv(result_var_name, buffer, 1);
        cJSON_Delete(root);
        return 0;
    } else {
        char *sub_json_str = cJSON_Print(current);
        setenv(result_var_name, sub_json_str, 1);
        free(sub_json_str);
        cJSON_Delete(root);
        return 2;
    }
}

// Bash可加载模块的入口函数
int json_builtin(WORD_LIST *list) {
    if (list == NULL) {
        fprintf(stderr, "Usage: json_module -v var_name create|print|add|delete|get <key_path> <result_var_name> <value>\n");
        return EXECUTION_FAILURE;
    }

    char *var_name = NULL;
    char *operation = NULL;
    char *key_path = NULL;
    char *result_var_name = NULL;
    char *value = NULL;

    while (list) {
        if (strcmp(list->word->word, "-v") == 0) {
            list = list->next;
            if (list == NULL) {
                fprintf(stderr, "Usage: json_module -v var_name create|print|add|delete|get <key_path> <result_var_name> <value>\n");
                return EXECUTION_FAILURE;
            }
            var_name = list->word->word;
        } else if (operation == NULL) {
            operation = list->word->word;
        } else if (key_path == NULL) {
            key_path = list->word->word;
        } else if (result_var_name == NULL) {
            result_var_name = list->word->word;
        } else {
            value = list->word->word;
        }
        list = list->next;
    }

    if (var_name == NULL || operation == NULL) {
        fprintf(stderr, "Usage: json_module -v var_name create|print|add|delete|get <key_path> <result_var_name> <value>\n");
        return EXECUTION_FAILURE;
    }

    if (strcmp(operation, "create") == 0) {
        return create_json(var_name);
    } else if (strcmp(operation, "print") == 0) {
        return print_json(var_name);
    } else if (strcmp(operation, "add") == 0) {
        if (key_path == NULL || value == NULL) {
            fprintf(stderr, "Usage: json_module -v var_name add <key_path> <value>\n");
            return EXECUTION_FAILURE;
        }
        return add_json_item(var_name, key_path, value);
    } else if (strcmp(operation, "delete") == 0) {
        return delete_json(var_name);
    } else if (strcmp(operation, "get") == 0) {
        if (key_path == NULL || result_var_name == NULL) {
            fprintf(stderr, "Usage: json_module -v var_name get <key_path> <result_var_name>\n");
            return EXECUTION_FAILURE;
        }
        return get_json_value(var_name, key_path, result_var_name);
    } else {
        fprintf(stderr, "Invalid operation: %s\n", operation);
        return EXECUTION_FAILURE;
    }
}

char *json_builtin_doc[] = {
    "json_module -v var_name create|print|add|delete|get <key_path> <result_var_name> <value>",
    "Perform JSON operations.",
    (char *)NULL
};

struct builtin json_builtin_struct = {
    "json_module",
    json_builtin,
    BUILTIN_ENABLED,
    json_builtin_doc,
    "json_module -v var_name create|print|add|delete|get <key_path> <result_var_name> <value>",
    0
};

