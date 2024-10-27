# log

## 一些备份的实现

### 日志的数量限制

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

### 日志函数中的暂时不用的代码

```bash
# # 把当前环境中所有变量的值记录到日志文件中(不打印)
# local -a _log_dbg_all_vars_name_list
# mapfile -t _log_dbg_all_vars_name_list < <(compgen -A variable)
# array_del_elements_dense _log_dbg_all_vars_name_list "${_LOG_INIT_VARIABLES_NAME[@]}" '_log_dbg_log_type' '_log_dbg_is_need_break' '_log_dbg_msg' \
#     '_log_dbg_i' '_log_dbg_declare_str' '_log_dbg_prt_str' '_log_dbg_log_info' '_log_dbg_func_index' '_LOG_INIT_VARIABLES_NAME' 'LOG_ALLOW_BREAK' \
#     'LOG_LEVEL' 'LOG_LEVEL_KIND'  '__META_BASH_VERSION' 'DEFENSE_VARIABLES' '__META' '_log_dbg_color' '_log_dbg_other_effect'

# echo "==============ALL VARIABLE===================" >>"$LOG_FILE_NAME"
# for _log_dbg_i in "${_log_dbg_all_vars_name_list[@]}" ; do
#     :TODO: 下面这个写法有风险,调用函数 atom_identify_data_type 保险
#     if [[ "${!_log_dbg_i@a}" == *[aA]* ]] ; then
#         json_dump_hq "${_log_dbg_i}" >> "$LOG_FILE_NAME" 
#     else
#         declare -p "$_log_dbg_i" >> "$LOG_FILE_NAME"
#     fi
#     echo '-  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -' >>"$LOG_FILE_NAME"
# done
```

