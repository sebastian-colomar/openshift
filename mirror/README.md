- https://console-openshift-console.apps.openshift.sebastian-colomar.es/k8s/ns/openshift-config/secrets/pull-secret
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mirror-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1000Gi
  storageClassName: ocs-storagecluster-cephfs
  volumeMode: Filesystem
```
```
kind: ConfigMap
apiVersion: v1
metadata:
  name: isc
  namespace: default
data:
  ImageSetConfiguration: |-
    apiVersion: mirror.openshift.io/v2alpha1
    kind: ImageSetConfiguration
    mirror:
      platform:
        channels:
        - name: stable-4.20
          minVersion: 4.20.10
          maxVersion: 4.20.10
          graph: true
```
```
apiVersion: batch/v1
kind: Job
metadata:
  name: oc-mirror2disk
  namespace: default
spec:
  template:
    spec:
      restartPolicy: Never
      initContainers:
      - name: download-oc-mirror
        image: registry.access.redhat.com/ubi9/ubi:latest
        env:
        - name: BINARY
          value: oc-mirror
        - name: RELEASE
          value: 4.20.10
        command: ["/bin/bash", "-c"]
        args:
        - |
          set -e

          BINARY="oc-mirror"

          if [ -f "$BINARY" ] && [ -x "$BINARY" ]; then
            echo "$BINARY binary already exists - skipping download."
            exit 0
          fi

          echo "No valid $BINARY binary found - downloading..."
          curl -L -o $BINARY.tgz https://mirror.openshift.com/pub/openshift-v4/$(arch)/clients/ocp/$RELEASE/$BINARY.rhel9.tar.gz || { echo "Download failed - check URL or network"; exit 1; }

          tar fxz $BINARY.tgz
          chmod +x $BINARY
          echo "$BINARY binary downloaded and persisted"
        volumeMounts:
        - mountPath: /mirror
          name: mirror
        workingDir: /mirror
      containers:
      - name: oc-mirror
        image: registry.access.redhat.com/ubi9/ubi:latest
        env:
        - name: BINARY
          value: oc-mirror
        - name: REGISTRY
          value: quay.apps-int.openshift.sebastian-colomar.es
        command: ["/bin/bash", "-c"]
        args:
        - |
          set -e

          mkdir -p $HOME/.docker
          cp .dockerconfigjson $HOME/.docker/config.json

          cp $BINARY /usr/local/bin/$BINARY
          echo "$BINARY ready. Version:"
          $BINARY --v2 --version
          echo ""

          echo "Ready for mirroring. Examples (run manually if needed):"
          echo "  Phase 1 - Mirror to disk:"
          echo "    $BINARY --v2 --config ImageSetConfiguration.yaml --cache-dir . file://ocp"
          echo ""
          echo "  Phase 2 - Mirror from disk to registry:"
          echo "    $BINARY --v2 --config ImageSetConfiguration.yaml --cache-dir . --from file://ocp docker://$REGISTRY/ocp"
          echo ""

          $BINARY --v2 --config ImageSetConfiguration.yaml --cache-dir . file://ocp

          echo "Job complete."
        volumeMounts:
        - mountPath: /mirror/ImageSetConfiguration.yaml
          name: isc
          subPath: ImageSetConfiguration.yaml
        - mountPath: /mirror
          name: mirror
        - mountPath: /mirror/.dockerconfigjson
          name: pull-secret
          subPath: .dockerconfigjson
        workingDir: /mirror
      volumes:
      - name: pull-secret
        secret:
          secretName: pull-secret
          items:
          - key: .dockerconfigjson
            path: .dockerconfigjson
      - name: isc
        configMap:
          name: isc
          items:
          - key: ImageSetConfiguration
            path: ImageSetConfiguration.yaml
      - name: mirror
        persistentVolumeClaim:
          claimName: mirror-pvc
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
          cp .dockerconfigjson $HOME/.docker/config.json
          cp oc-mirror /usr/local/bin/oc-mirror
          echo "oc-mirror installed. Version:"
          oc-mirror --v2 --version
          echo "Ready for mirroring."
          echo "From source to file:"
          echo "oc-mirror --v2 -c ImageSetConfiguration.yaml --cache-dir . file://mirror"
          echo "From file to mirror"
          echo "oc-mirror --v2 -c ImageSetConfiguration.yaml --cache-dir . --from file://mirror docker://$REGISTRY/mirror"
          exec sleep infinity
        command: ["/bin/bash", "-c"]
        env:
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
#oc-mirror --v2 -c $MIRROR/ImageSetConfiguration.yaml --image-timeout 60m --cache-dir $MIRROR --from file://$MIRROR/ocp docker://mirror.apps.openshift.sebastian-colomar.es/ocp

oc-mirror --v2 -c $MIRROR/ImageSetConfiguration.yaml --image-timeout 60m --cache-dir $MIRROR --from file://$MIRROR/ocp docker://mirror.apps-int.openshift.sebastian-colomar.es/ocp
```
