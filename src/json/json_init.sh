. ./meta/meta.sh
((DEFENSE_VARIABLES[json_init]++)) && return 0

# 部署json转换工具到可执行目录下
json_init ()
{
    local root_dir
    root_dir="${PWD%%/pure_bash*}/pure_bash"
    local -a cp_cmd=('cp') chmod_cmd=('chmod')
    which sudo 2>/dev/null && {
        cp_cmd=('sudo' 'cp')
        chmod_cmd=('sudo' 'chmod')
    }

    "${cp_cmd[@]}" -f "${root_dir}/src/json/json_common_load.py" /usr/bin/
    "${chmod_cmd[@]}" +x /usr/bin/json_common_load.py
}

return 0

