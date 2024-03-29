# Replication Controllers, Replica Sets and Daemon Sets
1. Replication Controllers manage the replicas (Pods):
    ```
    apiVersion: v1
    kind: ReplicationController
    metadata:
      name: httpd-rc
    spec:
      replicas: 2
      selector:
        app: httpd-rc
      template:
        metadata:
          labels:
            app: httpd-rc
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
          initContainers:
            - name: httpd-init
              args:
                - cp -v /etc/hostname index.html
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
1. Replica Sets are very similar to Replication Controllers with the only difference of the selector:

    ```
    apiVersion: apps/v1
    kind: ReplicaSet
    metadata:
      name: httpd-rs
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: httpd-rs
      template:
        metadata:
          labels:
            app: httpd-rs
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
                - cp -v /etc/hostname index.html
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
1. Daemon Sets are designed to create one single replica (daemon) per node. Therefore, there is no replicas option in the manifest:

    ```
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: httpd-ds
    spec:
      selector:
        matchLabels:
          app: httpd-ds
      template:
        metadata:
          labels:
            app: httpd-ds
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
                - cp -v /etc/hostname index.html
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
# Jobs and Cron Jobs
1. Jobs are replicas which are created to perform a task (job) and supposed to be completed (and not restarted) afterwards:

    ```
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: anagrams-job
    spec:
      template:
        spec:
          containers:
            - name: anagrams-container
              image: 'academiaonline/anagrams:latest'
              volumeMounts:
                - name: anagrams-volume
                  readOnly: true
                  mountPath: /data/
          initContainers:
            - name: anagrams-init
              args:
                - 'wget ${URL}'
              command:
                - sh
                - '-c'
              env:
                - name: URL
                  value: https://raw.githubusercontent.com/Viviane-maker/santander-anagrams/docker/data/words.txt
              image: busybox
              volumeMounts:
                - name: anagrams-volume
                  mountPath: /data/
              workingDir: /data/
          restartPolicy: Never
          volumes:
            - name: anagrams-volume
              emptyDir:
                medium: Memory
                sizeLimit: 10M
    ```        
1. Cron Jobs are designed to launch Jobs regularly:

    ```
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: example
    spec:
      schedule: '* * * * *'
      jobTemplate:
        spec:
          template:
            spec:
              containers:
                - name: hello
                  image: busybox
                  args:
                    - /bin/sh
                    - '-c'
                    - date; echo Hello from the Kubernetes cluster
              restartPolicy: OnFailure
    ```    

# Deployments and Deployment Configs
1. Deployments are Kubernetes objects which can control the deployment of our Pods through Replica Sets:

    ```
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: httpd-deploy
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: httpd-deploy
      template:
        metadata:
          labels:
            app: httpd-deploy
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
                - cp -v /etc/hostname index.html
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
1. Deployment Configs are Openshift objects to control the deployment of the Pods through Replication Controllers:

    ```
    apiVersion: apps.openshift.io/v1
    kind: DeploymentConfig
    metadata:
      name: httpd-dc
    spec:
      replicas: 2
      selector:
        app: httpd-dc
      template:
        metadata:
          labels:
            app: httpd-dc
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
                - cp -v /etc/hostname index.html
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
   
# Horizontal Pod Autoscaler
1. Deployments, Deployment Configs, Replica Sets and Replication Controllers can be autoscaled through Horizontal Pod Autoscalers:
    ```
    kind: HorizontalPodAutoscaler
    apiVersion: autoscaling/v2beta2
    metadata:
      name: httpd-hpa
    spec:
      scaleTargetRef:
        kind: ReplicationController
        name: httpd-rc
        apiVersion: v1
      minReplicas: 1
      maxReplicas: 5
      metrics:
        - type: Resource
          resource:
            name: cpu
            target:
              type: Utilization
              averageUtilization: 50
        - type: Resource
          resource:
            name: memory
            target:
              type: Utilization
              averageUtilization: 50       
    ```
1. In order for this to work, the targeted controller needs to include resources limitations or requests (at least):

    ```
    apiVersion: v1
    kind: ReplicationController
    metadata:
      name: httpd-rc
    spec:
      replicas: 2
      selector:
        app: httpd-rc
      template:
        metadata:
          labels:
            app: httpd-rc
        spec:
          containers:
            - name: httpd-container
              image: 'image-registry.openshift-image-registry.svc:5000/openshift/httpd:latest'
              ports:
                - containerPort: 8080
              resources:
                limits:
                  cpu: 1m
                  memory: 40M
                requests:
                  cpu: 1m
                  memory: 40M
              volumeMounts:
                - mountPath: /var/www/html/
                  name: httpd-volume
          initContainers:
            - name: httpd-init
              args:
                - cp -v /etc/hostname index.html
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
# Helm

