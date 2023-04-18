☸️ Helm Charts Repository
> When deploying a lot of similar workload to kubernetes, it is convenient to use helm for templating and release management.


Each microservice has its own repository and override-env.yaml. In its own CI file (Github Action/Jenkins/GitLab) you can do something like this:

deploy-devel:
    stage: deploy-dev
``` 
    script:
    - cd build
    - helm init --upgrade
    - helm repo add clouddrove https://charts.clouddrove.com/
    - helm repo list | grep helmchart
    - |
      helm upgrade --install --namespace=$NAMESPACE --debug "$APP_NAME"-devel -f _k8s/override-env.yaml \
        --set image.repository=$IMAGE_REPO \
        --set image.tag=$IMAGE_TAG \
        --set namespace=$NAMESPACE 
        clouddrove/<application>
``` 


# helmchart

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for Kubernetes

**Homepage:** <https://github.com/clouddrove/helmchart>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| CloudDrove Inc | <hello@clouddrove.com> |  |

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
| securityContext | object | `{}` |  |
| service.enabled | bool | `true` | service is a map that specifies the configuration for the Service resource that is created by the chart. |
| service.port | int | `80` | The Service type, as defined in Kubernetes. Defaults to ClusterIP. |
| service.type | string | `"ClusterIP"` | Specifies whether a service account should be created.         |
| serviceAccount.annotations | object | `{}` | Specifies whether a service account should be created |
| serviceAccount.enabled | bool | `true` |  |
| serviceAccount.name | string | `""` | Annotations to add to the service account |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
