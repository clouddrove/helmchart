# pass2gh Helm Chart

This Helm chart deploys pass2gh (1Password to GitHub secrets sync tool) to Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- 1Password Connect server accessible from the cluster
- GitHub personal access token with `admin:org` and `repo:secrets` permissions
- Access to GitHub Container Registry (ghcr.io) - images are at `ghcr.io/clouddrove/pass2gh`

## Installation

### 1. Create values file

Create `my-values.yaml`:

```yaml
# 1Password Configuration
onepassword:
  connectHost: "http://1password-connect-service:8080"
  vaultId: "your-vault-id"
  token: "your-1password-connect-token"  # Set via --set or secrets

# GitHub Configuration
github:
  org: "clouddrove"
  repos:
    - "clouddrove/repo1"
    - "clouddrove/repo2"
  token: "your-github-token"  # Set via --set or secrets

# Organization Secrets
orgSecrets:
  DATABASE_URL: "DATABASE_URL"
  SHARED_API_KEY: "SHARED_API_KEY"

# Repository Secrets
repoSecrets:
  clouddrove/repo1:
    API_KEY: "API_KEY"
    DEPLOY_KEY: "DEPLOY_KEY"
  clouddrove/repo2:
    WEBHOOK_SECRET: "WEBHOOK_SECRET"

# Deployment Type
deployment:
  type: "CronJob"  # or "Deployment"
  cronJob:
    schedule: "0 * * * *"  # Every hour

# Image (defaults to GitHub Container Registry)
image:
  repository: ghcr.io/clouddrove/pass2gh
  tag: latest
```

### 2. Install with Helm

**Option A: Set secrets via --set (not recommended for production)**

```bash
helm install pass2gh ./helm/pass2gh \
  --namespace github-sync \
  --create-namespace \
  --set onepassword.token="your-op-token" \
  --set github.token="your-github-token" \
  -f my-values.yaml
```

**Option B: Use existing Kubernetes secrets (recommended)**

1. Create secrets manually:
```bash
kubectl create secret generic pass2gh-secrets \
  --from-literal=onepassword-token="your-op-token" \
  --from-literal=github-token="your-github-token" \
  -n github-sync
```

2. Update values.yaml to reference existing secret:
```yaml
existingSecret:
  enabled: true
  name: pass2gh-secrets
  onepasswordKey: onepassword-token
  githubKey: github-token

# Optionally omit onepassword.token and github.token when using existing secrets
```

3. Install:
```bash
helm install pass2gh ./helm/pass2gh \
  --namespace github-sync \
  --create-namespace \
  -f my-values.yaml
```

**Option C: Use External Secrets Operator or Sealed Secrets**

If using External Secrets Operator or Sealed Secrets, create the secret using those tools and reference it in values.yaml.

### 3. Verify Installation

```bash
# Check CronJob
kubectl get cronjobs -n github-sync

# Check Jobs
kubectl get jobs -n github-sync

# View logs
kubectl logs -l app.kubernetes.io/name=pass2gh -n github-sync
```

## Configuration

### Values File Structure

```yaml
# 1Password Connect
onepassword:
  connectHost: "http://1password-connect:8080"
  vaultId: "your-vault-id"
  token: "your-token"  # Or use existing secret

# GitHub
github:
  org: "clouddrove"
  repos:
    - "clouddrove/repo1"
  token: "your-token"  # Or use existing secret

# Use an existing Kubernetes Secret for tokens
existingSecret:
  enabled: true
  name: pass2gh-secrets
  onepasswordKey: onepassword-token
  githubKey: github-token

# Secret Mappings
orgSecrets:
  SECRET_NAME: "1PASSWORD_ITEM_TITLE"

repoSecrets:
  clouddrove/repo1:
    SECRET_NAME: "1PASSWORD_ITEM_TITLE"

# Deployment
deployment:
  type: "CronJob"  # or "Deployment"
  cronJob:
    schedule: "0 * * * *"
```

### Secret Mappings

The secret mappings work the same as in `config.json`:

**Simple format (recommended):**
```yaml
orgSecrets:
  DATABASE_URL: "DATABASE_URL"  # 1Password item title = GitHub secret name
```

**If names differ:**
```yaml
orgSecrets:
  DATABASE_URL: "My Database Connection"  # Different 1Password item title
```

## Upgrading

```bash
helm upgrade pass2gh ./helm/pass2gh \
  --namespace github-sync \
  -f my-values.yaml \
  --set onepassword.token="new-token" \
  --set github.token="new-token"
```

## Uninstalling

```bash
helm uninstall pass2gh --namespace github-sync
```

## Managing Secrets

### Using Helm Secrets Plugin

1. Install helm-secrets:
```bash
helm plugin install https://github.com/jkroepke/helm-secrets
```

2. Encrypt your values file:
```bash
helm secrets encrypt my-values.yaml > my-values.yaml.enc
```

3. Install with encrypted values:
```bash
helm secrets install pass2gh ./helm/pass2gh \
  -f my-values.yaml.enc
```

### Using External Secrets Operator

1. Create ExternalSecret:
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: pass2gh-secrets
spec:
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: pass2gh-secrets
  data:
  - secretKey: op-connect-token
    remoteRef:
      key: 1password/connect/token
  - secretKey: github-token
    remoteRef:
      key: github/token
```

2. Reference in Helm values (secrets will be created automatically)

## Troubleshooting

### Check ConfigMap

```bash
kubectl get configmap pass2gh-config -n github-sync -o yaml
```

### Check Secrets

```bash
kubectl get secret pass2gh-secrets -n github-sync -o yaml
```

### View Pod Logs

```bash
kubectl logs -l app.kubernetes.io/name=pass2gh -n github-sync
```

### Dry Run

To test your configuration without deploying:

```bash
helm install pass2gh ./helm/pass2gh \
  --dry-run --debug \
  -f my-values.yaml
```
