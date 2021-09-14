```
cat /proc/1/cgroup 

docker run --detach --name test --rm --tty busybox
docker ps
docker top test

cat /proc/10763/cgroup 

```
