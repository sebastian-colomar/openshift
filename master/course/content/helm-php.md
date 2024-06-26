1. Create a new Helm chart:

    ```
    helm create phpinfo
    ```
1. View the folder tree created by the previous command:

    ```
    ls -lR phpinfo
    ```
1. Change directory to the repository:

    ```
    cd phpinfo
    ```
3. Modify the Chart.yaml file:

    ```
    tee Chart.yaml 0<<EOF

    apiVersion: v2
    name: phpinfo
    description: Helm chart for PHP webserver
    type: application
    version: 0.1.0
    appVersion: "alpine"

    EOF
    ```
1. Modify the values.yaml file:

    ```
    tee values.yaml 0<<EOF
    
    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        -
          labelSelector:
            matchExpressions:
            -
              key: ha
              operator: In
              values:
              - 'true'
          topologyKey: topology.kubernetes.io/zone
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 20
      targetCPUUtilizationPercentage: 50
      targetMemoryUtilizationPercentage: 50
    command:
      - php  
      - -f
      - index.php
      - -S
      - 0.0.0.0:9000  
    image:
      repository: docker.io/library/php
      pullPolicy: IfNotPresent
    imagePullSecret:
      name: docker
    service:
      port: 80
      protocol: TCP
      targetPort: 9000
      type: ClusterIP
    replicaCount: 2
    resources:
      limits:
        cpu: 40m
        memory: 40M
      requests:
        cpu: 20m
        memory: 20M
    livenessProbe:
      path: index.php  
    readinessProbe:
      path: index.php
  
    EOF
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
          imagePullSecrets:
          - name: {{ .Values.imagePullSecret.name }}
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
    ```
1. Remove the ingress template:
    ```
    rm templates/ingress.yaml
    ```
1. Remove the service account template:
    ```
    rm templates/serviceaccount.yaml
    ```
1. Remove the notes text file:
    ```
    rm templates/NOTES.txt
    ```    
3. Deploy the application:

    ```
    oc new-project phpinfo-helm
   
    helm install phpinfo-helm .
    ```
1. Check the deployment:

    ```
    helm list

    helm history phpinfo-helm
    ```
1. Upgrade the deployment:
    ```
    helm upgrade phpinfo-helm .
    ```
1. Delete the deployment:

    ```
    helm uninstall phpinfo-helm
    ```
