# Storage
1. https://access.redhat.com/documentation/en-us/openshift_container_platform/4.10/html-single/storage/index
2. https://res.cloudinary.com/canonical/image/fetch/f_auto,q_auto,fl_sanitize,c_fill,w_2932,h_1617/https://assets.ubuntu.com/v1/09b510e0-UAS_storage_options.png
3. https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
4. https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/
5. https://docs.openshift.com/container-platform/4.10/nodes/nodes/nodes-nodes-rebooting.html
6. https://docs.openshift.com/container-platform/4.10/nodes/scheduling/nodes-scheduler-pod-affinity.html

# Pods, Services, IPtables and Network Policies:
1. Create a basic Pod:

    ```
    apiVersion: v1
    kind: Pod
    metadata:
      name: httpd-po-1
      labels:
        app: httpd
    spec:
      containers:
        - name: httpd-container
          image: 'image-registry.openshift-image-registry.svc:5000/openshift/httpd:latest'
          ports:
            - containerPort: 8080
          securityContext:
            readOnlyRootFilesystem: true
          volumeMounts:
            - mountPath: /var/www/html/
              name: httpd-volume
              readOnly: true
            - mountPath: /etc/httpd/conf/
              name: httpd-conf
              readOnly: false
          workingDir: /var/www/html/
      initContainers:
        - name: httpd-init
          args:
            - cp -v /etc/hostname index.html
          command:
            - sh
            - -c
          image: busybox
          securityContext:
            readOnlyRootFilesystem: true
          volumeMounts:
            - mountPath: /data/
              name: httpd-volume
              readOnly: false
          workingDir: /data/
      volumes:
        - name: httpd-volume
        - name: httpd-conf
    ```
1. Create a Service to connect to this Pod:

    ```
    apiVersion: v1
    kind: Service
    metadata:
      name: httpd-svc
    spec:
      selector:
        app: httpd
      ports:
        - protocol: TCP
          port: 80
          targetPort: 8080
    ```
1. Now you can connect from any Pod running in any other Project to this Service (in the next section we will how to protect from this possibility):

    ```
    nslookup httpd-svc.my-project.SVC.CLUSTER.LOCAL
    
    curl httpd-svc.my-project.SVC.CLUSTER.LOCAL
    
    curl 172.30.x.y
    ```
1. Open a terminal on a worker Node:

    ```
    chroot /host
    ```
1. Show the IPtables rules that forward the traffic from the Service VIP to the target Pod:

    ```
    iptables -S -t nat | grep A.KUBE-SERVICES.*172.30.x.y
    
    iptables -S -t nat | grep A.KUBE-SVC-XXX.*KUBE-SEP
    
    iptables -S -t nat | grep A.KUBE-SEP-YYY.*DNAT
    ```
1. Create a second Pod with the same label so it will be included by the Service selector as a valid target:

    ```
    apiVersion: v1
    kind: Pod
    metadata:
      name: httpd-po-2
      labels:
        app: httpd
    spec:
      containers:
        - name: httpd-container
          image: 'image-registry.openshift-image-registry.svc:5000/openshift/httpd:latest'
          ports:
            - containerPort: 8080
          volumeMounts:
            - mountPath: /var/www/html/
              name: httpd-volume
      initContainers:
        - name: httpd-init
          args:
            - cp /etc/hostname index.html
          command:
            - sh
            - -c
          image: busybox
          volumeMounts:
            - mountPath: /data/
              name: httpd-volume
          workingDir: /data/
      volumes:
        - name: httpd-volume
    ```    
1. The IPtables will include a new rule for the new Pod and traffic will be load balanced randomly across the targets:

    ```
    iptables -S -t nat | grep A.KUBE-SVC-XXX.*KUBE-SEP
    ```
1. Every time you connect to the target Pod you will visualize a possibly different hostname (randomly chosen from the target pool):    

    ```
    curl httpd-svc.my-project.SVC.CLUSTER.LOCAL
    ```
3. Create a Network Policy to block access to the target Pods from outside the Project:

    ```
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: httpd-netpol
    spec:
      podSelector:
        matchLabels:
          app: httpd
      policyTypes:
        - Ingress
      ingress:
        - from:
            - podSelector: {}
          ports:
            - protocol: TCP
              port: 8080
    ```
# Routes and HAProxy
1. Create a Route to connect to the Service from outside the cluster (though the connection will be blocked until we delete the previously created Network Policy):

    ```
    apiVersion: route.openshift.io/v1
    kind: Route
    metadata:
      name: httpd-route
    spec:
      to:
        kind: Service
        name: httpd-svc
    ```
1. The previous command will create a backend in the HA Proxy configuration of the router default Pod in the Openshift Ingress Namespace:
    ```
    grep httpd-route haproxy.config
    
    grep server.*httpd-svc haproxy.config 
    ```
