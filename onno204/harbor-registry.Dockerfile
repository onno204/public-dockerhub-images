# Copied from https://github.com/goharbor/harbor/blob/main/make/photon/registry/Dockerfile

# START: https://github.com/goharbor/harbor/blob/main/make/photon/registry/Dockerfile.binary
FROM golang:1.23.2 as go-binary

ENV DISTRIBUTION_DIR /go/src/github.com/docker/distribution
ENV BUILDTAGS include_oss include_gcs
ENV GO111MODULE auto

WORKDIR $DISTRIBUTION_DIR
# COPY ./onno204/harbor-registry/ $DISTRIBUTION_DIR

# RUN git clone https://gitlab.com/gitlab-org/container-registry.git .
RUN git clone https://github.com/distribution/distribution.git .

RUN CGO_ENABLED=0 make PREFIX=/go clean binaries

# START: https://github.com/goharbor/harbor/blob/main/make/photon/registry/Dockerfile.base
FROM photon:5.0 as photon-builder

ENV PGDATA /var/lib/postgresql/data

RUN tdnf install -y shadow >> /dev/null \
  && tdnf clean all \
  && mkdir -p /etc/registry \
  && groupadd -r -g 10000 harbor && useradd --no-log-init -m -g 10000 -u 10000 harbor

# START: https://github.com/goharbor/harbor/blob/main/make/photon/registry/Dockerfile
FROM photon-builder as production

COPY --chmod=0755 ./onno204/harbor-common/install_cert.sh /home/harbor
COPY --chmod=0755 ./onno204/harbor-registry/entrypoint.sh /home/harbor
COPY --chmod=0755 --from=go-binary /go/src/github.com/docker/distribution/bin/registry /usr/bin/registry_DO_NOT_USE_GC

RUN chown -R harbor:harbor /etc/pki/tls/certs \
  && chown harbor:harbor /home/harbor/entrypoint.sh && chmod u+x /home/harbor/entrypoint.sh \
  && chown harbor:harbor /home/harbor/install_cert.sh && chmod u+x /home/harbor/install_cert.sh \
  && chown harbor:harbor /usr/bin/registry_DO_NOT_USE_GC && chmod u+x /usr/bin/registry_DO_NOT_USE_GC

RUN mkdir -p /etc/harbor/ssl
RUN chown -R harbor:harbor /etc/harbor/ssl

HEALTHCHECK CMD curl --fail -s http://localhost:5000 || curl -k --fail -s https://localhost:5443 || exit 1

USER harbor

ENTRYPOINT ["/home/harbor/entrypoint.sh"]

VOLUME ["/storage"]