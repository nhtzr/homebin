#!/usr/bin/env bash

set -euo pipefail

xargs_debug_flag() {
  if [[ "${-}" == *x* ]]; then
    printf '%s' '-t'
  fi
}

[ -n "${AWS_PROFILE:-}" ] || export AWS_PROFILE="${1?AWS_PROFILE missing}"

aws_ecr_get_repository_names() {
  aws ecr describe-repositories | jq -r '.repositories[].repositoryName'
}

aws_ecr_get_image_tags() {
  local repositoryName="${1?}"
  aws ecr describe-images --repository-name "$repositoryName" |
    jq -r '.imageDetails[] | ( (.imageTags | debug)[] ) as $imageTag | ["\(.repositoryName):\($imageTag)", .imageDigest] | @tsv'
}

main_1() {
  {
    while IFS='\n' read -r repositoryName; do
      test -n "${repositoryName:-}" || continue
      aws_ecr_get_image_tags "$repositoryName"
    done < <( aws_ecr_get_repository_names )
  } | column -ts $'\t'
}

main_2() {
  aws_ecr_get_repository_names |
    xargs $(xargs_debug_flag) -r -I{} aws ecr describe-images --repository-name '{}' |
    jq -r '.imageDetails[] | ( try (.imageTags[]) catch "" ) as $imageTag | ["\(.repositoryName):\($imageTag)", .imageDigest] | @tsv' |
    column -ts $'\n'
}

todo_main_3() {
  aws ecr describe-repositories --out text --query 'repositories[*].[repositoryName]' |
    xargs $(xargs_debug_flag) -r -I{} aws ecr describe-images --repository-name '{}' --out text --query 'imageDetails[*].[repositoryName,join(",", imageTags),imageDigest]' |
    column -ts $'\n'
}

