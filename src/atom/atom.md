# atom

## 一些备忘

### 关于upvar的一篇很有用的文章

文章的链接: https://fvue.nl/wiki/Bash:_Passing_variables_by_reference#Appendix_A:_upvars.sh

还有关于`unset`原理的一些说明：https://unix.stackexchange.com/questions/382391/what-does-unset-do


```bash
# Bash: Passing variables by reference
# Copyright (C) 2010 Freddy Vulto
# Version: upvars-0.9.dev
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Assign variable one scope above the caller
# Usage: local "$1" && upvar $1 "value(s)"
# Param: $1  Variable name to assign value to
# Param: $*  Value(s) to assign.  If multiple values, an array is
#            assigned, otherwise a single value is assigned.
# NOTE: For assigning multiple variables, use 'upvars'.  Do NOT
#       use multiple 'upvar' calls, since one 'upvar' call might
#       reassign a variable to be used by another 'upvar' call.
# Example: 
#
#    f() { local b; g b; echo $b; }
#    g() { local "$1" && upvar $1 bar; }
#    f  # Ok: b=bar
#
upvar() {
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}


# Assign variables one scope above the caller
# Usage: local varname [varname ...] && 
#        upvars [-v varname value] | [-aN varname [value ...]] ...
# Available OPTIONS:
#     -aN  Assign next N values to varname as array
#     -v   Assign single value to varname
# Return: 1 if error occurs
# Example:
#
#    f() { local a b; g a b; declare -p a b; }
#    g() {
#        local c=( foo bar )
#        local "$1" "$2" && upvars -v $1 A -a${#c[@]} $2 "${c[@]}"
#    }
#    f  # Ok: a=A, b=(foo bar)
#
upvars() {
    if ! (( $# )); then
        echo "${FUNCNAME[0]}: usage: ${FUNCNAME[0]} [-v varname"\
            "value] | [-aN varname [value ...]] ..." 1>&2
        return 2
    fi
    while (( $# )); do
        case $1 in
            -a*)
                # Error checking
                [[ ${1#-a} ]] || { echo "bash: ${FUNCNAME[0]}: \`$1': missing"\
                    "number specifier" 1>&2; return 1; }
                printf %d "${1#-a}" &> /dev/null || { echo "bash:"\
                    "${FUNCNAME[0]}: \`$1': invalid number specifier" 1>&2
                    return 1; }
                # Assign array of -aN elements
                [[ "$2" ]] && unset -v "$2" && eval $2=\(\"\${@:3:${1#-a}}\"\) && 
                shift $((${1#-a} + 2)) || { echo "bash: ${FUNCNAME[0]}:"\
                    "\`$1${2+ }$2': missing argument(s)" 1>&2; return 1; }
                ;;
            -v)
                # Assign single value
                [[ "$2" ]] && unset -v "$2" && eval $2=\"\$3\" &&
                shift 3 || { echo "bash: ${FUNCNAME[0]}: $1: missing"\
                "argument(s)" 1>&2; return 1; }
                ;;
            --help) echo "\
Usage: local varname [varname ...] &&
   ${FUNCNAME[0]} [-v varname value] | [-aN varname [value ...]] ...
Available OPTIONS:
-aN VARNAME [value ...]   assign next N values to varname as array
-v VARNAME value          assign single value to varname
--help                    display this help and exit
--version                 output version information and exit"
                return 0 ;;
            --version) echo "\
${FUNCNAME[0]}-0.9.dev
Copyright (C) 2010 Freddy Vulto
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law."
                return 0 ;;
            *)
                echo "bash: ${FUNCNAME[0]}: $1: invalid option" 1>&2
                return 1 ;;
        esac
    done
}
```

### 关于装饰器

