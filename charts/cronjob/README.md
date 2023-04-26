# cronjob

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square)

A chart for cron jobs

**Homepage:** <https://github.com/clouddrove/helmchart>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| CloudDrove Inc. | <hello@clouddrove.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| jobs.hello-env-var.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/e2e-az-name"` |  |
| jobs.hello-env-var.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"In"` |  |
| jobs.hello-env-var.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"e2e-az1"` |  |
| jobs.hello-env-var.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[1] | string | `"e2e-az2"` |  |
| jobs.hello-env-var.args[0] | string | `"-c"` |  |
| jobs.hello-env-var.args[1] | string | `"echo $(date) - hello from $ECHO_VAR"` |  |
| jobs.hello-env-var.args[2] | string | `"echo $(date) - loaded secret $secret_data"` |  |
| jobs.hello-env-var.args[3] | string | `"echo $(date) - loaded config $config_data"` |  |
| jobs.hello-env-var.command[0] | string | `"/bin/sh"` |  |
| jobs.hello-env-var.concurrencyPolicy | string | `"Forbid"` |  |
| jobs.hello-env-var.envFrom[0].secretRef.name | string | `"secret_data"` |  |
| jobs.hello-env-var.envFrom[1].configMapRef.name | string | `"config_data"` |  |
| jobs.hello-env-var.env[0].name | string | `"ECHO_VAR"` |  |
| jobs.hello-env-var.env[0].value | string | `"busybox"` |  |
| jobs.hello-env-var.failedJobsHistoryLimit | int | `1` |  |
| jobs.hello-env-var.image.imagePullPolicy | string | `"Always"` |  |
| jobs.hello-env-var.image.repository | string | `"busybox"` |  |
| jobs.hello-env-var.image.tag | string | `"latest"` |  |
| jobs.hello-env-var.nodeSelector.type | string | `"infra"` |  |
| jobs.hello-env-var.resources.limits.cpu | string | `"50m"` |  |
| jobs.hello-env-var.resources.limits.memory | string | `"256Mi"` |  |
| jobs.hello-env-var.resources.requests.cpu | string | `"50m"` |  |
| jobs.hello-env-var.resources.requests.memory | string | `"256Mi"` |  |
| jobs.hello-env-var.restartPolicy | string | `"Never"` |  |
| jobs.hello-env-var.schedule | string | `"* * * * *"` |  |
| jobs.hello-env-var.securityContext.fsGroup | int | `2000` |  |
| jobs.hello-env-var.securityContext.runAsGroup | int | `1000` |  |
| jobs.hello-env-var.securityContext.runAsUser | int | `1000` |  |
| jobs.hello-env-var.serviceAccount.name | string | `"busybox-serviceaccount"` |  |
| jobs.hello-env-var.successfulJobsHistoryLimit | int | `3` |  |
| jobs.hello-env-var.tolerations[0].effect | string | `"NoSchedule"` |  |
| jobs.hello-env-var.tolerations[0].operator | string | `"Exists"` |  |
| jobs.hello-ubuntu.args[0] | string | `"-c"` |  |
| jobs.hello-ubuntu.args[1] | string | `"echo $(date) - hello from ubuntu"` |  |
| jobs.hello-ubuntu.command[0] | string | `"/bin/bash"` |  |
| jobs.hello-ubuntu.concurrencyPolicy | string | `"Forbid"` |  |
| jobs.hello-ubuntu.failedJobsHistoryLimit | int | `1` |  |
| jobs.hello-ubuntu.image.imagePullPolicy | string | `"Always"` |  |
| jobs.hello-ubuntu.image.repository | string | `"ubuntu"` |  |
| jobs.hello-ubuntu.image.tag | string | `"latest"` |  |
| jobs.hello-ubuntu.imagePullSecrets[0].email | string | `"joe@example.com"` |  |
| jobs.hello-ubuntu.imagePullSecrets[0].password | string | `"password2"` |  |
| jobs.hello-ubuntu.imagePullSecrets[0].registry | string | `"quay.io"` |  |
| jobs.hello-ubuntu.imagePullSecrets[0].username | string | `"joe"` |  |
| jobs.hello-ubuntu.resources.limits.cpu | string | `"50m"` |  |
| jobs.hello-ubuntu.resources.limits.memory | string | `"256Mi"` |  |
| jobs.hello-ubuntu.resources.requests.cpu | string | `"50m"` |  |
| jobs.hello-ubuntu.resources.requests.memory | string | `"256Mi"` |  |
| jobs.hello-ubuntu.restartPolicy | string | `"OnFailure"` |  |
| jobs.hello-ubuntu.schedule | string | `"*/5 * * * *"` |  |
| jobs.hello-ubuntu.successfulJobsHistoryLimit | int | `3` |  |
| jobs.hello-world.concurrencyPolicy | string | `"Allow"` |  |
| jobs.hello-world.failedJobsHistoryLimit | int | `1` |  |
| jobs.hello-world.image.imagePullPolicy | string | `"IfNotPresent"` |  |
| jobs.hello-world.image.repository | string | `"hello-world"` |  |
| jobs.hello-world.image.tag | string | `"latest"` |  |
| jobs.hello-world.imagePullSecrets[0].password | string | `"password"` |  |
| jobs.hello-world.imagePullSecrets[0].registry | string | `"docker.io"` |  |
| jobs.hello-world.imagePullSecrets[0].username | string | `"fred"` |  |
| jobs.hello-world.restartPolicy | string | `"OnFailure"` |  |
| jobs.hello-world.schedule | string | `"* * * * *"` |  |
| jobs.hello-world.successfulJobsHistoryLimit | int | `3` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
