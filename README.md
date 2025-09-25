# Traefik Infrastructure

Docker Compose setup with Traefik reverse proxy and SSL certificates via Cloudflare.

## Services

- **Traefik v3.0** - Reverse proxy with SSL
- **PostgreSQL 16** - Database
- **MongoDB 8** - Database
- **Redis 7** - Cache
- **Portainer** - Docker UI
- **Stirling PDF** - PDF tools

## Quick Start

1. Copy environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit .env with your credentials

3. Create network:
   ```bash
   docker network create my_network
   ```

4. Start services:
   ```bash
   docker compose up -d
   ```

## Database Connections

All databases use standard ports and specific hostnames via Traefik:

### PostgreSQL
```
Host: postgres-1riun.heimerng.dev
Port: 5432
User: postgres
Password: secure_postgres_password_123
Database: myapp
```

### MongoDB
```
Host: mongodb-g8ycd.heimerng.dev
Port: 27017
User: mongo_admin
Password: secure_mongo_password_123
Database: myapp
AuthSource: admin
```

**MongoDB URI:**
```
mongodb://mongo_admin:secure_mongo_password_123@mongodb-g8ycd.heimerng.dev:27017/myapp?authSource=admin
```

### Redis
```
Host: redis-gbh5t.heimerng.dev
Port: 6379
Password: secure_redis_password_123
```

## Web Access

- Traefik Dashboard: https://traefik.heimerng.dev
- Portainer: https://portainer.heimerng.dev
- PDF Tools: https://pdf.heimerng.dev

## Security Features

- Database hostnames with random suffixes for obscurity
- SSL certificates via Cloudflare
- Password authentication required
- Access only through Traefik reverse proxy

## DNS Setup

Add these A records in Cloudflare (DNS only - grey cloud):
```
postgres-1riun.heimerng.dev → your-server-ip
mongodb-g8ycd.heimerng.dev → your-server-ip  
redis-gbh5t.heimerng.dev → your-server-ip
```

**Important:** Database hostnames must be set to **DNS only** (grey cloud) in Cloudflare, not proxied (orange cloud), because database ports cannot go through Cloudflare proxy.
