. ./meta/meta.sh
((DEFENSE_VARIABLES[float_mul]++)) && return 0

# :TODO: 这个函数的原理是什么?
# :TODO: 如果对效率要求不高尽量别使用这个函数，正确性没有得到充分验证，并且原理还没弄清楚
#        浮点运算还是用awk或者bc比较好
# https://cfajohnson.com/shell/?2012-11-08_floating_point_multiplication
float_mul () #@ USAGE: fpmul '' NUM NUM ... => $_FLOAT_MUL
{
    local -n _float_mul_out_ref=${1:-_FLOAT_MUL}
    shift
    local places= tot=1 qm= neg= n= int= dec= df=
    for n ; do
        ## 2 negatives make a positive
        case $n in
        -*) [[ "$neg" == '-' ]] && neg= || neg='-'
            n=${n#-}
            ;;
        esac

        ## Check for non-numeric characters
        case $n in
            *[!0-9.]*) return 1 ;;
        esac

        ## count the number of decimal places,
        ## then remove the decimal point
        case $n in
        .*) int=
            dec=${n#?}
            places=$places$dec
                n=$dec
            ;;
        *.*) dec=${n#*.}
            int=${n%.*}
            places=$places$dec
                n=$int$dec
            ;;
        esac

        ## remove leading zeroes
        while : ; do
            case $n in
              ""|0) n=0
                _float_mul_out_ref=0
                return
                ;;
              0*) n=${n#0} ;;
              *) break;;
            esac
        done

        ## multiply by the previous total
        ((tot*=${n:-0}))

        ## report any overflow error
        case $tot in
            -*) printf "fpmul: overflow error: %s\n" "$tot" >&2
                return 1
                ;;
        esac
    done

    while ((${#tot}<${#places})) ; do
        tot=0$tot
    done

    df=
    while ((${#df}<${#places})) ; do
        left=${tot%?}
        df=${tot#$left}$df
        tot=$left
    done
    _float_mul_out_ref=$tot${df:+.$df}

    ## remove trailing zeroes or decimal points
    while : ; do
        case $_float_mul_out_ref in
        *.*[0\ ]|*.) _float_mul_out_ref=${_float_mul_out_ref%?} ;;
        .*)  _float_mul_out_ref=0$_float_mul_out_ref ;;
        *) break ;;
        esac
    done

    _float_mul_out_ref="${neg}${_float_mul_out_ref}"
    return 0
}

return 0

