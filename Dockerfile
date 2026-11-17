# PrivateBin for Railway: the official image, pinned by version and digest.
# Bump both together; see CHANGELOG.md.
FROM privatebin/nginx-fpm-alpine:2.1.1@sha256:9fbcc4d5671b974cafb55948d6fc3ab9eaf77f0c39271a50a16dd71bd4c4d3e6

# The entrypoint starts as root only to prepare the Railway volume (root-owned
# when Railway mounts it), set the listen port and optional config, then drops
# to the image's own unprivileged user (nobody:www-data) before PrivateBin starts.
USER root
COPY railway-realip.conf /etc/nginx/http.d/00-railway-realip.conf
COPY --chmod=0755 railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
