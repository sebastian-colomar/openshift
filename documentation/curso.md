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
3. 
