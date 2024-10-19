# pure_bash

bash是优美的，纯bash更优美，本项目尽量使用bash内置的功能来实现需求。当前某些情况下，也会使用少数强大的外部命令。

不使用递归实现，函数与函数之间不能嵌套调用。比如`A->B->C->A`是不允许的。

关于检查库函数是否存在嵌套调用情况，可以使用`dependency_diagram.py`生成函数的调用关系图，如果想用更直观更交互式的方式  
查看函数之间的调用关系以及校验是否有嵌套引用的情况，可以使用`dependency_diagram_interact.py`生成函数调用关系节点的`json`  
配置文件，然后使用`dependency_diagram_interact.html`生成动态可以交互的调用关系图谱，通过浏览器查看当前库函数的函数调用  
情况，并且可以直观发现有嵌套引用的情况，这种函数都需要修改。

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


3个比较厉害的bash库：

https://github.com/hornos/shf3
https://github.com/javier-lopez/learn
https://github.com/scop/bash-completion

## Credits

本库使用了 [JSON.awk](https://github.com/step-/JSON.awk)，一个用`awk`实现的`json`解析程序。比较稳定可靠。

