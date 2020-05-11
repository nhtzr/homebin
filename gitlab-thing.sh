#!/usr/bin/env bash
TOKEN_FILE=~/.ssh/gitlab-token.txt

function are_pipelines_running {
  curl -#f https://gitlab.tuk2.intelius.com/api/v4/groups/9 -H "$(cat ${TOKEN_FILE})" |
    jq '.projects[].id' |
    while IFS='\n' read -r id; do
      jq --arg project $id '.[] | select(.status == "running") | . + {"project": $project}' \
        <( curl -#f https://gitlab.tuk2.intelius.com/api/v4/projects/$id/pipelines -H "$(cat ${TOKEN_FILE})") \
        >&2 ;
    done
}


function latest_pipelines {
  curl -#f https://gitlab.tuk2.intelius.com/api/v4/groups/9 -H "$(cat ${TOKEN_FILE})" |
    jq -c '.projects[] | {name, id}' |
    while IFS='\n' read -r project; do
      jq -c --arg name "$(echo $project | jq -r '.name')"  'first(.[] | select(.ref == "master")) + {$name} | {sha, name}' \
        <( curl -#f "https://gitlab.tuk2.intelius.com/api/v4/projects/$(echo $project | jq -r '.id')/pipelines" -H "$(cat ${TOKEN_FILE})") \
        >&2 ;
    done
}

function latest_commit {
  curl -#f https://gitlab.tuk2.intelius.com/api/v4/groups/9 -H "$(cat ${TOKEN_FILE})" |
    jq -c '.projects[] | {name, id}' |
    while IFS='\n' read -r project; do
      jq -c -n \
        --arg name "$(echo $project | jq -r '.name')" \
        --arg sha "$(curl -#f "https://gitlab.tuk2.intelius.com/api/v4/projects/$(echo $project | jq -r '.id')/repository/branches/master" -H "$(cat ${TOKEN_FILE})" | jq -r '.commit.id')" \
        '{$name, $sha}'
    done
}

function latest_tag {
  curl -#f https://gitlab.tuk2.intelius.com/api/v4/groups/9 -H "$(cat ${TOKEN_FILE})" |
    jq -c '.projects[] | {name, id}' |
    while IFS='\n' read -r project; do
      jq -c -n \
        --arg name "$(echo $project | jq -r '.name')" \
        --arg tag "$(curl -#f "https://gitlab.tuk2.intelius.com/api/v4/projects/$(echo $project | jq -r '.id')/repository/tags" -H "$(cat ${TOKEN_FILE})" | jq -r 'first.name')" \
        '{$name, $tag}'
    done
}

function check_project {
  local project_id=${1?}
  curl -#f "https://gitlab.tuk2.intelius.com/api/v4/projects/${project_id}" -H "$(cat ${TOKEN_FILE})" | jq .
}

function lint {
  set -x
  curl -#vv --header "Content-Type: application/json" https://gitlab.tuk2.intelius.com/api/v4/ci/lint --data '{"content": "{ \"image\": \"ruby:2.6\", \"services\": [\"postgres\"], \"before_script\": [\"bundle install\", \"bundle exec rake db:create\"], \"variables\": {\"DB_NAME\": \"postgres\"}, \"types\": [\"test\", \"deploy\", \"notify\"], \"rspec\": { \"script\": \"rake spec\", \"tags\": [\"ruby\", \"postgres\"], \"only\": [\"branches\"]}}"}'
}

function each-tag {
  local project_id=${3?}
  local repo_id=${2?}
  local tag=${3?}
  echo $tag > /dev/stderr
  curl -#f "https://gitlab.tuk2.intelius.com/api/v4/projects/$project_id/registry/repositories/$repo_id/tags/$tag" -H "$(cat ${TOKEN_FILE})"
}

export -f each-tag

function oldest-tags {
  set -x
  local project_id=${1?project_id}
  local repo_id=${2:-}


  if test -z "${repo_id}"; then
    curl -#f https://gitlab.tuk2.intelius.com/api/v4/projects/$project_id/registry/repositories -H "$(cat ${TOKEN_FILE})" -vv | jq .
    return 0
  fi

  (
    curl -#f https://gitlab.tuk2.intelius.com/api/v4/projects/$project_id/registry/repositories/$repo_id/tags -H "$(cat ${TOKEN_FILE})" |
      jq '.[].name' -r |
      xargs -I{} bash -c "each-tag '$project_id' '$repo_id' '{}'"
  ) | jq -s 'sort_by(.created_at | gsub("\\.\\d\\d\\d\\+00:00$"; "Z") | fromdateiso8601)'

  # curl -#f https://gitlab.tuk2.intelius.com/api/v4/projects/$project_id/registry/repositories/$repo_id/tags/chore-fluentd -H "$(cat ${TOKEN_FILE})" -vv | jq . | nvim - -c 'set ft=json'
}

