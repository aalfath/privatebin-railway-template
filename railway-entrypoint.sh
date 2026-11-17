#!/bin/sh
# Railway wrapper for the official PrivateBin image.
set -eu

DATA_DIR=/srv/data
APP_UID=65534   # nobody, the image's own user
APP_GID=82      # www-data
PORT="${PORT:-8080}"

if [ "$(id -u)" = "0" ]; then
  # Railway volumes are mounted root-owned; PrivateBin runs as nobody.
  mkdir -p "$DATA_DIR"
  if [ "$(stat -c %u "$DATA_DIR")" != "$APP_UID" ]; then
    chown -R "$APP_UID:$APP_GID" "$DATA_DIR"
  fi
  chmod 0750 "$DATA_DIR"

  # Listen on Railway's PORT (8080 unless you change it).
  case "$PORT" in
    ''|*[!0-9]*) echo "PORT must be a number, got '$PORT'" >&2; exit 1 ;;
  esac
  sed -i -E "s/listen ([^0-9]*)[0-9]+ default_server;/listen \1${PORT} default_server;/" \
    /etc/nginx/http.d/site.conf

  # Optional: the full contents of PrivateBin's conf.php (INI format) in
  # PRIVATEBIN_CONFIG. Without it, PrivateBin's built-in defaults apply.
  if [ -n "${PRIVATEBIN_CONFIG:-}" ]; then
    printf '%s\n' "$PRIVATEBIN_CONFIG" > /srv/cfg/conf.php
    chown "$APP_UID:$APP_GID" /srv/cfg/conf.php
    chmod 0640 /srv/cfg/conf.php
  fi

  # php-fpm and nginx reopen /dev/stderr after the switch; let them.
  chmod a+rw /proc/self/fd/1 /proc/self/fd/2 || true

  exec s6-applyuidgid -u "$APP_UID" -g "$APP_GID" -G "$APP_GID" /etc/init.d/rc.local
fi

# Already unprivileged (for example docker run --user): start as upstream does.
exec /etc/init.d/rc.local
