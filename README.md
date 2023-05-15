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

***
## Installtion Guide

#### This HelmChart contains manifests for all kubernetes object that needed to deploy applications.

# 1. Clone Helm Chart in Local machine
- First add helmchart repo using below command - 
   ```yaml
   helm repo add clouddrove https://charts.clouddrove.com/
   ```

- Update clouddrove repo using below command - 
   ```yaml
   helm repo update clouddrove
   ```
   you should be seeing below output
   > Hang tight while we grab the latest from your chart repositories... <br>
   > ...Successfully got an update from the "clouddrove" chart repository <br>
   > Update Complete. ⎈Happy Helming!⎈

- Create a directory in your machine and pull this clouddrove chart into directory created.
   ```yaml
   mkdir clouddrove-helmchart
   cd clouddrove-helmchart
   helm pull clouddrove/helmchart --untar 
   ```
- Now you should be seeing a directory named `helmchart`
- By using this single helmchart you can deploy multiple applications. 
- **If you are deploying an application that requires some extra kubernetes objects (`.yaml` files) then please create an `issue` in https://github.com/clouddrove/helmchart/issues repository.** 


- To setup helmchart for multiple application, create a `config` directory inside `helmchart` and create a different `override-appname-values.yaml` for each application in this `config` folder as follows -
   ```yaml
   cd helmchart
   mkdir config
   cd config
   cp ../values.yaml override-nginx-values.yaml
   cp ../values.yaml override-apache-values.yaml
   ```
- Here we are deploying two simple application nginx and apache by using single helm chart.
- Use below command with respective override-app-values.yaml file to deploy application on kubernetes cluster.
- Assuming that you are connected to your kubernetes-cluster ([AKS](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli#connect-to-the-cluster:~:text=created%20with%20AKS%3F-,Connect%20to%20the%20cluster,-To%20manage%20a), [EKS](https://catalog.workshops.aws/eks-blueprints-terraform/en-US/030-provision-eks-cluster/5-connect-to-cluster#:~:text=EKS%20Created%20Cluster-,Connect%20to%20EKS%20Created%20Cluster,-In%20the%20previous), [GKE](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#apt:~:text=Update%20the%20kubectl%20configuration%20to%20use%20the%20plugin%3A))

   ```yaml
   helm upgrade --install --namespace=anyname release-name /path/to/chart/ -f /path/to/override-app-values.yaml --atomic --debug --timeout 20m
   ```
- Some flags are optional but good to have
  - `--atomic` : If helm deployment fails then it will delete all resources created during this helm deployment process, so that you can do a fresh start.
  - `--debug` : Shows cause of error if helm deployment fails.
  - `--timeout 20m` : It will wait upto 20-minutes to let the deployment complete, after 20-minutes it will stop the helm deployment and delete the resources created during helm deployment(as --atomic is set). This time can be changed. Examples: `--timeout 200s`, `--timeout 15m`

- To deploy **nginx** you can use below command
  ```yaml
  kubectl create namespace nginx-ns
  helm upgrade --install --namespace=nginx-ns nginx-release helmchart/ -f helmchart/config/override-nginx-values.yaml --atomic --debug --timeout 5m
  ```
   - To confirm the installation, list the helm releases
      ```bash
      helm ls -n nginx-ns
      kubectl get pods -n nginx-ns
      ```


- To deploy **apache** you can use below command
  ```yaml
  kubectl create namespace apache-ns
  helm upgrade --install --namespace=apache-ns apache-release helmchart/ -f helmchart/config/override-apache-values.yaml --set image.repository=httpd --set image.tag=latest --atomic --debug --timeout 5m
  ```
  - Either change the image repository & tag in override-app-values.yaml or you can use `--set` flag to achive this. `--set` does not changes values in `override-app-values.yaml` file.
   - To confirm the installation, list the helm releases
      ```bash
      helm ls -n apache-ns
      kubectl get pods -n apache-ns
      ```
- To uninstall or delete the chart use below command
  - Get the name of release
    ```bash
     helm ls -n namespace-name
    ```
  - Uninstall the release
    ```bash
     helm uninstall release-name -n namespace-name
    ```