#!/bin/bash

# Flowise Backup Script
set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🔄 Starting Flowise backup process..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Source environment variables
if [ -f .env ]; then
    source .env
else
    echo "❌ .env file not found!"
    exit 1
fi

echo "💾 Creating database backup..."
# Database backup
docker compose exec -T postgres pg_dump -U "$DATABASE_USER" "$DATABASE_NAME" > "$BACKUP_DIR/database_backup_$TIMESTAMP.sql"

echo "📁 Creating volume backup..."
# Volume backup
docker run --rm \
    -v flowise_flowise_data:/data \
    -v "$(pwd)/$BACKUP_DIR":/backup \
    alpine tar czf "/backup/flowise_data_backup_$TIMESTAMP.tar.gz" -C /data .

echo "🗃️ Creating configuration backup..."
# Configuration backup
tar czf "$BACKUP_DIR/config_backup_$TIMESTAMP.tar.gz" \
    docker-compose.yml \
    .env \
    README.md \
    deploy.sh \
    backup.sh 2>/dev/null || true

echo "🧹 Cleaning up old backups (keeping last 7 days)..."
# Clean up old backups (keep last 7 days)
find "$BACKUP_DIR" -name "*backup_*.sql" -mtime +7 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "*backup_*.tar.gz" -mtime +7 -delete 2>/dev/null || true

echo "✅ Backup completed successfully!"
echo "📊 Backup files created:"
ls -la "$BACKUP_DIR"/*"$TIMESTAMP"*

echo ""
echo "💡 To restore from backup:"
echo "   Database: docker compose exec -T postgres psql -U $DATABASE_USER $DATABASE_NAME < $BACKUP_DIR/database_backup_$TIMESTAMP.sql"
echo "   Data: tar xzf $BACKUP_DIR/flowise_data_backup_$TIMESTAMP.tar.gz"
