# How to build a new Docker image for our PHP sample application

1. Create the Dockerfile:

    ```
    tee ${PWD}/phpinfo/Dockerfile 0<<EOF
    
    FROM    index.docker.io/library/alpine:3.16.2@sha256:1304f174557314a7ed9eddb4eab12fed12cb0cd9809e4c28f29af86979a3c870
    RUN     apk add php81
    
    EOF
    ```
1. Create the Docker image:

    ```
    mkdir --parents ${PWD}/phpinfo/build-context/
    
    docker build --file ${PWD}/phpinfo/Dockerfile --tag localhost/library/alpine:php ${PWD}/phpinfo/build-context/
    ```
1. List the local Docker images:

    ```
    docker images
    ```
1. The new Docker image layers will be located in this internal Docker folder:

    ```
    sudo ls /var/lib/docker/overlay2/
    ```
1. Locate the PHP package in the corresponding Docker image layer:

    ```
    sudo find /var/lib/docker/overlay2/ | grep bin/php81$
    ```
1. Get detailed information about the Docker image:

    ```
    docker inspect localhost/library/alpine:php
    ```
# How to run a Docker container to test the Docker image:

1. Run a test container using the created Docker image:
    ```
    docker run --detach --name test --tty localhost/library/alpine:php
    ```
1. Inspect the Docker image to get the overlay2 layers for the image:

    ```
    docker inspect localhost/library/alpine:php
    ```
1. Inspect the Docker container to get the overlay2 layers for the container:    

    ```
    docker inspect test
    ```
1. Create a new empty file inside the running test container:

    ```
    docker exec test touch sebastian
    ```
1. Find the location of the new file inside the internal overlay2 filesystem layers:

    ```
    sudo find /var/lib/docker/overlay2/ | grep /sebastian$
    ```
1. Both commands will show you the content of the upper directory of your Docker container:

    ```
    docker diff test
    
    sudo ls /var/lib/docker/overlay2/dcb3a3d7898a333d4234c1de0b10d8c55353aaf8237507aaa937965a7a2461b6/diff
    ```
1. Check the inode numbers to confirm that the merged and the upper directories are not duplicating the new file:

    ```
    sudo stat /var/lib/docker/overlay2/dcb3a3d7898a333d4234c1de0b10d8c55353aaf8237507aaa937965a7a2461b6/diff/sebastian
    
    sudo stat /var/lib/docker/overlay2/dcb3a3d7898a333d4234c1de0b10d8c55353aaf8237507aaa937965a7a2461b6/merged/sebastian
    ```
1. The merged directory will be mounted at the root filesystem of the container so that:

    ```
    INSIDE THE CONTAINER        OUTSIDE THE CONTAINER
             /              =   /var/lib/docker/overlay2/dcb3a3d7898a333d4234c1de0b10d8c55353aaf8237507aaa937965a7a2461b6/merged/
    ```
# How to automate the test of my applications with Github Actions:
1. Let us suppose that we want test the following Dockerfile:

    * https://github.com/sebastian-colomar/phpinfo/blob/main/docker/Dockerfile

1. For this purpose we have to create a pipeline in Github Actions:

    * https://github.com/sebastian-colomar/phpinfo/blob/main/.github/workflows/ci.yaml
# How to deploy a Docker stack using a Docker compose file

* https://docs.docker.com/compose/compose-file/compose-file-v3/

```
tee ${PWD}/phpinfo/docker-compose.yaml 0<<EOF

# docker-compose.yaml
configs:
  phpinfo-config:
    external: false
    file: index.php
networks:
  phpinfo-network:
    external: false
    internal: false
secrets:
  phpinfo-secret:
    external: false
    file: index.php
services:
  phpinfo-svc:
    command:
      - -f
      - index.php
      - -S
      - 0.0.0.0:8080
    configs:
      - source: phpinfo-config
        target: /var/data/index.php
        uid: '65534'
        gid: '65534'
        mode: 0400
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.2'
          memory: 200M
        reservations:
          cpus: '0.2'
          memory: 200M
    entrypoint:
      # docker exec phpinfo which php
      - /usr/local/bin/php
    image: index.docker.io/library/php:alpine@sha256:ab23b416d86aec450ee7b75727f6bbec272edc2764a1b6fad13bc2823c59bb6b
    networks:
      - phpinfo-network
    ports:
      - 8080:8080
    read_only: true
    # docker exec phpinfo touch sebastian
    secrets:
      - source: phpinfo-secret
        target: /var/data/index2.php
        uid: '65534'
        gid: '65534'
        mode: 0400
    user: nobody:nogroup
    # docker exec phpinfo id
    # docker exec phpinfo whoami
    volumes:
      - type: volume
        source: my_volume
        target: /var/data/my_volume/
        read_only: false
    working_dir: /var/data/
version: '3.8'
volumes:
  my_volume:
    external: false
    
EOF
```
```
docker swarm init
```
```
docker stack rm PHPINFO ; sleep 20

docker stack deploy --compose-file ${PWD}/phpinfo/docker-compose.yaml PHPINFO

docker stack ps PHPINFO --no-trunc

docker stack ls

docker stack services PHPINFO

docker service logs PHPINFO_phpinfo-svc

docker ps
```
```
docker exec PHPINFO_php-svc.4.z51xlgdlmt1ifpjmjvemh8z1r df
```
# How to install OpenShift Container Platform in AWS
* https://github.com/sebastian-colomar/openshift/blob/master/README.md
