# Base copied and editted from https://github.com/cloakmail/postfix-pg-docker, who has modified it from https://github.com/jessfraz/dockerfiles
FROM alpine:3

RUN apk add --no-cache \
  bash \
  ca-certificates \
  libsasl \
  mailx \
  sed \
  postfix \
  postfix-lmdb \
  postfix-pgsql

# postfix-btree \

# If postfix fails to open /dev/stdout after a restart ("Permission denied"), run: chmod 666 /dev/stdout
# See: https://github.com/Mailu/Mailu/issues/3271
RUN postconf -e "maillog_file=/dev/stdout"

# etc/postfix/postfix-files is required for `postfix start-fg`, but removed when overwriting a volume-mount
RUN mkdir -p /usr/share/postfix && cp /etc/postfix/postfix-files /usr/share/postfix/postfix-files

COPY ./onno204/postfix-pg-docker/entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod +x /usr/sbin/entrypoint.sh

STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
