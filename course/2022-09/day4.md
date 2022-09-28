# Managing and using OpenShift Container Platform
1. https://access.redhat.com/documentation/en-us/openshift_container_platform/4.10/html-single/web_console/index
2. https://developer.mozilla.org/en-US/docs/Web/HTTP
3. https://auth0.com/intro-to-iam/what-is-oauth-2/
4. https://access.redhat.com/documentation/en-us/openshift_container_platform/4.10/html-single/cli_tools/index

# How to install the command line tool
* https://console-openshift-console.apps.ocp.sebastian-colomar.es/command-line-tools
```
wget https://downloads-openshift-console.apps.ocp.sebastian-colomar.es/amd64/linux/oc.tar
tar xf oc.tar
sudo install oc /usr/local/bin/
which oc
oc version
sudo ln -s /usr/local/bin/oc /usr/local/bin/kubectl
which kubectl
kubectl version
```
# Docker vs CRI-O
* https://access.redhat.com/documentation/en-us/openshift_container_platform/4.10/html/support/troubleshooting#troubleshooting-crio-issues
# Template vs Manifest
* https://github.com/academiaonline-org/openshift/blob/master/etc/docker/kubernetes/php-template.yaml
