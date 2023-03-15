```bash
docker network create mi_red
docker run --rm --name aa -d --network mi_red busybox ping localhost
docker run --rm --name bb -d --network mi_red busybox ping localhost
docker exec aa ping -c1 8.8.8.8
docker exec bb ping -c1 8.8.8.8
docker exec aa ping -c1 bb
docker exec bb ping -c1 aa

docker network create mi_red_2
docker run --rm --name cc -d --network mi_red_2 busybox ping localhost
docker exec cc ping -c1 aa

```
