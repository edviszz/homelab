# Media Automation Stack (`media-stack`)

## Isolation & Networking Rules
1. **Gluetun VPN Gateway:** qBittorrent runs exclusively inside Gluetun's network namespace (`network_mode: "service:gluetun"`). If the VPN tunnel drops, all torrent traffic halts instantly.
2. **Local Bridge (`media-net`):** Prowlarr, Sonarr, Radarr, Jellyfin, and Jellyseerr operate on an internal bridge network (`media-net`) to eliminate routing bottlenecks.
3. **Proxy Ingress:** Jellyfin and Jellyseerr also join the external `proxy-net` so Nginx Proxy Manager can route inbound web traffic via container names.

## Environment Variables (.env.example)
```env
PUID=1000
PGID=1000
TZ=UTC
VPN_SERVICE_PROVIDER=your_provider
OPENVPN_USER=your_username
OPENVPN_PASSWORD=your_password