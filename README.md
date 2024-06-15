# pure_bash

bash是优美的，纯bash更优美，本项目尽量使用bash内置的功能来实现需求。当前某些情况下，也会使用少数强大的外部命令。

不使用递归实现，函数与函数之间不能嵌套调用。比如`A->B->C->A`是不允许的。

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

可以在使用中只放我们需要的函数，这样就不用降整个库拷贝到TU中，节省了代码的空间和灵活性。同时也能最大化验证库的功能，并且TU中的代码都是需要的。没有无关的代码，代码检视的数据也会准确。

**copy_modules.sh**

这个脚本的目的是根据指定要使用模块拷贝关联模块，防止了手动拷贝的遗漏情况。

使用方法：

1. 编辑`copy_modules.cfg`文件，指定需要拷贝的模块，脚本会自动拷贝这些模块的相关关联模块。
2. 使用`bash copy_modules.sh`的方法来执行脚本，脚本执行完成后会生成`copy_modules`目录，我们需要的模块都在里面。

## bash特殊语法记录

### 语句

#### case语句

```bash
case "$a" in
    (1) echo 'xx' ;;
    2)  echo 'yy' ;;
esac
```

在`case`语句中，使用`半括号`或者`全括号`都是可以的。

### 参数

`bash`的命令行参数是有最大值的，一般由系统的`ARG_MAX`参数决定。一般是`2M`。所以在有大数据的场景下执行`bash`代码要特别小心，使用`xargs`之类的工具来处理。

但是`bash`内部的一些操作，比如数组`a=("${b[@]}")`类似的语法是在内存中处理的，并不受命令行参数的影响。要搞清楚哪些是在操作命令行参数，哪些是语言内置的功能(这些都是在内存中处理)。

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

