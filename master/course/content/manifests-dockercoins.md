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
```
apiVersion: v1
kind: Service
metadata:
  name: rng
spec:
  ports:
  - 
    port: 80
    targetPort: 9000
  selector:
    app: hasher
  type: ClusterIP
```
```
apiVersion: v1
kind: Service
metadata:
  name: hasher
spec:
  ports:
  - 
    port: 80
    targetPort: 9000
  selector:
    app: hasher
  type: ClusterIP
```
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: worker
data:
  worker.py: |
    import logging
    import os
    from redis import Redis
    import requests
    import time
    
    DEBUG = os.environ.get("DEBUG", "").lower().startswith("y")
    
    log = logging.getLogger(__name__)
    if DEBUG:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)
        logging.getLogger("requests").setLevel(logging.WARNING)
    
    
    redis = Redis("redis")
    
    
    def get_random_bytes():
        # Se mantiene puerto 80 para el service
        r = requests.get("http://rng/32")
        return r.content
    
    
    def hash_bytes(data):
        r = requests.post("http://hasher/",
                          data=data,
                          headers={"Content-Type": "application/octet-stream"})
        hex_hash = r.text
        return hex_hash
    
    
    def work_loop(interval=1):
        deadline = 0
        loops_done = 0
        while True:
            if time.time() > deadline:
                log.info("{} units of work done, updating hash counter"
                         .format(loops_done))
                redis.incrby("hashes", loops_done)
                loops_done = 0
                deadline = time.time() + interval
            work_once()
            loops_done += 1
    
    
    def work_once():
        log.debug("Doing one unit of work")
        time.sleep(0.1)
        random_bytes = get_random_bytes()
        hex_hash = hash_bytes(random_bytes)
        if not hex_hash.startswith('0'):
            log.debug("No coin found")
            return
        log.info("Coin found: {}...".format(hex_hash[:8]))
        created = redis.hset("wallet", hex_hash, random_bytes)
        if not created:
            log.info("We already had that coin")
    
    
    if __name__ == "__main__":
        while True:
            try:
                work_loop()
            except:
                log.exception("In work loop:")
                log.error("Waiting 10s and restarting.")
                time.sleep(10)
```
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: webui
data:
  webui.js: |
    var express = require('express');
    var app = express();
    var redis = require('redis');
    
    var client = redis.createClient(6379, 'redis');
    client.on("error", function (err) {
        console.error("Redis error", err);
    });
    
    app.get('/', function (req, res) {
        res.redirect('/index.html');
    });
    
    app.get('/json', function (req, res) {
        client.hlen('wallet', function (err, coins) {
            client.get('hashes', function (err, hashes) {
                var now = Date.now() / 1000;
                res.json( {
                    coins: coins,
                    hashes: hashes,
                    now: now
                });
            });
        });
    });
    
    app.use(express.static('files'));
    
    var server = app.listen(9000, function () {
        console.log('WEBUI running on port 9000');
    });
```
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: rng
data:
  rng.py: |
    from flask import Flask, Response
    import os
    import socket
    import time
    
    app = Flask(__name__)
    
    # Enable debugging if the DEBUG environment variable is set and starts with Y
    app.debug = os.environ.get("DEBUG", "").lower().startswith('y')
    
    hostname = socket.gethostname()
    
    urandom = os.open("/dev/urandom", os.O_RDONLY)
    
    
    @app.route("/")
    def index():
        return "RNG running on {}\n".format(hostname)
    
    
    @app.route("/<int:how_many_bytes>")
    def rng(how_many_bytes):
        # Simulate a little bit of delay
        time.sleep(0.1)
        return Response(
            os.read(urandom, how_many_bytes),
            content_type="application/octet-stream")
    
    
    if __name__ == "__main__":
        app.run(host="0.0.0.0", port=9000)
```
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: hasher
data:
  hasher.rb: |
    require 'digest'
    require 'sinatra'
    require 'socket'
    
    set :bind, '0.0.0.0'
    set :port, 9000
    
    post '/' do
        # Simulate a bit of delay
        sleep 0.1
        content_type 'text/plain'
        "#{Digest::SHA2.new().update(request.body.read)}"
    end
    
    get '/' do
        "HASHER running on #{Socket.gethostname}\n"
    end
```
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webui
spec:
  replicas: 6
  selector:
    matchLabels:
      app: webui
  template:
    metadata:
      labels:
        app: webui
    spec:
      containers:
      - 
        command:
        - node
        - webui.js
        image: docker.io/academiaonline/dockercoins-webui:2.0
        name: webui
        ports:
        -
          containerPort: 9000
          protocol: TCP
        resources:
          limits:
            cpu: 40m
            memory: 40M
          requests:
            cpu: 20m
            memory: 20M
        securityContext:
          readOnlyRootFilesystem: true
        volumeMounts:
        - 
          mountPath: /var/data/webui.js
          name: webui
          readOnly: true
          subPath: webui.js
        - 
          mountPath: /var/data/files/
          name: files
          readOnly: true
        workingDir: /var/data/
      imagePullSecrets:
      - name: docker
      initContainers:
      -
        command:
        - sh
        - -c
        - set -x;rm -rf dockercoins/;git clone -b main --single-branch https://github.com/sebastian-colomar/dockercoins;cp -rv dockercoins/cchillida/webui/files/* /var/data/files/
        image: docker.io/bitnami/git:latest
        name: init
        volumeMounts:
        -
          mountPath: /var/data/clone/
          name: clone
          readOnly: false
        -
          mountPath: /var/data/files/
          name: files
          readOnly: false
        workingDir: /var/data/clone/
      topologySpreadConstraints:
      -
        labelSelector:
          matchLabels:
            app: webui
        maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
      -
        labelSelector:
          matchLabels:
            app: webui
        maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
      volumes:
      - 
        configMap:
          defaultMode: 0400
          items: 
          -
            key: webui.js
            mode: 0400
            path: webui.js
          name: webui
        name: webui
      -
        emptyDir:
          medium: Memory
          sizeLimit: 1Mi
        name: files
      -
        emptyDir:
          medium: Memory
          sizeLimit: 2Mi
        name: clone
```
```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - 
        image: docker.io/library/redis:latest
        name: redis
        ports:
        - 
          containerPort: 6379
          protocol: TCP
        volumeMounts:
        -
          mountPath: /data/
          name: redis
          readOnly: false
        workingDir: /data/
      imagePullSecrets:
      - name: docker
  volumeClaimTemplates:
  - 
    metadata:
      name: redis
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
```
```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: rng
spec:
  selector:
    matchLabels:
      app: rng
  template:
    metadata:
      labels:
        app: rng
    spec:
      containers:
      - 
        command:
        - python
        - rng.py
        image: docker.io/academiaonline/dockercoins-rng:0.1
        name: rng
        ports:
        - 
          containerPort: 9000
          protocol: TCP
        volumeMounts:
        -
          mountPath: /var/data/rng.py
          name: rng
          readOnly: true
          subPath: rng.py
        workingDir: /var/data/
      imagePullSecrets:
      - name: docker
      volumes:
      -
        configMap:
          defaultMode: 0400
          items:
          -
            key: rng.py
            mode: 0400
            path: rng.py
          name: rng
        name: rng
```
