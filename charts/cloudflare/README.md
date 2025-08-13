# cloudflared-tunnel Helm Chart

Run [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) in Kubernetes with a pre-provisioned token.  
This chart deploys the Cloudflare `cloudflared` client without auto-updates, optionally exposing Prometheus-compatible metrics.

---

## 📦 Chart Details

- **Name:** `cloudflared-tunnel`
- **Type:** `application`
- **Version:** `0.1.0`
- **App Version:** `2025.8.0`
- **Image:** `cloudflare/cloudflared:2025.8.0`

---

## 🚀 Features

- Deploy `cloudflared` in a Kubernetes cluster.
- Configurable namespace creation.
- Securely store the tunnel token in a Kubernetes Secret.
- Optional metrics endpoint for monitoring.
- Configurable resource requests/limits, node selectors, tolerations, and affinities.

---

## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- A valid [Cloudflare Tunnel token](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/#create-a-tunnel-and-get-the-credentials-file).

---

## 🔧 Installation

### 1️⃣ Add the Helm repository (if applicable)

```bash
helm repo add myrepo https://example.com/charts
helm repo update
