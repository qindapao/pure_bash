. ./meta/meta.sh
((DEFENSE_VARIABLES[log_todo]++)) && return 0


# 日志份数限制
# # 日志最多保留10份
# (
#     cd "${PLAT_LOG_DIR}/$1" || exit 1
#     declare -i keep_cnt=10

#     declare -a log_file_list=(*)
#     declare -a log_file_remain=(*)

#     if((${#log_file_list[@]}>keep_cnt)) ; then
#         IFS=$'\n' read -d "" -r -a log_file_remain < <(printf "%s\n" "${log_file_list[@]}" | sort -u | tail -n "$keep_cnt")

#         # 删除多余文件
#         for i in "${log_file_list[@]}" ; do
#             if [[ " ${log_file_remain[*]} " != *" ""$i"" "* ]] ; then
#                 rm -f ./"$i"
#             fi
#         done
#     fi
# )

return 0

