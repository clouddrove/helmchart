# Adrija Helm Chart

A production-ready Helm chart for deploying Adrija - AI Assistant for Slack on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- kubectl configured to access your cluster

## Installation

### Basic Installation

```bash
# Add your values
helm install adrija ./helm/adrija \
  --namespace adrija \
  --create-namespace \
  --set slack.botToken="xoxb-your-token" \
  --set slack.appToken="xapp-your-token" \
  --set aiProviders.geminiApiKey="your-gemini-key"
```

### Production Installation

```bash
# Use production values
helm install adrija ./helm/adrija \
  --namespace adrija \
  --create-namespace \
  -f helm/adrija/values-production.yaml \
  --set slack.botToken="xoxb-your-token" \
  --set slack.appToken="xapp-your-token" \
  --set aiProviders.geminiApiKey="your-gemini-key"
```

### Using 1Password (Recommended for Production)

The chart supports 1Password via External Secrets Operator. This is the recommended approach for production.

1. **Prerequisites**: Install External Secrets Operator and 1Password Connect in your cluster

2. **Create SecretStore** (if not already created):

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: 1password
  namespace: adrija
spec:
  provider:
    onepassword:
      connect:
        url: http://onepassword-connect-api.onepassword-connect.svc.cluster.local:8080
```

3. **Create secrets in 1Password**:
   - Vault: `Engineering` (or your vault name)
   - Item: `adrija-secrets`
   - Fields: `slack_bot_token`, `slack_app_token`, `gemini_api_key`, etc.

4. **Configure values**:

```yaml
externalSecrets:
  enabled: true
  secretStore: "1password"
  vault: "Engineering"
  item: "adrija-secrets"
```

5. **Install**:

```bash
helm install adrija ./helm/adrija \
  --namespace adrija \
  --create-namespace \
  -f values.yaml
```

See [1Password Setup Guide](./examples/1password-setup.md) for detailed instructions.

### Using Kubernetes Secrets (Alternative)

1. Create a Kubernetes secret with your credentials:

```bash
kubectl create secret generic adrija-secrets \
  --from-literal=slack-bot-token="xoxb-your-token" \
  --from-literal=slack-app-token="xapp-your-token" \
  --from-literal=gemini-api-key="your-gemini-key" \
  --namespace adrija
```

2. Update `values.yaml` to disable external secrets:

```yaml
externalSecrets:
  enabled: false

slack:
  botToken: ""  # Will be set from secret
  appToken: ""  # Will be set from secret

aiProviders:
  geminiApiKey: ""  # Will be set from secret
```

3. Install with your custom values:

```bash
helm install adrija ./helm/adrija \
  --namespace adrija \
  --create-namespace \
  -f my-values.yaml
```

## Configuration

### Key Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `image.repository` | Container image repository | `adrija` |
| `image.tag` | Container image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `3000` |
| `ingress.enabled` | Enable ingress | `false` |
| `autoscaling.enabled` | Enable HPA | `true` |
| `autoscaling.minReplicas` | Minimum replicas | `2` |
| `autoscaling.maxReplicas` | Maximum replicas | `10` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.requests.memory` | Memory request | `256Mi` |
| `slack.botToken` | Slack bot token (required) | `""` |
| `slack.appToken` | Slack app token (required) | `""` |
| `aiProviders.enableGemini` | Enable Gemini provider | `true` |
| `aiProviders.enableClaude` | Enable Claude provider | `true` |
| `aiProviders.enableOpenAI` | Enable OpenAI provider | `false` |
| `aiProviders.defaultProvider` | Default AI provider | `gemini` |
| `aiProviders.geminiApiKey` | Gemini API key | `""` |
| `aiProviders.anthropicApiKey` | Anthropic API key | `""` |
| `aiProviders.openaiApiKey` | OpenAI API key | `""` |
| `features.autoRespondChannel` | Auto-respond channel | `""` |
| `features.conversationMaxHistory` | Max conversation history | `10` |
| `features.rateLimitMaxRequests` | Rate limit max requests | `10` |
| `features.rateLimitWindowSeconds` | Rate limit window | `60` |
| `externalSecrets.enabled` | Enable External Secrets (1Password) | `true` |
| `externalSecrets.secretStore` | SecretStore name | `"1password"` |
| `externalSecrets.vault` | 1Password vault name | `"Engineering"` |
| `externalSecrets.item` | 1Password item name | `"adrija-secrets"` |
| `externalSecrets.refreshInterval` | Secret refresh interval | `"1h"` |

### Complete Configuration Example

