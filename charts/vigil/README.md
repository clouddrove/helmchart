# vigil

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![version: 0.0.1](https://img.shields.io/badge/version-0.0.1-informational?style=flat-square)

A Helm chart for Kubernetes

**Homepage:** <https://github.com/clouddrove/vigil>

Vigil is a tool for endpoint monitoring and health checkup, designed to provide real-time insights into the status and performance of your microservices.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Clouddrove Inc | <hello@clouddrove.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` | The minimum amount of replicas allowed |
| autoscaling.minReplicas | int | `1` | Whether or not Horizontal Pod Autoscaler should be created, if false the Horizontal Pod Autoscaler will not be created |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | The maximum amount of replicas allowed |
| configmap.configs.KEY | string | `"value"` |  |
| configmap.enabled | bool | `true` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` | The container image repository that should be used.  E.g 'nginx', 'gcr.io/kubernetes-helm/tiller'.        |
| image.repository | string | `"nginx"` | Image to use for deploying, must support an entrypoint which creates users/databases from appropriate config files |
| image.tag | string | `""` | The image pull policy to employ. Determines when the image will be pulled in. If undefined, this will default to 'IfNotPresent'.   |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` | Specifies whether a ingress should be created |
| ingress.enabled | bool | `false` | ingress is a map that can be used to configure an Ingress resource for this service. |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Annotations that should be added to the Service resource. This is injected directly in to the resource yaml. kubernetes.io/ingress.class: nginx kubernetes.io/tls-acme: "true" |
| ingress.tls | list | `[]` |  |
| metrics.enabled | bool | `true` | Whether or not metrics should be created, if false the metrics will not be created |
| metrics.port | int | `3001` |  |
| metrics.portName | string | `"prometheus"` | portName specify the name of the port for the metrics resource.   |
| metrics.targetPort | int | `3001` |  |
| nameOverride | string | `""` | imagePullSecrets lists the Secret resources that should be used for accessing private registries. |
| nodeSelector | object | `{}` |  |
| pdbMinAvailable | string | `"30%"` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| poddisruptionbudget.enabled | bool | `false` |  |
| replicaCount | int | `1` |  |
| resources.limits | object | `{"cpu":"100m","memory":"128Mi"}` | We usually recommend not to specify default resources and to leave this as a conscious.  We usually recommend not to specify default resources and to leave this as a conscious. resources, such as Minikube. If you do want to specify resources, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'resources:'.     |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| secret.enabled | bool | `true` |  |
| secret.secrets | object | `{"KEY":"value"}` | secrets is a map that specifies the Secret resources that should be exposed to the main application container.            |
| secretConfig | string | `""` | Configuration for Vigil in TOML format. |
| securityContext | object | `{}` |  |
| service.enabled | bool | `true` | service is a map that specifies the configuration for the Service resource that is created by the chart. |
| service.port | int | `80` | The Service type, as defined in Kubernetes. Defaults to ClusterIP. |
| service.type | string | `"ClusterIP"` | Specifies whether a service account should be created.         |
| serviceAccount.annotations | object | `{}` | Specifies whether a service account should be created |
| serviceAccount.enabled | bool | `true` |  |
| serviceAccount.name | string | `""` | Annotations to add to the service account |
| tolerations | list | `[]` |  |

## Secret Configuration

The `secretConfig` parameter allows you to provide a TOML configuration for Vigil. This configuration is used to set up various aspects of the Vigil application, such as server settings, branding, metrics, and notifications.

### Example Configuration

```toml
[server]
log_level = "debug"
inet = "0.0.0.0:8080"
workers = 4

[branding]
page_title = "Crisp Status"
page_url = "https://status.crisp.chat/"
company_name = "Crisp IM SAS"

[metrics]
poll_interval = 120
poll_retry = 2

[notify]
startup_notification = true

[probe]
[[probe.service]]
id = "web"
label = "Web nodes"

[[probe.service.node]]
id = "router"
label = "Core main router"
mode = "poll"
replicas = [
  "icmp://edge-1.pool.net.crisp.chat",
  "icmp://edge-2.pool.net.crisp.chat"
]
```

This configuration allows you to define endpoints for monitoring and customize the branding of your status page.


This updated `README.md` includes a description of Vigil's purpose and provides an example of how to configure endpoints and branding using the `secretConfig` parameter.