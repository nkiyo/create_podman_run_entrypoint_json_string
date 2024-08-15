#!/bin/bash
source sample.env

# envファイル内のPARAM_で始まる値を、JSONリスト化する
# リストは、podman run --entrypoint オプションに渡せる形式とする
arg_cnt=1
jq_arg=()
for var in ${!PARAM_@}; do
  key=$(echo --$var | tr '[:upper:]' '[:lower:]' | sed 's/param_//g' | tr '_' '-')
  jq_arg+=("--arg")
  jq_arg+=(i$arg_cnt)
  jq_arg+=("$key")
  jq_arg+=("--arg")
  jq_arg+=(i$((arg_cnt + 1)))
  jq_arg+=("${!var}")
  arg_cnt=$((arg_cnt + 2))
done
jq_arg_list=$(seq $((arg_cnt - 1)) | xargs -I{} echo '$i{}' | paste -sd, | sed 's/^/[/; s/$/]/')

#echo jq -nc "${jq_arg[@]}" $jq_arg_list
json_list=$(jq -nc "${jq_arg[@]}" "$jq_arg_list")
echo \' $json_list \'

