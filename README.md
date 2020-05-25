# Docker for Docker-in-Docker (`dind`) with Amazon AWS CLI `awscli`

If you face the simple problem that you want to to a simple `aws ecr set-login-password … | docker login …` inside your Docker-based CI you stumble over the following problems:

* The official `docker:stable` Image does not contain Python, `pip` or `aws` CLI tool installed
* The popular `awscli` images do not have Docker support
* **Even manually installing `awscli` into `docker:stable` [as described in the official AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html) does not work,** 

The last point is because `docker:stable` is based on Alpine Liinux, and awscli does not work on Alpine distribution due to missing glibc libraries.

This repository reflects a workaround as described by @blagerweij in [this upstream issue](https://github.com/aws/aws-cli/issues/4685#issuecomment-615872019)