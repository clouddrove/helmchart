**CloudDrove created this HelmChart so that One can deploy as many as application with common template and separate override-values.yaml for each application**



## ☸️ HELM installation
Below is an installer script that will automatically grab the latest version of Helm and install it locally.
```bash
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```
Binary downloads of the Helm client can be found on [the Releases page](https://github.com/helm/helm/releases/latest).
For installation in different Operating Systems you can follow [this guide.](https://helm.sh/docs/intro/install/)

## Clouddrove helmchart structure
```bash
helmchart
├── Chart.yaml
├── README.md
├── templates
│   ├── configmap.yaml
│   ├── cronjob.yaml
│   ├── deployment.yaml
│   ├── gateway.yaml
│   ├── _helpers.tpl
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── poddisruptionbudget.yaml
│   ├── pvc.yaml
│   ├── pv.yaml
│   ├── secret.yaml
│   ├── serviceaccount.yaml
│   ├── servicemonitor.yaml
│   ├── service.yaml
│   ├── storageclass.yaml
│   ├── tests
│   │   └── test-connection.yaml
│   └── virtualservice.yaml
├── values.schema.json
└── values.yaml

```
- `Chart.yaml` : It contains a description of the chart such as Chart's `version` `appVersion` etc.
- `templates/` : This directory is for YAML files for Kubernetes resources to be created using this chart.
- `tests` : This directory contains a yaml file for creating a pod to test the cluster accessibility and networking related configurations.

- `values.yaml` : This file is important to templates and contains the default values for a chart. These values can be overridden by users in helmchart/config/override-values.yaml and then can be used during helm install/upgrade by specifying path of this override-values.yaml.

## Installing Clouddrove helmchart in your Kubernetes Cluster
   1. Add clouddrove helm repository in your local. 
   ```bash
    helm repo add clouddrove https://charts.clouddrove.com/ 
   ```
   2. Update the clouddrove helm repo. 
   ```bash
   helm repo update clouddrove
   ```
   3. Get the values.yaml to override it.
   ```bash
   helm pull clouddrove/helmchart --untar && cp helmchart/values.yaml override-app1-values.yaml && rm -rf helmchart
   ls
   ```
   > override-app1-values.yaml


   4. Change the attributes in override-app1-values.yaml as per your requirement. Some changes are given below
   ```yaml
  replicaCount: 2

  image:
    repository: nginx
    pullPolicy: IfNotPresent
    tag: "latest"

  service: 
    enabled: true
    type: NodePort 
    port: 80   

   ```

   5. You can test the helmchart with default OR override-values.yaml
   ```bash
   helm template release-name clouddrove/helmchart -f override-app1-values.yaml --debug
   ```

   6. Deploy the clouddrove/helmchart on kubernetes cluster (eks, aks, gks, minikube). Here we are using `clouddrove` as `releasename` .
   - Find the required CustomResourceDefinitions(crds) [here](https://github.com/clouddrove/helmchart/tree/master/crds).
   ```bash
   kubectl create namespace clouddrove
   helm install clouddrove clouddrove/helmchart -f override-app1-values.yaml --namespace=clouddrove --debug
   ``` 
   - using `--debug` flag to get more information of helm installation.
   - Check the STATUS of helmchart `helm list` it should be deployed
   ```bash
    $ helm list                 
    NAME      	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART          	APP VERSION
    clouddrove	clouddrove  	1       	2023-05-23 20:28:39.571788019 +0530 IST	deployed	helmchart-0.0.6	0.0.6  
   ```
   - Further verify by seeing all information of clouddrove helmchart deployment
   ```bash
    $ kubectl get all --namespace=clouddrove
    NAME                                        READY   STATUS    RESTARTS   AGE
    pod/clouddrove-helmchart-8445d9c6c6-6lrmn   1/1     Running   0          19s
    pod/clouddrove-helmchart-8445d9c6c6-ncw97   1/1     Running   0          19s

    NAME                           TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
    service/clouddrove-helmchart   NodePort   10.100.87.24   <none>        80:32245/TCP   19s

    NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/clouddrove-helmchart   2/2     2            2           19s

    NAME                                              DESIRED   CURRENT   READY   AGE
    replicaset.apps/clouddrove-helmchart-8445d9c6c6   2         2         2       19s

    NAME                                                       REFERENCE                         TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
    horizontalpodautoscaler.autoscaling/clouddrove-helmchart   Deployment/clouddrove-helmchart   <unknown>/80%   1         100       1          19s
   ```

   - Access the sample application deployed using clouddrove/helmchart 
   - Run below command to get IP of your node. Change `podname` with the name of your pod. In above example podname is `clouddrove-helmchart-8445d9c6c6-6lrmn`
     ```bash
     kubectl describe pod podname -n clouddrove | grep Node: | awk -F / '{print $2}'
     ```
     > 192.172.100.10

   - Get the port number from `service` by which your container is mapped with Node's Port. In above example port number is `32245`
   - Access your application running on pod by visiting on `192.172.100.10:32245` in your browser


   7. Deploying another application using same clouddrove/helmchart with different overrode-app2-values.yaml
   ```bash
   helm pull clouddrove/helmchart --untar && cp helmchart/values.yaml override-app2-values.yaml && rm -rf helmchart
   ```
   - Change the attributes in override-app2-values.yaml as per your requirement. Some changes are given below
   ```yaml
  replicaCount: 2

  image:
    repository: tutum/hello-world
    pullPolicy: IfNotPresent
    tag: "latest"

  service: 
    enabled: true
    type: NodePort 
    port: 80   

   ```
   - Follow the same steps to get the IP and NodePort of second application to open webpage on your browser.


## Uninstalling Cloudrove/helmchart
   1. List the helm release in clouddrove namespace
   ```bash
   helm list --namespace=clouddrove                                                                                  
   NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
   clouddrove      clouddrove      1               2023-05-23 21:05:03.061111663 +0530 IST deployed        helmchart-0.0.6 0.0.6      
   ```

   2. Uninstall this helm release using below command
   ```bash
   helm uninstall clouddrove -n clouddrove
   ```

   3. Make sure to delete Persistent Volume as default `reclaimPolicy` was set to `Retain`
   ```bash
   $ kubectl get persistentVolume            
   NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                             STORAGECLASS           REASON   AGE
   clouddrove-helmchart                       512Mi      RWO            Retain           Bound      clouddrove/clouddrove-helmchart   clouddrove-helmchart            114s

   $ kubectl delete persistentVolume clouddrove-helmchart
   ```

### We are continously working on this HelmChart to improve as much as we can. We want your contribution :handshake: by raising an [issue](https://github.com/clouddrove/helmchart/issues/new) if you find any problem or wan't to give some suggestions.

***
# Thanks! Team [CloudDrove](https://github.com/clouddrove) 