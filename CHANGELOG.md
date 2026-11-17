# Changelog

Breaking changes are listed first in each entry.

## 2.1.1 (2026-11-17)

- First release of this template: PrivateBin 2.1.1 on the official `privatebin/nginx-fpm-alpine` image, pinned by digest `sha256:9fbcc4d5671b974cafb55948d6fc3ab9eaf77f0c39271a50a16dd71bd4c4d3e6`.
- Pastes, comments, the server salt and the rate-limiter state live on a Railway volume at `/srv/data`.
- nginx listens on `PORT` and takes the visitor's address from `X-Forwarded-For`, so the rate limit applies per visitor behind Railway's proxy.
- Optional `PRIVATEBIN_CONFIG` variable for a full `conf.php`.
- Deploy on Railway button in the README.
