. ./meta/meta.sh
((DEFENSE_VARIABLES[jobs_wait]++)) && return 0

# 把每个子进程的退出状态存储到关联数组中
# :TODO: 如果在获取的时候已经有子进程已经结束呢？还能捕捉到已经结束后的子进程的状态吗？
# 1: 保存每个后台 pid 退出状态的关联数组名,键是pid进程号
jobs_wait ()
{
    local _jobs_wait_block_str='
    # 防止命名冲突
    local pid_'$1'

    # :TODO: 验证这里使用jobs -p是否妥当啊,这里是否包含非当前脚本的别的子进程啊?
    for pid_'$1' in $(jobs -p) ; do
        wait "$pid_'$i'"
        '$1'[$pid_'$1']=$?
    done'

    eval -- "$_jobs_wait_block_str"
}

return 0

