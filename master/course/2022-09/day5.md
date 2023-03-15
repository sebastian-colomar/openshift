# How to deploy our sample application using a Pod
```
# docker run --cpus 100m --detach --env AUTHOR=Sebastian --expose 8080 --memory 100M --memory-reservation 100M --name phpinfo --read-only --restart always --user nobody:nogroup --volume ${HOME}/phpinfo/:/data/:ro --workdir /data/ index.docker.io/library/php:alpine@sha256:ab23b416d86aec450ee7b75727f6bbec272edc2764a1b6fad13bc2823c59bb6b php -f index.php -S 0.0.0.0:8080
apiVersion: v1
kind: Pod
metadata:
  name: phpinfo-po
  labels:
    app: phpinfo-po
spec:
  containers:
    - name: phpinfo
      image: 'index.docker.io/library/php:alpine@sha256:ab23b416d86aec450ee7b75727f6bbec272edc2764a1b6fad13bc2823c59bb6b'
      ports:
        - containerPort: 8080
          protocol: TCP
      resources:
        limits:
          cpu: 100m
          memory: 100M
        requests:
          cpu: 100m
          memory: 100M
      env:
        - name: AUTHOR
          value: Sebastian
      securityContext:
          readOnlyRootFilesystem: true
          runAsUser: 65534
          runAsGroup: 65534
      volumeMounts:
        - mountPath: /data/index.php
          subPath: index.php
          name: phpinfo-volume
          readOnly: true
      workingDir: /data/
      args:
        - php
        - -f
        - index.php
        - -S
        - 0.0.0.0:8080
  restartPolicy: Always
  securityContext:
    fsGroup: 65534
  volumes:
    - name: phpinfo-volume
      configMap:
          defaultMode: 0400
          items:
            - key: index.php
              path: index.php
              mode: 0400
          name: phpinfo-cm
```
# We also need to create the ConfigMap:
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: phpinfo-cm
data:
  index.php: |-
    <?php
    // Show all information, defaults to INFO_ALL
    phpinfo();
    // Show just the module information.
    // phpinfo(8) yields identical results.
    phpinfo(INFO_MODULES);
    ?>
```    
# Updating Pods
1. Create a basic Pod:
    ```
    kind: Pod
    apiVersion: v1
    metadata:
      name: example-1
      labels:
        app: httpd-1
    spec:
      containers:
        - name: httpd
          ports:
            - containerPort: 8080
              protocol: TCP
          image: 'image-registry.openshift-image-registry.svc:5000/openshift/httpd:latest'
    ```      
1. Create a Service to connect to the Pod:
    ```
    apiVersion: v1
    kind: Service
    metadata:
      name: example-1
    spec:
      selector:
        app: httpd-1
      ports:
        - protocol: TCP
          port: 80
          targetPort: 8080
    ```      
1. Create a Route to connect to the Service:

    ```
    apiVersion: route.openshift.io/v1
    kind: Route
    metadata:
      name: example
    spec:
      path: /
      to:
        kind: Service
        name: example-1
    ```    
