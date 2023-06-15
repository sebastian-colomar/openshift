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
2. https://github.com/sebastian-colomar/phpinfo
```
git clone https://github.com/sebastian-colomar/phpinfo
cd phpinfo
git checkout main
php -f src/index.php -S localhost:8080
curl localhost:8080/src/index.php
```
1. https://github.com/sebastian-colomar/dca/blob/main/registry.md
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
2. https://github.com/sebastian-colomar/phpinfo/blob/2022-01/README.md
3. https://github.com/sebastian-colomar/phpinfo/blob/2022-01/kube-compose-cm.yaml
4. https://kubernetes.io/docs/concepts/overview/components/
```
cat /proc/1/cgroup
cat /proc/$$/cgroup
docker ps
docker top 3f2b34079177
cat /proc/2736/cgroup
docker top 6d219de4e98c
cat /proc/2566/cgroup
cat /proc/2602/cgroup
ls /var/lib/docker/containers/
ls /var/lib/docker/overlay2/
```
1. https://docs.openshift.com/container-platform/4.10/architecture/architecture.html
```
docker network ls
ip link

docker run --detach --name nginx1-docker0 --network bridge library/nginx:alpine
docker run --detach --name nginx2-docker0 --network bridge library/nginx:alpine
docker exec nginx1-docker0 sh -c 'echo nginx1-docker0 | tee /usr/share/nginx/html/index.html'
docker exec nginx2-docker0 sh -c 'echo nginx2-docker0 | tee /usr/share/nginx/html/index.html'

docker exec nginx1-docker0 nslookup nginx1-docker0 127.0.0.11
docker exec nginx2-docker0 nslookup nginx2-docker0 127.0.0.11

docker exec nginx1-docker0 curl http://nginx1-docker0 --connect-timeout 3
docker exec nginx2-docker0 curl http://nginx2-docker0 --connect-timeout 3

docker exec nginx1-docker0 curl http://$( docker container inspect nginx1-docker0 | grep IPAddress | tail -1 | cut -d\" -f4 ) -s
docker exec nginx2-docker0 curl http://$( docker container inspect nginx2-docker0 | grep IPAddress | tail -1 | cut -d\" -f4 ) -s

docker exec nginx1-docker0 curl http://$( docker container inspect nginx2-docker0 | grep IPAddress | tail -1 | cut -d\" -f4 ) -s
docker exec nginx2-docker0 curl http://$( docker container inspect nginx1-docker0 | grep IPAddress | tail -1 | cut -d\" -f4 ) -s

iptables -S -t filter | grep docker0.*DROP

docker network create net1
docker network create net2

docker run --detach --name nginx1 --network net1 library/nginx:alpine
docker run --detach --name nginx2 --network net2 library/nginx:alpine

docker exec nginx1 sh -c 'echo nginx1 | tee /usr/share/nginx/html/index.html'
docker exec nginx2 sh -c 'echo nginx2 | tee /usr/share/nginx/html/index.html'

docker exec nginx1 nslookup nginx1 127.0.0.11
docker exec nginx2 nslookup nginx2 127.0.0.11

docker exec nginx1 curl http://nginx1 -s
docker exec nginx2 curl http://nginx2 -s

docker exec nginx1 curl http://$( docker container inspect nginx1 | grep IPAddress | tail -1 | cut -d\" -f4 ) -s
docker exec nginx2 curl http://$( docker container inspect nginx2 | grep IPAddress | tail -1 | cut -d\" -f4 ) -s

docker exec nginx1 curl http://$( docker container inspect nginx2 | grep IPAddress | tail -1 | cut -d\" -f4 ) --connect-timeout 3
docker exec nginx2 curl http://$( docker container inspect nginx1 | grep IPAddress | tail -1 | cut -d\" -f4 ) --connect-timeout 3

iptables -S -t filter | grep br.*DROP

docker network create net3

docker run --detach --name nginx3-1 --network net3 library/nginx:alpine
docker run --detach --name nginx3-2 --network net3 library/nginx:alpine

docker exec nginx3-1 sh -c 'echo nginx3-1 | tee /usr/share/nginx/html/index.html'
docker exec nginx3-2 sh -c 'echo nginx3-2 | tee /usr/share/nginx/html/index.html'

docker exec nginx3-1 nslookup nginx3-1 127.0.0.11
docker exec nginx3-2 nslookup nginx3-2 127.0.0.11

docker exec nginx3-1 nslookup nginx3-2 127.0.0.11
docker exec nginx3-2 nslookup nginx3-1 127.0.0.11

docker exec nginx3-1 curl http://nginx3-1 -s
docker exec nginx3-2 curl http://nginx3-2 -s

docker exec nginx3-1 curl http://nginx3-2 -s
docker exec nginx3-2 curl http://nginx3-1 -s

docker exec nginx3-1 curl http://$( docker container inspect nginx3-1 | grep IPAddress | tail -1 | cut -d\" -f4 ) -s
docker exec nginx3-2 curl http://$( docker container inspect nginx3-2 | grep IPAddress | tail -1 | cut -d\" -f4 ) -s

docker exec nginx3-1 curl http://$( docker container inspect nginx3-2 | grep IPAddress | tail -1 | cut -d\" -f4 ) -s
docker exec nginx3-2 curl http://$( docker container inspect nginx3-1 | grep IPAddress | tail -1 | cut -d\" -f4 ) -s

docker run --detach --rm --name nginx --network host library/nginx:alpine
curl localhost -I
```
1. https://iximiuz.com/en/
1. https://docs.openshift.com/container-platform/4.10/applications/application-health.html
