[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/privatebin-1?utm_medium=integration&utm_source=button&utm_campaign=privatebin)

# PrivateBin on Railway

One-click [PrivateBin](https://privatebin.info/) for [Railway](https://railway.com): a minimalist, open-source pastebin where the server has zero knowledge of what is pasted. The browser encrypts every paste with 256-bit AES-GCM before it is sent, and the key stays in the part of the link after `#`, which browsers never send to the server.

## What this template deploys

| | |
|---|---|
| App | PrivateBin **2.1.1** |
| Image | official [`privatebin/nginx-fpm-alpine:2.1.1`](https://hub.docker.com/r/privatebin/nginx-fpm-alpine), pinned by digest `sha256:9fbcc4d5671b974cafb55948d6fc3ab9eaf77f0c39271a50a16dd71bd4c4d3e6` |
| Services | one, `PrivateBin` (nginx + PHP-FPM), with a public HTTPS domain |
| Storage | a Railway volume at `/srv/data`: pastes, comments, the server salt and the rate-limiter state |
| Health check | `GET /` |

There is no admin account and no setup step: open the URL and paste.

The wrapper (`railway-entrypoint.sh`) is small. On boot it gives the volume to the image's own unprivileged user (Railway mounts volumes as root), makes nginx listen on `PORT`, writes your optional configuration, then starts PrivateBin as `nobody:www-data`, exactly as upstream does. `railway-realip.conf` makes nginx use the visitor's address from `X-Forwarded-For`, so PrivateBin's per-visitor rate limit (one new paste per 10 seconds) applies to each visitor rather than to Railway's proxy, which every request comes through.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `PORT` | `8080` | Port nginx listens on. The public domain points at it. |
| `PRIVATEBIN_CONFIG` | not set | Optional. The full text of PrivateBin's `conf.php` (INI format). Not set means PrivateBin's built-in defaults. |

To change settings (site name, file uploads, default expiry, size limit, rate limit), add `PRIVATEBIN_CONFIG` to the service with the full file. It must contain the `[main]`, `[model]` and `[model_options]` sections; see [`cfg/conf.sample.php`](https://github.com/PrivateBin/PrivateBin/blob/master/cfg/conf.sample.php) for every option. For example:

```ini
[main]
name = "Our PrivateBin"
fileupload = true
[model]
class = Filesystem
[model_options]
dir = PATH "data"
```

Keep `class = Filesystem` with `dir = PATH "data"` so pastes stay on the volume.

## How updates reach you

This template builds from this repository. When we bump the pinned PrivateBin version here, Railway shows an "update available" notice on your project, and you choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) first: breaking changes are listed first in each entry. Your pastes stay on the volume across updates and redeploys.

## Run it locally

```sh
docker build -t privatebin-railway .
docker run --rm -p 8080:8080 -v privatebin-data:/srv/data privatebin-railway
```

Then open http://localhost:8080.

## License

The wrapper files in this repository are MIT licensed. PrivateBin itself is under the [zlib/libpng licence](https://github.com/PrivateBin/PrivateBin/blob/master/LICENSE.md).
