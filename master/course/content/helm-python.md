1. Create a new Helm chart:

    ```
    helm create python
    ```
1. View the folder tree created by the previous command:

    ```
    ls -lR python
    ```
1. Initialize a git repository:

    ```
    cd python

    git init
    
    git add .
    
    git commit -m Initial

    git checkout -b 0.1.0
    ```
3. Modify the Chart.yaml file:

    ```
    tee Chart.yaml 0<<EOF

    apiVersion: v2
    name: python
    description: A Helm chart for Kubernetes
    type: application
    version: 0.1.0
    appVersion: "alpine"

    EOF

    git add Chart.yaml

    git commit -m Chart.yaml
    ```
1. Modify the values.yaml file:

    ```
    tee values.yaml 0<<EOF
    
    replicaCount: 2
    image:
      repository: docker.io/library/python
      pullPolicy: IfNotPresent
      tag: "alpine"
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
      targetPort: 9000
      type: ClusterIP
    resources:
      limits:
        cpu: 40m
        memory: 40M
      requests:
        cpu: 20m
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
      - python  
      - -m
      - http.server
      - '9000'  
    livenessProbe:
      path: index.html  
    readinessProbe:
      path: index.html
  
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
      name: {{ include "python.fullname" . }}
      labels:
        {{- include "python.labels" . | nindent 4 }}
    spec:
      type: {{ .Values.service.type }}
      ports:
        - port: {{ .Values.service.port }}
          targetPort: {{ .Values.service.targetPort }}
          protocol: {{ .Values.service.protocol }}
      selector:
        {{- include "python.selectorLabels" . | nindent 4 }}

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
      name: {{ include "python.fullname" . }}
      labels:
        {{- include "python.labels" . | nindent 4 }}
    spec:
      {{- if not .Values.autoscaling.enabled }}
      replicas: {{ .Values.replicaCount }}
      {{- end }}
      selector:
        matchLabels:
          {{- include "python.selectorLabels" . | nindent 6 }}
      template:
        metadata:
          {{- with .Values.podAnnotations }}
          annotations:
            {{- toYaml . | nindent 8 }}
          {{- end }}
          labels:
            {{- include "python.selectorLabels" . | nindent 8 }}
        spec:
          {{- with .Values.imagePullSecrets }}
          imagePullSecrets:
            {{- toYaml . | nindent 8 }}
          {{- end }}
          serviceAccountName: {{ include "python.serviceAccountName" . }}
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
                - name: python-volume
                  mountPath: /src/
                  readOnly: true
              workingDir: /src/
          initContainers:
            - name: python-init-container
              args:
                - echo 'Hello world!' 1> index.html
              command:
                - sh
                - -c
              image: docker.io/library/busybox:latest
              volumeMounts:
                - name: python-volume
                  mountPath: /src/
                  readOnly: false
              workingDir: /src/
          volumes:
            - name: python-volume
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
      name: {{ include "python.fullname" . }}
      labels:
        {{- include "python.labels" . | nindent 4 }}
    spec:
      to:
        kind: Service
        name: {{ include "python.fullname" . }}

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
      name: {{ include "python.fullname" . }}
      labels:
        {{- include "python.labels" . | nindent 4 }}
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: {{ include "python.fullname" . }}
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
    oc new-project python-helm
    
    helm install python-helm .
    ```
1. Check the deployment:

    ```
    helm list

    helm history python-helm
    ```
1. Delete the deployment:

    ```
    helm uninstall python-helm
    ```
