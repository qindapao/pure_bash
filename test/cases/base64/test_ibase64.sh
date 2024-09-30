#!/usr/bin/bash

_test_ibase64_old_dir=$PWD
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./base64/base64_encode.sh || return 1
. ./base64/base64_decode.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_ibase64_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local test_str=""
    local -i ret_code=0
    {
    IFS= read -r -d '' test_str <<'    EOF'
    在一个晴朗的早晨，Alice走在公园里，心情愉快。她突然想起了昨天晚上看的那本书，书中提到：“生活就像一盒巧克力\U0001f36b，你永远不知道你会得到什么。”这句话让她深有感触。
“Hello, Alice!” 一个熟悉的声音传来。她转过身，看到她的朋友小明正向她挥手。“你今天看起来很开心啊！”
“是啊，小明，”Alice笑着回答，“我刚刚在想，生活中有很多未知的惊喜，就像这句话说的——‘Life is like a box of chocolates, you never know what you’re gonna get.’”
小明点点头，说：“没错！我们应该珍惜每一天，享受每一个瞬间。对了，今天下午有一个音乐会\U0001f3b5，你要不要一起去？”
“当然好啊！”Alice兴奋地说，“我最喜欢音乐会了！”
他们继续在公园里散步，聊着各种有趣的话题。突然，小明停下脚步，指着前方说：“看，那边有一只小猫\U0001f431！”
Alice顺着他的手指看去，果然看到一只可爱的小猫正在草地上玩耍。她走过去，轻轻地抚摸小猫的头，小猫发出愉快的喵喵声。
“这只小猫真可爱！”Alice说，“我真希望我也能养一只。”
“那你为什么不试试呢？”小明问道。
“我住的地方不允许养宠物，”Alice有些遗憾地说，“不过，我可以经常来这里看这只小猫。”
他们继续在公园里散步，享受着美好的时光。突然，天空中出现了一道彩虹\U0001f308，他们停下脚步，欣赏着这美丽的景象。
“这真是一个美好的早晨，”Alice感叹道，“有时候，生活中的小惊喜真的能让人感到幸福。”
“是啊，”小明点点头，“我们应该学会发现和珍惜这些美好的瞬间。”
他们继续在公园里散步，聊着各种有趣的话题。突然，小明停下脚步，指着前方说：“看，那边有一只小猫\U0001f431！”
Alice顺着他的手指看去，果然看到一只可爱的小猫正在草地上玩耍。她走过去，轻轻地抚摸小猫的头，小猫发出愉快的喵喵声。
“这只小猫真可爱！”Alice说，“我真希望我也能养一只。”
“那你为什么不试试呢？”小明问道。
“我住的地方不允许养宠物，”Alice有些遗憾地说，“不过，我可以经常来这里看这只小猫。”
他们继续在公园里散步，享受着美好的时光。突然，天空中出现了一道彩虹\U0001f308，他们停下脚步，欣赏着这美丽的景象。
“这真是一个美好的早晨，”Alice感叹道，“有时候，生活中的小惊喜真的能让人感到幸福。”
“是啊，”小明点点头，“我们应该学会发现和珍惜这些美好的瞬间。”
他们继续在公园里散步，聊着各种有趣的话题。突然，小明停下脚步，指着前方说：“看，那边有一只小猫\U0001f431！”
Alice顺着他的手指看去，果然看到一          只可爱的小猫正在草地上玩耍。她走过去，轻轻地抚摸小猫的头，小猫发出愉快的喵喵声。
“这只小猫真可爱！”Alice说，“我真希望我也能养一只。”
“那你为什么不试试呢？”小明问道。
“我住的地方不允许养宠物，”Alice有些遗憾地说，“不过，我可以经常来这里看这只小猫。”



他们继续在公园里散步，享受着美好的时光。突然，天空中出现了一道彩虹\U0001f308，他们停下脚步，欣赏着这美丽的景象。
“这真是一个美好的早晨，”Alice感叹道，“有时候，生活中的小惊喜真的能让人感到幸福。”
“是啊，”小明点点头，“我们应该学会发现和珍惜这些美好的瞬间。”

     




    EOF
    } || true

    local ibase_str obase_str
    base64_encode ibase_str "$test_str" 
    obase_str=$(printf "%s" "$test_str" |base64 -w 0)
    if [[ "$ibase_str" == "$obase_str" ]] ; then
        echo "${FUNCNAME[0]} encode test pass"
    else
        echo "${FUNCNAME[0]} encode test fail"
        ret_code=1
    fi

    # declare -p ibase_str
    
    local d_ibase_str d_obase_str
    base64_decode d_ibase_str "$ibase_str"
    # 解码的时候会丢失结尾所有的换行符,所以要补空格,然后删掉
    d_obase_str=$(printf "%sIA==" "$ibase_str" | base64 -d)
    d_obase_str=${d_obase_str%?}

    if [[ "$d_ibase_str" == "$test_str" ]] && 
        [[ "$d_obase_str" == "$test_str" ]] ; then
        echo "${FUNCNAME[0]} decode test pass"
    else
        echo "${FUNCNAME[0]} decode test fail"
        ret_code=1
    fi
    
    return $ret_code
}

test_case1

