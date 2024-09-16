. ./meta/meta.sh
((DEFENSE_VARIABLES[json_init]++)) && return 0

# 部署json转换工具到可执行目录下
json_init ()
{
    local root_dir
    root_dir="${PWD%%/pure_bash*}/pure_bash"

    cp -f "${root_dir}/src/json/json_common_load.py" /usr/bin/
    chmod +x /usr/bin/json_common_load.py
}

return 0

