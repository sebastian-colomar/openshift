```
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: app
spec:
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: edge
  to:
    kind: Service
    name: webui
```
```
apiVersion: v1
kind: Service
metadata:
  name: webui
spec:
  ports:
  - 
    port: 80
    targetPort: 9000
  selector:
    app: webui
  type: ClusterIP
```
