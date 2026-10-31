# Storage Architecture & ZFS Configuration

## 1. Pool & Dataset Layout
We utilize ZFS on Proxmox to guarantee bitrot protection, native compression, and instant snapshots.

```bash
# Create ZFS pool (adjust disks as necessary)
zpool create -f -o ashift=12 tank mirror /dev/disk/by-id/ATA-DISK1 /dev/disk/by-id/ATA-DISK2

# Enable lz4 compression and modern features
zfs set compression=lz4 tank
zfs set xattr=sa tank

# Create isolated datasets
zfs create tank/media
zfs create tank/appdata
```

## 2. Unified Mount Structure & Hardlinks
All containers mount a single unified path (/mnt/data) to ensure completed downloads are instantly hardlinked rather than copied across filesystems.

/mnt/data/
├── torrents/
│   ├── incomplete/
│   └── completed/
└── media/
    ├── movies/
    └── tv/