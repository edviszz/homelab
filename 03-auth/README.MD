# Authentication & Access Control (Authentik)

## Architecture Overview
Authentik acts as the centralized Single Sign-On (SSO) and Forward Auth bouncer. No external request reaches an application container without passing through Authentik's verification checkpoint in Nginx Proxy Manager.

## Deployment Blueprint
- **Provider Type:** Proxy Provider
- **Enforcement:** Enforced globally on public-facing subdomains.
- **Bypass Rules:** Internal Docker network traffic (`media-net`, `proxy-net`) bypasses external auth checks for service-to-service communication (e.g., Prowlarr talking to Sonarr).