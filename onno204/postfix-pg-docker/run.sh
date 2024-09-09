#!/bin/bash
set -e

if [[ -f "/usr/libexec/postfix/master" ]]; then
  cmd="/usr/libexec/postfix/master"
fi

if [[ -f "/usr/lib/postfix/master" ]]; then
  cmd="/usr/lib/postfix/master"
fi

if [[ -z "$cmd" ]]; then
  echo "Could not find postfix master in /usr/lib or /usr/libexec"
  exit 1
fi

"$cmd" -c /etc/postfix -d 2>&1
