. ./meta/meta.sh
((DEFENSE_VARIABLES[json_init]++)) && return 0

. ./json/json_common.sh || return 1
. ./awk/awk_json.sh || return 1

json_init_check_python3 ()
{
    # 检查是否安装了 Python 3
    if command -v python3 &>/dev/null; then
        echo "Python 3 installed"
    else
        echo "Python 3 not installed" >&2
        return 1
    fi

    # 检查标准模块
    local -a modules missing_modules
    local module
    modules=("json" "re" "subprocess" "os" "sys" "getopt" "shlex" "base64")
    missing_modules=()

    for module in "${modules[@]}"; do
        python3 -c "import $module" 2>/dev/null || missing_modules+=("$module")
    done

    if (( ${#missing_modules[@]} )) ; then
        echo "missing python3 modules: ${missing_modules[*]}" >&2
        return 1
    fi
    echo "all python3 modules is installed"
    return 0
}


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
    "${cp_cmd[@]}" -f "${PURE_BASH_TOOLS_DIR}/json_common_load.py" /usr/bin/
    "${chmod_cmd[@]}" +x /usr/bin/json_common_load.py

    # 指定当前使用的json算法(不能混用,只能指定一个)
    JSON_COMMON_SERIALIZATION_ALGORITHM=${1:-${JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin]}}
    JSON_COMMON_MAGIC_STR=${2:-${JSON_COMMON_MAGIC_STR}}

    json_init_check_python3 || {
        JSON_COMMON_STANDARD_JSON_PARSER='awk'
        awk_json_init
    }
}

return 0

