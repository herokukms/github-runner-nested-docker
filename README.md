# github-runner-nested-docker

This is a modified **alpine-nested-qemu-docker** for running **[myoung34/github-runner:ubuntu-jammy](https://github.com/myoung34/docker-github-actions-runner)** in a Docker container without privileged mode.

## How to ?

This is a sample Kubernetes manifest for deploying it:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: heartbeat
  namespace: sandbox-github-runner
type: Opaque
stringData:
  now: "19820002"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: entrypoint
  namespace: sandbox-github-runner
data:
  entrypoint: |
    #!/bin/sh
    while (! docker stats --no-stream ); do
      # Docker takes a few seconds to initialize
      echo "Waiting for Docker to launch..."
      sleep $((`od -vAn -N2 -tu2 < /dev/urandom` %15))
    done
    docker run -e ACCESS_TOKEN=kfNKfcRR7rYAUebw31o= -e ORG_NAME=herokukms -e RUNNER_GROUP=Docker-runners -e RUNNER_SCOPE=org -e RUNNER_NAME_PREFIX=heroku  -e TIMESTAMP=19820002 myoung34/github-runner:ubuntu-jammy
---
apiVersion: apps/v1
#kind: Deployment
kind: StatefulSet
metadata:
  name: herokukms-runner
  namespace: sandbox-github-runner
  labels:
    app: herokukms-runner
spec:
  replicas: 9
  #strategy:
  #  type: Recreate
  selector:
    matchLabels:
      app: herokukms-runner
  template:
    metadata:
      labels:
        app: herokukms-runner
    spec:
      containers:
      - name: herokukms-runner
        image: herokukms/github-runner-nested:1.0.0
        volumeMounts:
        - name: entrypoint
          mountPath: /ext
        env:
          - name: ACCESS_TOKEN
            value: kfNKfcRR7rYAUebw31o=
          - name: ORG_NAME
            value: herokukms
          - name: RUNNER_GROUP
            value: Docker-runners
          - name: RUNNER_SCOPE
            value: org
          - name: TIMESTAMP
            value: "19820002"
          - name: RANDOM_RUNNER_SUFFIX
            value: "hostname"
          - name: QEMU_CPU
            value: "1"
          - name: QEMU_RAM
            value: "2048"
          - name: UPDATED                      
            value: "19820002"
#        securityContext:
#          privileged: true
      volumes:
      - name: entrypoint
        configMap: 
          name: entrypoint
          defaultMode: 0777
```

## alpine-nested-qemu-docker

## Why this strange  idea ?

Because most of docker container can't run in a privileged environment and so cannot run Docker.  
This Docker image runs an Alpine linux in a QEMU virtual machine so the docker daemon runs like in a real machine.

## How to

```sh
docker run -it -v ./entrypoint:/ext/entrypoint eltorio/alpine-nested-qemu-docker  
```

`./entrypoint` is a mandatory shell script. It will be run after docker and ntpd services in the Alpine virtual machine

## Demo

For launching busybox:latest in the non privileged image:

```sh
make build
make demo
```

## Connect to nested Alpine

While connected to the qemu container you can reach the nested Alpine vm with

```sh
telnet localhost
```

hit enter and connect as root
For leaving telnet hit CTRL+$ and quit

## Kubernetes sample deployement

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
