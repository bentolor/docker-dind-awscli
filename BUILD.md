# Building & Publishing instructions

Mostly notes to myself.

## AMD64

```
$ sudo docker build -t bentolor/docker-dind-awscli "."
$ # note the AWS CLI version output in the build
$ sudo docker tag bentolor/docker-dind-awscli:latest bentolor/docker-dind-awscli:<VERSION>
$ sudo docker push bentolor/docker-dind-awscli:<VERSION>
$ sudo docker push bentolor/docker-dind-awscli:latest
```

## AARCH64 (aka. `linux/arch64/v8`) mostly Apple M1 platform

### One-time preparation for cross-compiling

```
$ sudo apt-get install qemu binfmt-support qemu-user-static 
$ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
$ docker run --rm -t arm64v8/ubuntu uname -m
# Should return: aarch64
```

### Building

```
$ sudo docker build --platform linux/arm64/v8 -f Dockerfile.arm64v8 -t bentolor/docker-dind-awscli "." 
```