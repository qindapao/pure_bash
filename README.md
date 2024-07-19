# pure_bash

bash是优美的，纯bash更优美，本项目尽量使用bash内置的功能来实现需求。当前某些情况下，也会使用少数强大的外部命令。

不使用递归实现，函数与函数之间不能嵌套调用。比如`A->B->C->A`是不允许的。

测试库脚本可以改变目录，但是在引用`source`后必须还原原始目录。正式函数脚本不允许改变工作目录。

并且引用库的脚本必须是`UTF-8`格式的，不允许非`UTF-8`格式的脚本引用本库的函数。会造成不可预期的问题。

由于使用了一些高级语法，bash的版本至少是:`4.4`.

## 如何使用这些库函数

```bash
IMPORT_FUNCS=(
    ./str/str_basename.sh
    ./str/str_contains.sh
)
for i in "${IMPORT_FUNCS[@]}" ; do . "$i" || exit 1 ; done
```

像上面这样，如果有任何的错误，都会退出脚本不会继续往下执行。函数中自己会处理依赖关系，如果拷贝漏掉了某些文件(或者是不知道某些函数还依赖别的函数，它自己会处理依赖关系，如果有问题，会报错，退出码不是0)，这里导出阶段就会退出，从而避免漏拷贝函数源文件的情况。

**这有什么好处呢？**

可以在使用中只放我们需要的函数，这样就不用降整个库拷贝到用户脚本中，节省了代码的空间和灵活性。同时也能最大化验证库的功能。没有无关的代码，代码检视的数据也会准确。

**copy_modules.sh**

这个脚本的目的是根据指定要使用模块拷贝关联模块，防止了手动拷贝的遗漏情况。

使用方法：

1. 编辑`copy_modules.cfg`文件，指定需要拷贝的模块，脚本会自动拷贝这些模块的相关关联模块。
2. 使用`bash copy_modules.sh`的方法来执行脚本，脚本执行完成后会生成`copy_modules`目录，我们需要的模块都在里面。

## 有用的链接

https://linuxstory.gitbook.io/advanced-bash-scripting-guide-in-chinese/zheng-wen/part1/01_shell_programming

https://github.com/gdbtek/linux-cookbooks/blob/main/libraries/aws.bash

https://github.com/NobodyXu/bash-loadables/tree/master

https://git.savannah.gnu.org/cgit/bash.git/

https://github.com/cjungmann/ate

https://github.com/644/ldnsbash/blob/main/ldnsbash.c

https://link.springer.com/book/10.1007/978-1-4842-9588-5

https://dokumen.pub/bash-it-out-strengthen-your-bash-knowledge-with-17-scripting-challenges-of-varied-difficulties-1521773262-9781521773260.html

https://blog.dario-hamidi.de/a/build-a-bash-builtin

https://github.com/cjungmann/bash_builtin

https://github.com/ayosec/timehistory-bash

https://www.programming-books.io/essential/bash/parallel-185b3ea3467c44148f4296480fe0a994#d980c5e6-5fc8-4275-88c1-5f26e2af50b7

https://devtut.github.io/bash/when-to-use-eval.html#using-eval


两个比较牛逼的bash库：

https://github.com/hornos/shf3
https://github.com/javier-lopez/learn



## bash特殊语法记录

### 常用操作

https://mywiki.wooledge.org/BashSheet

### bash常见的误用和陷阱

#### bash陷阱合集

https://mywiki.wooledge.org/BashPitfalls#A.5B.5B_-v_hash.5B.24key.5D_.5D.5D

#### 关于关联数组带变量下标做算数运算的坑

https://unix.stackexchange.com/questions/627474/how-to-use-associative-arrays-safely-inside-arithmetic-expressions

目前只有下面4种语法可以用于`bash5.2`和之前的bash版本：

- `let 'assoc[$var]++'`
- `assoc[$var]=$(( ${assoc[$var]} + 1 ))`
- `ref='assoc[$var]'; (( $ref++ ))`
- `@ormaaj bash wiki 中的技巧：(( assoc${-+[}\$var]++ ))`

其中比较魔幻的是最后一种方法，让我们来解释下：

在早期的bash版本中，`((assoc[\$var]++))`这种语法是可以起作用的，但是随着`bash5.2`
的发布，这种语法不再起作用。而是需要欺骗解释器。

`${-+[}`的含义是如果`-`已经设置，那么把表达式的值扩展为`[`，因为`-`必然是被设置的，
所以这个表达式被扩展为`[`，然后在和剩下的部分拼接形成：

```bash
((k[\$tmp_key]++))
```

所以用这个也可以: `(( assoc${#+[}\$var]++ ))`，只要是一个明确定义的变量都可以，这里
`${#}`是肯定会存在的变量。

不知道是出于什么原因，这阻止了`bash5.2`的进一步扩展。我想可能是因为`bash`解释器
第一眼看到这个表达式，并没有找到明显的`[]`边界，于是乎它不知道这是一个带关联数组下标
的算术表达式，然后扩展`${#+[`，这个时候才出现`[`，和后面的变量表达式一起扩展，
但是已经晚了，解释器误认为对算术表达式已经扩展完成。

所以，最安全的做法还是用：

`let 'assoc[$var]++'`，记得这里的单引号是一定需要的。只是下面这种一步到位的写法比较
爽，就是可读性真的是太糟糕了：

```bash
declare -A assoc
declare var='gge
geg()
xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)
'

if (( assoc${#+[}\$var]++ )) ; then
    echo "xx"
fi

declare -p assoc
if (( assoc${#+[}\$var]++ )) ; then
    echo "xx"
fi
declare -p assoc
```


`bash`的作者对于这个问题的回复：

https://lists.gnu.org/archive/html/bug-bash/2021-02/msg00189.html

按照作者的说法，以前使用单引号其实是不正确的，因为算术表达式其实是双引号扩展表达式，
所以现在不需要使用引号的`bash5.2`看起来是修复。似乎是解释器提前预处理了一些扩展，就不需要
使用引号了。

`bash5.2`的新解析器的稳定性需要等待时间来检验。另外，等待`bash5.3`正式发布后，这个
语法需要被 **重点测试**。如果非要用双圆括号来测试关联数组的值，可以用下面的形式：

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# tmp_x="${assoc[$var]}"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# if ((tmp_x)) ; then echo xx ; fi
xx
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# let 'assoc[$var]++'
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# declare -p assoc
declare -A assoc=([$'gge\ngeg()\nxxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)\n']="4" )
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# 
```

如上所示，使用一个中间变量来办到。

如果申明关联数组是一个整形数组，那么也可以像下面这样：

```bash
declare -iA assoc
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# assoc[$var]+=1
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# declare -p assoc
declare -Ai assoc=([$'gge\ngeg()\nxxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)\n']="6" )
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# assoc[$var]+=1
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# declare -p assoc
declare -Ai assoc=([$'gge\ngeg()\nxxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)\n']="7" )

```


### 关于bash的兼容级别

https://www.gnu.org/software/bash/manual/html_node/Shell-Compatibility-Mode.html

### 语句

#### case语句

```bash
case "$a" in
    (1) echo 'xx' ;;
    2)  echo 'yy' ;;
esac
```

在`case`语句中，使用`半括号`或者`全括号`都是可以的。


在 Bash 编程中，case 语句的结束符确实有三种：`;;`、`;&` 和 `;;&`。它们的用法和用途如下：

`;;`：这是最常用的结束符，它用于结束当前的 case 分支，不再测试后续的模式。例如：

```bash
case $variable in
pattern1)
# 如果 $variable 匹配 pattern1，执行这里的命令
;;
pattern2)
# 如果 $variable 匹配 pattern2，执行这里的命令
;;
esac
```

`;&`：这个结束符在 `Bash 4.0` 中引入，它允许当前的 `case` 分支执行完毕后，不进行新的模式匹配，直接执行下一个 `case` 分支的命令。例如：

```bash
case $variable in
pattern1)
# 如果 $variable 匹配 pattern1，执行这里的命令
;&
pattern2)
# 不管 $variable 是否匹配 pattern2，都会执行这里的命令
;;
esac
```

`;;&`：这个结束符也是在 `Bash 4.0` 中引入的，它允许在当前 `case` 分支执行完毕后，继续对后续的模式进行匹配测试。如果后续的模式匹配成功，那么相应的命令也会被执行。例如：

```bash
case $variable in
pattern1)
# 如果 $variable 匹配 pattern1，执行这里的命令
;;&
pattern2)
# 接着测试 $variable 是否匹配 pattern2，如果匹配，执行这里的命令
;;
esac
```

#### for循环

在`C`风格的`for循环`的双圆括号中是可以连续使用两个整形变量的。用逗号分隔语句即可。

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# for((i=0,j=1;i<4;i++,j++)) ; do
> echo $i $j
> done
0 1
1 2
2 3
3 4
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
```

`for in words`循环中可以省略`in words`，这个时候作用于每个位置参数。

```bash
test_case1 ()
{
    local a
    for a ; do
        echo "a:$a"
    done
}


test_case1 1 2 3 4
```


上面的`for`循环和

```bash
for a in "${@}" ; do
    echo "a:$a"
done
```

是等价的。

下面的用法比较危险，会受到扩展的影响：

```bash
Storage:~ # x='*-*'
Storage:~ # IFS='-'
Storage:~ # for i in $x ; do echo "$i"; done
03026KLP_parameter.txt
03033ECX_parameter.txt
03033MSB_parameter.txt
06010397_parameter.txt
06411241_parameter.txt
```


#### if条件判断

##### 可以把赋值语句写到条件判断中

由于赋值语句没有返回值，所以我们可以这样写：

```bash
root@DESKTOP-0KALMAH:~# if a=$(cat xx.txt) ; then
> echo success
> fi
cat: xx.txt: No such file or directory
root@DESKTOP-0KALMAH:~# touch xx.txt
root@DESKTOP-0KALMAH:~# if a=$(cat xx.txt) ; then echo success; fi
success
root@DESKTOP-0KALMAH:~# 
```

注意：上面这种写法是有限制的，一定要确定`$()`里面的命令执行失败返回非0，有管道符的情况下要特别小心。

```bash
q00546874@DESKTOP-0KALMAH ~
$ grep xxyy xx.txt | sed -n '1p'
grep: xx.txt: No such file or directory

q00546874@DESKTOP-0KALMAH ~
$ echo $?
0

q00546874@DESKTOP-0KALMAH ~
$ 
```
#### 逻辑判断链

逻辑判断链的表现行为和`if else`块并不一样，看一个例子：

```bash
local a=1
((a)) && {
    echo 'this not happan'
    echo '2' | grep 2
    echo '3' | grep 2
    echo '' | grep 2
} || {
    echo "this happan"
}
```


最终的打印结果如下：

```bash
this not happan
2
this happan
```

这里为什么`&&`里面的分支和`||`里面的分支都走到了呢？

是因为这是按照链条顺序执行的，和`if...else`是不同的。

1. `((a))`为真，然后执行第一个大括号中的语句，大括号的总返回值是它执行的最后一个语句的返回值。这里是`echo '' | grep 2`
2. 由于这个语句的返回值是假的，所以当前整个大括号的返回值为假，所以执行了后面的`||`中的语句。
3. 很明显这和`if...else`的控制逻辑并不相同。也就是说和下面的语句 **不等价**。

```bash
a=1
if ((a)) ; then
    echo 'this not happan'
    echo '2' | grep 2
    echo '3' | grep 2
    echo '' | grep 2
else
    echo "this happan"
fi
```

对于在`if...else`块中的复合命令判断，规则也是一样,`{...}`复合命令的总的退出码是以
最后一个命令的退出码为准，而不是任意的命令失败都失败。可以看下面的代码：

```bash
if {
    echo '1' | grep '2'
    echo '1' | grep '2'
    echo '1' | grep '2'
    echo '2' | grep '2'
} ; then
    echo "if pass"
else
    echo "if fail"
fi
```

最终会打印`pass`。因为`{...}`中的最后一个命令是返回成功的。



还可以有下面用法，赋值语句中的返回值是命令替换中的返回值。

```bash
a="$(cat 1.txt)" && echo xx
```

另外一个比较复杂的例子：

```bash
((0)) && {
        ((0)) || echo 1
    } || echo 0
```

在 Bash 中，&& 和 || 是逻辑控制运算符，它们通常用于根据前一个命令的退出状态来决定是否执行下一个命令。

&& 运算符表示“逻辑与”，它后面的命令只有在前一个命令成功执行（即退出状态为0）时才会执行。
|| 运算符表示“逻辑或”，它后面的命令只有在前一个命令失败执行（即退出状态非0）时才会执行。
让我们来详细解释您提供的代码段：

