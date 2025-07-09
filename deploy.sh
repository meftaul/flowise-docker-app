#!/bin/bash

# Flowise Production Deployment Script
set -e

echo "🚀 Starting Flowise Production Deployment"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "📋 Please copy .env.example to .env and configure your settings:"
    echo "   cp .env.example .env"
    echo "   nano .env"
    exit 1
fi

# Source environment variables
source .env

# Check critical environment variables
REQUIRED_VARS=(
    "DATABASE_PASSWORD"
    "JWT_AUTH_TOKEN_SECRET"
    "JWT_REFRESH_TOKEN_SECRET"
    "FLOWISE_SECRETKEY_OVERWRITE"
    "TOKEN_HASH_SECRET"
)

echo "🔍 Checking environment variables..."
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ] || [ "${!var}" = "your-secure-database-password-change-me" ] || [ "${!var}" = "generate-with-openssl-rand-hex-32" ] || [ "${!var}" = "production-token-hash-secret-change-me" ]; then
        echo "❌ $var is not properly configured!"
        echo "Please update your .env file with secure values."
        exit 1
    fi
done

echo "✅ Environment variables check passed"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    exit 1
fi

echo "✅ Docker is running"

# Pull latest images
echo "📦 Pulling latest Docker images..."
docker compose pull

# Create volumes if they don't exist
echo "💾 Creating Docker volumes..."
docker volume create flowise_flowise_data 2>/dev/null || true
docker volume create flowise_postgres_data 2>/dev/null || true

# Start services
echo "🚀 Starting services..."
docker compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check service health
if docker compose ps | grep -q "unhealthy"; then
    echo "❌ Some services are unhealthy!"
    docker compose logs
    exit 1
fi

echo "✅ All services are running and healthy!"

# Display running services
echo "📊 Service Status:"
docker compose ps

echo ""
echo "🎉 Flowise is now running in production mode!"
echo "📱 Access your application at: http://localhost:${PORT}"
echo "⚠️  Remember to set up a reverse proxy with SSL for external access"
echo ""
echo "📋 Useful commands:"
echo "   View logs: docker compose logs -f"
echo "   Stop services: docker compose down"
echo "   Restart: docker compose restart"
echo ""
echo "🔒 Security reminders:"
echo "   - Set up SSL/TLS with a reverse proxy"
echo "   - Configure firewall rules"
echo "   - Set up regular backups"
echo "   - Monitor resource usage"
