# Introduction to the Course

1. https://docs.openshift.com/
4. https://docs.openshift.com/container-platform/4.10/welcome/oke_about.html
5. https://ap-south-1.console.aws.amazon.com/cloud9/
6. https://en.wikipedia.org/wiki/Linux_namespaces

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
php -f ${PWD}/phpinfo/index.php -S localhost:8080
```
Go to this location to see the resulting web page:
* http://localhost:8080/phpinfo/

# Introduction to Docker

1. https://docs.docker.com/
2. https://hub.docker.com/
3. https://camo.githubusercontent.com/365252849548af802a787aefa6202e4e600b0843/68747470733a2f2f692e737461636b2e696d6775722e636f6d2f76477561792e706e67

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
docker network create phpinfo-network --driver bridge
```
Let us download the Docker image from Docker Hub:
```
docker pull index.docker.io/library/php:alpine@sha256:ab23b416d86aec450ee7b75727f6bbec272edc2764a1b6fad13bc2823c59bb6b

docker images
```
Let us see all the options for docker run command:
```
docker run --help
```
Let us create the container:
```
docker run --cpus 1 --detach --env AUTHOR=Sebastian --memory 100M --memory-reservation 100M --name phpinfo --network phpinfo-network --publish 8080:9000 --read-only --restart always --user nobody:nogroup --volume ${HOME}/phpinfo/:/var/data/:ro --workdir /var/data/ index.docker.io/library/php:alpine@sha256:ab23b416d86aec450ee7b75727f6bbec272edc2764a1b6fad13bc2823c59bb6b php -f index.php -S 0.0.0.0:9000
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
Test the connection to the webserver:
```
docker exec phpinfo curl localhost:9000 -I -s
```
In order to remove the container:
```
docker rm phpinfo --force
```

