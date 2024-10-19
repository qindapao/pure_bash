# str

字符串相关的备份和废弃函数备份

## 废弃函数备份

### str_trim

下面的实现和别名都没用了

```bash
# 使用shopt -s extglob
# :TODO: $(str_trim x str1) 进程替换后会丢失结尾换行符,如果介意用printf -v
str_trim ()
{
    local tmp_str=${2##+([[:space:]])}
    printf "%s" "${tmp_str%%+([[:space:]])}"
}

alias str_trim_s='str_trim ""'
```

### str_basename

`extglob`的实现备份起来。

```bash
# 另外一种使用extglob的实现
# shopt -s extglob
# str_basename () { printf "%s" "${2//@(*\/|.*)}" ; }

# 带s的是直接使用的,上面的是在高阶函数中的
alias str_basename_s='str_basename ""'
```

