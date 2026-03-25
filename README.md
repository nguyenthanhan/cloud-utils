# cloud-utils

Utility scripts for VPS setup, a Docker stack, macOS helpers, MTProto proxy, and Rclone transfers.

## Installation

```bash
git clone https://github.com/nguyenthanhan/cloud-utils.git
cd cloud-utils
```

## Usage

### VPS setup

```bash
./setup.sh
```

```bash
./setup.sh -apt-update -basic-tools -firewall -ssh-security -fail2ban
./setup.sh -docker -fnm -python -uv
./setup.sh -zsh -zimfw -bash-it -zoxide -eza -fastfetch
./setup.sh -proxy -proxy-port=8080
./setup.sh -xrdp -xrdp-port=33899 -verify-xrdp
```

Common flags:

- `-apt-update`, `-basic-tools`, `-set-password`
- `-firewall`, `-ssh-security`, `-fail2ban`
- `-docker`, `-rclone`, `-proxy`, `-proxy-port=PORT`
- `-fnm`, `-python`, `-uv`
- `-zsh`, `-zimfw`, `-bash-it`, `-zoxide`, `-eza`, `-fastfetch`
- `-qbittorrent`, `-xrdp`, `-xrdp-port=PORT`, `-firefox`, `-verify-xrdp`

### Docker stack

```bash
cp .env.example .env
docker network create traefik_network
touch acme.json && chmod 600 acme.json
docker compose up -d
```

### macOS scripts

```bash
zsh mac_scripts/dbt --help
zsh mac_scripts/dbt connect
zsh mac_scripts/dbt list --status
zsh mac_scripts/dbt sync postgres -s 1 -d 1
zsh mac_scripts/dbt sync mongodb -s 1 -d 1
```

```bash
zsh mac_scripts/create_link_zshrc
```

```bash
zsh mac_scripts/buc
zsh mac_scripts/buc list
zsh mac_scripts/buc add <cask>
zsh mac_scripts/buc remove <cask>
```

```bash
zsh mac_scripts/gt fetch
zsh mac_scripts/gt push
```

### MTProto

```bash
cd mtproto
bash save_random_hex.sh
docker compose up -d
```

### Rclone

```bash
cd rclone
export PROXY_URL="http://user:pass@host:port"
bash transfer.sh
```

Windows:

```powershell
cd rclone
.\transfer.ps1
```

## Main Features

- Ubuntu VPS provisioning with one script
- Traefik + Portainer + Stirling PDF + DB services stack
- macOS helpers for DB tunnel/sync, git, and Homebrew casks
- MTProto proxy deployment
- Rclone transfer helpers

## Technology Stack

- Bash and Zsh
- Docker and Docker Compose
- Traefik, Portainer, Stirling PDF
- PostgreSQL, MongoDB, Redis

## Project Structure

```text
.
├── setup.sh
├── docker-compose.yml
├── .env.example
├── dbt_secrets.example
├── fail2ban-configs/
├── mac_init/
├── mac_scripts/
├── mtproto/
└── rclone/
```

## Contribution Guidelines

- Keep changes small and focused
- Follow existing script style (Bash vs Zsh)
- Include brief testing notes in PRs

## License

Provided as-is for personal use. Add an explicit license if you plan to redistribute.