```bash
((0)) && {
    ((0)) || echo 1
} || echo 0
```

((0))：这是一个算术表达式，用于评估0。在 Bash 中，0通常表示“假”，因此这个表达式的退出状态为非0（失败）。
((0)) && { ... }：因为第一个 ((0)) 的退出状态为非0，所以 && 后面的代码块 { ... } 不会被执行。
{ ... } || echo 0：由于 && 后面的代码块没有被执行，所以 || 后面的 echo 0 将会被执行，打印出0。
现在，如果 && 后面的代码块被执行了，它会如何工作呢？

((0)) || echo 1：这里，((0)) 同样会失败，因为它的值是0（假）。所以 || 后面的 echo 1 会被执行，打印出1。
如果 { ... } 代码块中的 echo 1 被执行了，那么整个 { ... } 代码块的退出状态将是0（
因为 echo 命令成功执行），这将阻止 || echo 0 被执行。
总结一下，您的代码段将只打印出0，因为第一个 ((0)) 表达式失败了，导致 && 后面的代
码块不会执行，然后 || 后面的 echo 0 将会执行。希望这能帮助您理解 Bash 中 && 和 || 的逻辑。


如果修改成下面这样，情况又不同：

```bash
((1)) && {
        ((0)) || echo 1
    } || echo 0
```

让我们逐步分析执行逻辑：

((1))：这是一个算术表达式，用于评估1。在 Bash 中，任何非零值通常表示“真”，因此这个表达式的退出状态为0（成功）。
((1)) && { ... }：因为第一个 ((1)) 的退出状态为0（成功），所以 && 后面的代码块 { ... } 会被执行。
((0)) || echo 1：在代码块内部，((0)) 表达式失败（因为它的值是0，表示“假”），所以 || 后面的 echo 1 会被执行，打印出1。
{ ... } || echo 0：由于 { ... } 代码块内的 echo 1 被执行了，整个 { ... } 代码块的退出状态将是0
（因为 echo 命令成功执行）。这意味着 { ... } 代码块被认为是成功的，所以 || echo 0 不会被执行。

因此，echo 0 没有执行是因为 { ... } 代码块已经成功执行了（即使它包含了一个失败的表达式 ((0))），
并且 echo 1 已经被打印出来。在 Bash 中，只有当前一个命令或代码块失败时（即退出状态非0），|| 后面的命令才会执行。

希望这能清楚地解释了您的问题。如果您还有其他疑问，或者需要更多帮助，请随时告诉我！

大括号内的
 ((0)) || echo 1

在 Bash 中，大括号 {} 内的命令组成了一个代码块，这个代码块内部的命令是独立的。
即使这个代码块被包含在 && 或 || 的逻辑中，代码块内部的 && 和 || 仍然只控制它们直接相关的命令。


```bash
((0)) || echo 1
```

这个表达式是独立的，它不会受到外面的 && 或 || 的影响。如果 ((0)) 计算结果为假
（在 Bash 中，0 表示假），那么 echo 1 将会执行。这个行为只依赖于 ((0)) 的结果，与外部的逻辑没有关系。

所以，即使这个代码块是作为一个更大的逻辑表达式的一部分（如 && { ... } || echo 0），
代码块内的命令仍然只根据它们自己的逻辑来执行。希望这能帮助您更好地理解 Bash 中的逻辑控制。




### 参数

`bash`的命令行参数是有最大值的，一般由系统的`ARG_MAX`参数决定。一般是`2M`。所以在有大数据的场景下执行`bash`代码要特别小心，使用`xargs`之类的工具来处理。

但是`bash`内部的一些操作，比如数组`a=("${b[@]}")`类似的语法是在内存中处理的，并不受命令行参数的影响。要搞清楚哪些是在操作命令行参数，哪些是语言内置的功能(这些都是在内存中处理)。

### 变量

#### 多个变量初始化成一个值

可以利用大括号功能这样写:

```bash
declare {x,y,z}=''
```

#### 间接引用

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/nfor# unset -n a b c
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/nfor# a=b
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/nfor# declare -n b=c
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/nfor# c=xxoo
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/nfor# echo ${!a}
xxoo
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/nfor# declare -p a b c
declare -- a="b"
declare -n b="c"
declare -- c="xxoo"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/nfor# 
```


上面的例子是间接引用和`${!var}`取值嵌套的情况，会找到真正的变量。

有一个讨论页面讲得比较深入：https://mywiki.wooledge.org/BashFAQ/006

#### 检查变量是否设置的另外一种方法

```bash
$ echo ${x1y1+set}


q00546874@DESKTOP-0KALMAH ~
$ x1y1=''

q00546874@DESKTOP-0KALMAH ~
$ echo ${x1y1+set}
set

q00546874@DESKTOP-0KALMAH ~
$ 
```

最简单的方法是使用`-v`操作符，还有一种方法是上面那样，如果变量设置，返回set字符串，否则为空。注意这里判断变量是否设置，并不是判断变量为空。

数组的索引也可以这么判断：

```bash
q00546874@DESKTOP-0KALMAH ~
$ a=(1 2 3 '' '')

q00546874@DESKTOP-0KALMAH ~
$ echo ${a[4]+set}
set

q00546874@DESKTOP-0KALMAH ~
$ 
```





#### 在函数中定义一个和全局变量同名的局部变量

比如：

```bash
func1 ()
{
    local IFS='-'
    ... ...
}
```

**注意：**： 这种用法还是有一定的危险性，因为我们当前的函数可能还会调用下级函数，那么
这样修改后，下级函数的`IFS`也会继承这个局部变量，那么可能会造成问题，慎用。还有个
问题是如果这里 `unset IFS`会造成变量悬空，并不会删除变量。如果对变量的打印有要求的时候要注意。




#### 变量的前缀展开

在 Bash 编程中，可以使用 ${!prefix@} 或 ${!prefix*} 来展开所有以特定前缀开头的变
量名。这可以用来模拟多维数据结构，尤其是在 Bash 中没有真正的多维数组的情况下。这
两种展开方式的区别在于：

- `${!prefix@}` 展开为一个由空格分隔的列表，每个元素都是一个独立的单词。
- `${!prefix*}` 展开为一个单一的长字符串，其中所有的变量名都由第一个 `IFS` 变量的第一个字符连接起来（默认是空格）。


上面的代码中，函数内部的`IFS`替换了全局变量`IFS`(字段分隔符)，这使得在函数内部，字
段分隔符用局部变量定义的，但是出了函数，分隔符会恢复到全局，我们不用手动恢复。

模拟多维数组，可以定义很多以数字结尾的变量，作为数组的第一级，然后每个变量本身是
一个数组。当然大部分的情况下，使用关联数组来模拟更加自然：

```bash
declare -A data
data["1,1"]="value11"
data["1,2"]="value12"
data["2,1"]="value21"
data["2,2"]="value22"
```

#### 默认值

##### 一种方便的求默认值方法

```bash
    : ${ALL_CTRL_NUM=$(get_ctrl_num)}
```

表示变量如果没有定义，就使用函数求默认值。如果上面是：

```bash
    : ${ALL_CTRL_NUM:=$(get_ctrl_num)}
```

那么表示变量未定义或者为空的情况。


##### 可以为变量嵌套赋默认值

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# : ${mxx:=${mxb:=${mxc:=5}}}
+ : 5
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# declare -p mxx mxb mxc
+ declare -p mxx mxb mxc
declare -- mxx="5"
declare -- mxb="5"
declare -- mxc="5"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# 
```

一种更有用的可能用法：

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# : ${mxx:=ax${mxb:=bx${mxc:=5}}}
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# declare -p mxx mxb mxc
declare -- mxx="axbx5"
declare -- mxb="bx5"
declare -- mxc="5"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# 
```

注意，有`:`和没有`:`的情况是不同的

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# unset mxx
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# : ${mxx:=2}
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# declare -p mxx
declare -- mxx="2"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# mxx=''
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# : ${mxx:=2}
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# declare -p mxx
declare -- mxx="2"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# mxx=''
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# : ${mxx=2}
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# declare -p mxx
declare -- mxx=""
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# unset mxx
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# : ${mxx=2}
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# declare -p mxx
declare -- mxx="2"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# 
```

如果有`:`，比如`${mxx:=2}`会检查`mxx`定义并且非空，但是如果没有`:`，就只会检查
`mxx`是否定义。这个情况同样适用于另外几个扩展，比如`+`、`-`，`?`。


#### 内置变量

##### PIPESTATUS

`PIPESTATUS`是一个数组，它包含了最近执行的管道（pipeline）中每个命令的退出状态码。
这个数组的每个元素对应于管道中相应命令的返回值。

例如，如果有一个由多个命令组成的管道：

`
command1 | command2 | command3
`

执行完毕后，`PIPESTATUS`数组将会包含三个元素，分别是`command1`、`command2`和`command3`的
退出状态码。可以通过`echo ${PIPESTATUS[@]}`来查看所有的返回值。

这是一个非常有用的特性，因为它允许你检查管道中每个命令的成功与否，而不仅仅是最后
一个命令的返回值。这在调试复杂的管道命令时特别有帮助。

##### BASH_XTRACEFD

`BASH_XTRACEFD`变量允许你将`shell`的跟踪输出（由`set -x`命令启用）重定向到一个指
定的文件描述符。默认情况下，跟踪输出是发送到标准错误（STDERR），即文件描述符2。

当你设置了`BASH_XTRACEFD`变量为一个有效的文件描述符后，所有的跟踪信息将会被写入
到这个文件描述符对应的文件或设备中，而不是标准错误。这使得你可以将调试信息发送到
一个日志文件或其他处理流程，而不会干扰脚本的正常输出。

例如，如果你想将跟踪输出重定向到文件描述符`3`，你可以这样做：

```bash
exec 3>trace.log
BASH_XTRACEFD=3
set -x
你的脚本命令
```

这段代码会将所有跟踪输出重定向到`trace.log`文件中。当你不再需要跟踪输出时，可以
通过取消设置`BASH_XTRACEFD`变量或将其设置为空字符串来恢复默认行为，即将跟踪输出
发送到标准错误。

注意：如果你设置了`BASH_XTRACEFD`为一个文件描述符，然后取消设置它或将其关闭，那
么对应的文件描述符也会被关闭。因此，在使用BASH_XTRACEFD时需要小心，以避免意外关
闭重要的文件描述符


##### BASH_SUBSHELL

在Bash中，`BASH_SUBSHELL`变量用来表示当前shell环境的嵌套级别。每当`Bash`创建一个
子`shell`环境时，`BASH_SUBSHELL`的值就会增加。这通常发生在执行脚本、命令替换、后
台命令、以及子shell（使用括号()创建）时。

例如，当你在一个Bash脚本中使用括号创建一个子shell来执行一些命令时，BASH_SUBSHELL
的值会在子shell中增加。这个变量在父shell中的值不会改变，因为每个子shell都是独立的。

这里有一个简单的例子来演示BASH_SUBSHELL的用法：

```bash
echo "在父shell中 BASH_SUBSHELL = $BASH_SUBSHELL"
( # 开始一个子shell
echo "在子shell中 BASH_SUBSHELL = $BASH_SUBSHELL"
)
```

在这个例子中，父shell中的BASH_SUBSHELL值通常是0，而在子shell中，它会增加1。如果
你在子shell中再创建一个子shell，那么BASH_SUBSHELL会继续增加。

BASH_SUBSHELL变量对于理解和调试涉及多层嵌套的复杂脚本非常有用。它可以帮助你跟踪
当前代码执行的上下文，特别是当你需要确定某些操作是在主shell环境中执行还是在子
shell环境中执行时。


##### BASH_LOADABLES_PATH

**重要!**: 因为这可以通过C扩展`bash`的功能。

在Bash中，BASH_LOADABLES_PATH变量定义了一个冒号分隔的目录路径列表。这些路径是Bash
内置命令enable用来搜索可加载内置命令（loadable builtins）的位置。当你使用enable命
令来启用或禁用内置命令时，Bash会在BASH_LOADABLES_PATH指定的目录中查找相应的可加载
内置命令。

可加载内置命令是一种特殊的内置命令，它们不是Bash默认提供的，而是作为共享对象文件
存在，可以在运行时加载到Bash中。这允许你扩展Bash的功能，而无需修改和重新编译Bash本身。

例如，如果你有一个自定义的内置命令实现在~/.bash_builtins目录中，你可以这样设置BASH_LOADABLES_PATH：

export BASH_LOADABLES_PATH=~/.bash_builtins

然后，你可以使用enable命令来启用或禁用该目录中的可加载内置命令。

