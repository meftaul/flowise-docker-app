# Flowise Docker Application

A complete Docker setup for running **Flowise** (Visual LLMOps platform) with **Weaviate** (vector database) for building and deploying AI workflows and chatbots.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Services](#services)
- [Usage](#usage)
- [Data Persistence](#data-persistence)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🔍 Overview

This Docker Compose setup provides:

- **Flowise**: Visual LLMOps platform for building AI workflows and chatbots
- **Weaviate**: Open-source vector database for storing and querying embeddings
- **Persistent Storage**: Data volumes for both services
- **Health Checks**: Automatic service health monitoring
- **Network Isolation**: Custom Docker network for service communication

## ⚡ Prerequisites

Before you begin, ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/) (version 20.10 or higher)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0 or higher)
- At least 4GB of available RAM
- At least 2GB of free disk space

## 🚀 Quick Start

1. **Clone or download this repository:**
   ```bash
   git clone <your-repo-url>
   cd flowise-docker-app
   ```

2. **Create environment file:**
   ```bash
   cp .env.example .env
   ```

3. **Start the services:**
   ```bash
   docker-compose up -d
   ```

4. **Access the applications:**
   - **Flowise UI**: http://localhost:3000
   - **Weaviate API**: http://localhost:8080
   - **Weaviate gRPC**: localhost:50051

5. **Login to Flowise:**
   - Username: `admin` (default)
   - Password: `admin123` (default)

## ⚙️ Configuration

### Environment Variables

Copy `.env.example` to `.env` and customize the following variables:

#### Flowise Configuration
| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Flowise web interface port |
| `FLOWISE_VERSION` | `3.0.4` | Flowise Docker image version |
| `FLOWISE_USERNAME` | `admin` | Admin username for Flowise |
| `FLOWISE_PASSWORD` | `admin123` | Admin password for Flowise |
| `DATABASE_PATH` | `/root/.flowise` | Database storage path |
| `APIKEY_PATH` | `/root/.flowise` | API keys storage path |
| `SECRETKEY_PATH` | `/root/.flowise` | Secret keys storage path |
| `LOG_LEVEL` | `info` | Logging level (debug, info, warn, error) |
| `LOG_PATH` | `/root/.flowise/logs` | Log files storage path |

#### Weaviate Configuration
| Variable | Default | Description |
|----------|---------|-------------|
| `WEAVIATE_VERSION` | `1.31.5` | Weaviate Docker image version |
| `WEAVIATE_PORT` | `8080` | Weaviate HTTP API port |
| `WEAVIATE_GRPC_PORT` | `50051` | Weaviate gRPC port |
| `WEAVIATE_QUERY_DEFAULTS_LIMIT` | `25` | Default query result limit |
| `WEAVIATE_AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED` | `true` | Enable anonymous access |
| `WEAVIATE_PERSISTENCE_DATA_PATH` | `/var/lib/weaviate` | Data persistence path |

### Security Recommendations

**⚠️ Important**: For production use, please:

1. Change default credentials:
   ```bash
   FLOWISE_USERNAME=your_secure_username
   FLOWISE_PASSWORD=your_secure_password_here
   ```

2. Disable anonymous access to Weaviate if not needed:
   ```bash
   WEAVIATE_AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED=false
   ```

3. Use strong passwords and consider implementing additional authentication layers.

## 🛠️ Services

### Flowise Service
- **Image**: `flowiseai/flowise:3.0.4`
- **Port**: 3000 (configurable)
- **Purpose**: Visual LLMOps platform for building AI workflows
- **Health Check**: HTTP endpoint monitoring
- **Data Volume**: `./flowise_data:/root/.flowise`

### Weaviate Service
- **Image**: `cr.weaviate.io/semitechnologies/weaviate:1.31.5`
- **Ports**: 8080 (HTTP), 50051 (gRPC)
- **Purpose**: Vector database for storing embeddings and metadata
- **Data Volume**: `./weaviate_data:/var/lib/weaviate`

## 💡 Usage

### Starting the Services
```bash
# Start all services in detached mode
docker-compose up -d

# Start with logs visible
docker-compose up

# Start specific service
docker-compose up flowise
```

### Stopping the Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ This will delete all data!)
docker-compose down -v
```

### Viewing Logs
```bash
# View all logs
docker-compose logs

# View logs for specific service
docker-compose logs flowise
docker-compose logs weaviate

# Follow logs in real-time
docker-compose logs -f
```

### Updating Services
```bash
# Pull latest images
docker-compose pull

# Restart with updated images
docker-compose up -d --force-recreate
```

## 💾 Data Persistence

The setup creates two data directories on your host system:

- `./flowise_data/`: Contains Flowise database, API keys, and logs
- `./weaviate_data/`: Contains Weaviate vector database data

**Backup Recommendations:**
```bash
# Create backup
tar -czf flowise-backup-$(date +%Y%m%d).tar.gz flowise_data/ weaviate_data/

# Restore backup
tar -xzf flowise-backup-YYYYMMDD.tar.gz
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Check what's using the port
sudo lsof -i :3000
sudo lsof -i :8080

# Change ports in .env file if needed
PORT=3001
WEAVIATE_PORT=8081
```

#### 2. Permission Issues
```bash
# Fix data directory permissions
sudo chown -R $USER:$USER flowise_data/ weaviate_data/
```

#### 3. Service Won't Start
```bash
# Check service status
docker-compose ps

# View detailed logs
docker-compose logs [service_name]

# Restart specific service
docker-compose restart [service_name]
```

#### 4. Health Check Failures
```bash
# Check Flowise health manually
curl http://localhost:3000

# Check Weaviate health
curl http://localhost:8080/v1/meta
```

### Useful Commands

```bash
# Check running containers
docker ps

# Enter container shell
docker-compose exec flowise sh
docker-compose exec weaviate sh

# Check resource usage
docker stats

# Clean up unused containers/images
docker system prune
```

## 🔍 Accessing Services

### Flowise Web Interface
- **URL**: http://localhost:3000
- **Default Login**: admin / admin123
- **Features**: 
  - Visual workflow builder
  - Chatbot creation
  - Integration with various LLM providers
  - API management

### Weaviate API
- **HTTP API**: http://localhost:8080
- **GraphQL Playground**: http://localhost:8080/v1/graphql
- **Health Check**: http://localhost:8080/v1/meta
- **Documentation**: http://localhost:8080/v1/doc

## 📈 Monitoring and Maintenance

### Health Checks
The setup includes automatic health checks:
- **Flowise**: HTTP endpoint check every 30 seconds
- **Weaviate**: Built-in health monitoring

### Log Management
```bash
# Rotate logs (if they get too large)
docker-compose exec flowise sh -c "find /root/.flowise/logs -name '*.log' -size +100M -delete"

# Monitor disk usage
df -h ./flowise_data ./weaviate_data
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Flowise Documentation**: https://docs.flowiseai.com/
- **Weaviate Documentation**: https://weaviate.io/developers/weaviate/
- **Docker Documentation**: https://docs.docker.com/

---

**Happy Building! 🚀**