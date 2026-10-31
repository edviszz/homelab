#!/bin/bash
set -euo pipefail

# Configuration
BACKUP_DIR="/mnt/data/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

echo "[*] Starting homelab appdata backup..."

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Create a compressed tarball of all appdata volumes across the homelab
tar -czf "$BACKUP_DIR/appdata_backup_$TIMESTAMP.tar.gz" \
    --exclude='*/appdata/*/cache' \
    /path/to/your/homelab/01-core/data \
    /path/to/your/homelab/03-auth/appdata \
    /path/to/your/homelab/04-apps/media-stack/appdata \
    /path/to/your/homelab/05-monitoring/appdata

echo "[*] Backup completed: appdata_backup_$TIMESTAMP.tar.gz"

# Prune old backups exceeding retention policy
find "$BACKUP_DIR" -name "appdata_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete
echo "[*] Pruned backups older than $RETENTION_DAYS days."