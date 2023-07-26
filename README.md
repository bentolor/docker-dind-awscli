# Docker with Amazon AWS CLI v2.x `awscli`, i.e. for Docker-in-Docker (`dind`)

**`bentolor/docker-dind-awscli` is a drop-in replacement for the `docker` image in situations where you'd also want to use `awscli` at the same time.**
Similarily `bentolor/docker-dind-awscli:dind` is a drop-in replacement for `docker:dind` augmented by  `awscli`. Read section "docker:dind vs. docker:latest"

---

If you face the simple problem that you want to do a simple `aws ecr set-login-password … | docker login …` inside your Docker-based CI pipeline, you might stumble over the following problems:

* The official `docker:latest` Image does not have Python, `pip` or the `aws` tools installed
* The popular `awscli` images do not provide Docker support
* Even **manually installing `awscli`** into `docker:stable` [as described in the official AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html) **does not work,** 

The last point is because `docker:latest` is based on Alpine Liinux and `awscli` does not work on Alpine distribution due to missing glibc libraries.

This repository reflects a workaround as described by @blagerweij in [this upstream issue](https://github.com/aws/aws-cli/issues/4685#issuecomment-615872019). Basically it

1. Starts of `docker:latest`
2. Downloads & install glibc libraries for Apline from https://github.com/sgerrand/alpine-pkg-glibc/
3. Downloads & insstalls `awscli` using the method described in https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html

## Example: Building & Pushing Containers inside Gitlab CI via `.gitlab-ci.yml`

This synthetical example pulls a docker image by SHA1 from the Gitlab container repository and then pushes it to an ECR instance. 

```yaml
deploy:api:ecr-image:
  image: bentolor/docker-dind-awscli
  services:
    - name: docker:dind 
  stage: publish-aws
  script:
    # Fetch local docker image, rename & push to target environment
    - docker info
    - docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN gitlab.foo.bar:4567
    - docker pull $LOCAL_IMAGE_NAME:$CI_COMMIT_SHA
    - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REPOSITORY_HOST_API
    - docker tag $LOCAL_IMAGE_NAME:$CI_COMMIT_SHA $REPOSITORY_HOST_API/myservice:latest
    - docker push $REPOSITORY_HOST_API/myservice:latest
  only:
  - master
```
Note: Using the `services`-Tag we start a separate _dind_ container running the actual docker daemon. Gitlab CI automatically passes the required `DOCKER_HOST`, so that the `docker`-Client talks to that _dind_ container.


## Upgrade Notes
Since 2021-10-15 this image no longer is based on the [no longer maintained `docker:stable` tag (Docker v19)](https://github.com/docker-library/docker/issues/301) but now is based on the `docker:latest` tag. If this broke your build you might quick-resort into using `bentolor/docker-dind-awscli:2.2.36`.

## docker:dind vs. docker:latest
Please note, that while this image is called `docker-dind-awscli`, the `bentolor/docker-dind-awscli` image itself **is not meant as replacement for `docker:dind`**, but for `docker:latest`.

**Short explanation:** `docker:dind` is an image, which allows to run an _additional_ Docker daemon inside another Docker daemon. Therefore _Docker-in-Docker_, or short: _dind_. Containers based on this image expose a new Docker daemon instance via TCP sockets at port `2375` and `2376` (SSL/TLS). 

The general idea here is, that instead of using and exposing your host Docker, you now can run a separate Docker _dind_ daemon _inside_ your Docker installation. For example to build images inside you CI/CD, which itself might run as Docker container.  This approach avoids opening and directly exposing your host daemon, therefore less threatening your overall host security.

On the other hand, the `docker` command itself is _only a client_. The `DOCKER_HOST` defines to which Docker daemon it talks to. By default the `docker` client tries to directly access your local Docker daemon installation. 

So there are to approaches to use Docker-in-Docker:

1. You start a separate `docker:dind` container while running your `docker` and `awscli` client commands in a separate container based on `docker:latest`. There `DOCKER_HOST` must point to the _dind_ container. This is the recommended way and is shown in the Gitlab CI example. To use `aws` commands, i.e. along with `docker build …` commands, you'd replace the `docker:latest` image with `bentolor/docker-dind-awscli`.

2. You start a `docker:dind` container and run you `docker` client commands _inside_ that nested Docker installation. In that case `bentolor/docker-dind-awscli:dind` would replace `docker:dind`, if you want to use `aws` commands, i.e. along with `docker build …` commands.
