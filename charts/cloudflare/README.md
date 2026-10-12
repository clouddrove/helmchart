# Cloudflare Tunnel (`cloudflared-tunnel`) Helm Chart

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/cloudflared-tunnel)](https://artifacthub.io/packages/helm/clouddrove/cloudflared-tunnel)
![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 2026.9.3](https://img.shields.io/badge/AppVersion-2026.9.3-informational?style=flat-square)
![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue?style=flat-square)

A production-ready, security-hardened Helm chart for deploying Cloudflare Tunnel ([`cloudflared`](https://github.com/cloudflare/cloudflared)) into Kubernetes using remote token authentication.

Expose internal Kubernetes services and ingress controllers securely to the Internet via Cloudflare Zero Trust without opening inbound firewall ports, configuring port forwarding, or provisioning public IP addresses.

---

## 🚀 Features

- **Outbound-Only Connectivity**: Creates a lightweight, outbound-only tunnel to the nearest Cloudflare Edge PoPs.
- **Remote Zero Trust Management**: Managed entirely through the Cloudflare Zero Trust Dashboard via a single tunnel token (`TUNNEL_TOKEN`).
- **Security Hardened**:
  - Enforces Kubernetes **Restricted Pod Security Standard** (`readOnlyRootFilesystem: true`, `runAsNonRoot: true`, user/group `65532`, `allowPrivilegeEscalation: false`, drops `ALL` capabilities).
  - Dedicated `ServiceAccount` with API credential automounting disabled (`automountServiceAccountToken: false`).
- **Production High Availability (HA)**:
  - Supports active-active multi-replica tunnels connecting to distinct Cloudflare edge locations simultaneously.
  - Zero-downtime rolling updates (`maxUnavailable: 0`, `maxSurge: 1`).
  - Configurable `PodDisruptionBudget` (PDB) and `podAntiAffinity`.
- **Observability**:
  - Built-in readiness and liveness health checks against `/ready`.
  - Prometheus metrics endpoint on port `2000`.
  - Native Prometheus Operator `ServiceMonitor` integration.
- **Enterprise Secret Management**:
  - Seamless integration with external secret stores (HashiCorp Vault, AWS Secrets Manager, SealedSecrets, External Secrets Operator).

---

## 📋 Prerequisites

- Kubernetes cluster 1.21+
- Helm 3.8.0+
- A Cloudflare account with a Tunnel created in the **Cloudflare Zero Trust Dashboard**:
  1. Navigate to **Networks** > **Tunnels**.
  2. Click **Create a tunnel** and select **Cloudflare (remotely-managed)**.
  3. Copy the token provided in the installation command (`--token <YOUR_TOKEN>`).

---

## 📦 Installation

### Add the Helm Repository

```bash
helm repo add clouddrove https://charts.clouddrove.com/
helm repo update
```

---

## 💡 Practical Examples

### Example 1: Quickstart (Direct Token)

For quick testing or non-production deployments, pass the token directly during installation:

```bash
helm install cloudflared-tunnel clouddrove/cloudflared-tunnel \
  --namespace cloudflare-tunnel \
  --create-namespace \
  --set secret.token="eyJhIjoiZWU..."
```

> **Note**: Provide the raw token string copied from Cloudflare. Do not pre-encode it into Base64; Kubernetes will automatically handle encoding.

---

### Example 2: Using an Existing Secret (Recommended for Production & GitOps)

In production and GitOps workflows (e.g., ArgoCD, Flux), you should never store plaintext tokens in Helm values. Instead, pre-create a Kubernetes Secret or sync it using External Secrets Operator / Vault.

#### Step 1: Create the Secret
```bash
kubectl create secret generic cloudflare-tunnel-credentials \
  --namespace cloudflare-tunnel \
  --from-literal=TUNNEL_TOKEN="eyJhIjoiZWU..."
```

#### Step 2: Configure `values.yaml`
```yaml
secret:
  enabled: true
  existingSecret: "cloudflare-tunnel-credentials"
  existingSecretKey: "TUNNEL_TOKEN"   # Name of the key containing the token
```

Deploy with:
```bash
helm install cloudflared-tunnel clouddrove/cloudflared-tunnel \
  --namespace cloudflare-tunnel \
  --create-namespace \
  -f values.yaml
```

---

### Example 3: High Availability (Multi-Replica with PDB & Anti-Affinity)

Cloudflare Tunnels natively support running multiple replicas with the **same tunnel token**. Each replica connects to a different Cloudflare Edge server to provide seamless failover and redundancy.

Create `ha-values.yaml`:

```yaml
replicaCount: 2

strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0

# Ensure at least 1 tunnel replica is always running during node drains
podDisruptionBudget:
  enabled: true
  minAvailable: 1

# Spread tunnel pods across different physical nodes
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values:
                  - cloudflared-tunnel
          topologyKey: kubernetes.io/hostname

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi

secret:
  existingSecret: "cloudflare-tunnel-credentials"
```

---

### Example 4: Prometheus Operator Monitoring (`ServiceMonitor`)

If your cluster runs Prometheus Operator (or `kube-prometheus-stack`), enable the `ServiceMonitor` to scrape cloudflared metrics:

Create `monitoring-values.yaml`:

```yaml
metrics:
  enabled: true
  port: 2000

service:
  enabled: true
  type: ClusterIP
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "2000"

serviceMonitor:
  enabled: true
  interval: 15s
  scrapeTimeout: 10s
  path: /metrics
  labels:
    release: prometheus-stack  # Set to match your Prometheus serviceMonitorSelector
```

---

### Example 5: Custom CLI Flags (`extraArgs`)

You can pass additional CLI options to `cloudflared` using `extraArgs`:

```yaml
extraArgs:
  - --protocol
  - quic                  # Force QUIC/UDP transport protocol
  - --loglevel
  - info
  - --edge-ip-version
  - "4"                   # Connect over IPv4 only
```

---

### Example 6: Private Registry Pull (`imagePullSecrets`)

If your environment mirrors the `cloudflared` image into a private container registry (e.g., AWS ECR, Harbor, Google Artifact Registry):

```yaml
image:
  repository: myregistry.internal/docker/cloudflare/cloudflared
  tag: "2026.9.3"
  pullPolicy: IfNotPresent

imagePullSecrets:
  - name: my-registry-secret
```

---

### Example 7: Cloudflare WARP Routing / ICMP Ping Support

If you use Cloudflare WARP to access internal Kubernetes subnets and need ICMP ping support, enable the Linux ping sysctl:

```yaml
podSecurityContext:
  runAsNonRoot: true
  fsGroup: 65532
  fsGroupChangePolicy: "OnRootMismatch"
  sysctls:
    - name: net.ipv4.ping_group_range
      value: "0 2147483647"
```

---

### Example 8: Extra Environment Variables & ConfigMap

Inject proxy settings or custom `TUNNEL_*` configuration options:

```yaml
# Direct environment variables
env:
  - name: TUNNEL_TRANSPORT_LOGLEVEL
    value: "warn"
  - name: NO_PROXY
    value: "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

# Or populate via ConfigMap
configmap:
  enabled: true
  data:
    TUNNEL_METRICS: "0.0.0.0:2000"
```

---

## ⚙️ Configuration Reference

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `replicaCount` | `int` | `1` | Number of replica pods (set to 2+ for High Availability) |
| `image.repository` | `string` | `"cloudflare/cloudflared"` | Image repository |
| `image.tag` | `string` | `"2026.9.3"` | Image tag |
| `image.pullPolicy` | `string` | `"IfNotPresent"` | Image pull policy |
| `imagePullSecrets` | `list` | `[]` | Image pull secret references for private registries |
| `strategy` | `object` | `RollingUpdate (maxSurge: 1, maxUnavailable: 0)` | Deployment rolling update strategy |
| `serviceAccount.create` | `bool` | `true` | Create dedicated ServiceAccount |
| `serviceAccount.name` | `string` | `""` | Custom ServiceAccount name |
| `serviceAccount.automount` | `bool` | `false` | Automount Kubernetes API token to container |
| `podSecurityContext` | `object` | `{runAsNonRoot: true, fsGroup: 65532, ...}` | Pod-level security context |
| `securityContext` | `object` | `{runAsUser: 65532, readOnlyRootFilesystem: true, ...}` | Container-level security context (Restricted PSS) |
| `terminationGracePeriodSeconds`| `int` | `30` | Grace period in seconds for connection draining |
| `secret.enabled` | `bool` | `true` | Enable secret management |
| `secret.token` | `string` | `""` | Raw plaintext tunnel token from Cloudflare Zero Trust |
| `secret.existingSecret` | `string` | `""` | Name of an existing Kubernetes secret containing the token |
| `secret.existingSecretKey` | `string` | `"TUNNEL_TOKEN"` | Key inside the existing secret holding the token |
| `configmap.enabled` | `bool` | `false` | Enable injecting environment variables via ConfigMap |
| `configmap.data` | `object` | `{}` | Key-value pairs for the ConfigMap |
| `command` | `list` | `["cloudflared"]` | Container entrypoint command |
| `args` | `list` | `["tunnel", "--no-autoupdate", "--metrics", "0.0.0.0:2000", "run"]` | Container run arguments |
| `extraArgs` | `list` | `[]` | Additional CLI arguments passed to `cloudflared` |
| `env` | `list` | `[]` | Additional environment variables |
| `envFrom` | `list` | `[]` | Additional `envFrom` sources |
| `metrics.enabled` | `bool` | `true` | Expose metrics container port (2000) |
| `metrics.port` | `int` | `2000` | Port for Prometheus metrics |
| `service.enabled` | `bool` | `true` | Create a Kubernetes Service for the metrics endpoint |
| `service.type` | `string` | `"ClusterIP"` | Metrics Service type |
| `serviceMonitor.enabled` | `bool` | `false` | Create a Prometheus Operator `ServiceMonitor` |
| `serviceMonitor.interval` | `string` | `"15s"` | Prometheus scrape interval |
| `podDisruptionBudget.enabled` | `bool` | `false` | Create a `PodDisruptionBudget` for the deployment |
| `podDisruptionBudget.minAvailable` | `int/string`| `1` | Minimum available pods during eviction |
| `livenessProbe` | `object` | `{httpGet: {path: /ready, port: 2000}, ...}` | Liveness probe settings |
| `readinessProbe` | `object` | `{httpGet: {path: /ready, port: 2000}, ...}` | Readiness probe settings |
| `resources` | `object` | `{}` | Container CPU/Memory resource requests and limits |
| `affinity` | `object` | `{}` | Pod affinity and anti-affinity rules |
| `nodeSelector` | `object` | `{}` | Node label selectors |
| `tolerations` | `list` | `[]` | Node taint tolerations |
| `commonLabels` | `object` | `{}` | Labels added to all resources |
| `podAnnotations` | `object` | `{}` | Annotations for pod template |
| `deployment.annotations` | `object` | `{}` | Annotations for Deployment |

---

## 🔍 Verification & Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n cloudflare-tunnel -l app.kubernetes.io/name=cloudflared-tunnel
```

### Inspect Tunnel Logs
```bash
kubectl logs -n cloudflare-tunnel -l app.kubernetes.io/name=cloudflared-tunnel -f
```

You should see output similar to:
```text
INF Starting tunnel tunnelID=...
INF Version 2026.9.3
INF Generated Connector ID: ...
INF Connection ... registered connIndex=0 location=ORD
INF Connection ... registered connIndex=1 location=IAD
```

### Check Health Probe & Metrics Endpoint
Since the official `cloudflare/cloudflared` image is **distroless** (contains no shell or package binaries for security), use `port-forward` to query endpoints:

```bash
# Port-forward the metrics port to localhost:
kubectl port-forward -n cloudflare-tunnel deploy/cloudflared-tunnel 2000:2000

# Query the /ready probe:
curl -i http://localhost:2000/ready
# (HTTP/1.1 200 OK confirms active edge connection)

# Query metrics:
curl -s http://localhost:2000/metrics | grep cloudflared_tunnel
```
