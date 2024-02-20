```
export KUBECONFIG=/etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/node-kubeconfigs/localhost.kubeconfig
```
```
oc debug no/ip-10-0-141-107.ap-south-1.compute.internal -- chroot /host systemctl reboot
```
