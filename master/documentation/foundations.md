# Underlying technology for Docker containers:

* https://en.wikipedia.org/wiki/Linux_namespaces
  
  Namespaces isolate:
  * Network stack (routing tables and network interfaces)
  * Mount points (file systems)
  * Process ID (table of processes)
  * ...

* https://en.wikipedia.org/wiki/Cgroups
  
  Control Groups isolate:
  * CPU usage (100 millicores per container)
  * RAM usage (100 MiB per container)
  * ...

```
[root@ip-172-31-6-215 ~]# cat /proc/1/cgroup
11:blkio:/
10:perf_event:/
9:freezer:/
8:hugetlb:/
7:pids:/
6:cpuset:/
5:devices:/
4:cpu,cpuacct:/
3:net_cls,net_prio:/
2:memory:/
1:name=systemd:/
```
```
[root@ip-172-31-6-215 ~]# strings /proc/1/cmdline
/usr/lib/systemd/systemd
--switched-root
--system
--deserialize
```
```
[root@ip-172-31-6-215 ~]# cat /proc/$$/cgroup
11:blkio:/user.slice
10:perf_event:/
9:freezer:/
8:hugetlb:/
7:pids:/user.slice
6:cpuset:/
5:devices:/user.slice
4:cpu,cpuacct:/user.slice
3:net_cls,net_prio:/
2:memory:/user.slice
1:name=systemd:/user.slice/user-0.slice/session-c6.scope
```
```
[root@ip-172-31-6-215 ~]# strings /proc/$$/cmdline
-bash
```
```
[root@ip-172-31-6-215 ~]# docker run --detach --name test --rm busybox sleep infinity
1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
```
```
[root@ip-172-31-6-215 ~]# cat /proc/$( docker top test | awk '!/PID/{ print $2 }' )/cmdline | strings
sleep
infinity
```
```
[root@ip-172-31-6-215 ~]# cat /proc/$( docker top test | awk '!/PID/{ print $2 }' )/cgroup
11:blkio:/docker/1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
10:perf_event:/docker/1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
9:freezer:/docker/1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
8:hugetlb:/docker/1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
7:pids:/docker/1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
6:cpuset:/docker/1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
5:devices:/docker/1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
4:cpu,cpuacct:/docker/1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
3:net_cls,net_prio:/docker/1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
2:memory:/docker/1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
1:name=systemd:/docker/1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
```
```
[root@ip-172-31-6-215 ~]# ls /var/lib/docker/containers -l | awk '{ print $9 }'

1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
```
```
[root@ip-172-31-6-215 ~]# docker ps --no-trunc | awk '!/CONTAINER/{ print $1 }'
1cfb1776ca37faaf41a076131b991089a6eb6416c9c89d58002b95631e66f219
```
```
[root@ip-172-31-6-215 ~]# docker diff test
```
```
[root@ip-172-31-6-215 ~]# touch SEBASTIAN
[root@ip-172-31-6-215 ~]# docker exec test touch sebastian
```
```
[root@ip-172-31-6-215 ~]# find / 2> /dev/null | grep -E "SEBASTIAN|sebastian"
/var/lib/docker/overlay2/e0ed21c403c7f1d4f906659b8d8afdd7f43770c4e21ffa872a2c69eb520b8305/diff/sebastian
/var/lib/docker/overlay2/e0ed21c403c7f1d4f906659b8d8afdd7f43770c4e21ffa872a2c69eb520b8305/merged/sebastian
/root/SEBASTIAN
```
```
[root@ip-172-31-6-215 ~]# docker diff test
A /sebastian
```
```
[root@ip-172-31-6-215 ~]# find /var/lib/docker/ | grep sebastian
/var/lib/docker/overlay2/e0ed21c403c7f1d4f906659b8d8afdd7f43770c4e21ffa872a2c69eb520b8305/diff/sebastian
/var/lib/docker/overlay2/e0ed21c403c7f1d4f906659b8d8afdd7f43770c4e21ffa872a2c69eb520b8305/merged/sebastian
```
```
[root@ip-172-31-6-215 ~]# for file in $( find /var/lib/docker/ | grep sebastian );do stat $file;done
  File: ‘/var/lib/docker/overlay2/e0ed21c403c7f1d4f906659b8d8afdd7f43770c4e21ffa872a2c69eb520b8305/diff/sebastian’
  Size: 0               Blocks: 0          IO Block: 4096   regular empty file
Device: ca01h/51713d    Inode: 46181855    Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2024-02-07 05:48:39.767913362 +0000
Modify: 2024-02-07 05:48:39.767913362 +0000
Change: 2024-02-07 05:48:39.767913362 +0000
 Birth: -
  File: ‘/var/lib/docker/overlay2/e0ed21c403c7f1d4f906659b8d8afdd7f43770c4e21ffa872a2c69eb520b8305/merged/sebastian’
  Size: 0               Blocks: 0          IO Block: 4096   regular empty file
Device: 2ah/42d Inode: 46181855    Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2024-02-07 05:48:39.767913362 +0000
Modify: 2024-02-07 05:48:39.767913362 +0000
Change: 2024-02-07 05:48:39.767913362 +0000
 Birth: -
```
```
[root@ip-172-31-6-215 ~]# docker exec test stat sebastian
  File: sebastian
  Size: 0               Blocks: 0          IO Block: 4096   regular empty file
Device: 2ah/42d Inode: 46181855    Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2024-02-07 05:48:39.767913362 +0000
Modify: 2024-02-07 05:48:39.767913362 +0000
Change: 2024-02-07 05:48:39.767913362 +0000
```
```
[root@ip-172-31-6-215 ~]# docker run --detach --name test2 --rm busybox sleep infinity
afc182009d3a91514149720e83e2ea302916396ddeba0a7844116fb5f4613d13
```
```
[root@ip-172-31-6-215 ~]# stat /bin/sleep
  File: ‘/bin/sleep’
  Size: 28960           Blocks: 64         IO Block: 4096   regular file
Device: ca01h/51713d    Inode: 50689       Links: 1
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2022-03-07 00:15:01.765424951 +0000
Modify: 2020-01-23 19:07:31.000000000 +0000
Change: 2022-03-07 00:14:05.537335177 +0000
 Birth: -
```
```
[root@ip-172-31-6-215 ~]# docker exec test stat /bin/sleep
  File: /bin/sleep
  Size: 1153296         Blocks: 2256       IO Block: 4096   regular file
Device: 2ah/42d Inode: 9006319     Links: 401
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2022-03-10 23:59:31.000000000 +0000
Modify: 2022-03-10 23:59:31.000000000 +0000
Change: 2022-04-07 03:10:16.633739970 +0000
```
```
[root@ip-172-31-6-215 ~]# docker exec test2 stat /bin/sleep
  File: /bin/sleep
  Size: 1153296         Blocks: 2256       IO Block: 4096   regular file
Device: 37h/55d Inode: 9006319     Links: 401
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2022-03-10 23:59:31.000000000 +0000
Modify: 2022-03-10 23:59:31.000000000 +0000
Change: 2022-04-07 03:10:16.633739970 +0000
```
```
[root@ip-172-31-6-215 ~]# ls /var/lib/docker/overlay2/
002bce1b51290d0737f835e609d246d4b6c72edf131cacbd4aa9366ca13e2a9b       958c6fed9918a4550fa48fc477660ea8ba25b618ccc34f92535ae7ebd6934eb4       l
69ea32edcf889a572d9828434220694950ed1cf4d6a58ce1921b1239fc27c6e4       958c6fed9918a4550fa48fc477660ea8ba25b618ccc34f92535ae7ebd6934eb4-init
69ea32edcf889a572d9828434220694950ed1cf4d6a58ce1921b1239fc27c6e4-init  backingFsBlockDev
```
# Docker engine and tools:
  * HIGH LEVEL = `docker --help`
  * MID LEVEL = `containerd --help`
  * LOW LEVEL = `runc --help`
