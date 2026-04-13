# pihole-toggle-sync

A lightweight web UI for toggling ad-blocking on one or more [Pi-hole](https://pi-hole.net/) instances simultaneously. Shows live stats per instance and syncs disable/enable actions across all of them at once.

![License](https://img.shields.io/badge/license-MIT-blue)
![Pi-hole](https://img.shields.io/badge/Pi--hole-v6%2B-red)
![Build](https://github.com/bartekmp/pihole-toggle-sync/actions/workflows/publish.yml/badge.svg)

---

## Features

- Per-instance info cards showing queries today, blocked count, block rate, and blocklist size
- Disable blocking across all instances at once — for 30s, 5m, 10m, a custom duration, or indefinitely
- Live countdown timer with automatic re-enable
- Per-instance status chips showing which hosts succeeded or failed
- Instance cards refresh automatically every 30 seconds and after each toggle action
- Material Design 3 UI with full dark mode support
- Configurable entirely via environment variables — no build step needed
- Multi-arch image: `amd64`, `arm64`, `armv7` (Raspberry Pi)

## Requirements

- Pi-hole **v6+** (uses the `/api/stats/summary` and `/api/dns/blocking` REST API endpoints)
- Docker + Docker Compose

## Quick start

### Using the pre-built image from GHCR (recommended)

```bash
curl -O https://raw.githubusercontent.com/bartekmp/pihole-toggle-sync/main/compose.yml
curl -O https://raw.githubusercontent.com/bartekmp/pihole-toggle-sync/main/.env.example
mv .env.example .env
nano .env
docker compose up -d
```

The image is published to [GitHub Container Registry](https://ghcr.io/bartekmp/pihole-toggle-sync) and is publicly available without authentication.

### Building from source

```bash
git clone https://github.com/bartekmp/pihole-toggle-sync.git
cd pihole-toggle-sync
cp .env.example .env
nano .env
docker compose up -d
```

Then open `http://<your-host>:8087` in a browser.

## Configuration

All configuration is done at **runtime** via environment variables — the image itself contains no hardcoded addresses. Set them in a `.env` file or directly in `compose.yml`.

| Variable | Default | Description |
|---|---|---|
| `PH_HOSTS` | *(empty)* | Comma-separated list of Pi-hole base URLs |
| `PH_PASSWORD` | *(empty)* | Pi-hole web password — leave empty if none is set |
| `LISTEN_PORT` | `8087` | Host port to expose the UI on |

### Example `.env`

```env
PH_HOSTS=https://pihole.example.com,https://pihole2.example.com
PH_PASSWORD=yourpassword
LISTEN_PORT=8087
```

## CORS and reverse proxy

API calls are made directly from the **browser**, not from the container. This means Pi-hole must be reachable from the browser and must respond with appropriate CORS headers for cross-origin POST requests (used when toggling blocking).

The recommended setup is a reverse proxy (e.g. Caddy) in front of each Pi-hole, which handles CORS and avoids Pi-hole ACL issues:

```
pihole.example.com {
    redir / /admin/ 301

    @api path /api/*
    header @api {
        ?Access-Control-Allow-Origin *
        ?Access-Control-Allow-Methods "GET, POST, OPTIONS"
        ?Access-Control-Allow-Headers "Content-Type, X-FTL-SID"
    }

    @preflight {
        method OPTIONS
        path /api/*
    }
    respond @preflight 204

    reverse_proxy http://127.0.0.1:8053
}
```

If you access Pi-hole directly by IP, ensure its webserver ACL allows your browser's LAN IP:

```yaml
FTLCONF_webserver_acl: "+127.0.0.0/8,+192.168.0.0/24"
```

## How it works

The UI is a single static HTML file served by nginx. On container start, an entrypoint script runs `envsubst` to substitute the `${PH_HOSTS}` and `${PH_PASSWORD}` placeholders in the HTML with runtime environment variable values. The browser then talks directly to each Pi-hole's REST API — there is no backend process.

## Project structure

```
pihole-toggle-sync/
├── .github/
│   └── workflows/
│       └── publish.yml          # CI/CD: build & push to GHCR
├── docker-entrypoint.d/
│   └── 40-envsubst-html.sh      # Injects env vars into HTML at startup
├── www/
│   ├── index.html               # Single-file Material Design 3 UI
│   └── favicon.svg              # App icon
├── Dockerfile                   # nginx:alpine + www/ + entrypoint script
├── nginx.conf                   # Static file server config
├── compose.yml                  # Docker Compose service definition
├── .env.example                 # Example environment file
├── .gitignore
├── LICENSE
└── README.md
```

## License

[MIT](LICENSE)
