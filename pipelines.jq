#!/usr/local/bin/jq -c -f

def env(x): x as $x | .env[] | select(.name == $x) | .value;
def key: .name | sub("CI_"; "") | ascii_downcase | gsub("_(?<a>[a-z0-9])"; .a | ascii_upcase);

[
  .items[].spec.containers[].env |
  map
  (
    select(.name | startswith("CI_")) |
    .key = key
  ) |
  from_entries | {projectName, pipelineId} |
  select
  (
    .pipelineId != null and
    .projectName != null
  )
#  {
#    "pipeline": env("CI_PIPELINE_ID"),
#    "project": env("CI_PROJECT_NAME")
#  }
] | unique_by(.pipelineId) | .[]
