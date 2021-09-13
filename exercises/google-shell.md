```
wget https://downloads-openshift-console.apps.openshift.sebastian-colomar.es/amd64/linux/oc.tar
tar xf oc.tar
sudo cp oc /usr/local/bin
cd /usr/local/bin
sudo ln -s oc kubectl
```
```
kubectl cp phpinfo-5fd494bc75-l5ztq:/etc/os-release os-release
kubectl cp phpinfo-5fd494bc75-l5ztq:/etc/motd motd
cat motd
kubectl cp motd phpinfo-5fd494bc75-l5ztq:/tmp/motd
kubectl port-forward pod/phpinfo-5fd494bc75-l5ztq 8000:8080
kubectl port-forward service/phpinfo 8000:8080
```
