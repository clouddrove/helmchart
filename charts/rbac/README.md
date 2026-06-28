# rbac

Per-user (or per-bot) namespace RBAC using **ServiceAccounts + RoleBindings**, with **no SSO/IdP required**.

For each entry in `members`, the chart creates:

| Resource | Name | Purpose |
|----------|------|---------|
| `Namespace` *(optional)* | `ns-<name>` | sandbox namespace (skip with `createNamespace: false`) |
| `ServiceAccount` | `sa-<name>` | the identity |
| `Secret` (`service-account-token`) | `sa-<name>-token` | long-lived bearer token for that SA |
| `RoleBinding` → built-in `ClusterRole` | `rb-<name>` | grants `view` / `edit` / `admin` in the namespace |

Portable: pure Kubernetes RBAC primitives, runs identically on **EKS, AKS, GKE, kind, and on-prem** — no cloud-specific APIs.

## Quick start

```bash
helm repo add clouddrove https://charts.clouddrove.com/
helm repo update clouddrove

cat > members.yaml <<'EOF'
members:
  - name: alice
    namespace: alice
    role: edit          # view | edit | admin
    createNamespace: true
  - name: ci-bot
    namespace: build
    role: edit
EOF

helm upgrade --install rbac clouddrove/rbac -f members.yaml
```

Retrieve a member's token:

```bash
kubectl -n alice get secret sa-alice-token -o jsonpath='{.data.token}' | base64 -d
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `members` | list | `[]` | one entry per user/bot |
| `members[].name` | string | — | **required**; DNS-safe (`^[a-z0-9]([-a-z0-9]*[a-z0-9])?$`) |
| `members[].namespace` | string | `ns-<name>` | target namespace |
| `members[].role` | string | `edit` | one of `view`, `edit`, `admin` |
| `members[].createNamespace` | bool | `true` | create the namespace |

`values.schema.json` enforces `role` and the name/namespace patterns at install time.

## When to use this chart vs cloud-native RBAC

This chart binds **ServiceAccount tokens**, not human cloud identities. Every managed cloud has a native path that maps **cloud IAM/SSO identities** to Kubernetes RBAC — prefer it for real users:

| Cloud | Native human identity → RBAC | Native workload identity |
|-------|------------------------------|--------------------------|
| **EKS** | Access Entries (or legacy `aws-auth` ConfigMap) map IAM roles/users to RBAC groups | IRSA / EKS Pod Identity |
| **AKS** | Microsoft Entra ID + Azure RBAC for Kubernetes (`--enable-aad`) | Workload Identity |
| **GKE** | Google Groups for RBAC + Cloud IAM | Workload Identity |

**Prefer cloud-native** when you have human users behind an IdP — those credentials are **short-lived and federated**, with nothing static to leak or rotate.

**Use this chart** when SSO is absent or unnecessary:

- bots / CI / automation that need a stable machine identity
- bootstrapping a cluster before an IdP is wired up
- `kind` / on-prem / bare clusters with no IdP
- quick per-namespace sandbox for a teammate

> ⚠️ **Security:** `sa-<name>-token` is a **long-lived bearer token**. Anyone holding it has standing access until the Secret is deleted. Treat tokens as secrets, scope `role` to least privilege, and avoid handing them to humans as a long-term substitute for SSO.

The two approaches **coexist** — these RoleBindings stack on top of any cloud IAM mapping. This chart deliberately covers only the no-SSO / machine-identity case.
