.items[] | select(.status.reason | values | contains("Evicted")) | .spec.nodeName
