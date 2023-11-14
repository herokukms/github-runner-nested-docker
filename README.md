# alpine-nested-qemu-docker
## Why this strange  idea ?
Because most of docker container can't run in a privileged environment and so cannot run Docker.  
This Docker image runs an Alpine linux in a QEMU virtual machine so the docker daemon runs like in a real machine. 

# How to
```sh
docker run -it -v ./entrypoint:/ext/entrypoint eltorio/alpine-nested-qemu-docker  
```
`./entrypoint` is a mandatory shell script. It will be run after docker and ntpd services in the Alpine virtual machine

# Demo
For launching busybox:latest in the non privileged image:
```sh
make build
make demo
```

# Connect to nested Alpine
While connected to the qemu container you can reach the nested Alpine vm with
```sh
telnet localhost
```
hit enter and connect as root
For leaving telnet hit CTRL+$ and quit

# Kubernetes sample deployement
This launch 10 replicas of busybox:latest on Kubernetes
```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: heartbeat
  namespace: 
type: Opaque
stringData:
  now: "1698685516"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: entrypoint
data:
  entrypoint: |
    #!/bin/sh
    while (! docker stats --no-stream ); do
      # Docker takes a few seconds to initialize
      echo "Waiting for Docker to launch..."
      sleep 1
    done
    docker run -it busybox:latest
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: busybox-tester
  labels:
    app: busybox-tester
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox-tester
  template:
    metadata:
      labels:
        app: busybox-tester
    spec:
      containers:
      - name: busybox-tester
        image: eltorio/alpine-nested-qemu-docker:latest
        volumeMounts:
        - name: entrypoint
          mountPath: /ext
        env:
          - name: TIMESTAMP
            value: "1698685516"
#        securityContext:
#          privileged: true
      volumes:
      - name: entrypoint
        configMap: 
          name: entrypoint
          defaultMode: 0777
```