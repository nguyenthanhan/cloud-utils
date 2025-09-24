# Traefik Infrastructure

This repository contains the Docker Compose configuration for a complete infrastructure setup with Traefik as a reverse proxy and SSL certificate management.

## Services Included

- **Traefik v3.0** - Reverse proxy with automatic SSL certificates via Cloudflare DNS challenge
- **PostgreSQL 16** - Relational database
- **MongoDB 8** - Document database
- **Redis 7** - In-memory data store
- **Portainer** - Docker container management UI
- **Stirling PDF** - PDF manipulation tools

## Setup

1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your actual credentials and API tokens

3. Ensure the external network exists:
   ```bash
   docker network create my_network
   ```

4. Start the services:
   ```bash
   docker compose up -d
   ```

## Database Access

- **PostgreSQL**: `localhost:5432`
- **MongoDB**: `localhost:27017`
- **Redis**: `localhost:6379`

All credentials are stored in the `.env` file.

## Web Interfaces

- Traefik Dashboard: https://traefik.heimerng.dev
- Portainer: https://portainer.heimerng.dev
- Stirling PDF: https://pdf.heimerng.dev

## SSL Certificates

SSL certificates are automatically obtained and renewed via Cloudflare DNS challenge. The `acme.json` file stores the certificates and should never be committed to version control.

## Data Persistence

All databases use Docker volumes for data persistence:
- `postgres_data`
- `mongodb_data`
- `mongodb_config`
- `redis_data`

## Security Notes

- The `.env` file contains sensitive credentials and is excluded from version control
- The `acme.json` file contains SSL certificates and private keys
- Ensure proper file permissions on sensitive files
