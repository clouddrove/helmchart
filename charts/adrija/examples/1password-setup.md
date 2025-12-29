# 1Password Integration Setup

This guide explains how to set up 1Password as the secret source for Adrija using External Secrets Operator.

## Prerequisites

1. **1Password Connect** installed in your Kubernetes cluster
2. **External Secrets Operator** installed in your cluster
3. **1Password account** with a vault containing the required secrets

## Step 1: Install External Secrets Operator

```bash
# Add the Helm repository
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# Install External Secrets Operator
helm install external-secrets \
  external-secrets/external-secrets \
  --namespace external-secrets-system \
  --create-namespace
```

## Step 2: Install 1Password Connect

### Option A: Using Helm (Recommended)

```bash
# Add 1Password Connect Helm repository
helm repo add 1password https://1password.github.io/connect-helm-charts
helm repo update

# Install 1Password Connect
helm install onepassword-connect \
  1password/connect \
  --namespace onepassword-connect \
  --create-namespace \
  --set-file connect.credentials=./1password-credentials.json
```

### Option B: Using Kubernetes Manifests

See the [official 1Password Connect documentation](https://support.1password.com/connect-kubernetes/).

## Step 3: Create SecretStore

Create a SecretStore resource that points to your 1Password Connect instance:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: 1password
  namespace: adrija  # Your namespace
spec:
  provider:
    onepassword:
      connect:
        url: http://onepassword-connect-api.onepassword-connect.svc.cluster.local:8080
        # Or use token authentication
        # auth:
        #   secretRef:
        #     connectTokenSecretRef:
        #       name: onepassword-connect-token
        #       key: token
```

Apply it:

```bash
kubectl apply -f secretstore.yaml
```

## Step 4: Create Secrets in 1Password

In your 1Password vault, create a new item (or use an existing one) with the following fields:

**Item Name**: `adrija-secrets` (or match your `externalSecrets.item` value)

**Fields**:
- `slack_bot_token` - Your Slack bot token (xoxb-...)
- `slack_app_token` - Your Slack app token (xapp-...)
- `gemini_api_key` - Your Gemini API key (if using Gemini)
- `anthropic_api_key` - Your Anthropic API key (if using Claude)
- `openai_api_key` - Your OpenAI API key (if using OpenAI)

**Note**: Field names in 1Password must match exactly (case-sensitive):
- `slack_bot_token`
- `slack_app_token`
- `gemini_api_key`
- `anthropic_api_key`
- `openai_api_key`

## Step 5: Configure Helm Values

Update your `values.yaml` or create a custom values file:

```yaml
externalSecrets:
  enabled: true
  secretStore: "1password"  # Name of your SecretStore
  refreshInterval: "1h"
  vault: "Engineering"       # Your 1Password vault name
  item: "adrija-secrets"     # Your 1Password item name

# These values are ignored when externalSecrets.enabled=true
slack:
  botToken: ""
  appToken: ""

aiProviders:
  geminiApiKey: ""
  anthropicApiKey: ""
  openaiApiKey: ""
```

## Step 6: Install/Upgrade Adrija

```bash
helm install adrija ./helm/adrija \
  --namespace adrija \
  --create-namespace \
  -f values.yaml
```

## Step 7: Verify Secret Sync

Check if the ExternalSecret has synced:

```bash
# Check ExternalSecret status
kubectl get externalsecret -n adrija

# Describe to see details
kubectl describe externalsecret adrija-secret -n adrija

# Check if the secret was created
kubectl get secret adrija-secret -n adrija

# View secret (base64 encoded)
kubectl get secret adrija-secret -n adrija -o yaml
```

## Troubleshooting

### ExternalSecret Not Syncing

1. **Check ExternalSecret status**:
   ```bash
   kubectl describe externalsecret adrija-secret -n adrija
   ```

2. **Check SecretStore**:
   ```bash
   kubectl describe secretstore 1password -n adrija
   ```

3. **Check 1Password Connect**:
   ```bash
   kubectl get pods -n onepassword-connect
   kubectl logs -n onepassword-connect -l app.kubernetes.io/name=onepassword-connect
   ```

4. **Verify field names**: Ensure field names in 1Password match exactly (case-sensitive)

5. **Check vault and item names**: Verify they match your configuration

### Common Issues

**Issue**: `SecretStore not found`
- Solution: Ensure the SecretStore exists in the same namespace as the ExternalSecret

**Issue**: `Cannot connect to 1Password Connect`
- Solution: Verify 1Password Connect is running and the URL is correct

**Issue**: `Field not found in 1Password item`
- Solution: Check that all required fields exist in your 1Password item with exact names

**Issue**: `Authentication failed`
- Solution: Verify 1Password Connect credentials are correct

## Advanced Configuration

### Custom Field Names

If your 1Password item uses different field names, you can customize the mapping in the ExternalSecret template or create a custom values file.

### Multiple Environments

For different environments (dev, staging, prod), use different vaults or items:

```yaml
# Production
externalSecrets:
  vault: "Production"
  item: "adrija-secrets-prod"

# Staging
externalSecrets:
  vault: "Staging"
  item: "adrija-secrets-staging"
```

### Refresh Interval

Adjust the refresh interval based on your needs:

```yaml
externalSecrets:
  refreshInterval: "5m"  # Sync every 5 minutes
  # or
  refreshInterval: "24h" # Sync once per day
```

## Security Best Practices

1. **Use separate vaults** for different environments
2. **Limit access** to 1Password vaults using vault permissions
3. **Rotate secrets regularly** in 1Password
4. **Monitor ExternalSecret sync status** using alerts
5. **Use RBAC** to restrict who can view ExternalSecrets
6. **Enable audit logging** for 1Password Connect

## References

- [External Secrets Operator Documentation](https://external-secrets.io/)
- [1Password Connect Kubernetes Guide](https://support.1password.com/connect-kubernetes/)
- [External Secrets Operator 1Password Provider](https://external-secrets.io/v0.9.0/provider/onepassword/)

