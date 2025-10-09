# Traefik + Fail2ban VPS Setup

Automated VPS setup with security hardening, development tools, and modern terminal utilities.

## Quick Start

```bash
# Run interactive setup
./setup.sh
```

The script will ask which components you want, then install everything automatically.

---

## Usage

### Default (Interactive)
```bash
./setup.sh
```

### Install Specific Components
```bash
./setup.sh -docker -nvm -python
./setup.sh -zsh -zimfw -eza
./setup.sh -proxy -proxy-port=8080
```

### Available Flags
- `-basic-tools` - System essentials
- `-nvm` - Node.js
- `-python` - Python 3 + pip
- `-uv` - Python package manager
- `-docker` - Docker
- `-rclone` - Cloud storage sync
- `-proxy` - Squid proxy (default port 31288)
- `-zsh` - Zsh shell
- `-zimfw` - Zsh framework
- `-eza` - Modern ls
- `-zoxide` - Smart cd
- `-fastfetch` - System info
- `-qbittorrent` - Torrent client
- `-xrdp` - Remote desktop (port 33899)
- `-firefox` - Web browser
- `-ssh-port=PORT` - Custom SSH port
- `-proxy-port=PORT` - Custom proxy port

---

## What Gets Installed

### Security
- UFW Firewall (allows all incoming - managed at cloud level)
- SSH hardening (key-only auth, no root login)
- Fail2ban with GeoIP blocking (blocks CN, RU, KP)

### Development
- Node.js (via NVM)
- Python 3 + pip + UV
- Docker

### Tools
- Rclone (cloud storage)
- Squid Proxy
- Zsh + Zim + Eza + Zoxide + Fastfetch
- qBittorrent
- XRDP (remote desktop)
- Firefox

---

## Prerequisites

Before running:
1. SSH keys configured (avoid lockout)
2. Sudo privileges available
3. Internet connection
4. Don't run as root

---

## Fail2ban Status

### Check Active Jails
```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

### Current Settings
| Jail | Trigger | Ban Time |
|------|---------|----------|
| SSH | 3 attempts | 1 day |
| Recidive | 2 bans in 7 days | 30 days |
| GeoIP | CN/RU/KP | Permanent |

### Edit Configuration
```bash
nano fail2ban-configs/fail2ban-jail.local
sudo cp fail2ban-configs/fail2ban-jail.local /etc/fail2ban/jail.local
sudo systemctl restart fail2ban
```

### Unban IP
```bash
sudo fail2ban-client set sshd unbanip IP_ADDRESS
```

---

## Troubleshooting

### Locked Out of SSH
1. Use VPS provider console
2. Restore config: `sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config`
3. Restart SSH: `sudo systemctl restart ssh`

### Installation Failed
The script automatically rolls back changes on failure.

---

## Traefik Configuration

See `docker-compose.yml` for Traefik setup with:
- Automatic HTTPS (Let's Encrypt)
- Dashboard on port 8443
- Reverse proxy configuration

### Access Dashboard
```
https://your-domain:8443/dashboard/
```

---

## File Structure

```
.
├── setup.sh                    # Main setup script
├── docker-compose.yml          # Traefik configuration
├── fail2ban-configs/           # Fail2ban configs
│   ├── fail2ban-jail.local
│   ├── fail2ban-geoip-block.conf
│   └── fail2ban-geoip-action.conf
└── acme.json                   # Let's Encrypt certificates
```

---

## Safety Features

- ✅ SSH key verification before disabling password auth
- ✅ Automatic rollback on failures
- ✅ Config backups before modifications
- ✅ Port validation
- ✅ Internet connectivity checks

---

## License

MIT
