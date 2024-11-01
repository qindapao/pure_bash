. ./meta/meta.sh
((DEFENSE_VARIABLES[remote_cp_r2l]++)) && return 0

# 发送一个带参数的命令到远程主机
# 1: host
# 2: 拷贝源文件(远端)
# 3: 拷贝目标文件(本地)
# 4: 拷贝超时
# 5: 用户名
# 6: 密码
remote_cp_r2l ()
{
    cp_r2l.exp "$@"
}

return 0

