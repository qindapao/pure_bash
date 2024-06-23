# 文件操作函数集

. ./meta/meta.sh
((DEFENSE_VARIABLES[file_todo]++)) && return 0

# 查找一个目录下的保护下列条件的文件名
# 1. 文件名包含 PropertyProductConfig 和 ${BOMCODE}
# 2. 文件名不包含 PropertyProductConfig
# read -d '' -r -a ALL_PROPERTY_FILES < <(find "$HARDPARAM_PROPERTY_PAGE_PATH" -type f \( -name "*PropertyProductConfig*${BOMCODE}*" -o ! -name "*PropertyProductConfig*" \))

return 0

