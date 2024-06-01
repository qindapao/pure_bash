# pure_bash
A tool library implemented in pure bash, unless it is absolutely necessary, 
no external programs are required to ensure excellent performance of the library

In rare cases external tools may be used. Do not use recursion, and functions cannot be nested. For example, `A->B->C->A` is not allowed.

## How to use these library functions

```bash
IMPORT_FUNCS=(
    ./str/str_basename.sh
    ./str/str_contains.sh
)
for i in "${IMPORT_FUNCS[@]}" ; do . "$i" || exit 1 ; done
```

As above, if there is any error, the script will exit and will not continue to execute. The function will handle dependencies by itself. If some files are missed in the copy (or it is not known that some functions depend on other functions, it will handle dependencies by itself. If there is a problem, it will report an error and the exit code is not 0), the export stage will exit here to avoid missing the copy of the function source file.

** What are the benefits of this? **

You can only put the functions you need in your project, so you don’t have to copy the entire library to projetc, saving space and flexibility.

