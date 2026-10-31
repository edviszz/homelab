#!/bin/bash
set -euo pipefail

echo "=========================================="
echo " Starting Homelab Deployment Pipeline"
echo "=========================================="

# Ensure external networks exist
docker network create proxy-net 2>/dev/null || true
docker network create media-net 2>/dev/null || true
docker network create auth-net 2>/dev/null || true
docker network create monitoring-net 2>/dev/null || true

# 1. Deploy Core Ingress
echo "[+] Deploying 01-core..."
cd 01-core && docker compose pull && docker compose up -d && cd ..

# 2. Deploy Authentication
echo "[+] Deploying 03-auth..."
cd 03-auth && docker compose pull && docker compose up -d && cd ..

# 3. Deploy Media Stack
echo "[+] Deploying 04-apps/media-stack..."
cd 04-apps/media-stack && docker compose pull && docker compose up -d && cd ..

# 4. Deploy Monitoring
echo "[+] Deploying 05-monitoring..."
cd 05-monitoring && docker compose pull && docker compose up -d && cd ..

echo "=========================================="
echo " Deployment Complete Successfully!"
echo "=========================================="