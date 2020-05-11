#!/usr/bin/env bash

set -ueo pipefail

prefix="${1:-}"
suffix="${2:-}"

a="$(cat)"
a="${a##${prefix}}"
a="${a%%${suffix}}"
echo ${a}
