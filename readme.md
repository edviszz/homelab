# Made entirely with AI!

# Master Infrastructure Setup Runbook

This guide details the exact step-by-step procedure required to provision the bare-metal Proxmox host, initialize ZFS datasets, establish storage mount points, configure permissions, and deploy all infrastructure layers defined in this repository.

---

## Phase 1: Storage & Filesystem Initialization

Run all commands in this section directly on the host (or Proxmox host shell).

### 1. Create ZFS Pool & Datasets
Enable `lz4` compression, set standard metadata settings, and create isolated datasets for application data and media stores.

```bash
# Enable ZFS pool (Replace disk IDs with your specific block devices, e.g., /dev/disk/by-id/...)
# Example using dual-disk mirror:
zpool create -f -o ashift=12 tank mirror /dev/nvme0n1 /dev/nvme1n1

# Global dataset performance options
zfs set compression=lz4 tank
zfs set xattr=sa tank
zfs set atime=off tank

# Create isolated datasets
zfs create tank/media
zfs create tank/appdata
```

### 2. Create Unified Mount Directory Structure
To ensure zero-space atomic hardlinks between download clients and media managers, all workloads mount the root `/mnt/data` path.

```bash
# Mount points on the host system
sudo mkdir -p /mnt/data/torrents/incomplete
sudo mkdir -p /mnt/data/torrents/completed
sudo mkdir -p /mnt/data/media/movies
sudo mkdir -p /mnt/data/media/tv
sudo mkdir -p /mnt/data/appdata
```

### 3. User & Group Permissions Mapping
Standardize ownership to user ID `1000` and group ID `1000` (`dockeruser` / `homelab`).

```bash
# Create dedicated group and user if not present
sudo groupadd -g 1000 homelab || true
sudo useradd -u 1000 -g 1000 -m -s /bin/bash homelab || true

# Set path ownership and access permissions recursively
sudo chown -R 1000:1000 /mnt/data
sudo chmod -R 775 /mnt/data
```

---

## Phase 2: Host Network & Firewall Preparation

### 1. Host Firewalls (UFW)
Restrict open ports on bare metal while exposing only HTTP/HTTPS and SSH via the NetBird interface.

```bash
# Apply default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow HTTP/HTTPS traffic for Nginx Proxy Manager
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow SSH strictly via WireGuard/NetBird interface (wt0)
sudo ufw allow in on wt0 to any port 22 proto tcp

# Enable firewall
sudo ufw enable
```

### 2. External Docker Bridge Provisioning
Services across different sub-stacks communicate over decoupled external Docker networks. Pre-create these bridges prior to invoking compose files.

```bash
docker network create proxy-net      # Core Proxy Ingress
docker network create auth-net       # Central Identity Gateway
docker network create media-net      # Media Automation Stack
docker network create monitoring-net # Telemetry & Metrics
```

---

## Phase 3: Secrets & Environment Configuration

Copy the template `.env.example` files in each functional stack folder to `.env` and populate them with cryptographically strong values.

### 1. Generating Secure Keys
Execute this command in your host terminal to generate secrets:
```bash
# Generate 64-character hex keys for database/authentik secrets
openssl rand -hex 32
```

### 2. `.env` Deployment Matrix

#### `01-core/.env`
```env
TZ=UTC
```

#### `03-auth/.env`
```env
AUTHENTIK_SECRET_KEY=<GENERATED_OPENSSL_HEX>
PG_PASS=<GENERATED_STRONG_PASSWORD>
PG_USER=authentik
PG_DB=authentik
COMPOSE_PORT_HTTP=9000
COMPOSE_PORT_HTTPS=9443
```

#### `04-apps/media-stack/.env`
```env
PUID=1000
PGID=1000
TZ=UTC
VPN_SERVICE_PROVIDER=mullvad
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=<YOUR_VPN_PRIVATE_KEY>
WIREGUARD_ADDRESSES=<YOUR_VPN_IP_ADDRESS>
SERVER_COUNTRIES=Switzerland
```

---

## Phase 4: Automated Deployment Execution

Execute the root-level deployment script to pull containers and spin up services in strict dependency sequence.

```bash
# Make script executable
chmod +x deploy.sh

# Run the master deployment pipeline
./deploy.sh
```

---

## Phase 5: Verification & Validation Checklist

Confirm all layers are running by hitting their native management ports or running endpoint checks:

| Service Layer | Endpoint / URL | Default Port | Primary Validation Task |
| :--- | :--- | :--- | :--- |
| **01-core** | `http://<HOST-IP>:81` | 81 | Log into Nginx Proxy Manager (Default: `admin@example.com` / `changeme`) |
| **03-auth** | `http://<HOST-IP>:9000/if/flow/initial-setup/` | 9000 | Setup Authentik Initial Admin User |
| **04-apps** | `http://<HOST-IP>:8080` | 8080 | Verify qBittorrent Web UI via Gluetun IP |
| **05-monitoring** | `http://<HOST-IP>:3001` | 3001 | Configure Uptime Kuma Status Monitors |

---

## Disaster Recovery & Maintenance

To create a manual snapshot of all application configurations and database state:

```bash
chmod +x 06-backup/backup.sh
./06-backup/backup.sh
```