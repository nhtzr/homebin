#!/usr/bin/env bash

function kops-elb {
  aws --profile=prodadmin elb describe-load-balancers | jq '.LoadBalancerDescriptions[] | select([.ListenerDescriptions[].Listener.LoadBalancerPort] == [80,443]) | .DNSName' -r
}

function one-ip {
  nslookup "$(kops-elb)" | grep "^Address: " | tail -n 1 | cut -d' ' -f2
}

kops-elb
