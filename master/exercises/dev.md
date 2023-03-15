1. https://github.com/dockersamples/dockercoins
   * https://github.com/secobau/dockercoins
   * https://containers.goffinet.org/images/dockercoins-diagram.svg
1. https://ap-south-1.console.aws.amazon.com/cloud9
   
   In order to deploy petclinic and dockercoins in AWS Cloud9:
   ```bash
   docker swarm init
   
   project=spring-petclinic
   release=v0.7
   test -f $project.yaml && rm -f $project.yaml
   wget https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/swarm/$project.yaml
   sed --in-place /node/s/worker/manager/ $project.yaml
   docker stack deploy -c $project.yaml $project
   docker service ls

   docker stack rm $project
   test -f $project.yaml && rm -f $project.yaml

   project=dockercoins
   release=v2.0
   test -f $project.yaml && rm -f $project.yaml
   wget https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/swarm/$project.yaml
   sed --in-place /node/s/worker/manager/ $project.yaml
   docker stack deploy -c $project.yaml $project
   docker service ls

   docker stack rm $project
   test -f $project.yaml && rm -f $project.yaml
   
   
   ``` 
1. https://labs.play-with-docker.com/
   ```bash
   docker swarm init
   
   
   ```
   * https://github.com/secobau/spring-petclinic
   * https://hub.docker.com/repository/docker/secobau/spring-petclinic
   ```bash
   project=spring-petclinic
   release=v0.7
   test -f $project.yaml && rm -f $project.yaml
   wget https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/swarm/$project.yaml
   docker stack deploy -c $project.yaml $project
   docker service ls
   
   docker stack rm $project
   test -f $project.yaml && rm -f $project.yaml
   

   ```
   * https://github.com/secobau/dockercoins
   ```bash
   project=dockercoins
   release=v2.0
   test -f $project.yaml && rm -f $project.yaml
   wget https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/swarm/$project.yaml
   sed -i s/8080/8081/ $project.yaml
   docker stack deploy -c $project.yaml $project
   docker service ls

   docker stack rm $project
   test -f $project.yaml && rm -f $project.yaml
   

   ```
   * https://github.com/secobau/phpinfo
   ```bash
   project=phpinfo
   release=v1.5
   test -f $project.yaml && rm -f $project.yaml
   wget https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/swarm/$project.yaml
   docker stack deploy -c $project.yaml $project
   docker service ls

   docker stack rm $project
   test -f $project.yaml && rm -f $project.yaml
   

   ```
   * https://github.com/secobau/nlb
   * https://github.com/secobau/nginx
   ```bash
   project=nlb
   release=v1.3

   file=nlb.conf
   path=run/configs/etc/nginx/conf.d
   wget https://raw.githubusercontent.com/secobau/$project/$release/$path/$file
   mkdir -p /$path
   mv $file /$path

   file=nginx.conf
   path=run/configs/etc/nginx
   wget https://raw.githubusercontent.com/secobau/$project/$release/$path/$file
   mkdir -p /$path
   mv $file /$path

   test -f $project.yaml && rm -f $project.yaml
   wget https://raw.githubusercontent.com/secobau/$project/$release/etc/docker/swarm/$project.yaml
   docker stack deploy -c $project.yaml $project
   docker service ls

   docker stack rm $project
   test -f $project.yaml && rm -f $project.yaml
   

   ```
1. https://console-openshift-console.apps.openshift.sebastian-colomar.es
   * https://oauth-openshift.apps.openshift.sebastian-colomar.es/oauth/token/request

   In order to access the Openshift cluster from AWS Cloud9 terminal:
   ```bash
   wget https://downloads-openshift-console.apps.openshift.sebastian-colomar.es/amd64/linux/oc.tar
   tar xf oc.tar
   mkdir $HOME/bin
   mv oc $HOME/bin
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
1. Service Mesh:
   1. https://docs.openshift.com/container-platform/4.5/service_mesh/service_mesh_install/installing-ossm.html
   1. https://docs.openshift.com/container-platform/4.5/service_mesh/service_mesh_day_two/ossm-example-bookinfo.html
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
1. Deploy in Docker Swarm or Kubernetes: https://github.com/secobau/docker-aws
   1. Configure the infrastructure:
      * https://github.com/secobau/docker-aws/blob/master/etc/conf.d/aws.conf
   1. Choose Swarm or Kubernetes:
      ```bash
      mode=kubernetes
      mode=swarm
      repo=docker-aws
      export stack=$repo-$mode-$( date +%s )
      ```
   1. Download the installer:
      ```bash
      git clone https://github.com/secobau/$repo $repo-$mode
      cd $repo-$mode
      ```
   1. Create the infrastructure in AWS:
      ```bash
      ./bin/aws-init-start.sh
      ```
   1. Deploy the cluster in AWS:
      ```bash
      ./bin/cluster-init-start.sh
      ```
   1. You can now manually deploy the application from the Kubernetes master:
      ```bash
      username_app=secobau
      repository_app=nginx
      git clone --single-branch --branch $branch_app https://github.com/$username_app/$repository_app
      cd $repository_app
      sudo cp -rv run/* /run
      for config in $( find /run/configs -type f );
        do
          file=$( basename $config );
          kubectl create configmap $file --from-file $config;
          sudo rm --force $config;
        done;
      for secret in $( find /run/secrets -type f );
        do
          file=$( basename $secret );
          kubectl create secret generic $file --from-file $secret;
          sudo rm --force $secret;
        done;
      kubectl apply -f etc/docker/kubernetes/$repository_app.yaml
      
      
      ```
 1. https://manage.openshift.com
 1. https://learn.openshift.com/playgrounds/openshift45/
 1. https://github.com/secobau/docker/blob/master/Cloud9/README.md
 1. https://github.com/spring-projects/spring-petclinic
 1. https://github.com/secobau/nginx

