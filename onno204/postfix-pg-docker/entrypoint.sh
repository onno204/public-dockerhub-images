#!/bin/sh
set -e

[ -f /etc/postfix/postfix-files ] || cp /usr/share/postfix/postfix-files /etc/postfix/postfix-files

exec postfix start-fg
