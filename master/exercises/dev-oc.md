1. https://console-openshift-console.apps.openshift.sebastian-colomar.es
   * https://oauth-openshift.apps.openshift.sebastian-colomar.es/oauth/token/request

   In order to access the Openshift cluster from AWS Cloud9 terminal:
   ```bash
   wget https://downloads-openshift-console.apps.openshift.sebastian-colomar.es/amd64/linux/oc.tar
   tar xf oc.tar
   sudo cp oc /usr/local/bin
   oc version 
   oc login --token=xxx-yyy --server=https://api.openshift.sebastian-colomar.es:6443
   
   
   ```   
   In order to deploy petclinic and dockercoins in Red Hat Openshift:
   ```bash
   user=dev-x
   
   project=spring-petclinic
   release=v0.7
   
   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user
   
   oc delete -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user
   
   project=dockercoins
   release=v2.0
   
   oc new-project $project-$user
   oc apply -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc get deployment -n $project-$user
   
   oc delete -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user


   ```
1. Troubleshooting Dockercoins   
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
   
   oc delete -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
   oc delete project $project-$user


   ```
1. https://github.com/secobau/proxy2aws/tree/openshift
   * https://github.com/secobau/nginx
   * https://hub.docker.com/r/secobau/nginx

   1. In order to deploy proxy2aws in Red Hat Openshift:
      ```bash
      user=dev-x

      project=proxy2aws
      release=v10.0

      oc new-project $project-$user
      oc apply -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
      oc get deployment -n $project-$user

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

      oc process -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/templates/$project.yaml | oc delete -n $project-$user -f -
      oc delete project $project-$user


      ```
1. https://github.com/secobau/phpinfo

   1. In order to deploy phpinfo in Red Hat Openshift:
      ```bash
      user=dev-x

      project=phpinfo
      release=v1.4

      oc new-project $project-$user
      oc apply -n $project-$user -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/$project.yaml
      oc get deployment -n $project-$user

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

      oc process -f https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/kubernetes/openshift/templates/$project.yaml | oc delete -n $project-$user -f -
      oc delete project $project-$user


      ```
1. https://github.com/kubernetes/kubernetes/issues/77086
   
   ```
   apiVersion: project.openshift.io/v1
   kind: Project
   metadata:
     name: delete-dev-x
   spec:
     finalizers:
     - foregroundDeletion


   ```
   ```
   oc delete project delete-dev-x
   
   
   ```
   ```
   oc get ns delete-dev-x --output json | sed '/ "foregroundDeletion"/d' | curl -k  -H "Authorization: Bearer xxx" -H "Content-Type: application/json" -X PUT --data-binary @- https://api.openshift.sebastian-colomar.es:6443/api/v1/namespaces/delete-dev-x/finalize
   
   
   ```
 1. https://manage.openshift.com
 1. https://learn.openshift.com/playgrounds/openshift45/
 1. https://github.com/secobau/docker/blob/master/Cloud9/README.md
 1. https://github.com/spring-projects/spring-petclinic
 1. https://github.com/secobau/nginx
