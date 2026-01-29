- https://console-openshift-console.apps.openshift.sebastian-colomar.es/k8s/ns/openshift-config/secrets/pull-secret

```
cat $HOME/.docker/config.json

docker login https://example-registry-quay-openshift-operators.apps.openshift.sebastian-colomar.es/ --username $QUAY_USERNAME --password $QUAY_PASSWORD

cat $HOME/.docker/config.json
```
```
curl -O https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/oc-mirror.rhel9.tar.gz

gunzip oc-mirror.rhel9.tar.gz

tar xf oc-mirror.rhel9.tar

chmod +x oc-mirror

sudo mv oc-mirror /usr/local/bin/

oc mirror --v2 version
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
oc mirror --v2 -c $MIRROR/ImageSetConfiguration.yaml --cache-dir $MIRROR file://$MIRROR/ocp

oc mirror --v2 -c $MIRROR/ImageSetConfiguration.yaml --cache-dir $MIRROR --from file://$MIRROR/ocp docker://example-registry-quay-openshift-operators.apps.openshift.sebastian-colomar.es/ocp
```

```
apiVersion: v1
kind: Service
metadata:
  name: example-registry-quay-nlb
  namespace: openshift-operators
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internal"  # keep, but may still be ignored
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "instance"
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  selector:
    app: quay
    quay-component: quay-app
    quay-operator/quayregistry: example-registry
  ports:
    - name: https
      protocol: TCP
      port: 443
      targetPort: 8443
```
