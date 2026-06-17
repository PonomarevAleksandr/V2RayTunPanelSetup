# V2RayTun Panel — Universal Installer

One-command installer for the V2RayTun Panel beta. No GitHub token, no source clone, no manual configuration. Pulls pre-built Docker images from a private registry.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PonomarevAleksandr/V2RayTunPanelSetup/main/install.sh)
```

The installer asks for two things:

1. **Panel domain** (e.g. `panel.example.com`) — must already point to this server's IP via DNS A-record
2. **Docker registry credentials** — provided by the team lead (each beta tester gets a personal username/password)

Everything else is automated:

- Detects the OS and installs Docker + Docker Compose
- Logs in to `docker-registry.v2raytun.com` with your credentials
- Pulls the panel + frontend images
- Generates strong random secrets for PostgreSQL, RabbitMQ and JWT
- Brings up Postgres, Redis, RabbitMQ, backend, frontend
- Configures Caddy reverse proxy with automatic Let's Encrypt SSL
- Runs everything inside a `tmux` session so SSH disconnects don't break the install

After install, open `https://your-domain/auth/login` and create the first admin account.

---

## Requirements

- Linux server with **root access** (Ubuntu 22.04+, Debian 12+, Fedora, RHEL, Alma/Rocky, Alpine, Arch all supported)
- **2 vCPU / 2 GB RAM** for the panel server, **1 vCPU / 512 MB RAM** for each node
- A domain pointed at the panel server (`A` record), with ports **80** and **443** open
- Personal credentials for the private Docker registry (request from team lead)

---

## Adding a node

On a separate Linux server (a "node" runs Xray and serves VPN traffic):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PonomarevAleksandr/V2RayTunPanelSetup/main/install.sh)
```

In the menu choose **2) Install Node**, then pick the recommended option:

- **Paste docker-compose from the panel** — in the panel UI, go to *Nodes → Create Node*, fill in the fields, click *Create*, copy the docker-compose snippet, paste it into the installer. This mode includes mTLS certificates already.

The node should appear as *Connected* in the panel within ~60 seconds. Make sure the connection port (default `62050`) is open in your firewall.

---

## Updating

After a new release ships:

```bash
v2raytunsetup update         # update panel
v2raytunsetup update node    # update node
```

The command pulls fresh images and restarts the containers. Data and configuration are preserved.

---

## Useful commands

```bash
v2raytunsetup                  # interactive menu
v2raytunsetup status           # show containers
v2raytunsetup logs             # tail backend logs
v2raytunsetup logs frontend    # tail frontend logs
v2raytunsetup login            # re-login to registry (if creds rotated)
v2raytunsetup backup           # dump postgres + redis to /var/backups/v2raytunpanel
v2raytunsetup restore          # restore from a backup
v2raytunsetup attach           # reattach to running tmux setup session
v2raytunsetup resume           # restart containers after a reboot or crash
v2raytunsetup help             # show all options
```

---

## Non-interactive (CI / automation)

You can pre-fill all prompts via environment variables:

```bash
sudo \
  V2RAYTUN_PANEL_DOMAIN=panel.example.com \
  V2RAYTUN_SUB_DOMAIN=panel.example.com \
  V2RAYTUN_REGISTRY_USER=alice \
  V2RAYTUN_REGISTRY_PASS=secret \
  V2RAYTUN_ACTION=install-panel \
  bash <(curl -fsSL https://raw.githubusercontent.com/PonomarevAleksandr/V2RayTunPanelSetup/main/install.sh)
```

Available variables:

| Variable | Description |
|---|---|
| `V2RAYTUN_REGISTRY` | Docker registry hostname (default `docker-registry.v2raytun.com`) |
| `V2RAYTUN_REGISTRY_USER` | Registry username — skips prompt |
| `V2RAYTUN_REGISTRY_PASS` | Registry password — skips prompt |
| `V2RAYTUN_VERSION` | Image tag to pull (default `1.0.0`) |
| `V2RAYTUN_PANEL_DOMAIN` | Panel domain — skips prompt |
| `V2RAYTUN_SUB_DOMAIN` | Subscription page domain (defaults to panel domain) |
| `V2RAYTUN_ACTION` | `install-panel` / `install-node` / `update-panel` / `update-node` |
| `V2RAYTUNSETUP_REPO` | Source for helper scripts (default `PonomarevAleksandr/V2RayTunPanelSetup`) |
| `V2RAYTUNSETUP_BRANCH` | Branch (default `main`) |

---

## File layout after install

| Path | Description |
|---|---|
| `/opt/v2raytunpanel/docker/` | Panel docker-compose, `.env` and volumes |
| `/opt/v2raytunpanel/caddy/` | Caddy reverse proxy + TLS certificates |
| `/opt/v2raytunpanel-node/` | Node docker-compose and `.env` |
| `/opt/v2raytunpanel-setup/` | Cached installer scripts (used by `v2raytunsetup`) |
| `/var/backups/v2raytunpanel/` | Database / redis / env backups |
| `/usr/local/bin/v2raytunsetup` | Global CLI entrypoint |

---

## Troubleshooting

**Login fails with HTTP 401.** Your credentials are wrong or expired. Ask the team lead to issue a new pair, then run `v2raytunsetup login`.

**Pull fails with `unauthorized: authentication required`.** Same as above — re-run `v2raytunsetup login`.

**Backend stays unhealthy.** Check the logs:

```bash
v2raytunsetup logs backend
```

Common issues: domain not yet pointing at the server (Caddy can't issue TLS), `.env` missing required values, port 80/443 blocked by firewall.

**SSH dropped during install.** Reconnect, then run `v2raytunsetup attach` to reattach to the running tmux session.

---

## Security notes

- Source code stays in a private GitHub repository. The installer only downloads pre-built obfuscated Docker images.
- Each beta tester gets personal registry credentials. If a credential leaks, the team lead revokes only that user, not the whole project.
- Database, RabbitMQ, JWT and admin secrets are generated on the local machine during install and never leave it. Backups are stored only on the same machine in `/var/backups/v2raytunpanel/`.
- The installer chmods `.env` to `600` so it's readable only by root.

---

## License

This installer (the public part) is MIT-licensed. The panel itself, distributed as Docker images, is proprietary closed-beta software.