```yaml
# values.yaml
replicaCount: 3

image:
  repository: your-registry/adrija
  tag: "1.0.0"
  pullPolicy: Always

service:
  type: ClusterIP
  port: 3000

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: adrija.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: adrija-tls
      hosts:
        - adrija.example.com

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70

resources:
  limits:
    cpu: 2000m
    memory: 1Gi
  requests:
    cpu: 1000m
    memory: 512Mi

slack:
  botToken: "xoxb-your-token"
  appToken: "xapp-your-token"

aiProviders:
  enableGemini: true
  enableClaude: true
  enableOpenAI: false
  defaultProvider: "gemini"
  geminiApiKey: "your-gemini-key"
  anthropicApiKey: "your-claude-key"
  geminiModel: "gemini-1.5-flash"
  openaiModel: "gpt-3.5-turbo"

features:
  autoRespondChannel: "ask-anything"
  conversationMaxHistory: 10
  conversationTtlHours: 24
  rateLimitMaxRequests: 10
  rateLimitWindowSeconds: 60
  metricsMaxHistory: 1000

podDisruptionBudget:
  enabled: true
  minAvailable: 2

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
            - adrija
        topologyKey: kubernetes.io/hostname
```

## Upgrading

```bash
# Upgrade with new values
helm upgrade adrija ./helm/adrija \
  --namespace adrija \
  -f my-values.yaml

# Upgrade with production values
helm upgrade adrija ./helm/adrija \
  --namespace adrija \
  -f helm/adrija/values-production.yaml
```

## Uninstalling

```bash
helm uninstall adrija --namespace adrija
```

## Monitoring

### Health Checks

The chart includes health check endpoints:

- **Liveness Probe**: `/health` - checks if the pod is alive
- **Readiness Probe**: `/health` - checks if the pod is ready
- **Startup Probe**: `/health` - checks if the pod has started

### Metrics

Access metrics endpoint:

```bash
kubectl port-forward -n adrija svc/adrija 3000:3000
curl http://localhost:3000/metrics
```

### ServiceMonitor (Prometheus)

If you have Prometheus Operator installed, enable ServiceMonitor:

```yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels:
      release: prometheus
```

## Security

### Pod Security

The chart includes security best practices:

- Non-root user (UID 1000)
- Read-only root filesystem (configurable)
- Dropped capabilities
- No privilege escalation

### Network Policies

Enable network policies for additional security:

```yaml
networkPolicy:
  enabled: true
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            name: ingress-nginx
      ports:
      - protocol: TCP
        port: 3000
  egress:
    - to:
      - namespaceSelector: {}
      ports:
      - protocol: TCP
        port: 443
```

### Secrets Management

For production, use external secret management:

1. **1Password (Recommended)**: Use 1Password via External Secrets Operator - See [1Password Setup Guide](./examples/1password-setup.md)
2. **External Secrets**: Use External Secrets Operator with other providers
3. **Sealed Secrets**: Use Bitnami Sealed Secrets
4. **Vault**: Use HashiCorp Vault
5. **Cloud Secrets**: Use cloud provider secret managers (AWS Secrets Manager, GCP Secret Manager, Azure Key Vault)

**Note**: The chart is configured to use 1Password by default. Set `externalSecrets.enabled: false` to use Kubernetes secrets instead.

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n adrija
kubectl describe pod <pod-name> -n adrija
```

### View Logs

```bash
# All pods
kubectl logs -n adrija -l app.kubernetes.io/name=adrija -f

# Specific pod
kubectl logs -n adrija <pod-name> -f
```

### Check Events

```bash
kubectl get events -n adrija --sort-by='.lastTimestamp'
```

### Debug Pod

```bash
kubectl exec -it -n adrija <pod-name> -- /bin/sh
```

### Check HPA

```bash
kubectl get hpa -n adrija
kubectl describe hpa -n adrija
```

### Check PDB

```bash
kubectl get pdb -n adrija
kubectl describe pdb -n adrija
```

## Production Best Practices

1. **Use Specific Image Tags**: Never use `latest` in production
2. **Enable Resource Limits**: Set appropriate CPU and memory limits
3. **Enable HPA**: Configure autoscaling based on metrics
4. **Enable PDB**: Ensure availability during disruptions
5. **Use Secrets**: Store sensitive data in Kubernetes secrets
6. **Enable Network Policies**: Restrict network traffic
7. **Enable Monitoring**: Set up Prometheus/Grafana
8. **Use Ingress**: Expose services through ingress controller
9. **Pod Anti-Affinity**: Spread pods across nodes
10. **Regular Updates**: Keep images and dependencies updated

## Support

For issues and questions:
- GitHub Issues: https://github.com/cloudwizz/adrija/issues
- Documentation: See main README.md

