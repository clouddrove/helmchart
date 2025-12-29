# Helm Chart — favonia/cloudflare-ddns (with built-in Secret)

This chart now **creates the token Secret by default**. You can provide the token value inline or via `--set-file`.
Using an existing Secret is supported by setting `secret.existingSecret` (or `secret.name` for compatibility).

## Quick start (recommended: use --set-file to avoid shell history leaks)
```bash
# token.txt should contain ONLY the token string
helm upgrade --install cf-ddns ./charts/cloudflare-ddns -n tools --create-namespace   --set env.domains="home.example.com,*.lab.example.com"   --set-file secret.value=./token.txt
```

### Use an existing Secret instead
```bash
kubectl -n tools create secret generic cf-ddns-token   --from-literal=api-token='REDACTED_TOKEN'

helm upgrade --install cf-ddns ./charts/cloudflare-ddns -n tools   --set secret.existingSecret=cf-ddns-token   --set env.domains="home.example.com"
```

### IPv6 tip
If IPv6 detection is flaky in your environment, set:
```
--set hostNetwork=true
```

### Values
- `env.domains` **(required)**: comma-separated hostnames to update.
- `secret.name`: optional name override for the Secret when the chart creates it (defaults to release fullname).
- `secret.existingSecret`: name of an existing Secret to use; skips Secret creation.
- `secret.value`: API token string when creating a Secret. Prefer `--set-file secret.value=./token.txt`.

### Uninstall
```bash
helm -n tools uninstall cf-ddns
```
