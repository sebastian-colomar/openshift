- https://console-openshift-console.apps.openshift.sebastian-colomar.es/k8s/ns/openshift-config/secrets/pull-secret

```
cat $HOME/.docker/config.json

#docker login https://example-registry-quay-openshift-operators.apps.openshift.sebastian-colomar.es/ --username $QUAY_USERNAME --password $QUAY_PASSWORD

echo -n "$QUAY_USERNAME:$QUAY_PASSWORD" | base64 -w0

cat $MIRROR/.dockerconfigjson-mirror
```
```
kind: ConfigMap
apiVersion: v1
metadata:
  name: isc
data:
  ImageSetConfiguration: |-
    apiVersion: mirror.openshift.io/v2alpha1
    kind: ImageSetConfiguration
    mirror:
      platform:
        channels:
        -
          maxVersion: 4.20.10
          minVersion: 4.20.10
          name: stable-4.20
        graph: true
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: oc-mirror
spec:
  replicas: 1
  selector:
    matchLabels:
      app: oc-mirror
  serviceName: oc-mirror
  template:
    metadata:
      labels:
        app: oc-mirror
    spec:
      containers:
      - 
        args:
        - |
          set -e
          mkdir $HOME/.docker
          cp $MIRROR/.dockerconfigjson $HOME/.docker/config.json
          cp oc-mirror /usr/local/bin/oc-mirror
          echo "oc-mirror installed. Version:"
          oc-mirror --v2 --version
          echo "Ready for mirroring."
          echo "From source to file:"
          echo "oc-mirror --v2 -c $MIRROR/ImageSetConfiguration.yaml --cache-dir $MIRROR file://$MIRROR/ocp"
          echo "From file to mirror"
          echo "oc-mirror --v2 -c $MIRROR/ImageSetConfiguration.yaml --cache-dir $MIRROR --from file://$MIRROR/ocp docker://$REGISTRY/ocp
          exec sleep infinity
        command: ["/bin/bash", "-c"]
        env:
        - name: MIRROR
          value: /mirror
        - name: REGISTRY
          value: quay.apps-int.openshift.sebastian-colomar.es
        image: registry.access.redhat.com/ubi9/ubi:latest
        name: oc-mirror
        volumeMounts:
        -
          mountPath: /mirror/ImageSetConfiguration.yaml
          name: isc
          subPath: ImageSetConfiguration.yaml
        -
          mountPath: /mirror
          name: mirror
        -
          mountPath: /mirror/.dockerconfigjson
          name: pull-secret
          subPath: .dockerconfigjson
        workingDir: /mirror
      initContainers:
      - 
        args:
        - |
          set -e
          echo "Downloading oc-mirror..."
          curl -L -o oc-mirror.tgz https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.20.10/oc-mirror.rhel9.tar.gz || { echo "Download failed"; exit 1; }
          tar fxz oc-mirror.tgz
          chmod +x ./oc-mirror
          cp oc-mirror /usr/local/bin/oc-mirror
          echo "oc-mirror downloaded."
        command: ["/bin/bash", "-c"]
        image: registry.access.redhat.com/ubi9/ubi:latest
        name: download-oc-mirror
        volumeMounts:
        -
          mountPath: /mirror
          name: mirror
        workingDir: /mirror
      volumes:
      -
        name: pull-secret
        secret:
          secretName: pull-secret
          items:
          - key: .dockerconfigjson
            path: .dockerconfigjson
      -
        name: isc
        configMap:
          items:
          - key: ImageSetConfiguration
            path: ImageSetConfiguration.yaml
          name: isc
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
          storage: 300Gi
      volumeMode: Filesystem
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
  host: quay.apps-int.openshift.sebastian-colomar.es
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
