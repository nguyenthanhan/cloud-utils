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

All databases use custom ports and specific hostnames for security:

### PostgreSQL
```
Host: postgres-1riun.heimerng.dev
Port: 15432
User: postgres
Password: secure_postgres_password_123
Database: myapp
```

### MongoDB
```
Host: mongodb-g8ycd.heimerng.dev
Port: 27018
User: mongo_admin
Password: secure_mongo_password_123
Database: myapp
```

### Redis
```
Host: redis-gbh5t.heimerng.dev
Port: 16379
Password: secure_redis_password_123
```

## Web Access

- Traefik Dashboard: https://traefik.heimerng.dev
- Portainer: https://portainer.heimerng.dev
- PDF Tools: https://pdf.heimerng.dev

## Security Features

- Custom ports (not default 5432, 27017, 6379)
- Specific database hostnames with random suffixes
- SSL certificates via Cloudflare
- Password authentication required
- Default ports blocked

## DNS Setup

Add these A records in Cloudflare:
```
postgres-1riun.heimerng.dev → your-server-ip
mongodb-g8ycd.heimerng.dev → your-server-ip  
redis-gbh5t.heimerng.dev → your-server-ip
```
