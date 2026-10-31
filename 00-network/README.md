# Network Foundation: NetBird & Host Firewall

## 1. NetBird Host Installation (Out-of-Band Management)
Run these commands directly on the host OS kernel before initializing any Docker containers.

```bash
# Install NetBird official CLI client
curl -s [https://pkgs.netbird.io/install.sh](https://pkgs.netbird.io/install.sh) | sh

# Enable and start the NetBird service
sudo systemctl enable --now netbird

# Authenticate and join your private mesh network using your setup key
sudo netbird up --setup-key "YOUR_NETBIRD_SETUP_KEY"

# Verify the WireGuard interface (wt0) is active
sudo netbird status
```

## 2. UFW Firewall Hardening
Lock down the host firewall to prevent unauthorized external access while allowing mesh traffic and established connections.

```bash
# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH strictly over the NetBird interface (wt0) or local subnet if needed
sudo ufw allow in on wt0 to any port 22 proto tcp

# Allow HTTP/HTTPS traffic for Nginx Proxy Manager
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```