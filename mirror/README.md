- https://console-openshift-console.apps.openshift.sebastian-colomar.es/k8s/ns/openshift-config/secrets/pull-secret
```
oc project default
```
```
oc create secret docker-registry pull-secret --docker-username user --docker-password password --docker-email sebastian.colomar@gmail.com
oc patch secret pull-secret --patch='{"data":{".dockerconfigjson":"'$(oc get secret pull-secret --namespace openshift-config -o json | jq -r '.data[".dockerconfigjson"]')'"}}'
```
```
oc create secret docker-registry pull-secret-dockerhub --docker-username user --docker-password password --docker-email sebastian.colomar@gmail.com
oc patch secret pull-secret-mirror-quay --patch='{"data":{".dockerconfigjson":"'$(oc get secret pull-secret-dockerhub --namespace openshift-config -o json | jq -r '.data[".dockerconfigjson"]')'"}}'
```
```
oc apply -Rf ./gitops/bootstrap
```
