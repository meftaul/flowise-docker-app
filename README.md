# Flowise Production Deployment

## Security Checklist

Before deploying to production, ensure you have:

### 1. Updated Environment Variables
- [ ] Changed `DATABASE_PASSWORD` to a strong password
- [ ] Generated new JWT secrets using `openssl rand -hex 32`
- [ ] Updated `FLOWISE_SECRETKEY_OVERWRITE` (minimum 32 characters)
- [ ] Set `TOKEN_HASH_SECRET` to a unique value
- [ ] Updated `CORS_ORIGINS` and `IFRAME_ORIGINS` to your domain(s)
- [ ] Set `APP_URL` to your production domain

### 2. Database Security
- [ ] PostgreSQL is configured with strong authentication
- [ ] Database runs in isolated network
- [ ] Regular backups are configured

### 3. Network Security
- [ ] Application only binds to localhost (reverse proxy required)
- [ ] SSL/TLS termination at reverse proxy
- [ ] Firewall configured appropriately

### 4. Container Security
- [ ] Containers run as non-root user
- [ ] Security options enabled (`no-new-privileges`)
- [ ] Resource limits configured

## Deployment Commands

1. **Start the services:**
   ```bash
   docker compose up -d
   ```

2. **View logs:**
   ```bash
   docker compose logs -f flowise
   ```

3. **Stop the services:**
   ```bash
   docker compose down
   ```

4. **Update the application:**
   ```bash
   docker compose pull
   docker compose up -d
   ```

## Reverse Proxy Configuration

Since the application binds to `127.0.0.1:3000`, you need a reverse proxy (nginx, Apache, or Cloudflare Tunnel) to handle SSL and external access.

### Example Nginx Configuration:
```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Backup Strategy

### Database Backup:
```bash
docker compose exec postgres pg_dump -U flowise_user flowise_prod > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Volume Backup:
```bash
docker run --rm -v flowise_flowise_data:/data -v $(pwd):/backup alpine tar czf /backup/flowise_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .
```

## Monitoring

Consider setting up monitoring for:
- Container health and resource usage
- Database performance
- Application logs
- SSL certificate expiration
- Disk space usage

## Security Updates

Regularly update:
- Base container images
- Database version
- Host operating system
- SSL certificates
