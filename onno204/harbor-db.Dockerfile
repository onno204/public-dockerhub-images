# Copied from https://github.com/goharbor/harbor/blob/main/make/photon/db/Dockerfile.base

# START: https://github.com/goharbor/harbor/blob/main/make/photon/db/Dockerfile.base
FROM photon:5.0 as photon-builder

ENV PGDATA /var/lib/postgresql/data

RUN tdnf install -y shadow >> /dev/null \
  && groupadd -r postgres --gid=999 \
  && useradd -m -r -g postgres --uid=999 postgres

RUN tdnf install -y postgresql14-server >> /dev/null
RUN tdnf install -y gzip postgresql15-server findutils bc >> /dev/null \
  && mkdir -p /docker-entrypoint-initdb.d \
  && mkdir -p /run/postgresql \
  && chown -R postgres:postgres /run/postgresql \
  && chmod 2777 /run/postgresql \
  && mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA" \
  && sed -i "s|#listen_addresses = 'localhost'.*|listen_addresses = '*'|g" /usr/pgsql/15/share/postgresql/postgresql.conf.sample \
  && sed -i "s|#unix_socket_directories = '/tmp'.*|unix_socket_directories = '/run/postgresql'|g" /usr/pgsql/15/share/postgresql/postgresql.conf.sample \
  && tdnf clean all

RUN tdnf erase -y toybox && tdnf install -y util-linux net-tools


# START: https://github.com/goharbor/harbor/blob/main/make/photon/db/Dockerfile
FROM photon-builder as production

VOLUME /var/lib/postgresql/data

COPY ./onno204/harbor-db/docker-entrypoint.sh /docker-entrypoint.sh
COPY ./onno204/harbor-db/initdb.sh /initdb.sh
COPY ./onno204/harbor-db/upgrade.sh /upgrade.sh
COPY ./onno204/harbor-db/docker-healthcheck.sh /docker-healthcheck.sh
COPY ./onno204/harbor-db/initial-registry.sql /docker-entrypoint-initdb.d/


RUN chown -R postgres:postgres /docker-entrypoint.sh /docker-healthcheck.sh /docker-entrypoint-initdb.d \
  && chmod u+x /docker-entrypoint.sh /docker-healthcheck.sh /upgrade.sh

ENTRYPOINT ["/docker-entrypoint.sh", "14", "15"]
HEALTHCHECK CMD ["/docker-healthcheck.sh"]

USER postgres