1. In order to use Helm you need first to download the Openshift client:

    ```
    wget https://downloads-openshift-console.apps.ocp.sebastian-colomar.es/amd64/linux/oc.tar

    tar xf oc.tar

    sudo install oc /usr/local/bin/

    sudo ln -s /usr/local/bin/oc /usr/local/bin/kubectl
    ```
1. Then you need to login into the OCP cluster:

    ```
    oc login --token=sha256~xxx --server=https://api.ocp.sebastian-colomar.es:6443
    ```
1. Now you can download and install helm binary:

    ```
    wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/helm/latest/helm-linux-amd64.tar.gz

    tar xzf helm-linux-amd64.tar.gz

    sudo install helm-linux-amd64 /usr/local/bin/

    sudo ln -s /usr/local/bin/helm-linux-amd64 /usr/local/bin/helm
    ```
1. Create a new Helm chart:

    ```
    helm create phpinfo
    ```
1. View the folder tree created by the previous command:

    ```
    sudo yum install -y tree

    tree phpinfo
    ```
1. Initialize a git repository:

    ```
    cd phpinfo

    git init
    
    git add .
    
    git commit -m Initial

    git checkout -b 0.1.0
    ```
3. Modify the Chart.yaml file:

    ```
    tee Chart.yaml 0<<EOF

    apiVersion: v2
    name: phpinfo
    description: A Helm chart for Kubernetes
    type: application
    version: 0.1.0
    appVersion: "8.1-alpine"

    EOF

    git add Chart.yaml

    git commit -m Chart.yaml
    ```
1. Modify the values.yaml file:

    ```
    tee values.yaml 0<<EOF
    
    replicaCount: 2
    image:
      repository: index.docker.io/library/php
      pullPolicy: IfNotPresent
      tag: "8.1-alpine"
    imagePullSecrets: []
    nameOverride: ""
    fullnameOverride: ""
    serviceAccount:
      create: true
      annotations: {}
      name: ""
    podAnnotations: {}
    podSecurityContext: {}
    securityContext: {}
    service:
      port: 80
      protocol: TCP
      targetPort: 8080
      type: ClusterIP
    ingress:
      enabled: false
      className: ""
      annotations: {}
      hosts:
        - host: chart-example.local
          paths:
            - path: /
              pathType: ImplementationSpecific
      tls: []
    resources:
      limits:
        cpu: 1m
        memory: 20M
      requests:
        cpu: 1m
        memory: 20M
    autoscaling:
      enabled: true
      minReplicas: 1
      maxReplicas: 10
      targetCPUUtilizationPercentage: 50
      targetMemoryUtilizationPercentage: 50
    nodeSelector: {}
    tolerations: []
    affinity: {}
    command:
      - php  
    args:
      - -f
      - index.php
      - -S
      - 0.0.0.0:8080  
    livenessProbe:
      path: index.php  
    readinessProbe:
      path: index.php
  
    EOF

    git add values.yaml

    git commit -m values.yaml
    ```
1. Modify the service.yaml template:

    ```
    tee templates/service.yaml 0<<EOF

    apiVersion: v1
    kind: Service
    metadata:
      name: {{ include "phpinfo.fullname" . }}
      labels:
        {{- include "phpinfo.labels" . | nindent 4 }}
    spec:
      type: {{ .Values.service.type }}
      ports:
        - port: {{ .Values.service.port }}
          targetPort: {{ .Values.service.targetPort }}
          protocol: {{ .Values.service.protocol }}
      selector:
        {{- include "phpinfo.selectorLabels" . | nindent 4 }}

    EOF

    git add templates/service.yaml

    git commit -m templates/service.yaml
    ```    
