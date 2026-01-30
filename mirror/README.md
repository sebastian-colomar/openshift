- https://console-openshift-console.apps.openshift.sebastian-colomar.es/k8s/ns/openshift-config/secrets/pull-secret

```
cat $HOME/.docker/config.json

#docker login https://example-registry-quay-openshift-operators.apps.openshift.sebastian-colomar.es/ --username $QUAY_USERNAME --password $QUAY_PASSWORD

echo -n "$QUAY_USERNAME:$QUAY_PASSWORD" | base64 -w0

cat $MIRROR/.dockerconfigjson-mirror
```
```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: oc-mirror
spec:
  replicas: 1
  selector:
    matchLabels:
      app: oc-mirror
  template:
    metadata:
      labels:
        app: oc-mirror
    spec:
      containers:
        - 
          args:
            - -c
            - |
              echo 'alias oc="./oc"' >> ~/.bashrc
              echo '[[ $- == *i* ]] || source ~/.bashrc' >> ~/.bashrc
              exec sleep infinity
          command: ["/bin/bash"]
          env:
          - name: MIRROR
            value: /mirror
          image: registry.access.redhat.com/ubi9/ubi:latest
          name: oc-mirror
          volumeMounts:
            - name: mirror
              mountPath: /mirror
            - name: pull-secret-ro
              mountPath: /secrets/pull-secret
              readOnly: true
          workingDir: /mirror
      volumes:
        - name: pull-secret-ro
          secret:
            secretName: pull-secret
  volumeClaimTemplates:
    - apiVersion: v1
      kind: PersistentVolumeClaim
      metadata:
        name: mirror
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1000Gi
        volumeMode: Filesystem
```
```
curl -O https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/oc-mirror.rhel9.tar.gz

gunzip oc-mirror.rhel9.tar.gz

tar xf oc-mirror.rhel9.tar

chmod +x ./oc-mirror

#sudo mv ./oc-mirror /usr/local/bin/
```
```
alias oc-mirror="./oc-mirror"

oc-mirror --v2 --version
```
```
apiVersion: mirror.openshift.io/v2alpha1
kind: ImageSetConfiguration
mirror:
  platform:
    channels:
    -
      maxVersion: 4.20.10
      minVersion: 4.20.10
      name: stable-4.20
      type: ocp
    graph: true
```
```
mkdir -p $HOME/.docker
cp $MIRROR/.dockerconfigjson $HOME/.docker/config.json
```
```
oc-mirror --v2 -c $MIRROR/ImageSetConfiguration.yaml --cache-dir $MIRROR file://$MIRROR/ocp
```


```
echo -n "$QUAY_USERNAME:$QUAY_PASSWORD" | base64 -w0
```
```
vi $MIRROR/.dockerconfigjson-mirror
```
```
#docker login https://example-registry-quay-openshift-operators.apps.openshift.sebastian-colomar.es/ --username $QUAY_USERNAME --password $QUAY_PASSWORD
cp $MIRROR/.dockerconfigjson-mirror $HOME/.docker/config.json
```
```
apiVersion: operator.openshift.io/v1
kind: IngressController
metadata:
  name: internal
  namespace: openshift-ingress-operator
spec:
  domain: apps-int.openshift.sebastian-colomar.es
  endpointPublishingStrategy:
    loadBalancer:
      scope: Internal
    type: LoadBalancerService
  replicas: 2
  routeSelector:
    matchLabels:
      ingress-type: internal
```
```
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: example-registry-quay-int
  namespace: openshift-operators
  labels:
    ingress-type: internal
  annotations:
    haproxy.router.openshift.io/timeout: 30m
spec:
  host: example-registry-quay-openshift-operators.apps-int.openshift.sebastian-colomar.com
  to:
    kind: Service
    name: example-registry-quay-app
  port:
    targetPort: http
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

```
#oc-mirror --v2 -c $MIRROR/ImageSetConfiguration.yaml --image-timeout 60m --cache-dir $MIRROR --from file://$MIRROR/ocp docker://example-registry-quay-openshift-operators.apps.openshift.sebastian-colomar.es/ocp

oc-mirror --v2 -c $MIRROR/ImageSetConfiguration.yaml --image-timeout 60m --cache-dir $MIRROR --from file://$MIRROR/ocp docker://example-registry-quay-openshift-operators.apps-int.openshift.sebastian-colomar.es/ocp
```
