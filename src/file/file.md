# file

## 相关指令

`find`命令的编程属性。

- 查找一个目录下的包括下列条件的文件名
1. 文件名包含 `PropertyProductConfig` 和 `${BOMCODE}`
2. 文件名不包含 `PropertyProductConfig`

```bash
read -d '' -r -a ALL_PROPERTY_FILES < <(find "$HARDPARAM_PROPERTY_PAGE_PATH" -type f \( -name "*PropertyProductConfig*${BOMCODE}*" -o ! -name "*PropertyProductConfig*" \))
```