注意：BASH_LOADABLES_PATH变量通常在Bash的高级用法中使用

当然可以。在Bash中，可加载内置命令（loadable builtins）是一种可以在运行时动态加
载到Bash环境中的命令。这些命令不是Bash默认提供的，而是作为共享库（通常是.so文件）
存在。这样做的好处是可以扩展Bash的功能，而无需修改Bash的源代码或重新编译整个shell。

BASH_LOADABLES_PATH环境变量就是用来指定这些共享库所在的目录。当你使用enable命令
尝试启用一个可加载内置命令时，Bash会在BASH_LOADABLES_PATH指定的目录列表中搜索对应
的共享库文件。

这里是一个如何使用BASH_LOADABLES_PATH和可加载内置命令的例子：

设置BASH_LOADABLES_PATH: 首先，你需要设置BASH_LOADABLES_PATH环境变量，让它包含你
的可加载内置命令的目录。例如：
export BASH_LOADABLES_PATH=/usr/local/lib/bash

启用可加载内置命令: 使用enable命令来启用一个特定的可加载内置命令。例如，如果你有
一个名为mycmd的可加载命令：
enable -f mycmd.so mycmd

使用命令: 一旦启用，你就可以像使用其他任何Bash内置命令一样使用你的可加载命令了。
创建可加载内置命令: 要创建一个可加载内置命令，你需要编写C语言代码，然后将其编译
为共享库。Bash源代码提供了一些示例和必要的基础设施来帮助你开始。这里是一个非常简单的示例：

```bash
#include <stdio.h>
#include <bash/builtins.h>

int example_builtin(WORD_LIST *list) {
    printf("Hello from a loadable builtin!\n");
    return EXECUTION_SUCCESS;
}

char *example_doc[] = {
    "A simple example of a loadable builtin.",
    (char *)NULL
};

struct builtin example_struct = {
    "example",       // Builtin name
    example_builtin, // Function implementing the builtin
    BUILTIN_ENABLED, // Initial flags for this builtin
    example_doc,     // Array of strings documenting the builtin
    0                // Reserved for internal use
};

int example_builtin_load(char *name) {
    return add_builtin(&example_struct);
}

int example_builtin_unload(char *name) {
    return remove_builtin(&example_struct);
}
```

这段代码定义了一个名为example的新内置命令，当你在Bash中调用它时，它会打印一条消
息。你需要将这段代码编译为.so文件，并确保它位于BASH_LOADABLES_PATH指定的目录中。

注意：创建可加载内置命令需要对Bash内部结构和C语言有一定的了解。如果你是Bash的高级
用户或者有兴趣深入了解Bash的扩展机制，这将是一个有趣的项目。如果你需要更多的帮助
或有其他问题，请随时告诉我！


##### BASH_COMMAND

BASH_COMMAND 是一个特殊的 Bash 变量，它保存了当前正在执行的 shell 命令或者 shell
脚本中的命令。这个变量通常在调试时非常有用，因为它可以帮助你了解在执行时发生了什么。

例如，你可以在一个 trap 调试语句中使用 BASH_COMMAND 来打印出在脚本执行过程中每个
命令之前和之后的实际命令：

```bash
trap 'echo "Executing: $BASH_COMMAND"' DEBUG
```

每当脚本执行一个命令时，上面的 trap 语句都会输出那个命令。这对于跟踪脚本的执行流
程非常有帮助。

此外，BASH_COMMAND 变量在错误处理中也很有用。你可以在一个错误 trap 中使用它来确定
脚本失败的位置：

```bash
trap 'echo "Last command executed: $BASH_COMMAND"' ERR
```

如果脚本中的任何命令失败，上面的 trap 语句会输出导致错误的命令。这可以帮助你快速
定位问题所在。

总的来说，BASH_COMMAND 是一个用于调试和错误处理的强大工具，可以帮助你更好地理解
和控制你的 Bash 脚本。

##### BASH_CMDS

BASH_CMDS 是 Bash 中的一个关联数组变量，它包含了由 hash 内建命令创建的命令列表。
这个变量通常用于存储和查找命令的路径，以便加快命令的执行速度。

当你使用 hash 命令时，Bash 会记住每个命令的路径，并将这些信息存储在 BASH_CMDS 
关联数组中。这样，当你再次执行相同的命令时，Bash 可以直接从 BASH_CMDS 中查找命令
的路径，而不需要再次搜索文件系统。

例如，如果你执行了 ls 命令，Bash 会在 BASH_CMDS 中存储 ls 命令的路径。下次当你再
次执行 ls 时，Bash 就可以快速地从 BASH_CMDS 中找到 ls 的路径。

你可以通过直接向 BASH_CMDS 添加元素来更新哈希表。但是，如果你使用 unset 命令取消
设置 BASH_CMDS，它将失去其特殊属性1。

这里有一个简单的例子，展示了如何查看 BASH_CMDS 中的内容：

```bash
 # 查看BASH_CMDS中的内容
declare -p BASH_CMDS
```

这将输出 `BASH_CMDS` 关联数组中当前存储的所有命令及其对应的路径。

##### BASH_ALIASES

一个关联数组，保存当前`shell`环境中的别名和对应的值。

#### 变量替换

常用的就不提了，这里有两个不常用的：

