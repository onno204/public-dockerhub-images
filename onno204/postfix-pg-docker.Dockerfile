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
  rsyslog \
  rsyslog-pgsql \
  runit

COPY ./postfix-pg-docker/run.sh /usr/sbin/run.sh
# COPY runit_bootstrap /usr/sbin/runit_bootstrap
# COPY rsyslog.conf /etc/rsyslog.conf
RUN chmod +x /usr/sbin/run.sh


RUN ln -sf /dev/stdout /var/log/mail.log

STOPSIGNAL SIGKILL

ENTRYPOINT ["/usr/sbin/run.sh"]
