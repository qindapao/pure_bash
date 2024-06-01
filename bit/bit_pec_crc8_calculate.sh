. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_pec_crc8_calculate]++)) && return 0


# pmbus协议下的crc8码计算函数(不可用于高阶函数)
# @ 需要计算crc8的数组(这里不是引用,直接传递内容)
bit_pec_crc8_calculate ()
{
    local data=("$@")
    local i=0 pec=0
    local pec_128_r="" pec_64_r=""
    
    for((i=0;i<${#data[@]};i++)) ; do
        pec=$[${data[i]}^pec]
        ((pec_128_r=(pec&128 > 0)? 9 : 0))
        ((pec_64_r=(pec&64 > 0)? 7 : 0))
        
        pec=$[pec^(pec<<1)^(pec<<2)^pec_128_r^pec_64_r]
    done
    
    printf "0x%x" "$[pec&255]"
}

return 0

