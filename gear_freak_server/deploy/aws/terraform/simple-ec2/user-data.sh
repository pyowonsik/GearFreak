#!/bin/bash
# EC2 User Data Script for Gear Freak Serverpod Server
# This script runs automatically when the EC2 instance is launched

set -e
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "EC2 initialization started at $(date)"
echo "=========================================="

# ====================
# System Update
# ====================
echo "[1/9] Updating system packages..."
yum update -y

# ====================
# Install Docker
# ====================
echo "[2/9] Installing Docker..."
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# ====================
# Install Docker Compose
# ====================
echo "[3/9] Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# ====================
# Install Git
# ====================
echo "[4/9] Installing Git..."
yum install -y git

# ====================
# Create Server Directory
# ====================
echo "[5/9] Creating server directories..."
mkdir -p /opt/gear_freak/{config,backups}
chown -R ec2-user:ec2-user /opt/gear_freak

# ====================
# Create Environment File
# ====================
echo "[6/9] Creating environment file..."
cat > /opt/gear_freak/.env <<EOF
FCM_PROJECT_ID=${fcm_project_id}
FCM_SERVICE_ACCOUNT_PATH=./config/fcm-service-account.json
AWS_ACCESS_KEY_ID=${aws_access_key_id}
AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
AWS_REGION=${aws_region}
S3_PUBLIC_BUCKET_NAME=${s3_public_bucket_name}
S3_PRIVATE_BUCKET_NAME=${s3_private_bucket_name}
POSTGRES_PASSWORD=${db_password}
REDIS_PASSWORD=${redis_password}
DOCKER_IMAGE=${docker_image_url}
EOF
chmod 600 /opt/gear_freak/.env
chown ec2-user:ec2-user /opt/gear_freak/.env

# ====================
# Create Docker Compose File
# ====================
echo "[7/9] Creating docker-compose.yml..."
cat > /opt/gear_freak/docker-compose.yml <<'COMPOSE_EOF'
version: '3.8'

services:
  postgres:
    image: pgvector/pgvector:pg16
    container_name: gear_freak_postgres
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_DB: gear_freak
      POSTGRES_PASSWORD: $${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:6.2.6
    container_name: gear_freak_redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    command: redis-server --requirepass $${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  serverpod:
    image: $${DOCKER_IMAGE}
    container_name: gear_freak_serverpod
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "8081:8081"
      - "8082:8082"
    environment:
      - FCM_PROJECT_ID=$${FCM_PROJECT_ID}
      - AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY}
      - AWS_REGION=$${AWS_REGION}
      - S3_PUBLIC_BUCKET_NAME=$${S3_PUBLIC_BUCKET_NAME}
      - S3_PRIVATE_BUCKET_NAME=$${S3_PRIVATE_BUCKET_NAME}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./config:/app/config:ro
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

volumes:
  postgres_data:
  redis_data:
COMPOSE_EOF

chown ec2-user:ec2-user /opt/gear_freak/docker-compose.yml

# ====================
# Install Nginx
# ====================
echo "[8/9] Installing and configuring Nginx..."
yum install -y nginx
systemctl start nginx
systemctl enable nginx

# Create Nginx configuration
cat > /etc/nginx/conf.d/serverpod.conf <<'NGINX_EOF'
# API Server (port 8080)
server {
    listen 80;
    server_name api.gear-freaks.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $$host;
        proxy_set_header X-Real-IP $$remote_addr;
        proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $$scheme;
        proxy_cache_bypass $$http_upgrade;
    }
}

# Insights Server (port 8081)
server {
    listen 80;
    server_name insights.gear-freaks.com;

    location / {
        proxy_pass http://localhost:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $$host;
        proxy_set_header X-Real-IP $$remote_addr;
        proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $$scheme;
        proxy_cache_bypass $$http_upgrade;
    }
}

# Web/App Server (port 8082)
server {
    listen 80;
    server_name app.gear-freaks.com;

    location / {
        proxy_pass http://localhost:8082;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $$host;
        proxy_set_header X-Real-IP $$remote_addr;
        proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $$scheme;
        proxy_cache_bypass $$http_upgrade;
    }
}
NGINX_EOF

# Test Nginx configuration
nginx -t

# Reload Nginx
systemctl reload nginx

# ====================
# Start PostgreSQL and Redis
# ====================
echo "[9/9] Starting PostgreSQL and Redis containers..."
cd /opt/gear_freak
docker-compose up -d postgres redis

# Wait for services to be healthy
echo "Waiting for PostgreSQL and Redis to be ready..."
sleep 10

# ====================
# Completion
# ====================
touch /opt/gear_freak/.initialized
echo "=========================================="
echo "EC2 initialization completed at $(date)"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Upload FCM service account file to /opt/gear_freak/config/fcm-service-account.json"
echo "2. Upload production.yaml to /opt/gear_freak/config/production.yaml"
echo "3. Upload passwords.yaml to /opt/gear_freak/config/passwords.yaml"
echo "4. Start Serverpod: cd /opt/gear_freak && docker-compose up -d serverpod"
echo "5. Apply migrations: docker exec -it gear_freak_serverpod ./server --apply-migrations"
echo ""
