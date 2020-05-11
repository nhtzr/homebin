#!/usr/bin/env bash

ssh puppetmaster01.prod.iad1.cmates.com hostlist -e iad1 "${1?}" | sort -u
# ^ this is easier to parse, but only includes the servers with recen healtcheck

# v this is harder to read, but includes more information and all servers that
#  have ever installed the rpm
# ssh puppetmaster01.prod.iad1.cmates.com rpmhistory -e iad1 "${1?}" | 
#   ansifilter |
#   awk '$2 == ":" {print $1}' |
#   sort -u

