```
cat /proc/1/cgroup 

docker run --detach --name test --rm --tty busybox
docker ps

df
docker exec test df

ifconfig
docker exec test ifconfig

ps aux
docker exec test ps aux

cat /etc/hosts
docker exec test cat /etc/hosts

docker top test

cat /proc/10763/cgroup 
```
```
export KUBECONFIG=${PWD}/auth/kubeconfig

kubectl get nodes
chroot /host
cat /etc/redhat-release 
```
