# Docker for Docker-in-Docker (`dind`) with Amazon AWS CLI `awscli`

If you face the simple problem that you want to do a simple `aws ecr set-login-password … | docker login …` inside your Docker-based CI pipeline, you might stumble over the following problems:

* The official `docker:stable` Image does not have Python, `pip` or the `aws` tools installed
* The popular `awscli` images do not provide Docker support
* Even **manually installing `awscli`** into `docker:stable` [as described in the official AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html) **does not work,** 

The last point is because `docker:stable` is based on Alpine Liinux and `awscli` does not work on Alpine distribution due to missing glibc libraries.

This repository reflects a workaround as described by @blagerweij in [this upstream issue](https://github.com/aws/aws-cli/issues/4685#issuecomment-615872019). Basically it

1. Starts of `docker:latest`
2. Downloads & install glibc libraries for Apline from https://github.com/sgerrand/alpine-pkg-glibc/
3. Downloads & insstalls `awscli´ using the method described in https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
