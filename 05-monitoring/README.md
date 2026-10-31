# Monitoring & Observability Stack

## Components
- **Prometheus + Grafana:** Scrapes host metrics (Node Exporter) and container resource usage (cAdvisor) to track CPU, RAM, and disk I/O bottlenecks.
- **Uptime Kuma:** Actively pings container endpoints and public domain URLs, triggering Discord/Telegram webhook alerts the moment a service goes down.