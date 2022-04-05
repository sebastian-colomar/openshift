1. https://docs.docker.com/get-started/
1. https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
1. https://labs.play-with-docker.com/
1. https://hub.docker.com/
1. https://shell.cloud.google.com/
```
docker version

cat /proc/1/cgroup

man proc

ps aux

ls /proc/

cat /proc/18/cmdline;echo

cat /proc/18/cgroup

sleep infinity &

cat /proc/$( pidof sleep )/cmdline;echo

cat /proc/$( pidof sleep )/cgroup

docker run -d --entrypoint sleep --rm busybox:latest infinity

pidof sleep

docker top $( docker ps -q )

cat /proc/21324/cgroup

docker run -d --entrypoint sleep --rm busybox:latest infinity

md5sum /bin/sleep

docker exec xxxxxxxxx md5sum /bin/sleep

docker ps

docker exec xxxxxxxxx touch jose-luis

find /var/lib/docker/ | grep jose-luis

find /var/lib/docker/overlay2/yyyyy/merged/

md5sum /var/lib/docker/overlay2/yyyyy/merged/bin/sleep

docker exec xxxxxxxxx md5sum /bin/sleep

cat /proc/$( echo $$ )/cgroup

docker exec -it xxxxx sh
```
1. https://en.wikipedia.org/wiki/Linux_namespaces
2. https://en.wikipedia.org/wiki/Cgroups
```
docker run --entrypoint sh -it library/alpine:latest
apk add php
echo '<?php phpinfo();?>' | tee script.php
php -f script.php -S 0.0.0.0:8080
apk add curl
curl localhost:8080/script.php -I
ip route
```
1. https://docs.docker.com/engine/reference/builder/
```
tee Dockerfile 0<<EOF
FROM library/alpine:latest
RUN apk add php
RUN echo '<?php phpinfo();?>' | tee script.php
EOF

docker build -t localhost/alpine:phpinfo .
docker inspect localhost/alpine:phpinfo
docker history localhost/alpine:phpinfo
```
1. https://hub.docker.com/_/nginx
2. https://github.com/nginxinc/docker-nginx/blob/master/mainline/debian/Dockerfile
```
docker images
find /var/lib/docker | grep /script.php
docker run --entrypoint php -p 8080 localhost/alpine:phpinfo -f script.php -S 0.0.0.0:8080
```
1. https://docs.docker.com/storage/storagedriver/
2. https://github.com/academiaonline-org/phpinfo
```
git clone https://github.com/academiaonline-org/phpinfo
cd phpinfo
git checkout main
php -f src/index.php -S localhost:8080
curl localhost:8080/src/index.php
```
1. https://github.com/academiaonline-org/dca/blob/main/registry.md
```
docker run --detach --name registry --publish 5000:5000 --restart always --volume registry:/var/lib/registry:rw docker.io/library/registry:2
docker pull docker.io/library/busybox:latest
docker tag docker.io/library/busybox:latest localhost:5000/my_library/my_busybox:1.0
docker push localhost:5000/my_library/my_busybox:1.0
docker pull localhost:5000/my_library/my_busybox:1.0
docker volume inspect registry
sudo find /var/lib/docker/volumes/registry/_data/
```
1. https://docs.docker.com/storage/volumes/
2. https://github.com/academiaonline-org/phpinfo/blob/2022-01/kube-compose-cm.yaml
3. https://kubernetes.io/docs/concepts/overview/components/
