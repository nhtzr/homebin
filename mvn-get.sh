#!/usr/bin/env bash

usage="usage: ${0} group artifact version"

mvn \
  org.apache.maven.plugins:maven-dependency-plugin:2.1:get \
  -DrepoUrl=http://central.maven.org/maven2 \
  -Dartifact="${1?}:${2?}:${3?}"
