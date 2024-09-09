# Postfix with postfix-pgsql

Base copied and editted from <https://github.com/cloakmail/postfix-pg-docker>, who has modified it from <https://github.com/jessfraz/dockerfiles>

## Postfix Docker Image with Postgres Support

A Postfix Docker image with PostgreSQL support. This image allows you to...

1. Use Postgres-based alias lookups
2. Configure Postfix via environment variables (as an alternative to config files)
2. Forward Postfix logs to Postgres

## Example Usage

```
docker run --rm -ti -p 25:25 -p 587:587 \
  -e CONF_MYDOMAIN=example.com \
  -e CONF_RELAYHOST=[smtp.mailgun.org]:587
  -e SASL_AUTH=username:password \
  -e POSTGRES_HOSTS=pg_host \
  -e POSTGRES_USER=postfix_user \
  -e POSTGRES_PASSWORD=postfix_user_password \
  -e POSTGRES_ALIAS_DB=aliases \
  -e POSTGRES_ALIAS_QUERY="SELECT forw_addr FROM mxaliases WHERE alias='%s'" \
  -e POSTGRES_LOG_HOST=pg_host \
  -e POSTGRES_LOG_DB=postfix_logs \
  -e POSTGRES_LOG_USER=log_user \
  -e POSTGRES_LOG_PASSWORD=log_user_password \
  -e POSTGRES_LOG_TABLE=postfix_logs
  onno204/postfix-pg-docker:latest
```

## Configuration

This image aims to make Postfix configurable primarily through environment variables so that you don't have to bake config files into your sub-image.

### General

All settings need to be managed using the config files in `/etc/postfix`. This needs to de mapped to a local directory or a volume.

## Acknowledgements

*This image is a slightly modified version of the postfix image found in [cloakmail/postfix-pg-docker](https://github.com/cloakmail/postfix-pg-docker).*
*This image is a slightly modified version of the postfix image found in [Jessie Frazelle's dockerfile collection](https://github.com/jessfraz/dockerfiles).*
