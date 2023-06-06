**CloudDrove created this HelmChart so that One can deploy as many as application with common template and separate override-values.yaml for each application**



## ☸️ HELM installation
Below is an installer script that will automatically grab the latest version of Helm and install it locally.
  ```yaml
  $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  $ chmod 700 get_helm.sh
  $ ./get_helm.sh
  ```
Binary downloads of the Helm client can be found on [the Releases page](https://github.com/helm/helm/releases/latest).
For installation in different Operating Systems you can follow [this guide.](https://helm.sh/docs/intro/install/)

## CloudDrove helmchart structure
```yaml
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

## Installing CloudDrove helmchart in your Kubernetes Cluster
   1. Add clouddrove helm repository in your local. 
      ```yaml
       $ helm repo add clouddrove https://charts.clouddrove.com/ 
      ```
   2. Update the clouddrove helm repo. 
      ```yaml
       $ helm repo update clouddrove
      ```
   3. Get the overrides-values.yaml from [HERE](https://github.com/clouddrove/helmchart/tree/master/tests).


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
      ```yaml
       $ helm template release-name clouddrove/helmchart -f override-app1-values.yaml --debug
      ```

   6. Deploy the clouddrove/helmchart on kubernetes cluster (eks, aks, gks, minikube). Here we are using `clouddrove` as `releasename` .
   - Find the required CustomResourceDefinitions(crds) [here](https://github.com/clouddrove/helmchart/tree/master/crds).
      ```yaml
       $ kubectl create namespace clouddrove
       $ helm install clouddrove clouddrove/helmchart -f override-app1-values.yaml --namespace=clouddrove --debug
      ``` 
   - using `--debug` flag to get more information of helm installation.
   - If chart with same releasename is already installed then you can upgrade it via `helm upgrade clouddrove clouddrove/helmchart -f override-app1-values.yaml --namespace=clouddrove --debug`
   - To always be at safe side use `upgrade` and `--install` together, this option will Install the helmchart if not present.
     ```yaml
      $ helm upgrade --install clouddrove clouddrove/helmchart -f override-app1-values.yaml --namespace=clouddrove --debug
     ```
   - Check the STATUS of helmchart `helm list` it should be deployed
      ```yaml
       $ helm list --namespace=clouddrove                
       NAME      	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART          	APP VERSION
       clouddrove	clouddrove  	1       	2023-05-23 20:28:39.571788019 +0530 IST	deployed	helmchart-0.0.6	0.0.6  
      ```
   - Further verify by seeing all information of clouddrove helmchart deployment
      ```yaml
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
     ```yaml
      $ kubectl describe pod podname -n clouddrove | grep Node: | awk -F / '{print $2}'
     ```
     > 192.172.100.10

   - Get the port number from `service` by which your container is mapped with Node's Port. In above example port number is `32245`
   - Access your application running on pod by visiting on `192.172.100.10:32245` in your browser


   7. Deploying another application using same clouddrove/helmchart with different [overrides-values.yaml](https://github.com/clouddrove/helmchart/tree/master/tests)
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
   - Follow the same steps deploy this chart and get the IP & NodePort of second application to open webpage on your browser.


## Uninstalling CloudDrove/helmchart
   1. List the helm release in clouddrove namespace
      ```yaml
       $ helm list --namespace=clouddrove                                                                                  
       NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
       clouddrove      clouddrove      1               2023-05-23 21:05:03.061111663 +0530 IST deployed        helmchart-0.0.6 0.0.6      
      ```

   2. Uninstall this helm release using below command
      ```yaml
       $ helm uninstall clouddrove --namespace=clouddrove
      ```

   3. Make sure to delete Persistent Volume as default `reclaimPolicy` was set to `Retain`
       ```yaml
       $ kubectl get persistentVolume            
       NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                             STORAGECLASS           REASON   AGE
       clouddrove-helmchart                       512Mi      RWO            Retain           Bound      clouddrove/clouddrove-helmchart   clouddrove-helmchart            114s

       $ kubectl delete persistentVolume clouddrove-helmchart
      ```

## Feedback 
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/helmchart/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/helmchart)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
