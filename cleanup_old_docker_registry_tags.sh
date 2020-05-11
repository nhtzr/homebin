#!/usr/bin/env bash

[ -n "${token:-}" ] || token=~/.ssh/gitlab-root-token.txt

curl() {
  command curl -#f -H "$(cat ~/.ssh/gitlab-root-token.txt)" "$@"
}

declare page=1
declare project_id
while true; do
  project_id="$(curl "https://gitlab.tuk2.intelius.com/api/v4/projects" -G -d per_page=1 -d page="${page}" | jq -r '.[].id')"
  let page++ || true
  if test -z "${project_id:-}"; then
    break
  fi
  while IFS=$'\n' read registry_id ; do
    if test -z "${registry_id:-}"; then
      continue
    fi

    curl \
      --request DELETE \
      --data 'name_regex=[0-9a-z]{40}' \
      --data 'keep_n=5' \
      --data 'older_than=1month' \
      "https://gitlab.tuk2.intelius.com/api/v4/projects/$project_id/registry/repositories/$registry_id/tags"

  done < <(
    curl "https://gitlab.tuk2.intelius.com/api/v4/projects/$project_id/registry/repositories" | jq -r '.[].id'
  )
done

