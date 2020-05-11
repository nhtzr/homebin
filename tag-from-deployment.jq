#!/usr/local/bin/jq -r -c -f

.spec.template.spec.containers[].image | capture(":(?<a>[a-zA-Z0-9.]*)$").a
