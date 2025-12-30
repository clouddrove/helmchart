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

### Providing Secrets

The chart creates a Kubernetes secret named `<release>-secret` using the values you provide. To reuse an existing secret, set `existingSecret` to its name and the chart will not create a new one. Supply sensitive values via your preferred secrets management in CI/CD and pass them as values:

```bash
helm install adrija ./helm/adrija \
  --namespace adrija \
  --create-namespace \
  --set slack.botToken="xoxb-your-token" \
  --set slack.appToken="xapp-your-token" \
  --set aiProviders.geminiApiKey="your-gemini-key" \
  --set aiProviders.anthropicApiKey="your-claude-key" \
  --set aiProviders.openaiApiKey="your-openai-key"
```

Disable any AI providers you do not use to avoid creating empty secret keys.

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
| `existingSecret` | Use an existing secret name instead of creating one | `""` |

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

The chart creates a Kubernetes secret named `<release>-secret` from the values you supply. For production, inject those values from a secure source in your CI/CD system (Vault, cloud secret managers, Sealed Secrets, etc.) rather than committing them to git. Disable unused AI providers to avoid generating empty secret keys.

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
