# V2RayTun Panel Setup

Universal installer for V2RayTun Panel — Enterprise VPN Management System.

## Quick Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PonomarevAleksandr/V2RayTunPanelSetup/main/install.sh)
```

## Features

- **One-liner installation** — just run the command above
- **Auto-detects OS** — Ubuntu, Debian, CentOS, RHEL, Fedora, Rocky, AlmaLinux, Alpine, Arch, openSUSE
- **Auto-installs Docker** — if not present
- **Interactive menu** — install Panel, Node, Backup/Restore
- **Multi-language support** — English and Russian

## What Gets Installed

### Panel Mode
- V2RayTun Panel (Web UI + API)
- PostgreSQL 17
- Redis 7
- RabbitMQ 3
- Optional: Caddy (reverse proxy with auto SSL)

### Node Mode
- V2RayTun Node Agent
- Xray Core
- Optional: BBR, WARP, Caddy

## Private Repository

If your repository is private, provide a GitHub Personal Access Token:

```bash
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx bash <(curl -fsSL https://raw.githubusercontent.com/PonomarevAleksandr/V2RayTunPanelSetup/main/install.sh)
```

Required token scopes:
- `repo` — for cloning
- `read:packages` — for pulling Docker images from GHCR

## Custom Repository

To use a different repository/branch:

```bash
V2RAYTUNPANEL_REPO=YourOrg/your-repo \
V2RAYTUNPANEL_BRANCH=develop \
bash <(curl -fsSL https://raw.githubusercontent.com/PonomarevAleksandr/V2RayTunPanelSetup/main/install.sh)
```

## Post-Installation

After installation completes, you'll see:

```
════════════════════════════════════════════════════════════════════
  ✅ Installation complete!
════════════════════════════════════════════════════════════════════

📋 Panel Information:
────────────────────────────────────────────────────────────────────

  Panel URL:      https://panel.example.com
  Subscription:   https://sub.example.com/api/sub/{shortUuid}

  Files location: /opt/v2raytunpanel/docker

────────────────────────────────────────────────────────────────────

📝 View logs:

  cd /opt/v2raytunpanel/docker && docker compose logs -f backend

────────────────────────────────────────────────────────────────────

🚀 Next Steps:

  1. Wait ~60 seconds for services to start
  2. Open registration page: https://panel.example.com/register
  3. Create admin account
  4. Set up reverse proxy (Caddy/Nginx) for HTTPS

════════════════════════════════════════════════════════════════════
```

## Commands

### View Logs
```bash
cd /opt/v2raytunpanel/docker && docker compose logs -f
cd /opt/v2raytunpanel/docker && docker compose logs -f backend
cd /opt/v2raytunpanel/docker && docker compose logs -f frontend
```

### Restart Services
```bash
cd /opt/v2raytunpanel/docker && docker compose restart
```

### Stop/Start
```bash
cd /opt/v2raytunpanel/docker && docker compose down
cd /opt/v2raytunpanel/docker && docker compose up -d
```

### Update
```bash
cd /opt/v2raytunpanel/docker && docker compose pull && docker compose up -d
```

## Re-run Setup

To access the setup menu again:

```bash
bash /opt/v2raytunpanel-setup/scripts/setup/v2raytunsetup.sh
```

Or re-run the installer:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PonomarevAleksandr/V2RayTunPanelSetup/main/install.sh)
```

## License

MIT License — see [LICENSE](LICENSE) for details.

## Links

- [Main Repository](https://github.com/PonomarevAleksandr/v2raytunpanel)
- [Documentation](https://github.com/PonomarevAleksandr/v2raytunpanel/tree/main/apps/docs)
