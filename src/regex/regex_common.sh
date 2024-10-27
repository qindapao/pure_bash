. ./meta/meta.sh
((DEFENSE_VARIABLES[regex_common]++)) && return 0

# :TODO: 如果后续正则表达式太多,可以拆分子模块
# 引用变量的declare声明(这个只能适用于引用变量,普通变量是不可以的)
REGEX_COMMON_DECLARE_REF='^declare\ [^\ ]*n[^\ ]*\ [^=]+=[\"\'\''](.+)[\"\'\'']$'

# 数组和关联数组的declare声明
REGEX_COMMON_DECLARE_CONTAINER='^declare\ ([^\ ]*[aA][^\ ]*)\ [^=]+=?.*'

# 把非字符串结构打包成字符串使用
REGEX_COMMON_DECLARE_PACK_STR='^(declare)\ ([^\ ]+)\ [a-zA-Z_]+[a-zA-Z0-9_]*=(.*)'

# 字符串是合法的bash变量名
REGEX_COMMON_VALID_VAR_NAME='^[a-zA-Z_]+[a-zA-Z0-9_]*$'

# 字符串是无无符号10进制整数
REGEX_COMMON_UINT_DECIMAL='^[1-9][0-9]*$|^0$'

# 空行(什么都没有或者只有空白字符)
REGEX_COMMON_BLANK_LINE='^[[:space:]]*$'

# 以0个或多个空格开始的所有内容(:TODO:感觉没有什么用?)
REGEX_COMMON_SPACE_LINE_CONTENT='^(\ *)'

# 全词匹配的左边界
REGEX_COMMON_W_L='(^|[^[:alnum:]_])'

# 全词匹配的右边界
REGEX_COMMON_W_R='([^[:alnum:]_]|$)'

return 0

