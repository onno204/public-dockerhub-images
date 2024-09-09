# Base copied and editted from https://github.com/cloakmail/postfix-pg-docker, who has modified it from https://github.com/jessfraz/dockerfiles
FROM alpine:3

RUN apk add --no-cache \
  bash \
  ca-certificates \
  libsasl \
  mailx \
  sed \
  postfix \ 
  postfix-pgsql \
  postfix-btree \
  rsyslog \
  rsyslog-pgsql \
  runit

COPY ./onno204/postfix-pg-docker/service /etc/service
COPY ./onno204/postfix-pg-docker/runit_bootstrap /usr/sbin/runit_bootstrap
COPY ./onno204/postfix-pg-docker/rsyslog.conf /etc/rsyslog.conf

RUN chmod +x /usr/sbin/runit_bootstrap
RUN chmod +x /etc/service/postfix/run
RUN chmod +x /etc/service/rsyslog/run

RUN ln -sf /dev/stdout /var/log/mail.log

STOPSIGNAL SIGKILL

ENTRYPOINT ["/usr/sbin/runit_bootstrap"]
