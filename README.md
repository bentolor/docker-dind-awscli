# Docker for Docker-in-Docker (`dind`) with Amazon AWS CLI `awscli`

**`bentolor/docker-dind-awscli` is a drop-in replacement for `docker:stable` in situations where you'd also want to use `awscli` at the same time.**

If you face the simple problem that you want to do a simple `aws ecr set-login-password … | docker login …` inside your Docker-based CI pipeline, you might stumble over the following problems:

* The official `docker:stable` Image does not have Python, `pip` or the `aws` tools installed
* The popular `awscli` images do not provide Docker support
* Even **manually installing `awscli`** into `docker:stable` [as described in the official AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html) **does not work,** 

The last point is because `docker:stable` is based on Alpine Liinux and `awscli` does not work on Alpine distribution due to missing glibc libraries.

This repository reflects a workaround as described by @blagerweij in [this upstream issue](https://github.com/aws/aws-cli/issues/4685#issuecomment-615872019). Basically it

1. Starts of `docker:latest`
2. Downloads & install glibc libraries for Apline from https://github.com/sgerrand/alpine-pkg-glibc/
3. Downloads & insstalls `awscli´ using the method described in https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html

## Example usage for illustration: `.gitlab-ci.yml`

A synthetical example pulling a docker image by SHA1 from gitlab repository and pushing it to an ECR instance. 

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
