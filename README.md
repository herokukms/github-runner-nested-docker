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