_test_bst_old_dir="$PWD"
root_dir="${_test_bst_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

. ./bst/bst_init.sh || return 1
. ./bst/bst_insert.sh || return 1
. ./bst/bst_lot.sh || return 1
. ./bst/bst_it.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_bst_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv


test_case1 ()
{
    local -A bst
    local node_id node_id2
    bst_init bst "value1"
    

    bst_insert bst node_id 'root' 'left' '1'
    bst_insert bst node_id2 "$node_id" 'left' '2'
    bst_insert bst node_id2 "$node_id" 'right' '3'
    bst_insert bst node_id 'root' 'right' '4'
    bst_insert bst node_id2 "$node_id" 'left' '5'
    bst_insert bst node_id2 "$node_id" 'right' '6'

    bst_insert bst xx "$node_id2" 'left' '7'
    bst_insert bst xx "$node_id2" 'right' '8'


    bst_insert bst node_id2 "$node_id" 'left' '9'
    bst_insert bst node_id "$node_id2" 'right' '10'
    bst_insert bst node_id "$node_id2" 'left' '11'
    bst_insert bst node_id2 "$node_id" 'right' '12'
    bst_insert bst node_id2 "$node_id" 'left' '13'
    bst_insert bst node_id "$node_id2" 'right' '14'
    bst_insert bst node_id "$node_id2" 'left' '15'

    bst_insert bst node_id '15' 'left' '16'
    bst_insert bst node_id '12' 'right' '17'

    bst_insert bst node_id '2' 'right' '18' 
    bst_insert bst node_id '3' 'left' '19' 
    bst_insert bst node_id '19' 'left' '20' 
    bst_insert bst node_id '19' 'right' '21' 
    bst_insert bst node_id '20' 'right' '22' 
    bst_insert bst node_id '20' 'left' '23' 
    bst_insert bst node_id '18' 'left' '24' 
    bst_insert bst node_id '18' 'right' '25' 
    bst_insert bst node_id '3' 'right' '26' 

    # lsdebug_bp 'show bst' bst
    bst_lot bst 'root'
    bst_it bst 'root'
    bst_it bst 'root' 0
    bst_it bst 'root' 1
    bst_it bst 'root' 1 1

    local -A bst2
    bst_init bst2 '0'
    bst_insert bst2 node_id 'root' 'right' '1' 
    bst_it bst2 'root'


    return
}

test_case1

