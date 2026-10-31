# Disaster Recovery & Backup Strategy

## Backup Targets
- **Appdata Volumes:** All persistent container configurations and databases located in `/mnt/data/appdata` are snapshotted daily.
- **Proxmox Backup Server (PBS):** Automated incremental block-level backups of entire LXCs/VMs.

## Automation Script Plan
Backups run via automated cron jobs executing encrypted snapshots to an off-host target using Borgmatic or Kopia.