在一个神奇的项目中，有人在`bash`中实现了类似[装饰器](https://github.com/vlisivka/bash-modules/blob/master/bash-modules/src/bash-modules/meta.sh)的效果。但是这样代码的可维护性反而不高，用处不大，暂时不去实现它，这里记录下。

`meta.sh`

```bash
##!/bin/bash
# Copyright (c) 2009-2021 Volodymyr M. Lisivka <vlisivka@gmail.com>, All Rights Reserved
# License: LGPL2+

#>> ## NAME
#>>
#>>> `meta` - functions for working with bash functions.

#>>
#>> ## FUNCTIONS

#>>
#>> * `meta::copy_function FUNCTION_NAME NEW_FUNCTION_PREFIX` - copy function to new function with prefix in name.
#>    Create copy of function with new prefix.
#>    Old function can be redefined or `unset -f`.
meta::copy_function() {
  local FUNCTION_NAME="$1"
  local PREFIX="$2"

  eval "$PREFIX$(declare -fp $FUNCTION_NAME)"
}

#>>
#>> * `meta::wrap BEFORE AFTER FUNCTION_NAME[...]` - wrap function.
#>    Create wrapper for a function(s). Execute given commands before and after
#>    each function. Original function is available as meta::orig_FUNCTION_NAME.
meta::wrap() {
  local BEFORE="$1"
  local AFTER="$2"
  shift 2

  local FUNCTION_NAME
  for FUNCTION_NAME in "$@"
  do
    # Rename original function
    meta::copy_function "$FUNCTION_NAME" "meta::orig_" || return 1

    # Redefine function
    eval "
function $FUNCTION_NAME() {
  $BEFORE

  local __meta__EXIT_CODE=0
  meta::orig_$FUNCTION_NAME \"\$@\" || __meta__EXIT_CODE=\$?

  $AFTER

  return \$__meta__EXIT_CODE
}
"
  done
}


#>>
#>> * `meta::functions_with_prefix PREFIX` - print list of functions with given prefix.
meta::functions_with_prefix() {
  compgen -A function "$1"
}

#>>
#>> * `meta::is_function FUNC_NAME` Checks is given name corresponds to a function.
meta::is_function() {
  declare -F "$1" >/dev/null
}

#>>
#>> * `meta::dispatch PREFIX COMMAND [ARGUMENTS...]` - execute function `PREFIX__COMMAND [ARGUMENTS]`
#>
#>    For example, it can be used to execute functions (commands) by name, e.g.
#> `main() { meta::dispatch command__ "$@" ; }`, when called as `man hw world` will execute
#> `command_hw "$world"`. When command handler is not found, dispatcher will try
#> to call `PREFIX__DEFAULT` function instead, or return error code when defaulf handler is not found.
meta::dispatch() {
  local prefix="${1:?Prefix is required.}"
  local command="${2:?Command is required.}"
  shift 2

  local fn="${prefix}${command}"

  # Is handler function exists?
  meta::is_function "$fn" || {
    # Is default handler function exists?
    meta::is_function "${prefix}__DEFAULT" || { echo "ERROR: Function \"$fn\" is not found." >&2; return 1; }
    fn="${prefix}__DEFAULT"
  }

  "$fn" "${@:+$@}" || return $?
}
```

### 关于@a操作符

可以先看下`atom_identify_data_type`的原始实现。

```bash
atom_identify_data_type ()
{
    case "${!1@a}" in
    *"$2"*) return 0 ;;
    '')     [[ "s" == "$2" ]] && return 0 ;;
    *)      return 1 ;;
    esac
}
```

这个实现有什么问题呢？

先看一个例子：

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/cntr# unset b
unset b
+ unset b
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/cntr# declare -A b
declare -A b
+ declare -A b
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/cntr# atom_identify_data_type b A
atom_identify_data_type b A
+ atom_identify_data_type b A
+ case "${!1@a}" in
+ [[ s == \A ]]
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/cntr# declare -A b=()
declare -A b=()
+ b=()
+ declare -A b
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/cntr# atom_identify_data_type b A
atom_identify_data_type b A
+ atom_identify_data_type b A
+ case "${!1@a}" in
+ return 0



root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/cntr# 
```

有一个BUG(使用declare或者local声明数组或者关联数组一定要附初始值，不然@a操作符配合!间接操作符无法识别到属性类别), 这个是否给bash的作用反馈下？使用@a操作符直接取变量属性是没问题的，所以函数做了变更,使用eval取原始变量名。

### 关于BASH_ARGV

bash 5.0+的 `shopt -s compat44`，然后`shopt -s extdebug`，就可以让`BASH_ARGV`存储当前函数的参数的反转，但是这个解释没有完全理解，暂时不在正式中实现。

备份的一个实现:

```bash
alias atom_func_reverse_params='shopt -q extdebug && set -- "${BASH_ARGV[@]}" || {shopt -s extdebug ; set -- "${BASH_ARGV[@]}" ; shopt -u extdebug ; }'
```


还有一些有趣的别名的调用方式，但是感觉并没有多大意义：

```bash
# 别名调试的方式
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/set# IFS= read -r -d '' xx <<'EOF'
eval -- eval -- 'eval -- '\''set -- \"\$\{{'$#'..1}\}\"'\'''
EOF
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/set# declare -p xx
declare -- xx="eval -- eval -- 'eval -- '\\''set -- \\\"\\\$\\{{'\$#'..1}\\}\\\"'\\'''
"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/set# 
```

另外，原始的复杂实现已经大大简化了。不需要嵌套那么多层了，备份下原始实现。

```bash
# alias atom_func_reverse_params="eval -- eval -- eval -- ''\\''set -- \\\"\\\$\\{{'\$#'..1}\\}\\\"'\\'''"
```
## 代码实现的备份

### atom_is_varname_valid

```bash
# global实现
atom_is_varname_valid () { [[ "$1" == +([a-zA-Z_])*([a-zA-Z0-9_]) ]] ; }
```

## 其它的一些想法但是没有实现

```bash
# :TODO: 可以给高阶函数传递多个数组函数，以及每个都可以正确带上自己的参数
# 诀窍是使用getopts,同一个字母的参数为一个函数的函数名或者参数
# 然后传递参数通过-a func_name1 -a 1 -a 2 -a 3 -b func_name2 -b 5 -b 5 -b 7这种方式区分不同函数的参数
# 可以弄一个公共的函数用于还原每个函数的参数即可
# 还有更简单的办法是使用q字符串把数组的declare -p展开打包,在函数中重新拆包即可。这样可以传递多个数组。
# my_func ()
# {
# 	local var
# 	local optind
# 	while getopts "a:b:c:" var ; do
# 		case "$var" in
# 			a)
# 				declare -p OPTIND
# 				declare -p OPTARG
# 				;;
# 			b)
# 				declare -p OPTIND
# 				declare -p OPTARG
# 				;;
# 			c)
# 				declare -p OPTIND
# 				declare -p OPTARG
# 				;;
# 		esac
# 	done
# }
# 
# mx=(-a "-b" -b "gege geg" -b "12345" -c "-c")
# 
# my_func "${mx[@]}"
# 
# 
# [root@localhost ~]# sh test.sh 
# declare -i OPTIND="3"
# declare -- OPTARG="-b"
# declare -i OPTIND="5"
# declare -- OPTARG="gege geg"
# declare -i OPTIND="7"
# declare -- OPTARG="12345"
# declare -i OPTIND="9"
# declare -- OPTARG="-c"
# [root@localhost ~]# 
```

目前看起来上面的建议并没有什么价值。