1. Modify the deployment.yaml template:

    ```
    tee templates/deployment.yaml 0<<EOF

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ include "phpinfo.fullname" . }}
      labels:
        {{- include "phpinfo.labels" . | nindent 4 }}
    spec:
      {{- if not .Values.autoscaling.enabled }}
      replicas: {{ .Values.replicaCount }}
      {{- end }}
      selector:
        matchLabels:
          {{- include "phpinfo.selectorLabels" . | nindent 6 }}
      template:
        metadata:
          {{- with .Values.podAnnotations }}
          annotations:
            {{- toYaml . | nindent 8 }}
          {{- end }}
          labels:
            {{- include "phpinfo.selectorLabels" . | nindent 8 }}
        spec:
          {{- with .Values.imagePullSecrets }}
          imagePullSecrets:
            {{- toYaml . | nindent 8 }}
          {{- end }}
          serviceAccountName: {{ include "phpinfo.serviceAccountName" . }}
          securityContext:
            {{- toYaml .Values.podSecurityContext | nindent 8 }}
          containers:
            - name: {{ .Chart.Name }}
              {{- with .Values.command }}
              command:
                {{- toYaml . | nindent 12 }}
              {{- end }}
              {{- with .Values.args }}
              args:
                {{- toYaml . | nindent 12 }}
              {{- end }}          
              securityContext:
                {{- toYaml .Values.securityContext | nindent 12 }}
              image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
              imagePullPolicy: {{ .Values.image.pullPolicy }}
              ports:
                - containerPort: {{ .Values.service.targetPort }}
                  protocol: {{ .Values.service.protocol }}
              livenessProbe:
                httpGet:
                  path: {{ .Values.livenessProbe.path }}
                  port: {{ .Values.service.targetPort }}
              readinessProbe:
                httpGet:
                  path: {{ .Values.readinessProbe.path }}
                  port: {{ .Values.service.targetPort }}
              resources:
                {{- toYaml .Values.resources | nindent 12 }}
              volumeMounts:
                - name: phpinfo-volume
                  mountPath: /src/
                  readOnly: true
              workingDir: /src/
          initContainers:
            - name: phpinfo-init-container
              args:
                - echo '<?php phpinfo();?>' 1> index.php
              command:
                - sh
                - -c
              image: docker.io/library/busybox:latest
              volumeMounts:
                - name: phpinfo-volume
                  mountPath: /src/
                  readOnly: false
              workingDir: /src/
          volumes:
            - name: phpinfo-volume
              emptyDir:
                medium: Memory
                sizeLimit: 1Mi            
          {{- with .Values.nodeSelector }}
          nodeSelector:
            {{- toYaml . | nindent 8 }}
          {{- end }}
          {{- with .Values.affinity }}
          affinity:
            {{- toYaml . | nindent 8 }}
          {{- end }}
          {{- with .Values.tolerations }}
          tolerations:
            {{- toYaml . | nindent 8 }}
          {{- end }}

    EOF

    git add templates/deployment.yaml

    git commit -m templates/deployment.yaml
    ```            
1. Create a new route.yaml template:

    ```
    tee templates/route.yaml 0<<EOF

    apiVersion: route.openshift.io/v1
    kind: Route
    metadata:
      name: {{ include "phpinfo.fullname" . }}
      labels:
        {{- include "phpinfo.labels" . | nindent 4 }}
    spec:
      to:
        kind: Service
        name: {{ include "phpinfo.fullname" . }}

    EOF

    git add templates/route.yaml

    git commit -m templates/route.yaml
    ```
1. Modify the hpa.yaml template:

    ```
    tee templates/hpa.yaml 0<<EOF

    {{- if .Values.autoscaling.enabled }}
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: {{ include "phpinfo.fullname" . }}
      labels:
        {{- include "phpinfo.labels" . | nindent 4 }}
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: {{ include "phpinfo.fullname" . }}
      minReplicas: {{ .Values.autoscaling.minReplicas }}
      maxReplicas: {{ .Values.autoscaling.maxReplicas }}
      metrics:
        {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
        - type: Resource
          resource:
            name: cpu
            target:
              averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
              type: Utilization
        {{- end }}
        {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
        - type: Resource
          resource:
            name: Memory
            target:
              averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
              type: Utilization
        {{- end }}
    {{- end }}

    EOF

    git add templates/hpa.yaml

    git commit -m templates/hpa.yaml
    ```

3. Deploy the application:

    ```
    oc new-project phpinfo-helm
    
    helm install phpinfo-helm phpinfo
    ```
1. Check the deployment:

    ```
    helm list

    helm history phpinfo-helm
    ```
1. Delete the deployment:

    ```
    helm uninstall phpinfo-helm
    ```
