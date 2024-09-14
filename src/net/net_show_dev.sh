. ./meta/meta.sh
((DEFENSE_VARIABLES[net_show_dev]++)) && return 0

# 原始打印格式
# [root@localhost ~]# cat /proc/net/dev
# Inter-|   Receive                                                |  Transmit
#  face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
#     lo:   47520     306    0    0    0     0          0         0    47520     306    0    0    0     0       0          0
#   veth:       0       0    0    0    0     0          0         0     1006      13    0    0    0     0       0          0
#   eth0: 136163559   98890    0    0    0     0          0         0  4431165   21241    0    0    0     0       0          0
#   eth1:  596968    5499    0    0    0     0          0         0 29824700   21652    0    0    0     0       0          0
# eth1.4084:  442498    4033    0    0    0     0          0         0 28540378    2321    0    0    0     0       0          0
# eth1.4093:   77172    1460    0 1269    0     0          0         0    21792     204    0    0    0     0       0          0
# eth0.4093:   51538     499    0    0    0     0          0         0    54722     511    0    0    0     0       0          0
# [root@localhost ~]# 
# [root@localhost ~]# 

# 格式化后的打印格式
# [root@localhost ~]# awk 'NR > 1 { gsub(/\|/, " |"); print }' /proc/net/dev | column -t
# face        |bytes     packets  errs  drop  fifo  frame  compressed  multicast  |bytes    packets  errs  drop  fifo  colls  carrier  compressed
# lo:         48672      322      0     0     0     0      0           0          48672     322      0     0     0     0      0        0
# veth:       0          0        0     0     0     0      0           0          1076      14       0     0     0     0      0        0
# eth0:       263829902  193537   0     0     0     0      0           0          15384783  44547    0     0     0     0      0        0
# eth1:       1157315    10561    0     0     0     0      0           0          31506359  24337    0     0     0     0      0        0
# eth1.4084:  774025     5664     0     0     0     0      0           0          30161895  4095     0     0     0     0      0        0
# eth1.4093:  234032     4870     0     4679  0     0      0           0          21932     206      0     0     0     0      0        0
# eth0.4093:  51538      499      0     0     0     0      0           0          54862     513      0     0     0     0      0        0
# [root@localhost ~]# 


net_show_dev ()
{
    awk 'NR > 1 { gsub(/\|/, " |"); print }' /proc/net/dev | column -t
}

return 0

