. ./meta/meta.sh
((DEFENSE_VARIABLES[jobs_wait]++)) && return 0

# 把每个子进程的退出状态存储到关联数组中
# :TODO: 使用eval不用间接引用实现
# :TODO: 如果在获取的时候已经有子进程已经结束呢？还能捕捉到已经结束后的子进程的状态吗？
jobs_wait ()
{
    local -n _jobs_wait_ref_hash=$1
    local pid

    # :TODO: 验证这里使用jobs -p是否妥当啊,这里是否包含非当前脚本的别的子进程啊?
    for pid in $(jobs -p) ; do
        wait "$pid"
        _jobs_wait_ref_hash[$pid]=$?
    done
}

return 0

