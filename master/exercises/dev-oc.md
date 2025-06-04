1. In order to install OpenShift CLI on a remote shell:
   * https://shell.cloud.google.com
   ```bash
   wget https://downloads-openshift-console.apps.openshift.sebastian-colomar.es/amd64/linux/oc.tar
   tar xf oc.tar
   sudo cp oc /usr/local/bin
   oc version   
   ```   
1. In order to access the Openshift cluster from a remote shell:
   * https://oauth-openshift.apps.openshift.sebastian-colomar.es/oauth/token/request
   ```bash
   oc login --token=$token --server=https://api.$cluster.$domain:6443   
   ```
    ```bash
   name=sebastian
   user=dev-$name
   repository=secobau
   ```
   Using Windows CMD:
   ```bash
   set name=sebastian
   set user=dev-%name%
   set repository=secobau
   ```
1. In order to deploy petclinic in Red Hat Openshift:
   ```bash
   project=spring-petclinic
   release=v0.7
   
   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user
   ```
   Using Windows CMD:
   ```bash
   set project=spring-petclinic
   set release=v0.7
   
   oc new-project %project%-%user%
   oc apply -n %project%-%user% -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/%project%.yaml
   oc get deployment -n %project%-%user%
   ```   
   Check here the resulting application:
   * https://spring-petclinic-route-spring-petclinic-dev-sebastian.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc delete -n $project-$user -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user
   ```
   Using Windows CMD:
   ```bash
   oc delete -n %project%-%user% -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/%project%.yaml
   oc delete project %project%-%user%
   ```
1. In order to deploy dockercoins in Red Hat Openshift:
   ```
   project=dockercoins
   release=v2.0
   
   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user   
   ```
   Using Windows CMD:
   ```bash 
   set project=dockercoins
   set release=v2.0
   
   oc new-project %project%-%user%
   oc apply -n %project%-%user% -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/%project%.yaml
   oc get deployment -n %project%-%user%
   ```   
   TROUBLESHOOT AND FIX THE PROBLEM.
   
   Once it is fixed, you can check here the resulting application:
   * https://dockercoins-dockercoins-dev-sebastian.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc delete -n $project-$user -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user
   ```
   Using Windows CMD:
   ```bash
   oc delete -n %project%-%user% -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/%project%.yaml
   oc delete project %project%-%user%
   ```
   

1. In order to deploy xwiki in Red Hat Openshift:   
   * https://github.com/xwiki-contrib/docker-xwiki
   * https://github.com/secobau/docker-xwiki
   ```bash 
   project=docker-xwiki
   release=v2.4
   
   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user   
   ```
   Using Windows CMD:
   ```bash 
   set project=docker-xwiki
   set release=v2.4
   
   oc new-project %project%-%user%
   oc apply -n %project%-%user% -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/%project%.yaml
   oc get deployment -n %project%-%user%
   ```   
   TROUBLESHOOT AND FIX THE PROBLEM.
   
   Once it is fixed, you can check here the resulting application:
   * https://xwiki-route-docker-xwiki-dev-sebastian.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc delete -n $project-$user -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user
   ```
   Using Windows CMD:
   ```bash
   oc delete -n %project%-%user% -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/%project%.yaml
   oc delete project %project%-%user%
   ```
   
1. In order to deploy proxy2aws in Red Hat Openshift:
   ```bash
   project=proxy2aws
   release=v10.0

   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user

   ```
   Using Windows CMD:
   ```bash 
   set project=proxy2aws
   set release=v10.0
   
   oc new-project %project%-%user%
   oc apply -n %project%-%user% -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/%project%.yaml
   oc get deployment -n %project%-%user%
   ```   
   TROUBLESHOOT AND FIX THE PROBLEM.
   
   Once it is fixed, you can check here the resulting application:
   * https://aws2cloud-route-proxy2aws-dev-sebastian.apps.openshift.sebastian-colomar.es/
   * https://aws2prem-route-proxy2aws-dev-sebastian.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc delete -n $project-$user -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user
   ```
   Using Windows CMD:
   ```bash
   oc delete -n %project%-%user% -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/%project%.yaml
   oc delete project %project%-%user%
   ```
   
1. In order to deploy proxy2aws in Red Hat Openshift through templates:
   ```bash
   project=proxy2aws
   release=v10.0

   oc new-project $project-$user
   oc process -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/templates/$project.yaml | oc apply -n $project-$user -f -
   oc get deployment -n $project-$user
   ```
   Using Windows CMD:
   ```bash 
   set project=proxy2aws
   set release=v10.0
   
   oc new-project %project%-%user%
   oc process -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/templates/%project%.yaml | oc apply -n %project%-%user% -f -
   oc get deployment -n %project%-%user%
   ```   
   TROUBLESHOOT AND FIX THE PROBLEM.
   
   Once it is fixed, you can check here the resulting application:
   * https://aws2cloud-route-proxy2aws-dev-sebastian.apps.openshift.sebastian-colomar.es/
   * https://aws2prem-route-proxy2aws-dev-sebastian.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc process -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/templates/$project.yaml | oc delete -n $project-$user -f -
   oc delete project $project-$user
   ```
   Using Windows CMD:
   ```bash
   oc process -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/templates/%project%.yaml | oc delete -n %project%-%user% -f -
   oc delete project %project%-%user%
   ```
1. In order to deploy phpinfo in Red Hat Openshift:
   ```bash
   project=phpinfo
   release=v1.4

   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user
   ```
   Using Windows CMD:
   ```bash 
   set project=phpinfo
   set release=v1.4
   
   oc new-project %project%-%user%
   oc apply -n %project%-%user% -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/%project%.yaml
   oc get deployment -n %project%-%user%
   ```   
   You can check here the resulting application:
   * https://phpinfo-route-phpinfo-dev-sebastian.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc delete -n $project-$user -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user
   ```
   Using Windows CMD:
   ```bash
   oc delete -n %project%-%user% -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/%project%.yaml
   oc delete project %project%-%user%
   ```
1. In order to deploy phpinfo in Red Hat Openshift through templates:
   ```bash
   project=phpinfo
   release=v1.4

   oc new-project $project-$user
   oc process -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/templates/$project.yaml | oc apply -n $project-$user -f -
   oc get deployment -n $project-$user
   ```
   Using Windows CMD:
   ```bash 
   set project=phpinfo
   set release=v1.4
   
   oc new-project %project%-%user%
   oc process -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/templates/%project%.yaml | oc apply -n %project%-%user% -f -
   oc get deployment -n %project%-%user%
   ```   
   You can check here the resulting application:
   * https://phpinfo-route-phpinfo-dev-sebastian.apps.openshift.sebastian-colomar.es/
  
   Afterwards, you may delete the resources:
   ```
   oc process -f https://raw.githubusercontent.com/$repository/$project/$release/etc/docker/kubernetes/openshift/templates/$project.yaml | oc delete -n $project-$user -f -
   oc delete project $project-$user
   ```
   Using Windows CMD:
   ```bash
   oc process -f https://raw.githubusercontent.com/%repository%/%project%/%release%/etc/docker/kubernetes/openshift/templates/%project%.yaml | oc delete -n %project%-%user% -f -
   oc delete project %project%-%user%
   ```
1. https://github.com/kubernetes/kubernetes/issues/77086
   
   ```
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
