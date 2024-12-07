. ./meta/meta.sh
((DEFENSE_VARIABLES[com_result_check]++)) && return 0

. ./date/date_prt.sh || return 1

com_result_check ()
{
    local - ; set +xv
    local -i slot_num=0 exit_code=0
    local -a test_result=() com_logs_contents=()
    local line_str valid_chars=''
    
    # 这里一定要用eval,不然参数不会扩展(92个合法字符),排除掉 & < >(xml的保留字符?)
    # 这里使用\x%x打印会有告警,所以转换成8进制打印
    # eval valid_chars="$(printf "$\'\\%o\'" {32..37} {39..59} 61 {63..126})"
    # 下面这种方法更快(因为不需要创建子进程,不用进程替换,但是字符串间隔不能出现空格,否则可能出问题)
    # printf -v valid_chars "$\'\\%o\'" {32..37} {39..59} 61 {63..126} ; eval "valid_chars=$valid_chars"
    # 下面这种方法不仅快,而且没有使用eval更安全可扩展(字符串的间隔可以出现空格)
    printf -v valid_chars '\\%o' {32..37} {39..59} 61 {63..126}
    printf -v valid_chars '%b' "$valid_chars"
    #   多字节字符的处理情况更加复杂些
    #   q00546874@DESKTOP-0KALMAH ~
    #   $ printf "%b" '\xe7\xa7\xa6'
    #   秦
    #   q00546874@DESKTOP-0KALMAH ~
    #   $ printf "%b" '\347\247\246'
    #   秦

    # 剔除文件中的非法字符
    for((slot_num=0;slot_num<COM_SLOTS_NUM;slot_num++)) ; do
        test_result[slot_num]=${test_result[slot_num]:-pass}
        
        # 如果环境中有level3_item.txt但是没有条码level3,那么追加到每个条码文件
        if [[ ! -s "${COM_LOGS[slot_num]}" ]] && [[ -s level3_item.txt ]] ; then
            echo "$(<level3_item.txt)" > "${COM_LOGS[slot_num]}"
        fi

        if [[ -s "${COM_LOGS[slot_num]}" ]] ; then
            local com_logs_str='' tmp_str=''
            local -i is_invalid_char_exist=0 line_num=1
            mapfile -t com_logs_contents < "${COM_LOGS[slot_num]}"
            for line_str in "${com_logs_contents[@]}" ; do
                tmp_str=${line_str//[^"$valid_chars"]/}
                # 如果转换后的字符串[]开头,填补一个null
                [[ "$tmp_str" =~ ^\[\](.*) ]] && tmp_str+="[null]${BASH_REMATCH[1]}"
                [[ "$tmp_str" != "$line_str" ]] && ((is_invalid_char_exist++))

                # 检查新行的格式是否正确,如果不正确不要写入
                if [[ "$tmp_str" =~ ^\[.+\]\ +([fF][aA][iI][lL]|[pP][aA][sS][sS])\ +[^\ ] ]] ; then
                    com_logs_str+="$tmp_str"
                    [[ "${BASH_REMATCH[1]}" == [fF][aA][iI][lL] ]] && test_result[slot_num]='fail'
                else
                    com_logs_str+="[level3_format_line_${line_num}] fail format error, please check ${COM_LOGS[slot_num]} file in line:${line_num}"
                    test_result[slot_num]='fail'
                    ((is_invalid_char_exist++))
                fi

                com_logs_str+=$'\n'
                ((line_num++))
            done

            # 有字符剔除发生,替换原文件
            ((is_invalid_char_exist)) && {
                printf "%s" "$com_logs_str" > "${COM_LOGS[slot_num]}"
                printf "%s\n" "${com_logs_contents[@]}" > "${COM_LOGS[slot_num]%.*}.old" 
            }
        else
            test_result[slot_num]='fail'
        fi

        if [[ ! -s "${COM_LOGS_SAVE[slot_num]}" ]] ; then
            echo "${test_result[slot_num]}" > "${COM_LOGS_SAVE[slot_num]}"
        fi

        echo "${test_result[slot_num]}" > "${COM_LOGS_RESULT[slot_num]}"
    done

    if [[ "${test_result[*]}" == *fail* ]] ; then
        exit_code=1
        echo ""
        echo "[40;31m ****$TU_NAME $(date_prt)....TEST FAIL****[0m"
    else
        echo ""
        echo "[40;32m ****$TU_NAME $(date_prt)....TEST PASS****[0m"
    fi

    # 恢复标准输出
    exec 1>&100
    # 关闭文件描述符100
    exec 100>&-

    exit ${exit_code}
}

return 0

