# Introduction to the Course

1. https://docs.openshift.com/
4. https://docs.openshift.com/container-platform/4.15/welcome/oke_about.html
6. https://en.wikipedia.org/wiki/Linux_namespaces
7. https://en.wikipedia.org/wiki/Cgroups

# Shell environment
- https://shell.cloud.google.com/

# PHP sample application

1. https://www.php.net/docs.php
2. https://www.php.net/manual/en/function.phpinfo

Create a new project folder in your home directory:
```
mkdir --parents ${PWD}/phpinfo/
```
Create a PHP file in the project folder:
```
tee ${PWD}/phpinfo/index.php 0<<EOF

<?php
// Show all information, defaults to INFO_ALL
phpinfo();
// Show just the module information.
// phpinfo(8) yields identical results.
phpinfo(INFO_MODULES);
?>

EOF
```
Execute the PHP application parsing the PHP file and launching a PHP embedded webserver:
```
php -f ${PWD}/phpinfo/index.php -S localhost:9000 &
```
Check the web server created:
```
curl localhost:9000/phpinfo/index.php -I -s
```
Find the PID of the running process:
```
ps aux|grep phpinfo --max-count 1
```
Or alternatively:
```
pidof php
```
Save this PID in an environment variable:
```
pid=$(pidof php)
```
Now you can inspect the running process:
```
ls /proc/${pid}/
```
```
strings /proc/${pid}/cmdline
```
```
strings /proc/${pid}/net/fib_trie
```

# Introduction to Docker

1. https://docs.docker.com/
2. https://hub.docker.com/

Check the version of the Docker client:
```
docker version
```
Check the status of the Docker service:
```
service docker status
```
# Example of containerization of our PHP sample application

Let us first create a network for our container:
```
docker network create phpinfo --driver bridge
```
Let us download the Docker image from Docker Hub:
```
docker pull index.docker.io/library/php:alpine

docker images
```
Let us see the Docker registry and the Dockerfile:
- https://hub.docker.com/_/php
- https://github.com/docker-library/php/blob/master/8.3/alpine3.19/cli/Dockerfile

Let us see all the options for docker run command:
```
docker run --help
```
Let us create the container:
```
docker run --cpus 0.01 --detach --env AUTHOR=Sebastian --memory 20M --memory-reservation 10M --name phpinfo --network phpinfo --publish 60000:9000 --read-only --restart always --user nobody:nogroup --volume ${HOME}/phpinfo/index.php:/var/data/index.php:ro --workdir /var/data/ index.docker.io/library/php:alpine php -f index.php -S 0.0.0.0:9000
```
# Troubleshooting the Docker container:

View the table of processes running inside you container
```
docker top phpinfo
```
View the logs of your container:
```
docker logs phpinfo
```
Show the resources consumption statistics of your container:
```
docker stats phpinfo --no-stream
```
Show the content of the working directory:
```
docker exec phpinfo ls -l
```
Test the connection to the webserver from inside the container:
```
docker exec phpinfo curl localhost:9000/index.php -I -s
```
Test the connection to the webserver from outside the container:
```
curl localhost:60000/index.php -I -s
```
In order to remove the container:
```
docker rm phpinfo --force
```
# How to build a new Docker image for our PHP sample application
1. Remove the previously downloaded Docker image:
    ```
    docker rmi php:alpine
    ```
1. Create the Dockerfile:

    ```
    tee ${PWD}/phpinfo/Dockerfile 0<<EOF
    
    FROM    index.docker.io/library/alpine:latest
    RUN     apk add php
    
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
1. Check the number of layers for the created Docker image:

    ```
    docker inspect localhost/library/alpine:php|grep Layers --after 3
    ```
    ```
    docker inspect localhost/library/alpine:php|jq '.[0].RootFS.Layers'
    ```
    ```
    docker inspect localhost/library/alpine:php|jq '.[0].GraphDriver.Data'
    ```
1. The new Docker image layers will be located in this internal Docker folder:

    ```
    sudo ls /var/lib/docker/overlay2/
    ```
1. Locate the PHP package in the corresponding Docker image layer:

    ```
    sudo find /var/lib/docker/overlay2/ | grep bin/php$
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
1. Inspect the Docker container to get the overlay2 layers for the container:    

    ```
    docker inspect test
    ```
    ```
    docker inspect test|jq '.[0].GraphDriver.Data'
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
    ```
    ```
    overlay2=$(docker inspect test|grep UpperDir|cut --delimiter / --field 6)
    ```
    ```    
    sudo ls /var/lib/docker/overlay2/${overlay2}/diff
    ```
1. Check the inode numbers to confirm that the merged and the upper directories are not duplicating the new file:

    ```
    sudo stat /var/lib/docker/overlay2/${overlay2}/diff/sebastian
    ```
    ```
    sudo stat /var/lib/docker/overlay2/${overlay2}/merged/sebastian
    ```
1. The merged directory will be mounted at the root filesystem of the container so that:

    ```
    INSIDE THE CONTAINER        OUTSIDE THE CONTAINER
             /              =   /var/lib/docker/overlay2/${overlay2}/merged/
    ```

# How to deploy a Docker stack using a Docker compose file

```
tee ${PWD}/phpinfo/docker-compose.yaml 0<<EOF

# docker-compose.yaml
configs:
#secrets:
  phpinfo:
    external: false
    file: ./index.php
networks:
  phpinfo:
    external: false
    internal: false
services:
  phpinfo:
    command:
      - php
      - -f
      - index.php
      - -S
      - 0.0.0.0:9000
    configs:
    #secrets:
      - source: phpinfo
        target: /var/data/index.php
        uid: '65534'
        gid: '65534'
        mode: 0400
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.02'
          memory: 20M
        reservations:
          cpus: '0.01'
          memory: 10M
    image: index.docker.io/library/php:alpine
    networks:
      - phpinfo
    ports:
      - 60000:9000
    read_only: true
    user: nobody:nogroup
    volumes:
      - type: volume
        source: phpinfo
        target: /var/data/tmp/
        read_only: false
    working_dir: /var/data/
version: '3.8'
volumes:
  phpinfo:
    external: false
    
EOF
```
```
docker swarm init
```
```
docker stack rm PHPINFO ; sleep 20

docker stack deploy --compose-file ${PWD}/phpinfo/docker-compose.yaml PHPINFO
```
```
docker stack ps PHPINFO
```
```
docker stack ls
```
```
docker stack services PHPINFO
```
```
docker service logs PHPINFO_phpinfo
```
```
docker ps
```
```
ps=$(docker stack ps PHPINFO --no-trunc --quiet|head -1)
```
```
docker exec PHPINFO_phpinfo.1.${ps} df
```
```
docker exec PHPINFO_phpinfo.1.${ps} ps aux
```
```
docker top PHPINFO_phpinfo.1.${ps}
```
# How to install OpenShift Container Platform in AWS
* [https://github.com/sebastian-colomar/openshift/](https://github.com/sebastian-colomar/openshift/blob/master/master/README.md)
