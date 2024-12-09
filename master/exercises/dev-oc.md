1. In order to access the Openshift cluster from Google Cloud Shell:
   * https://shell.cloud.google.com/
   * https://oauth-openshift.apps.openshift.sebastian-colomar.es/oauth/token/request
   ```bash
   wget https://downloads-openshift-console.apps.openshift.sebastian-colomar.es/amd64/linux/oc.tar
   tar xf oc.tar
   sudo cp oc /usr/local/bin
   oc version 
   oc login --token=$token --server=https://api.openshift.sebastian-colomar.es:6443
   
   
   ```   
   In order to deploy petclinic in Red Hat Openshift:
   ```bash
   user=dev-x
   
   project=spring-petclinic
   release=v0.7
   
   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user

   ```
   Check here the resulting application:
   * https://spring-petclinic-route-spring-petclinic-dev-x.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc delete -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user

   ```
   In order to deploy petclinic and dockercoins in Red Hat Openshift:
   ```
   project=dockercoins
   release=v2.0
   
   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user
   
   ```
   Troubleshoot and fix the deployment.
   
   Once it is fixed, you can check here the resulting application:
   * https://spring-petclinic-route-spring-petclinic-dev-x.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc delete -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user


   ```
1. https://github.com/xwiki-contrib/docker-xwiki
   * https://github.com/secobau/docker-xwiki

   In order to deploy xwiki in Red Hat Openshift:
   ```bash
   user=dev-x
   
   project=docker-xwiki
   release=v2.4
   
   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user
   
   ```
   Troubleshoot and fix the deployment.
   
   Once it is fixed, you can check here the resulting application:
   * https://xwiki-route-docker-xwiki-dev-x.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc delete -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user


   ```
1. In order to deploy proxy2aws in Red Hat Openshift:
   ```bash
   user=dev-x

   project=proxy2aws
   release=v10.0

   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user

   ```
   Troubleshoot and fix the deployment.
   
   Once it is fixed, you can check here the resulting application:
   * https://aws2cloud-route-proxy2aws-dev-x.apps.openshift.sebastian-colomar.es/
   * https://aws2prem-route-proxy2aws-dev-x.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc delete -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user


   ```
1. In order to deploy proxy2aws in Red Hat Openshift through templates:
   ```bash
   user=dev-x

   project=proxy2aws
   release=v10.0

   oc new-project $project-$user
   oc process -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/templates/$project.yaml | oc apply -n $project-$user -f -
   oc get deployment -n $project-$user

   ```
   Troubleshoot and fix the deployment.
   
   Once it is fixed, you can check here the resulting application:
   * https://aws2cloud-route-proxy2aws-dev-x.apps.openshift.sebastian-colomar.es/
   * https://aws2prem-route-proxy2aws-dev-x.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc process -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/templates/$project.yaml | oc delete -n $project-$user -f -
   oc delete project $project-$user


   ```
1. In order to deploy phpinfo in Red Hat Openshift:
   ```bash
   user=dev-x

   project=phpinfo
   release=v1.4

   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user

   ```
   You can check here the resulting application:
   * https://phpinfo-route-phpinfo-dev-x.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc delete -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user


   ```
1. In order to deploy phpinfo in Red Hat Openshift through templates:
   ```bash
   user=dev-x

   project=phpinfo
   release=v1.4

   oc new-project $project-$user
   oc process -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/templates/$project.yaml | oc apply -n $project-$user -f -
   oc get deployment -n $project-$user

   ```
   You can check here the resulting application:
   * https://phpinfo-route-phpinfo-dev-x.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc process -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/templates/$project.yaml | oc delete -n $project-$user -f -
   oc delete project $project-$user


   ```
1. https://github.com/kubernetes/kubernetes/issues/77086
   
   ```
   user=dev-x

   project=delete

   tee ns.yaml 0<<EOF
   
   apiVersion: project.openshift.io/v1
   kind: Project
   metadata:
     name: $project-$user
   spec:
     finalizers:
     - foregroundDeletion

   EOF

   oc apply -f ns.yaml
   

   ```
   ```
   oc delete project $project-$user
   
   
   ```
   ```
   oc get ns $project-$user --output json | sed '/ "foregroundDeletion"/d' | curl -k  -H "Authorization: Bearer $token" -H "Content-Type: application/json" -X PUT --data-binary @- https://api.openshift.sebastian-colomar.es:6443/api/v1/namespaces/$project-$user/finalize
   
   
   ```
