. ./meta/meta.sh
((DEFENSE_VARIABLES[remote_cp_l2r]++)) && return 0

# 发送一个带参数的命令到远程主机
# 1: host
# 2: 拷贝源文没(本地)
# 3: 拷贝目标文件(远端)
# 4: 拷贝超时
# 5: 用户名
# 6: 密码
remote_cp_l2r ()
{
    cp_l2r.exp "$@"
}

return 0

