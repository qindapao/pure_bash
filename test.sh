#! /usr/bin/bash

cd ./src
. ./cntr/cntr_grep.sh || return 1
. ./date/date_log.sh || return 1
. ./date/date_prt.sh || return 1
. ./file/file_traverse.sh || return 1

# :TODO: 搜集下每个用例执行的结果$?
exec_all_test_case ()
{
    local start_time=$(date_prt)
    # 保证当前不论在哪里都能正常执行
    local old_dir="$PWD"
    local root_dir="${old_dir%%/pure_bash*}/pure_bash"

    local test_report="$root_dir"/test_report_$(date_log).txt
    local -a test_case_files=() 
    cd "${root_dir}/test/cases"

    set -- "$IFS"
    local IFS=$'\n' ; test_case_files=($(file_traverse '.')) ; IFS="$1"
    cntr_grep test_case_files '[[ "$1" == *".sh" ]]'

    local test_case

    for test_case in "${test_case_files[@]}" ; do
        cd "${root_dir}/test/cases"
        cd "${test_case%/*}"
        bash "${test_case##*/}" | tee -a "$test_report"
    done

    cd "$old_dir"
    local end_time=$(date_prt)

    echo "test start in ${start_time},end_in ${end_time}."
}

exec_all_test_case
exit 0