${var/#pat/repl} Use value of var, with match of pat replaced with repl.
Match must occur at the beginning of the value.

${var/%pat/repl} Use value of var, with match of pat replaced with repl.
Match must occur at the end of the value.


### 变量修饰

#### K修饰符

```bash
[root@localhost ~]# eval x9=("${dict[@]@K}")
[root@localhost ~]# declare -p dict
declare -A dict=(["74g \\zx"]="dge2" [xyz]="233" )
[root@localhost ~]# declare -p x9
declare -a x9=([0]="74g \\zx" [1]="dge2" [2]="xyz" [3]="233")
[root@localhost ~]# 
```

见上面的`K`修饰符和`eval`的配套使用，可以把数组的键值对变成普通数组。然后可以使用printf配对打印。

```bash
[root@localhost ~]# printf "%-10s =>%s\n" "${x9[@]}"
74g \zx    =>dge2
xyz        =>233
[root@localhost ~]# 
```

这样打印字典的树状图会比较方便。但是这样打印出来的变量可能定位不是很方便，因为它把所有的转义字符都解释了。

#### E修饰符和Q修饰符

`E`变量修饰符目前我没看出来有什么实际的作用，`Q`变量修饰符的的作用挺大。

```bash
[root@localhost ~]# printf "%s" ${yy1@E}
74g\zx=>dge2xyz=>233[root@localhost ~]# printf "%s" "${yy1@E}"
74g \zx    =>dge2
xyz        =>233[root@localhost ~]# printf "%s" "${yy1@Q}"
$'74g \\zx    =>dge2\nxyz        =>233'[root@localhost ~]# 
```

`E`修饰符会解码转义序列，`Q`修饰符用引号包裹变量，会对其中的特殊字符进行转义，所以在打印树状变量的值定位问题的情况下，明显用这个更好(主要不要重新赋值，直接用这个修饰符打印变量即可，这样一个变量永远只打印一行)。


如果知道`Q`修饰符的字符串，如何得到原始的字符串？

我们可以通过`eval`命令来实现。

```bash
[root@localhost ~]# declare -p a
declare -- a="
1233"
[root@localhost ~]# b=${a@Q}
[root@localhost ~]# declare -p b
declare -- b="\$'\\n1233'"
[root@localhost ~]# eval "c=$b"
[root@localhost ~]# declare -p c
declare -- c="
1233"
[root@localhost ~]# 

[root@localhost ~]# declare -p a
declare -- a="
1233"
[root@localhost ~]# b="${a@Q}"
[root@localhost ~]# declare -p b
declare -- b="\$'\\n1233'"
[root@localhost ~]# eval "c=$b"
[root@localhost ~]# declare -p c
declare -- c="
1233"
[root@localhost ~]# 
```

这里的`eval`用法是安全的，并且上面`b=${a@Q}`加双引号和不加都没有关系，因为`${a@Q}`已经是引号包裹的字符串了。

如果没有`bash4.4`，那么可以使用`printf`命令达到一样的效果。

```bash
[root@localhost ~]# declare -p b
declare -- b="\$'\\n1233'"
[root@localhost ~]# printf -v b "%q" "$a"
[root@localhost ~]# declare -p b
declare -- b="\$'\\n1233'"
[root@localhost ~]# 
[root@localhost ~]# printf "%s" "$b"
$'\n1233'[root@localhost ~]# 
```

实际上使用`printf`可能更好!

bash5.2的printf增加了`%Q`的格式化选项，具体的用法还没有研究清楚。

### 算数扩展

#### 双圆括号

```bash
((128<$1&&(ret=4)))
```

从上面例子可以看到，双圆括号中也可以有`&&`逻辑运算符，注意，这里是逻辑运算符，并不是位运算符。

```bash
((ret+=w,i+=extend))
```

逗号表达式的含义是一次执行多条命令。

双圆括号中的变量名可以带变量：

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# a1=1
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# a2=3
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# i=1
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# j=2
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# ((a${i}=4))
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# echo $a1
4
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
```



#### 三目运算符

三目运算符的嵌套还挺有意思

```bash
## @fn ble/encoding:UTF-8/c2b char
##   @arr[out] bytes
function ble/encoding:UTF-8/c2b {
  local code=$1 n i
  ((code=code&0x7FFFFFFF,
    n=code<0x80?0:(
      code<0x800?1:(
        code<0x10000?2:(
          code<0x200000?3:(
            code<0x4000000?4:5))))))
  if ((n==0)); then
    bytes=("$code")
  else
    bytes=()
    for ((i=n;i;i--)); do
      ((bytes[i]=0x80|code&0x3F,
        code>>=6))
    done
    ((bytes[0]=code&0x3F>>n|0xFF80>>n&0xFF))
  fi
}
```

看上面例子中的用法。

### 条件判断

#### if判断多条语句返回值

```bash
if local xx=yy ; [[ "$xx" == yy ]] ; then
echo xx
fi
```

在 Bash 中，if 语句后面可以跟多条语句，这是因为 Bash 支持命令组合。

在这个例子中，`local xx=yy ; [[ "$xx" == yy ]]` 是两条命令。这两条命令被 ; 分隔开，
所以它们会依次执行。只有当所有命令都成功执行（即返回值为0），if 语句才会认为条件满足。

这种结构允许你在 if 语句的条件部分执行多个操作，然后基于这些操作的结果来决定是否执行 then 部分的代码。

所以，代码 `if local xx=yy ; [[ "$xx" == yy ]] ; then echo xx fi` 的含义是：
如果 `local xx=yy` 和 `[[ "$xx" == yy ]]` 这两条命令都成功执行，那么就打印 `xx`。
否则，不执行任何操作。

### 函数

#### 设计命令的封装函数

大部分的`linux`文本处理命令，都可以同时处理标准输入和具体的文件，可以把这些命令
封装，然后设计和命令相同工作模式的函数

```bash
file_del_end_blank_lines () 
{ 
    sed '{
        :start
        /^[[:space:]]*$/{$d ; N ; b start }
    }'
} < "${1:-/dev/stdin}"
```

这个函数的使用方法有两种:

```bash
cat other.txt  | file_del_end_blank_lines
file_del_end_blank_lines other.txt
```

唯一的缺点是无法直接修改文件，我们可以重新封装函数，直接处理传入的文件名，而不是
重定向它的内容。

当然，上面的命令封装函数可以使用别名(alias)来实现，这里只是提供函数实现的一种思路。



#### 函数的返回值

如果函数执行到最后没有`return`语句，那么默认使用最后执行的一条语句的命令的返回值。

比如:

```bash
func1 ()
{
    ... ...
    ((${#xx[@]}))
}
```

上面范例的含义是：如果数组为空，返回假，否则返回真。具体返回的数值，可以实际测试下。

#### 设计返回多个值的函数

##### 思路一 利用Q字符串不换行的能力

可以利用`@Q`的变量修饰符，或者是`printf "%q"`的功能，会对变量进行转义，输出中就不会有换行符。我们就可以
人为添加换行符，从而实现打印返回多个函数值的目的。然后我们对返回的多个值，通过换行符作为分隔符取出来，
保存到数组中或者其它方式。然后再使用`eval`对字符串进行还原就得到了原始字符串。

请看下面的例子演示了这种思想，可以通过这种方式让函数打印多个值，每个值用换行安全分隔。

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# a="geg
geg
111"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# b=$(printf "%q" "$a")
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p b
declare -- b="\$'geg\\ngeg\\n111'"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# eval "c=$b"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p c
declare -- c="geg
geg
111"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# b=${a@Q}
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p b
declare -- b="\$'geg\\ngeg\\n111'"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# b="${a@Q}"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p b
declare -- b="\$'geg\\ngeg\\n111'"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
```

##### 思路二 直接通过字符串重构数组或者关联数组

```bash
my_func ()
{
    local -a xx=("1223 " "dggeg" "
    ggeg
    gege
    " 5 6 "8 9")
    str_pack xx
}

test_str_pack ()
{
    eval local -a yy="$(my_func)"

    declare -p yy
}
```

参考上面的例子，通过库里面的`str_pack`函数可以通过进程替换得到数组，相当于通过函数打印了数组。比使用间接引用的可读性更好。


目前发现，使用`printf "%q"`和`Q`修饰符的时候，加不加双引号都没关系。

#### 在函数内部定义另外的函数

在函数里面定义另外一个函数是可以的，但是这些内部函数，其实在外部也是可用的。

```bash
test_big_cmd_param_process ()
{
    # 内部函数在外部也是可见的，只是每次进test_big_cmd_param_process会被重新定义一次
    test_case ()
    {
        local my_big_str=("${@}")
        str_pack my_big_str 
    }

    local i
    local -a tmp_str=()

    # 生成一个105M的超大数组
    date
    for((i=0;i<1000000;i++)) ; do
        tmp_str+=("i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.")
    done
    date

    get_str=$(test_case "${tmp_str[@]}")
    echo "get_str length:${#get_str}"
}
```

比如上面的`test_case`函数，其实在外部也可以访问，之所有在函数里面执行它是安全的(就算外面有同名的函数)。因为每次进入`test_big_cmd_param_process`，`test_acse`函数都会被重新定义。

但是，如果是内部函数就尽量定义在函数内部，外部的顶层函数的名字不要和它冲突。不然会覆盖外部的
顶层函数的定义。

#### 在函数内部避免命名冲突

在间接引用或者是使用`eval`的情况下，有时候为了避免命名冲突，会用到一些妙招。比如下面这样：

```bash
array_copy ()
{
    local _array_copy_script='
        '$1'=()
        local i'$1$2'
        for i'$1$2' in "${!'$2'[@]}"; do
          '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
        done'
    eval -- "$_array_copy_script"
}
```


上面的函数中，局部变量`i$1$2`包含两个数组的名字，就保证了它的名字不可能和数组中的
任何一个名字冲突。如果是使用`declare -n`或者`local -n`这种方式的话，就只能在函数
中命名引用变量的时候注意，并且函数内的局部变量的命名也不能和传入的变量名相同。可以
使用`_函数名_`类似的变量前缀命名法。不过始终还是不能完全完美。所以小函数，使用`eval`
反而是安全可靠的方法。

### 内置命令

#### bash命令执行的优先级

保留关键字 -> 别名 -> 函数 -> 内置命令 -> 外部命令或者脚本 -> command_not_found_handle 函数

#### eval 

##### bash执行命令的步骤和eval的原理

参考链接：https://unix.stackexchange.com/questions/23111/what-is-the-eval-command-in-bash

标准链接：https://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html

安全使用eval的原则：https://mywiki.wooledge.org/BashFAQ/048

##### 使用eval在函数中安全返回一个值

```bash
   1 # POSIX
   2 
   3 f() {
   4     # Code goes here that eventually sets the variable "x".
   5     # x=foo
   6 
   7     # Check that the referenced variable name is not empty.  Validating
   8     # it as a valid identifier is left as an exercise for the reader.
   9     if [ -z "$1" ]; then
  10         return 1
  11     fi
  12 
  13     eval "${1}=\$x"
  14 }
```


##### 如何调试一个带eval的代码

可以利用`set -x`让代码展开，就能看到执行过程

```bash
$ array_copy ()
> {
>     local _array_copy_script='
>         '$1'=()
>         local i'$1$2'
>         for i'$1$2' in "${!'$2'[@]}"; do
>           '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
>         done'
>     eval -- "$_array_copy_script"
> }

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ a=()

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ b=(1 2 3 4)

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ array_copy a b

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ declare -p a
declare -a a=([0]="1" [1]="2" [2]="3" [3]="4")

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ set -x

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ array_copy a b
+ array_copy a b
+ local '_array_copy_script=
        a=()
        local iab
        for iab in "${!b[@]}"; do
          a["${iab}"]="${b["${iab}"]}"
        done'
+ eval -- '
        a=()
        local iab
        for iab in "${!b[@]}"; do
          a["${iab}"]="${b["${iab}"]}"
        done'
++ a=()
++ local iab
++ for iab in "${!b[@]}"
++ a["${iab}"]=1
++ for iab in "${!b[@]}"
++ a["${iab}"]=2
++ for iab in "${!b[@]}"
++ a["${iab}"]=3
++ for iab in "${!b[@]}"
++ a["${iab}"]=4

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ 
```

如上面所示，可以完整看到经过`eval`展开后的代码。

##### 使用eval执行一个命令

使用`eval`执行一个命令的安全的方式

```bash
eval -- "$value"
```

在 Bash 中，`eval -- "$value"` 这种形式的命令中，`--` 是一个常见的 Unix 风格的命
令行选项，它表示后面的参数不应被解析为选项。

在例子中，`--` 确保了 `"$value"` 被当作参数，而不是选项。这在 `"$value"` 可能以
短杠 `-` 开头时特别有用，因为在那种情况下，如果没有 `--`，`"$value"` 可能会被误
解析为一个选项。

所以，`eval -- "$value"` 的含义是：执行 `"$value"` 中的命令，即使 `"$value"` 
以短杠 `-` 开头。

这在不确定要执行的字符串以什么开头时特别重要，如果确定字符串不可能以`-`开头，那么
不加也是可以的。


##### eval和for循环的配套使用

```bash
q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ x=1

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ y=4

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ eval "for i in {$x..$y} ; do echo \$i ; done"
1
2
3
4

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ 
```

上面是eval和参数扩展还有for循环的结合，但是还是比较危险，谨慎使用。

更极端的例子：

```bash
test_case1 ()
{
    local x=0 y=4
    local for_loop='
    for i in {'$x'..'$y'} ; do
        echo "$i"
    done
    '
    eval -- "$for_loop"
}

test_case1
```

当然一般情况下是不推荐这么写的，除非有明显的好处。只是展示下`eval`命令提供了无限的
可能，不过这个命令是把双刃剑，有命令注入的风险，具体取舍就看情况而定了。


#### unset

先看一个例子

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -A k=(["(xx:yy)"]="6" ["xxx->xxx->xxx->xx:xx.x-/dev/fd/61-/dev/fd/60"]="1" ["xxx xxx->xxx->xxx->xx:xx.x-/dev/fd/61-/dev/fd/60"]="1" ["xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"]="2" )
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# cnt=0
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# tmp_key=("xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)")
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# if [[ -v 'k[${tmp_key[cnt]}]' ]] ; then echo xx; fi
xx
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# if [[ -v 'k["${tmp_key[cnt]}"]' ]] ; then echo xx; fi
xx
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# unset 'k["${tmp_key[cnt]}"]'
-bash: bad substitution: no closing `}' in "${tmp_key[cnt
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# unset 'k[${tmp_key[cnt]}]'
-bash: ${tmp_key[cnt: bad substitution
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# tmp_key="${tmp_key[cnt]}"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# unset 'k["$tmp_key"]'
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p k
declare -A k=(["xxx xxx->xxx->xxx->xx:xx.x-/dev/f
```

可以看到，`unset`命令合`-v`操作符，对双引号的敏感度是不同的，要特别小心。并且判断数组的某个索引是否存在，一定要注意，要判断索引不能是空字符串。

```
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# cnt=1
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# if [[ -v 'k["${tmp_key[cnt]}"]' ]] ; then echo xx; fi
-bash: k: bad array subscript
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
```

`unset`的帮助文档：

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# help unset
unset: unset [-f] [-v] [-n] [name ...]
    Unset values and attributes of shell variables and functions.

    For each NAME, remove the corresponding variable or function.

    Options:
      -f        treat each NAME as a shell function
      -v        treat each NAME as a shell variable
      -n        treat each NAME as a name reference and unset the variable itself
                rather than the variable it references

    Without options, unset first tries to unset a variable, and if that fails,
    tries to unset a function.

    Some variables cannot be unset; also see `readonly'.

    Exit Status:
    Returns success unless an invalid option is given or a NAME is read-only.
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
```

#### 如何自己定义内置命令

如果有需要，可以参考下面的链接：

https://www.cnblogs.com/xkfz007/articles/2566441.html


参考官方的文档更好，其中除了`内置命令`和`可加载模块`的开发方法，还定义了一些实用函数：

https://github.com/bminor/bash/tree/master/examples


内置命令是内嵌在`bash`的解释器中的，而`可加载模块`可以动态加载，一般都是`.so`文件。


#### 关于bash5.1发布提到的新的内置命令

在`bash5.1`的发布说明中，提到了几个新的可以加载的内置命令：

```txt
新的内置功能和其他功能

有新的可加载内置程序mktemp，accept，mkfifo，csv和cut/lcut。

```
但是在我的环境下并没有找到，也不能启用。
```bash

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ enable -f accept accept
bash: enable: 无法打开共享目标 accept：No such file or directory

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$
```

目前不知道原因是什么。

#### printf

##### 打印到一个变量

利用这个特性，可以在函数内部打印一个变量到一个外部作用域的变量，类似间接引用效果。

```bash
func1 ()
{
    printf -v "$1" "%s" xxxx
}
func1 yy
echo $yy
xxxx
```

##### 关于安全的打印

在使用命令行工具的使用，如果参数中包含短杠，要特别小心。看下面的例子：

```bash
# echo 后面打印的内容如果为选项,会打印不出来
a='-e'
echo "$a"
# 上面打印出来是空
# 加了--也不行,会把 -- -e一起打印出来
echo -- "$a"
# -- -e

# printf 如果直接打印，遇到选项也打印不出来
a='-v'
printf "$a"
# 这会导致下面的错误打印
# -bash: printf: -v: option requires an argument
# printf: usage: printf [-v var] format [arguments]

# 但是如果加了--就可以正常打印
printf -- "$a"
# 这样任何情况都能打印
printf "%s" "$a"
```

所以，打印字符串推荐使用`printf`而不是`echo`，并且使用`printf`千万不要直接打印字符串，
而是要使用`%s`或者`%q`这种格式化的选项来打印才安全。


#### trap

trap不会改变外部的`$?`的值，但是有可能会改变`$_`的值，所以尽量再脚本中不要使用`$_`变量。
具体的一些说明可以在这个[链接](https://pubs.opengroup.org/onlinepubs/009696799/utilities/trap.html)中找到。

生成版本的脚本最好是关闭所有的`trap`，把`trap`仅用于调试阶段是比较明智的，不要为生产
脚本增加不必要的开销。如果实在要打开，可以考虑只打开`EXIT`陷阱，可以在脚本异常退出的
时候增加定位手段。

如果需要精确的退出行号，那么`EXIT`陷阱需要和`DEBUG`陷阱配合使用（`DEBUG`陷阱会导
致`$_`被影响，为了安全，就统一不用变量`$_`）。 如果不需要那么精确，就打开`EXIT`
陷阱就够了。

#### alias

##### 基本使用

由于`bash`扩展别名的特别的方式，一般而言，别名应该放置到脚本或者配置脚本`.bashrc`
最前面的位置，且最好不要放置到函数中，至于为何，在[下面](https://runebook.dev/zh/docs/bash/aliases)有说明：

```bash
别名允许在用作简单命令的第一个单词时用字符串替换单词。shell 维护一个可以使用 
alias 和 unalias 内置命令设置和取消设置的别名列表。

每个简单命令的第一个单词（如果未加引号）将被检查以查看它是否有别名。如果是这样，
该单词将被别名的文本替换。那些角色 '/’, ‘$’, ‘`’, ‘=' 以及上面列出的任何 shell 
元字符或引用字符不得出现在别名中。替换文本可以包含任何有效的 shell 输入，包括 
shell 元字符。替换文本的第一个单词会进行别名测试，但与正在扩展的别名相同的单词
不会再次扩展。例如，这意味着可以将 ls 别名为 "ls -F" ，并且 Bash 不会尝试递归扩
展替换文本。如果别名值的最后一个字符是 blank ，则还会检查别名后面的下一个命令字
是否有别名扩展。

别名是使用 alias 命令创建和列出的，并使用 unalias 命令删除。

没有在替换文本中使用参数的机制，如 csh 中那样。如果需要参数，请使用 shell 函数
（请参阅 Shell Functions ）。

当 shell 非交互式时，别名不会扩展，除非使用 shopt 设置 expand_aliases shell 选项
（请参阅 The Shopt Builtin ）。

有关别名的定义和使用的规则有些令人困惑。在执行该行或复合命令上的任何命令之前， 
Bash 始终读取至少一个完整的输入行以及构成复合命令的所有行。别名在读取命令时展开，
而不是在执行命令时展开。因此，与另一个命令出现在同一行的别名定义在读取下一行输入
之前不会生效。该行上别名定义后面的命令不受新别名的影响。执行函数时，此行为也是一
个问题。别名在读取函数定义时展开，而不是在执行函数时展开，因为函数定义本身就是一
个命令。因此，函数中定义的别名只有在执行该函数之后才可用。为了安全起见，请始终将
别名定义放在单独的行上，并且不要在复合命令中使用 alias 。

对于几乎所有用途，shell 函数都优于别名。
```

- 下面举个例子说明下别名的嵌套扩展。

```bash
echo "nested alias"
alias lx='ly -l'
alias ly='ls -s'
lx
```
当`bash`读取命令行的时候，首先尝试扩展`lx`，扩展为`ly -l`，然后会检查扩展后的字符串
以空格分隔的第一个单词(别名满足变量命名规范)，如果这个单词也有别名(并且不是它自己)，
会继续展开，这里`ly`展开就是`ls -l`，于是`lx`最终的展开结果是:`ls -s -l`。

- 说明下别名的连续的情况(就是别名以空格结尾的情况)

```bash
unalias -a
alias lx='ls '
alias ly='-l '
alias lz='-s'
lx ly lz
```

上面的别名展开后是:`ls -l -s`。这里`'ls '`的空格的含义是，检查`lx`别名后面的一个
命令字，这里是`ly`，如果它也是一个别名，那么扩展它。同样这里`alias ly='-l '`也是
相同的含义。上面的别名嵌套和下面的等价：

```bash
unalias -a
alias lx='ls -l '
alias lz='-s'
lx lz
```

##### 小心别名的嵌套

```bash
Storage:~ # alias zz='echo m'
Storage:~ # alias yy='echo xx'
Storage:~ # alias ll='zz ;yy'
Storage:~ # ll
m
xx
Storage:~ # 
```

请看上面的例子，`bash`会对每一个要执行的语句先尝试进行别名扩展。所以别名尽量别弄
太复杂了，不好定位。上面的`ll`别名中又展开了另外两个别名。

##### 别名和函数

```bash
Storage:~ # kk=ll
Storage:~ # $kk
-bash: ll: command not found
Storage:~ # declare -f echo_func
echo_func () 
{ 
    echo 1
}
Storage:~ # kk=echo_func
Storage:~ # $kk
1
Storage:~ # ll
m
xx
Storage:~ # 
```

可以使用变量来调用函数，但是不能用变量来调用别名，因为别名替换是在读取`bash`代码的时
侯展开的，读取代码的时候，不会展开`$kk`，也就没有别名替换发生。而函数是在执行时
展开。


##### 别名的位置

别名必须出现在使用它们的函数之前，所以下面这样是不行的：

```bash
func_1 ()
{
xxa
}

alias xxa='ls -l'
alias yx='func_1 ""'



mx=yx
eval $mx
```

由于别名是在定义的时候展开,或者在使用`eval`的时候强制展开，比如改成下面这样可以：

```bash
func_1 ()
{
eval xxa
}

alias xxa='ls -l'
alias yx='func_1 ""'



mx=yx
eval $mx

```


但是更通用的方式在，在函数中出现别名前就先定义它们。注意，除非使用eval，不然别名
是在代码预读取的时候展开的，并不是在执行的时候展开的。所以上面的代码改成下面也可以
按照预期工作

```bash
alias xxa='ls -l'
func_1 ()
{
xxa
}

alias yx='func_1 ""'



mx=yx
eval $mx

```





#### local

#### 函数内部控制选项
如果要在函数内部控制一些bash的选项，而希望在退出后继续适用全局的`set`选项`-`，那么
可以这么做：

```bash
func ()
{
local - ; set +xv
}
```

上面的代码在函数中屏蔽调试，注意：`local -="bB"`这种语法是非法的，只能先用local修饰，
然后在下一个语句中修改。为了适用方便，可以为它设置别名：

```bash
alias disable_xv='local - ; set +xv'
```
#### read 命令

##### read命令不清除前面和后面的空格

```bash
IFS= read -r -d '' xx <<<"   x y z  "
```

如上面的例子所示，需要清空`IFS`变量。注意：这里在read命令的同一行设置IFS=只会影响
read命令的执行，并不会修改全局的`IFS`变量。

##### read命令可以读取数据到数组或者关联数组的子元素中

```bash
array=(1)
index=1
read -r array[index++] <<<"xx"
read -r array[index++] <<<"yy"
read -r array[index++] <<<"zz"
declare -p array
declare -a array=([0]="1" [1]="xx" [2]="yy" [3]="zz")
```

其它对于常规字符串的操作，都可以用于数组或者关联数组的子元素，而不仅仅是`read`操作。


### 数据结构

#### 索引数组

虽然`bash`的索引数组只有一维，但是在大多数情况下已经够用了，如果我们需要保存`二维`的数据，其实可以换一个思路，
比如，把每两个元素分成一组，保存的时候一起保存，取用的时候也一起取出即可。

简单的数据结构是比较好控制的，如果问题不是那么复杂，尽量不要引入复杂的数据结构。

这个时候需要访问数组的时候可以使用类似下面的结构：

```bash
for((reg_i=0;reg_i<${#led_regs[@]};)) ; do
    ... ...
    x=led_regs[reg_i]
    y=led_regs[reg_i+1]
    ((reg_i+=2))
done
```

生成索引数组的一些特殊的方式：

```bash
root@DESKTOP-0KALMAH:~# a=({1..5}{'a b','c d'})
root@DESKTOP-0KALMAH:~# declare -p a
declare -a a=([0]="1a b" [1]="1c d" [2]="2a b" [3]="2c d" [4]="3a b" [5]="3c d" [6]="4a b" [7]="4c d" [8]="5a b" [9]="5c d")
root@DESKTOP-0KALMAH:~# 
```

通过参数扩展生成的数组正确处理了参数中包含特殊字符的情况。在某些特殊场景下或许会有用。



#### 关联数组

##### 关联数组的初始化构造赋值


```bash
q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ declare -A a

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ a=(xx yy zz 1)

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ declare -p a
declare -A a=([xx]="yy" [zz]="1" )

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ a=([xx]=yy [zz]=1)

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ declare -p a
declare -A a=([xx]="yy" [zz]="1" )

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ 
```

请看上面是关联数组的两种赋值方式。


##### 关联数组追加元素的三种语法

```bash
q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ a+=("xx2" 2 "xx1" 1)

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ declare -p a
declare -A a=([xx2]="2" [xx1]="1" [xx]="yy" [zz]="1" )

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ a+=([xx3]=3 [xx4]=5)

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ declare -p a
declare -A a=([xx4]="5" [xx3]="3" [xx2]="2" [xx1]="1" [xx]="yy" [zz]="1" )

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ a[xx7]=8

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ declare -p a
declare -A a=([xx7]="8" [xx4]="5" [xx3]="3" [xx2]="2" [xx1]="1" [xx]="yy" [zz]="1" )

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/nfor
$ 
$ 
```

上面的:

```bash
a+=("xx2" 2 "xx1" 1)
a=("xx2" 2 "xx1" 1)
```

给关联数组赋值的特殊语法只有`bash5.2`才支持的。如果元素的个数是奇数个，那么是下面
这种情况：

```bash
pc@DESKTOP-0MVRMOU ~                                                                                                                                         
$ declare -A m=(x y z)

pc@DESKTOP-0MVRMOU ~
$ declare -p m
declare -A m=([z]="" [x]="y" )

pc@DESKTOP-0MVRMOU ~
$ 
```

但是使用这种语法把一个数组追加到一个关联数组，目前验证确发现不行。

```bash
pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
$ ay=('zy
> 22' '12
> kk')
pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
$ declare -A ax=()
pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# 这样是不行的
$ ax+=("${ay[@]}")
pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
$ declare -p ax
declare -A ax=([$'zy\n22 12\nkk']="" )
pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
$ declare -A ax=()
pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# 这样也不行
$ eval ax+=("${ay[@]}")
pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
$ declare -p ax
declare -A ax=([zy]="22" [12]="kk" )
pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
$ declare -p ay
declare -a ay=([0]=$'zy\n22' [1]=$'12\nkk')
# 但是直接相加的语法又是可以的
pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
$ ax+=('zy
> 22' '12
> kk')
pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
$ declare -p ax
declare -A ax=([$'zy\n22']=$'12\nkk' )
```

使用的时候要特别小心。

#### 关联数组的特殊键

下面是在`bash5.2`版本上的验证结果

```bash
q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ declare -A m

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ m['@']=gge

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ m['*']=gggee

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ declare -p m
declare -A m=(["*"]="gggee" ["@"]="gge" )

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ unset m[@]

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ declare -p m
declare -A m=(["*"]="gggee" )

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ unset m[*]

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ declare -p m
declare -A m=()

$ 
```

下面是`bash5.2`版本前的效果，直接删除了整个关联数组：

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# declare -A m
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# m['@']=gg
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# m['*']=gggee
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# declare -p m
declare -A m=(["*"]="gggee" ["@"]="gg" )
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# unset m[@]
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# declare -p m
-bash: declare: m: not found
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# 
```


也就是说`bash5.2`以前是有BUG的，你不能把`@`或者`*`放到键里面删除，而是需要一个中间
变量。或者是用双引号把`@`或者`*`包裹起来。这在所有的支持关联数组的版本中都能用。

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# declare -A m
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# m['@']=gg
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# m['*']=gggee
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# xx='@'
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# unset 'm[$xx]'
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# declare -p m
declare -A m=(["*"]="gggee" )
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/bit# 
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# declare -A m
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# m['*']=1
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# m['@']=2
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# declare -p m
declare -A m=([1]="2" ["*"]="1" ["@"]="2" )
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# unset 'm["@"]'
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# declare -p m
declare -A m=([1]="2" ["*"]="1" )
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# unset 'm[@]'
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# declare -p m
-bash: declare: m: not found
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# 
```

要像上面的例子那样才能删除一个名为`@`的成员，而不是删除关联数组本身，这样在`bash5.2`
和以下的版本都适用。



#### 打印一个数组或者关联数组

在`bash5.1`(:TODO:确认下具体版本)中提供了变量的`@K`操作符，在`bash5.2`中提供了`@k`
操作符，可以通过简单的方式来打印键值对。

```bash
q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/array
$ declare -p b
declare -A b=([def]="2" ["xx yy"]="4" [abc]="1" )

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/array
$ eval xm=(${b[@]@K})

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/array
$ printf "%s => %s\n" "${xm[@]}"
def => 2
xx yy => 4
abc => 1

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/array
$ 
```

上面还利用了`printf`的配对打印。

上面的打印还可以有下面的更方便的形式，利用`@k`操作符。

```bash
q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/array
$ printf "%s => %s\n" "${b[@]@k}"
def => 2
xx yy => 4
abc => 1

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/array
$ 
```

注意：`"${b[@]@k}"`这里的双引号是必须的。

可惜`bash`的for循环无法一次迭代两个变量，不然数组和关联数组的遍历就会方便很多。
所以这里的意义最大还是打印一个数组或者关联数组。

不过也可以使用下面的代码来遍历数组或者关联数组，可以把
`((i^=1)) ; ((i)) || { k="$e" ; continue ; } ; v="$e"`这个语句封装成一个函数，函数
中使用`eval`处理传入的参数`k v e i`。

```bash
declare k v e
declare -i i=1
for e in "${b[@]@k}" ; do
    ((i^=1)) ; ((i)) || { k="$e" ; continue ; } ; v="$e"
    printf "%s => %s\n" "$k" "$v"
done
```
#### 关联数组的模拟

可以用一个数组，奇数是键，偶数是值。或者两个数组，一个存键一个存值。


#### 字符串处理

##### global匹配

global匹配有些时候虽然没有正则强大，但是它们是完全匹配，某些情况下可能更好用。

```bash
[[ $net_name == @(*.*|lo|veth) ]] && continue
```

上面的例子表示，网口名满足列表中的任何一个都认为是真。

##### 正则表达式匹配

###### 中文支持

1. 直接匹配

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# if [[ $x =~ ^(我)(是)$ ]] ; then     m=${BASH_REMATCH[1]};     n=${BASH_REMATCH[2]};
     declare -p m n; fi
declare -- m="我"
declare -- n="是"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# 
```

2. 如果想用`unicode`编码的范围来表示中文呢？

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# if [[ $x =~ ^($'\u6211')($'\u662f')$ ]] ; then     m=${BASH_REMATCH[1]};     n=${BAS
H_REMATCH[2]};     declare -p m n; fi
declare -- m="我"
declare -- n="是"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/array# 
```

你可以已经注意到`$''`这种语法，除了上面的`$'\u'`，还有其它的形式，可以通过这种方式
表示一些特殊字符或者是一些不可打印的字符，举一些例子(并不是全部)：

- `$'\n'`：表示换行符。
- `$'\t'`：表示制表符。
- `$'\xNN'`：其中 NN 是一个两位的十六进制数，表示一个字节的字符。例如，`$'\x41'` 表示大写字母 `A`。
- `$'\uNNNN'`：其中 NNNN 是一个四位的十六进制数，表示一个 Unicode 字符。例如，`$'\u6211'` 表示汉字 `我`。




### 进程管理

#### 关于bash5.2的重大变化

```txt
其他变化包括：
扩展了额外进程不分叉的情况，例如使用 “$(” 构造时不再使用分叉。
```

在`bash5.2`的发布说明中，有这样一句话，`AI`给出的解释是，当使用`$(comand)`的语法执行命令的时候，`bash`不会再启用新的子进程来执行了。

但是关于这一点，我还不知道如何验证，并且这里针对的命令是所有的命令还是部分的也还未知。

通过`$(xx)`这样的语法，如果`xx`是一个函数，那么在函数中修改了全局变量会影响当前环境吗？以前由于是在`子shell`中执行的，所以不会影响。

但是现在这样更改了，是否情况发生了变更？

可以尝试使用`strace`工具来跟踪系统调用

```bash
strace -f -e trace=process bash -c 'echo $(echo $$)'
```


在 `Bash 5.2` 中，确实有一些改进和优化，其中包括对进程替换的处理。在以前的版本
中，`$()` 进程替换会创建一个新的子进程。但在 Bash 5.2 中，这种情况已经得到了改善。

具体来说，`Bash 5.2` 的发布说明中提到，现在 Bash 在一些额外的情况下会抑制 fork，
包括大多数使用 `$(<file)` 的情况。这意味着在这些情况下，Bash 不再创建新的进程，
而是在当前进程中执行操作。这可以提高效率，因为创建新的进程通常会消耗更多的系统资源。

这种改变的一个重要影响是，现在你可以在脚本中更高效地使用进程替换，而不必担心每次
都会创建新的进程。这对于需要频繁使用进程替换的脚本来说，可能会带来显著的性能提升。



### HEAR DOCS

#### HEAR DOCS的两种形式

当使用 Here Document（也被称为 heredoc）时，可以选择是否在开始标识和结束标识中
加引号。这两种方式的区别：

1. 不带引号：
开始标识和结束标识都不带引号。
内嵌的变量和转义符号会被解释。
适用于需要保留变量替换和转义的情况。
示例：

```bash
cat <<EOF
This is a heredoc without quotes.
Variable value: $a
EOF
```

不带引号要保持缩进好看的情况下，只能使用`<<-`这种形式，但是这种形式下，只能剔除
行首的制表符，无法处理空格。

这可以用来生成eval执行的字符串，但是要注意变量扩展的时候可能生成的复杂字符串。

看一个例子：

```bash
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# m='geg " gge
# > geg geg'
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# read -d '' -r mxm <<EOF
# > xxy="$m"
# > EOF
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# printf "%s" "$mxm"
# xxy="geg " gge
# geg geg"root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# 
# m='geg " gge
# geg geg'
# escaped_m=$(printf "%q" "$m")
# read -d '' -r mxm <<EOF
# xxy=$escaped_m
# EOF
# printf "%s" "$mxm"
# printf "%s" "$mxm"
# xxy=$'geg " gge\ngeg geg'
# 然后我们执行后就会得到原始字符串
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# xxy=$'geg " gge\ngeg geg'
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# declare -p xxy
# declare -- xxy="geg \" gge
# geg geg"
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# 

```

如上面所示，如果`here docs`中的字符串替换可能涉及包含空格或者换行的特殊字符串，那么
在赋值的时候就最好使用安全字符串来赋值。或者是不在`here docs`中扩展它。




2. 带单引号或者双引号：
开始标识和结束标识带单引号。
不解释内嵌的变量和转义符号。
适用于需要保留原样内容的情况。
示例：

```bash
cat <<'EOF'
This is a heredoc with single quotes.
Variable value: $a
EOF
```

引号还有个意义是可以让你的here docs的结束符保持缩进

```bash
root@DESKTOP-0KALMAH:~# read -d '' -r xx<<"    EOF"
    a="$1"
    b="\$2"
    EOF
```

上面的例子中如果没有双引号，那么EOF结束符必须在行首。显然不好看。

注意：使用`read`命令的`-d ''`有一个缺陷是，执行完成后命令的返回值是非0的。
如果使用了ERR陷阱，那么很多误报。

如果想规避`read`命令返回非0的问题，可以使用`mapfile`替代，唯一需要注意的是`mapfile`
保存到一个数组中。行首的空格`mapfile`也会保留。并且也不用加`-r`参数保留反斜杠。

```bash
mapfile -d '' xxa <<EOF
m="$x"
EOF

declare -p xxa
declare -a xxa=([0]=$'m="geg\ngeg "\n')
```

其实还有一种方法让使用`read -d ''`的时候不会触发误报：

```bash
{
read -r -d '' mmxx <<EOF
geg geg
g  ge
EOF
} || true
```

就是像上面这样，让命令的返回值永远是0。


`HEAR STR`可以用来生成命令字符串，其实使用单引号也可以，就看具体使用场景了。


#### HEAR STR

在 `Bash` 中使用 `<<<` 来提供一个 `here string` 时，Bash 会自动在字符串的末尾添加一个换行符。
这是因为 `<<<` 语法实际上是 `here document (here doc)` 的一个特殊情况，它用于将字符串作为标准输入传递给命令。
在 `Unix-like` 系统中，文本文件通常以换行符结束，因此 `Bash` 在 `here string` 的末尾添加换行符，以模拟文件结束的行为。

这个行为可能会导致一些问题，特别是在处理那些对输入格式敏感的命令时。例如，如果您的脚本依赖于精确的字符计数或者需
要消除任何额外的空白字符，那么自动添加的换行符可能会造成问题。

### 引号

#### 单引号

单引号可以构建多行字符串，和复杂字符串，并且也可以带变量的值，请看两个例子：


```bash
array_epush () { eval "$1+=(\"\${@:2}\")" ; }
# 还有一种写法
array_epush () { eval ''$1'+=("${@:2}")' ; }
```

上面这两种写法几乎是等价的。要调试eval表达式，最简单的方法是打开`set -x`，让bash显示代码的详细展开和执行过程即可。


```bash
root@DESKTOP-0KALMAH:~# a='1 2 3 '
root@DESKTOP-0KALMAH:~# b='4 5 6'
root@DESKTOP-0KALMAH:~# c='xx "'$a'" "'$b'"'
root@DESKTOP-0KALMAH:~# declare -p c
declare -- c="xx \"1 2 3 \" \"4 5 6\""
root@DESKTOP-0KALMAH:~# 
```

如果要在单引号中对某个变量求值，再加一层单引号即可，见上面的例子。但是请不要直接把`'xx "'$a'" "'$b'"'`这个字符串作为函数的
一个参数传递，会有不符合预期的现象发生：

```bash
root@DESKTOP-0KALMAH:~# func_a ()
> {
> printf "%s" "$1"
> }
root@DESKTOP-0KALMAH:~# func_a 'xx "'$a'" "'$b'"'
xx "1root@DESKTOP-0KALMAH:~# 
root@DESKTOP-0KALMAH:~# c='xx "'$a'" "'$b'"'
root@DESKTOP-0KALMAH:~# func_a 'xx "'$a'" "'$b'"'
xx "1root@DESKTOP-0KALMAH:~# 
root@DESKTOP-0KALMAH:~# func_a "$c"
xx "1 2 3 " "4 5 6"root@DESKTOP-0KALMAH:~#
```

所以请不要把一个复杂字符串作为函数的参数直接传递给它，可以先赋值给一个变量，然后传递这个变量，并且用传递参数的时候用双引号
保护起来。


多行字符串：

```bash
root@DESKTOP-0KALMAH:~# c='
> local m=$1
> local c="4"
> '
root@DESKTOP-0KALMAH:~# declare -p c
declare -- c="
local m=\$1   
local c=\"4\" 
"
root@DESKTOP-0KALMAH:~# 
```

这种用法可以用来构造可执行的代码块。也不要把这个参数直接传递给函数，赋值给变量，然后把变量传递给函数，用双引号保护。


**注意**: 单引号唯一的缺点是，在单引号中无法再表示别的单引号！

其实单引号中也可以包裹别的单引号！只是比较麻烦，如下：

```bash
root@DESKTOP-0KALMAH:~# a=''\'''
root@DESKTOP-0KALMAH:~# declare -p a
declare -- a="'"
root@DESKTOP-0KALMAH:~# 
```


#### 双引号

在Bash中，双引号内的字符大多数会保持其字面值，但有一些特殊字符除外。双引号会处理以下特殊字符：

```bash
- $：用于参数扩展、命令替换和算术扩展
- `：用于命令替换
- \：当其后跟随$、`、"、\或换行符时，保留其特殊含义
- "：可以通过在其前面加上反斜杠来在双引号内引用双引号
- !：当历史扩展功能启用时，!用于历史扩展，除非它被反斜杠转义
```

关于引号的解释，这里有一篇详细的文档：

https://rg1-teaching.mpi-inf.mpg.de/unixffb-ss98/quoting-guide.html

一些可以 **不使用双引号** 的情况:

1. 一个变量赋值给另外一个变量，不需要加双引号，就算里面有特殊符号也不会被扩展

```bash
[root@localhost ~]# a='*!@[]'
[root@localhost ~]# b=$a
[root@localhost ~]# declare -p b
declare -- b="*!@[]"
[root@localhost ~]# 

```


同样的情况也用于函数位置参数的赋值，也是不需要加双引号的。如果位置参数超过10个，那么需要用大括号引用起来，要注意。

```bash
local a=$1 b=$2 c=$3
m=$b
k=$a
l=$c
declare -p a b c m k l
```


2. 圆括号的命令替换，不用加双引号保护。

```bash
[root@localhost ~]# echo "*" >1.txt
[root@localhost ~]# cat 1.txt 
*
[root@localhost ~]# xx=$(cat 1.txt)
[root@localhost ~]# declare -p xx
declare -- xx="*"
[root@localhost ~]# func_c () { echo '*'; echo '!' ; echo ' 13 geg'$'\n'' xxd gg' ; }
[root@localhost ~]# xx=$(func_c)
[root@localhost ~]# declare -p xx
declare -- xx="*
!
 13 geg
 xxd gg"
[root@localhost ~]# 
```
3. 在case中不需要加双引号保护

请看下面的范例：

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# declare -p a b
declare -- a="gege
geg\"gg geg
"
declare -- b="gege
geg\"gg geg
"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# case $a in
> $b) echo xx ;;
> esac
xx
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# b=${a}x
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# case $a in $b) echo xx ;; esac
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# 
```

多个变量组合情况相同：

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p b c d
declare -- b="1 2 3     4"
declare -- c="!("
declare -- d="\$"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# case $b$c$d in '1 2 3     4!($') echo xx; ;; esac
xx
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
```

但其实为了可读性和意义更明确，这里还是 **建议加上双引号**。

可以这么理解，解释器先进行变量扩展，`$b$c$d`被扩展为变量的值，然后后面就不会进行更多的扩展，会用这个字符串
来对后面的模式进行匹配。

4. 关联数组中的键不需要加引号保护，bash会自动处理，这里有一个[链接](https://stackoverflow.com/questions/69999743/bash-variables-quoted-in-the-index-field-of-an-associative-array-reference)说明。

```bash
a='!*()) 
gge
!
*
()'

declare -A m=(['!*()) 
gge
!
*
()']='g ge')

echo "${m[$a]}"
```

上面例子中的关联数组的键`$a`并不需要加双引号保护。

多个值组合的情况也相同：

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -A xxaxxb
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# xxaxxb[$b$c$d]=1
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p xxaxxb
declare -A xxaxxb=(["1 2 3     4!(\$"]="1" )
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
```


**需要加双引号**保护的情况：

总体原则是在不确定是否安全的情况下，加上双引号保护或者单引号都是比较可靠的。防止
未来产生问题。

1. 双中括号，最安全的做法是两边都加双引号保护，除非右边是正则表达式

下面的例子可以看到，没有正常加双引号会导致让解释器认为是扩展。

```bash
Storage:~ # declare -p  a b
declare -- a="*"
declare -- b="gge ggeg 
gege"
Storage:~ # 
Storage:~ # 
Storage:~ # 
Storage:~ # 
Storage:~ # 
Storage:~ # if [[ $b == $a ]] ; then echo xx; fi
xx
Storage:~ # 
```

其实可以这么理解，解释器首先进行变量扩展，`$a`被扩展为`*`，然后进行匹配。

2. 数组展开成一个字符串

同上面，没有引号可能被解释器当作是扩展。

```bash
Storage:~ # a=('*')
Storage:~ # b=ggege
Storage:~ # if [[ $b == ${a[*]} ]] ; then
> echo xx
> fi
xx
Storage:~ # 
```



### 变量替换

#### 进程替换

在赋值语句 `xx=$(yy)` 中，通常不需要为 `$(yy)` 加上双引号。因为在赋值操作中，Bash
会自动将命令替换的输出作为一个整体赋给变量，即使输出中包含有空格或特殊字符。看下面的
例子：

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# cat  1.txt 
$x!`"!
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# mm=$(cat 1.txt)
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p mm
declare -- mm="\$x!\`\"!"
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
```
### 循环

#### for

另外一种按行遍历的方法:

```bash
test_ifs ()
{
    local IFS=$'\n'
    echo "1 2 3" >1.txt
    echo "4 5 6" >>1.txt
    echo "7 8 9" >>1.txt

    for i in $(<1.txt) ; do
        eval "i=$i"
        echo $i
    done
}
```

**注意：**上面的for循环中的`$(<1.txt)`这个变量一定不能加双引号，加了就不对。要保证
这个循环是安全的，最好是使用安全的`Q字符串`。这样在没有引号保护的情况下也是安全的
拿到`Q字符串`后要使用前解码即可。

解码如上面的`eval "i=$i"`所示。


再看另外一个例子：

```bash
test_ifs ()
{
    local IFS=$'\n'
    echo "" >1.txt
    echo "" >>1.txt

    a=''

    for i in $(<1.txt) ; do
        echo xx
    done
}
```

上面的例子中，当`1.txt`中只有两个换行符的时候，for循环也没有进去，没有发生迭代，这在
编程的时候要特别小心。不过如果用来迭代数组的索引是安全的，因为数组的索引一定是有值的。
不可能出现空值。

使用`Q字符串有一个最大的好处`是，就算是空值，也能进循环迭代：

请看这个例子：

```bash
test_ifs ()
{
    local IFS=$'\n'
    m=""
    printf "%q\n" "" >1.txt
    printf "%q\n" "$m" >>1.txt
    printf "%q\n" "" >>1.txt

    for i in $(<1.txt) ; do
        eval "i=$i"
        echo xx
        echo "$i"
    done
}
```

函数执行完成后`1.txt`中的值是：

```bash
$ cat 1.txt 
''
''
''
```

除了`printf "%q"`，还可以用下面的方法得到Q字符串：

```bash
q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ declare -p a
declare -a a=([0]="1 2 3" [1]="4 5 6")

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ echo ${a[@]@Q}
'1 2 3' '4 5 6'

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash
$ 
```

#### for循环的参数列表

for循环的参数列表是一次性生成的，所以可以在循环体内对迭代的对象进行处理。

```bash
test_param_list ()
{
    a="1 2 3
4 5 6
7 8 9"
    nfor i in $a ; ndo
        a=''
        echo "i:$i"
    ndone

    echo "a:$a"
}

test_param_list
```

上面这个例子生成的结果是：

```bash
i:1 2 3
i:4 5 6
i:7 8 9
a:
```

可以看到在循环体内对a赋空，并不影响循环体内的迭代，因为for循环的参数列表在刚进入循环的时候就已经获取到了。这个特性非常重要
可以让我们灵活处理。而不用写很冗余的代码。

#### while循环

```bash
while a=$(cat 1.txt) ; do
    echo "success"
    sleep 1
done
```
while 循环可以用上面的语句迭代一个变量。

#### 关于循环的一个BUG

在 Bash 4.3 及之前的版本中，当执行一个 shell 函数时，循环状态（如 while、until 等）
不会被重置。这意味着如果在一个函数中使用 break 或 continue，它们将影响调用该函数
的上下文中的循环。例如：

```bash
function my_function {
    while true; do
        echo "Inside function loop"
        break
    done
    break
}

while true; do
    my_function
    echo "This will not be printed"
done
```

在上面的代码中，`my_function` 中的 `break` 将会中断外部的 `while` 循环，因为循环
状态没有被重置。

从 `Bash 4.4` 开始，这个行为被改变了。`Bash 4.4` 及之后的版本会在执行 shell 函数
时重置循环状态，以防止 break 或 continue 影响调用上下文中的循环。

在`bash3.2.51`上复现出了这个问题

```bash
while true; do
    echo "Inside function loop"
    break
done
```

这个代码并没有问题，而是后面那个独立的`break`导致了函数外面的循环被中断。这在`bash4.4`
已经更高的版本上，不会出问题，但是会出现告警

`-bash: break: only meaningful in a for, while, or until loop`




### 选项

#### localvar_unset

这个选项是`bash5.2`增加的。举个例子说明下：

```bash
test_case1 ()
{
    local a=test_case1
    test_case2
    declare -p a
}

test_case2 ()
{
    local a=test_case2
    test_case3
    declare -p a
}

test_case3 ()
{
    unset a
    declare -p a
}

shopt -s localvar_unset
a=out
test_case1
declare -p a

shopt -u localvar_unset
echo '--------------------------'

a=out
test_case1
declare -p a

```

上面例子的执行结果是：

```bash
declare -- a
declare -- a
declare -- a="test_case1"
declare -- a="out"
--------------------------
declare -- a="test_case1"
declare -- a="test_case1"
declare -- a="test_case1"
declare -- a="out"
```

这个选项主要的作用是，在函数中取消上一个作用域的变量，是让上一个作用域的变量恢复到上
一个作用域还是只取消局部作用域。如果开启，那么只取消局部作用域，如果没有开启，那么
恢复到上一个作用域。解释得有点绕，结合例子理解。

但是在函数中取消上一个作用域的变量的属性的用法并不常见，如果在当前的函数作用域中先定义
一个同名的局部变量，然后再使用unset取消它，那么不论开不开这个选项，结果都一样，比如：

```bash
test_case4 ()
{
    local -a a=(test_case4)
    test_case5
    declare -p a
}

test_case5 ()
{
    local -a a=(test_case5)
    test_case6
    declare -p a
}

test_case6 ()
{
    local -a a=(test_case6)
    unset a
    declare -p a
}

a=(out)
test_case4
```

上面的代码的执行结果是：

```bash
declare -- a
declare -a a=([0]="test_case5")
declare -a a=([0]="test_case4")
```

只会取消当前作用域中的变量，但是由于有外部同名变量，所以`declare`中还保留了变量的
残影(属性和值都丢失了，类似于变量被定义但是未被赋值的状态，默认为空字符串)。所以
在一般的使用场景下，`localvar_unset`这个选项的作用并不大。我们不应该在函数中去取消
一个上一个作用域中的变量的定义。

#### extglob

##### 在双中括号中的使用情况

```bash
[root@localhost ~]# str=abc
[root@localhost ~]# if [[ $str == @(abc|dbx) ]] ; then echo xx; fi
xx
[root@localhost ~]# if [[ $str == @(ac|dbx) ]] ; then echo xx; fi
[root@localhost ~]# if [[ $str == !(ac|dbx) ]] ; then echo xx; fi
xx
[root@localhost ~]# if [[ $str == !(abc|dbx) ]] ; then echo xx; fi
[root@localhost ~]# shopt | grep ext
extdebug        off
extglob         on
extquote        on
[root@localhost ~]# shopt -s extglob
[root@localhost ~]# shopt | grep ext
extdebug        off
extglob         on
extquote        on
[root@localhost ~]# shopt -u extglob
[root@localhost ~]# shopt | grep ext
extdebug        off
extglob         off
extquote        on
[root@localhost ~]# if [[ $str == !(abc|dbx) ]] ; then echo xx; fi
-bash: !: event not found
[root@localhost ~]# 
```

我发现下面这种语法，选项开关都没有影响：

```bash
[root@localhost ~]# shopt -u extglob
[root@localhost ~]# if [[ $str == @(abc|dbx) ]] ; then echo xx; fi
xx
[root@localhost ~]# str=abc
[root@localhost ~]# if [[ $str == @(abc|dbx) ]] ; then echo xx; fi
xx
[root@localhost ~]# str=dbx
[root@localhost ~]# if [[ $str == @(abc|dbx) ]] ; then echo xx; fi
xx
[root@localhost ~]# str=xxx
[root@localhost ~]# 
```

我发现5种量词语法在双中括号的表达式中，只有`!(pattern-list)`受选项影响，其它的打开和关闭都可以使用。
:TODO: 为什么？

可能是下面的原因：

```bash
compat51 (set using BASH_COMPAT)
Parsing command substitutions will behave as if extended glob (see The Shopt 
Builtin) is enabled, so that parsing a command substitution containing an 
extglob pattern (say, as part of a shell function) will not fail. This assumes 
the intent is to enable extglob before the command is executed and word 
expansions are performed. It will fail at word expansion time if extglob hasn’t 
been enabled by the time the command is executed.
```

命令替换解析：在 Bash 5.1 中，解析命令替换时会表现得好像启用了扩展 glob
（extglob）。扩展 glob 是一种允许使用更复杂的模式匹配的功能。假设你在一个 shell
函数中使用了包含 extglob 模式的命令替换，如果在解析命令替换时没有启用 extglob，
解析将不会失败。

举个例子，假设你有一个包含 extglob 模式的命令替换：

shopt -s extglob
echo $(echo @(foo|bar))

在 Bash 5.1 中，即使你没有显式启用 extglob，解析命令替换时也会假设你启用了它。
因此，上面的命令不会在解析时失败。

但是，如果在执行命令时没有启用 extglob，它将在单词扩展时失败。这意味着，
如果你在执行命令时没有启用 extglob，命令替换中的模式匹配将无法正常工作。

在 Bash 5.1 中，显式启用 extglob 是最安全的做法。这可以确保在解析和执行命令替换
时，扩展 glob 模式能够正常工作，避免潜在的解析或执行错误。

你可以通过以下命令显式启用 extglob：

shopt -s extglob

这样可以确保在使用包含 extglob 模式的命令替换时，不会遇到解析或执行失败的问题。


?(pattern-list)：模式匹配零次或一次。
*(pattern-list)：模式匹配零次或多次。
+(pattern-list)：模式匹配一次或多次。
@(pattern-list)：只匹配一次模式。
!(pattern-list)：匹配给定模式以外的任何内容。(只有这个受shopt -s extglob影响)

##### 在其它地方使用的情况

但是在其它地方，需要打开`extglob`才能使用。

```bash
str_basename () { printf "%s" "${2//@(*\/|.*)}" ; }
```

请看上面这个函数，只有在`extglob`打开的情况下才能正常工作。


#### patsub_replacement

`patsub_replacement`可以让你在替换字符串中使用`&`引用被替换子串。其实就是让替换输入更
简洁而已。但是如果开启，你要使用`&`本身，就需要用反斜杠转义它。或者使用引号显式的
引用它。

```bash
q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code
$ var=abcdef

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code
$ shopt -s patsub_replacement

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code
$ echo ${var/abc/&xyz&}
abcxyzabcdef

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code
$ echo ${var/abc/&xyz"$a"}
abcxyz&def

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code
$ shopt -u patsub_replacement

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code
$ echo ${var/abc/&xyz&}
&xyz&def
q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code
$ echo ${var/abc/abcxyzabc}
abcxyzabcdef

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code
$ 
```

但是这个特性比较危险，使用的时候如果包含变量的情况要考虑使用双引号和不适用的区别

看下面的例子就很能说明问题：

```bash
q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ a='&x&'

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ b=xxoo

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ echo ${b//oo/&y}
xxooy

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ echo ${b//oo/$ay}
xx

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ echo ${b//oo/${a}y}
xxooxooy

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ echo ${b//oo/"${a}"y}
xx&x&y

q00546874@DESKTOP-0KALMAH /cygdrive/d/my_code/pure_bash/test/cases/bit
$ 
```

#### 关闭扩展

这里有一个[链接](https://wangdoc.com/bash/expansion)对`bash`中的扩展讲得比较详细。
主要有下面几种：

1. 波浪线扩展
2. `?`字符扩展
3. `*`字符扩展
4. `[ab]`方括号或扩展
5. `[a-b]`方括号范围扩展
6. `{a,b}`大括号组合扩展
7. `{a..b}`大括号范围扩展
8. 变量扩展
9. 子命令扩展
10. 算术扩展

关闭选项`set -f`可以抑制这些扩展，见下面的例子：

不要理解错了，`set -f`只针对匹配文件的情况抑制，字符串是不会受影响的。

```bash
[root@localhost ~]# set -f
[root@localhost ~]# 
[root@localhost ~]# str=abc
[root@localhost ~]# if [[ $str == [ab]bc ]] ; then
> echo xx
> fi
xx
[root@localhost ~]# 
```

1. 波浪线扩展不需要抑制，`set -f`不会抑制它。:TODO: 谁抑制它？

```bash
[root@localhost ~]# echo ~
/root
[root@localhost ~]# a='~'
[root@localhost ~]# set +f
[root@localhost ~]# a='~'
[root@localhost ~]# b=($a)
[root@localhost ~]# declare -p b
declare -a b=([0]="~")
[root@localhost ~]# 
```

2. 抑制问号`?`扩展

```bash
[root@localhost ~]# set +f
[root@localhost ~]# a='?bc.txt'
[root@localhost ~]# b=($a)
[root@localhost ~]# declare -p b
declare -a b=([0]="abc.txt")
[root@localhost ~]# set -f
[root@localhost ~]# b=($a)
[root@localhost ~]# declare -p b
declare -a b=([0]="?bc.txt")
[root@localhost ~]# 
```

3. 抑制星号`*`扩展

```bash
[root@localhost ~]# set +f
[root@localhost ~]# 
[root@localhost ~]# a='[a]bc.txt'
[root@localhost ~]# b=($a)
[root@localhost ~]# declare -p b
declare -a b=([0]="abc.txt")
[root@localhost ~]# set -f
[root@localhost ~]# a='[a]bc.txt'
[root@localhost ~]# b=($a)
[root@localhost ~]# declare -p b
declare -a b=([0]="[a]bc.txt")
[root@localhost ~]# 
```

4. 抑制方括号扩展

```bash
[root@localhost ~]# set +f
[root@localhost ~]# a="[abc]bc.txt"
[root@localhost ~]# b=($a)
[root@localhost ~]# declare -p b
declare -a b=([0]="abc.txt")
[root@localhost ~]# set -f
[root@localhost ~]# b=($a)
[root@localhost ~]# declare -p b
declare -a b=([0]="[abc]bc.txt")
[root@localhost ~]# 
```

5. 抑制方括号范围扩展

```bash
[root@localhost ~]# set +f
[root@localhost ~]# a="[a-c]bc.txt"
[root@localhost ~]# b=($a)
[root@localhost ~]# declare -p b
declare -a b=([0]="abc.txt")
[root@localhost ~]# set -f
[root@localhost ~]# a="[a-c]bc.txt"
[root@localhost ~]# b=($a)
[root@localhost ~]# declare -p b
declare -a b=([0]="[a-c]bc.txt")
[root@localhost ~]# 
```

6. 抑制大括号组合扩展

关于花括号扩展的嵌套使用，这里有一个[说明](https://blog.csdn.net/astrotycoon/article/details/50886676)。

`set +B`

```bash
[root@localhost ~]# set -B
[root@localhost ~]# a=({a,b}bc.txt)
[root@localhost ~]# declare -p a
declare -a a=([0]="abc.txt" [1]="bbc.txt")
[root@localhost ~]# set +B
[root@localhost ~]# a=({a,b}bc.txt)
[root@localhost ~]# declare -p a
declare -a a=([0]="{a,b}bc.txt")
[root@localhost ~]# 
```



7. 抑制大括号范围扩展。

`set +B`

```bash
[root@localhost ~]# set -B
[root@localhost ~]# a=({a..b}bc.txt)
[root@localhost ~]# declare -p a
declare -a a=([0]="abc.txt" [1]="bbc.txt")
[root@localhost ~]# set +B
[root@localhost ~]# a=({a..b}bc.txt)
[root@localhost ~]# declare -p a
declare -a a=([0]="{a..b}bc.txt")
[root@localhost ~]# 
```

8. 变量扩展、子命令扩展、算术扩展在数组赋值中都没有用。





### 字符串切片

对于包含`unicode`字符的切片操作也是能符合预期：

```bash
a="我是谁"

echo "${a:0:1}"
echo "${a:1:1}"
echo "${a:2:1}"
echo "${a#?}"
echo "${a#??}"
echo "${a#???}"

```

得到的结果是：

```bash
我
是
谁
是谁
谁

```

`${a#?}`这个是前缀删除的语法，表示删除字符串的开头一个字符.


## git

### 分支操作

#### 强制合并分支

- git A 分支合并B分支，并强制使用B分支代码（不手动解决冲突）

```bash
git checkout A
git merge --strategy-option=theirs B
```


- git A 分支合并B分支，并强制使用A分支代码(不手动解决冲突)

```bash
git checkout A
git merge --strategy-option=ours B
git checkout A
git reset --hard B
```

## 关于动态可加载模块

### 是否可以实现多线程？

思路：用C编写可动态可加载模块，然后在bash中通过`enable -f /path/xx.so xx`来启用，然后在
可加载模块中做多线程。

## 外部命令发送

### 具有前导破折号的文件名

正确的做法是下面这样，使用`--`让bash不要把后面的文件名当成参数来处理。其它的相关
命令可能也有类似的问题。

```bash
cp -- "$file" "$target"
```

### 组装带参数的外部命令

如果需要发送的命令带参数，那么不能直接把命令+参数一起组装成字符串，而是要把它们放
到数组中，比如:

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# cmd='ls -l'
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# "$cmd"
-bash: ls -l: command not found
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# cmd=(ls -l)
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# "${cmd[@]}"
total 32
-rwxrwxrwx 1 root root 1021 Jul 11 11:44 test_case.sh
-rwxrwxrwx 1 root root  563 Jul 10 18:02 test_declare.sh
-rwxrwxrwx 1 root root  657 Jul  6 10:52 test_dict.sh
-rwxrwxrwx 1 root root  518 Jul 10 08:47 test_eval.sh
-rwxrwxrwx 1 root root  530 Jul  5 14:08 test_for.sh
-rwxrwxrwx 1 root root 5523 Jul 11 09:37 test_function_levels.sh
-rwxrwxrwx 1 root root  932 Jul 11 09:29 test_function_params.sh
-rwxrwxrwx 1 root root 1022 Jul  8 10:22 test_localvar_unset.sh
-rwxrwxrwx 1 root root  989 Jul  4 16:55 test_other_todo.sh
-rwxrwxrwx 1 root root  873 Jul  8 10:22 test_printf.sh
-rwxrwxrwx 1 root root  751 Jul  8 10:22 test_str_slice.sh
-rwxrwxrwx 1 root root  592 Jul  4 16:55 test_unset.sh
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# 
```

如果确保执行的命令中没有空格或者特殊字符分隔问题，那么直接`${cmd[@]}`运行也是可以的，
但是为了保险，还是用双引号包裹比较安全。

### rm

```bash
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# ls
-xx.txt  1.txt  test_fun_process_bar.sh  xx.txt  yy.txt
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# rm -f *.txt
rm: invalid option -- 'x'
Try 'rm ./-xx.txt' to remove the file '-xx.txt'.
Try 'rm --help' for more information.
xx
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# rm -f -- *.txt
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# rm -f ./*.txt
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# touch '-xx.txt'
touch: invalid option -- 'x'
Try 'touch --help' for more information.
xx
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# touch -- '-xx.txt'
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# ls 
-xx.txt  test_fun_process_bar.sh
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# ls -l
total 0
-rwxrwxrwx 1 root root   0 Jul 18 13:38 -xx.txt
-rwxrwxrwx 1 root root 549 Jul 16 21:53 test_fun_process_bar.sh
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# rm -f ./*.txt
root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/fun# 
```

先看一个例子，不管是`bash`的内置命令还是外部命令，当遇到参数中包含`-`的时候都很
容易被命令误当成一个选项，而不是参数来执行，规避这种情况的方法是使用`--`明确让命令
知道后面的都是参数，而不是选项。具体哪些命令受这个规则影响需要具体测试。


## 一些疑问

### 关于bash函数的参数长度

先看验证结论：

```bash
qinqing@DESKTOP-0MVRMOU:/mnt/e/code/pure_bash$     for((i=0;i<100000;i++)) ; do
>         tmp_str+="i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str."
>     done
qinqing@DESKTOP-0MVRMOU:/mnt/e/code/pure_bash$     test_case ()
>     {
>         local my_big_str="${1}"
>         echo "success, str lenth:${#my_big_str}"
>     }
qinqing@DESKTOP-0MVRMOU:/mnt/e/code/pure_bash$ test_case "$tmp_str"
success, str lenth:10500000
qinqing@DESKTOP-0MVRMOU:/mnt/e/code/pure_bash$ getconf ARG_MAX
2097152
qinqing@DESKTOP-0MVRMOU:/mnt/e/code/pure_bash$ 
```

我生成的字符串长度是`10.5M`，已经超过了最大的参数长度`2M`，但是这里并没有报错，是因为，不管是直接运行
脚本还是在命令行执行bash函数，参数的长度都不受`ARG_MAX的限制`，因为这里主要用`bash`内部的规则，是没有
限制的。但是如果传递这个参数给一个外部命令(不管是在脚本中还是在命令行)，那么这个时候参数的长度是就要
受`ARG_MAX`的限制了。

但是下面这种形式也不受限制(因为这里并不是作为参数传递给命令)：

```bash
wc -l <<<"$tmp_str"
```

下面这个就受限制了(使用外部的echo,而不是bash内建的)：

```bash
qinqing@DESKTOP-0MVRMOU:/mnt/e/code/pure_bash$ /usr/bin/echo "$tmp_str"
-bash: /usr/bin/echo: 参数列表过长
qinqing@DESKTOP-0MVRMOU:/mnt/e/code/pure_bash$ 
```

如果是使用`bash`内建的`echo`，那么参数的长度也不受限制。

命令替换的语法也不受缓冲区大小和这里的`ARG_MAX`的限制：

```bash
test_big_cmd_param_process ()
{
    # 内部函数在外部也是可见的，只是每次进test_big_cmd_param_process会被重新定义一次
    test_case ()
    {
        local my_big_str=("${@}")
        str_pack my_big_str 
    }

    local i
    local -a tmp_str=()

    # 生成一个105M的超大数组
    date
    for((i=0;i<1000000;i++)) ; do
        tmp_str+=("i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.")
    done
    date

    get_str=$(test_case "${tmp_str[@]}")
    echo "get_str length:${#get_str}"
}

```

它会执行括号中的命令，并将其输出作为字符串赋值给变量。这个过程并不涉及到缓冲区的问题，因为它是直接将命令的输出存储到变量中。

### bash4.4的一些BUG

#### 子shell中的循环问题

在`bash4.4`的兼容性列表中有这么一句话：

```bash
a subshell inherits loops from its parent context, so break or continue will 
cause the subshell to exit. Bash-5.0 and later reset the loop state to prevent 
the exit
```

看一个例子，下面的代码中`子shell`被中断，导致后面的`never print!`不会执行。这是
`bash4.4`的一个BUG。

```bash
#!/bin/bash

while true ; do
( break ; echo 'never print!' ; )
done
echo "end"
```

其实这个问题不严重，因为孤立的`break`或者是`continue`没有任何意义。像下面这个代码
在`bash4.4`中能正常工作。

```bash
Storage:~ # cat test.sh 
#!/bin/bash

while true ; do
    ( 
    while true ; do
    break ;
    done ;
    echo 'never print!'
    )
done
echo "end"

Storage:~ # 
```


### bash5.2的一些不兼容的情况

#### 关联数组的追加

:TODO: 社区求助


#### 进程替换的语法在某些嵌入式系统中无法使用

```bash
iBMC-1711 /data/dft/TestPlat/v40elabel_standard_load%card_mode_106/log # mapfile -t _LOG_INIT_VARIABLES_NAME < <(compgen -A variable)
bash_x: /dev/fd/62: No such file or directory
iBMC-1711 /data/dft/TestPlat/v40elabel_standard_load%card_mode_106/log # 
```

从上面看到，进程替换的语法出了问题，目前尚不知道原因。所以当前库中所有的这种语法都被替换了。

:TODO: 待研究。

