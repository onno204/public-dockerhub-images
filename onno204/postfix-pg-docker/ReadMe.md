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
  -v '/mnt/user/appdata/postfix-pg/config':'/etc/postfix':'rw'
  onno204/postfix-pg-docker:latest
```

### General

All settings need to be managed using the config files in `/etc/postfix`. This needs to de mapped to a local directory or a volume.

## Acknowledgements

*This image is a slightly modified version of the postfix image found in [cloakmail/postfix-pg-docker](https://github.com/cloakmail/postfix-pg-docker).*
*This image is a slightly modified version of the postfix image found in [Jessie Frazelle's dockerfile collection](https://github.com/jessfraz/dockerfiles).*
