#!/bin/bash
source sample.env

# envファイル内のPARAM_で始まる値を、JSONリスト化する
# リストは、podman run --entrypoint オプションに渡せる形式とする
arg_cnt=1
jq_arg=()
for var in ${!PARAM_@}; do
  # パラメータ名を変換する
  # 例: PARAM_HOGE_AAA => --hoge-aaa 
  key=$(echo --$var | tr '[:upper:]' '[:lower:]' | sed 's/param_//g' | tr '_' '-')

  # パラメータ名と値を--argで渡すためのリストを作る
  # 例: --arg i1 --hoge-aaa --arg i2  abc
  jq_arg+=("--arg")
  jq_arg+=(i$arg_cnt)
  jq_arg+=("$key")
  jq_arg+=("--arg")
  jq_arg+=(i$((arg_cnt + 1)))
  jq_arg+=("${!var}")
  arg_cnt=$((arg_cnt + 2))
done

# jqのフォーマット文字列の部分
# 例: '[$i1, $i2, $i3]'
jq_arg_list=$(seq $((arg_cnt - 1)) | xargs -I{} echo '$i{}' | paste -sd, | sed 's/^/[/; s/$/]/')

#echo jq -nc "${jq_arg[@]}" $jq_arg_list
json_list=$(jq -nc "${jq_arg[@]}" "$jq_arg_list")
echo \' $json_list \'

