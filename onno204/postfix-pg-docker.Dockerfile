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

# postfix-files is installed by the package into /etc/postfix/, but a volume mount over /etc/postfix
# hides it. postfix start-fg calls post-install which requires this file to set up queue directories.
# Save it outside /etc/postfix so the entrypoint can restore it after the volume is mounted.
RUN cp /etc/postfix/postfix-files /usr/share/postfix/postfix-files

COPY ./onno204/postfix-pg-docker/entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod +x /usr/sbin/entrypoint.sh

STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
