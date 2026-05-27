# Base copied and editted from https://github.com/cloakmail/postfix-pg-docker, who has modified it from https://github.com/jessfraz/dockerfiles
FROM alpine:3

RUN apk add --no-cache \
  bash \
  ca-certificates \
  libsasl \
  mailx \
  sed \
  postfix \
  postfix-pgsql

# postfix-btree \

# If postfix fails to open /dev/stdout after a restart ("Permission denied"), run: chmod 666 /dev/stdout
# See: https://github.com/Mailu/Mailu/issues/3271
RUN postconf -e "maillog_file=/dev/stdout"

STOPSIGNAL SIGTERM

ENTRYPOINT ["postfix", "start-fg"]
