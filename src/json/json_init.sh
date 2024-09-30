. ./meta/meta.sh
((DEFENSE_VARIABLES[json_init]++)) && return 0

. ./json/json_common.sh || return 1

# 部署json转换工具到可执行目录下并且指定json使用的算法
# 1: json使用的算法,见json_common.sh公共文件
# 2: 魔法字符串
json_init ()
{
    local root_dir
    root_dir="${PWD%%/pure_bash*}/pure_bash"
    local -a cp_cmd=('cp') chmod_cmd=('chmod')
    which sudo 2>/dev/null && {
        cp_cmd=('sudo' 'cp')
        chmod_cmd=('sudo' 'chmod')
    }

    # 实际部署的时候路径一定要改
    "${cp_cmd[@]}" -f "${root_dir}/src/json/json_common_load.py" /usr/bin/
    "${chmod_cmd[@]}" +x /usr/bin/json_common_load.py

    # 指定当前使用的json算法(不能混用,只能指定一个)
    JSON_COMMON_SERIALIZATION_ALGORITHM=${1:-${JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin]}}
    JSON_COMMON_MAGIC_STR=${2:-${JSON_COMMON_MAGIC_STR}}
}

return 0

