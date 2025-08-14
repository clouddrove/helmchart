# cloudflared-tunnel Helm Chart

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) 
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 2025.8.0](https://img.shields.io/badge/AppVersion-2025.8.0-informational?style=flat-square)

A Helm chart for deploying Cloudflare Tunnel (cloudflared) in Kubernetes with token authentication.

**Homepage:** <https://github.com/clouddrove/helmchart>

## 🚀 Features

- Deploy `cloudflared` in a Kubernetes cluster.
- Configurable namespace creation.
- Securely store the tunnel token in a Kubernetes Secret.
- Optional metrics endpoint for monitoring.
- Configurable resource requests/limits, node selectors, tolerations, and affinities.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| CloudDrove Inc | <hello@clouddrove.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `affinity` | object | `{}` | Affinity rules for pod assignment |
| `args` | list | `["tunnel","--no-autoupdate","--metrics","0.0.0.0:2000","run"]` | Arguments for cloudflared container |
| `command` | list | `["cloudflared"]` | Command for cloudflared container |
| `createNamespace` | bool | `false` | Whether to create the namespace |
| `extraArgs` | list | `[]` | Additional arguments for cloudflared |
| `image.pullPolicy` | string | `"IfNotPresent"` | Image pull policy |
| `image.repository` | string | `"cloudflare/cloudflared"` | Container image repository |
| `image.tag` | string | `"2025.8.0"` | Container image tag |
| `metrics.enabled` | bool | `true` | Enable metrics endpoint |
| `metrics.port` | int | `2000` | Metrics port number |
| `namespace` | string | `"cloudflare-tunnel"` | Namespace to deploy to |
| `nodeSelector` | object | `{}` | Node selector for pod assignment |
| `replicaCount` | int | `1` | Number of replicas |
| `resources` | object | `{}` | Resource requests/limits |
| `secret.name` | string | `"cloudflared-token"` | Secret name for token |
| `secret.token` | string | `""` | Base64 encoded tunnel token (required) |
| `tolerations` | list | `[]` | Tolerations for pod assignment |

## Installation

### Add Helm repository
```bash
helm repo add clouddrove https://charts.clouddrove.com/ 

helm repo update

helm install cloudflared-tunnel clouddrove/cloudflared-tunnel \
  --namespace cloudflare-tunnel
