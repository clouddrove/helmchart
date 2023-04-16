☸️ Helm Charts Repository

When deploying a lot of similar workload to kubernetes, it is convenient to use helm for templating and release management.


Each microservice has its own repository and override-<env>.yaml. In its own CI file (Github Action/Jenkins/GitLab) you can do something like this:

deploy-devel:
    stage: deploy-dev
...
    script:
    - cd build
    - helm init --upgrade
    - helm repo add clouddrove https://charts.clouddrove.com/
    - helm repo list | grep helmchart
    - |
      helm upgrade --install --namespace=$NAMESPACE --debug "$APP_NAME"-devel -f _k8s/override-<env>.yaml \
        --set image.repository=$IMAGE_REPO \
        --set image.tag=$IMAGE_TAG \
        --set namespace=$NAMESPACE 
        clouddrove/<application>

... 
and other stages with their namespaces and so on...
