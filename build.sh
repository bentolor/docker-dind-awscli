#!/bin/sh
set -exu
sudo docker buildx build --platform linux/amd64 -t bentolor/docker-dind-awscli:latest "."
sudo docker buildx build -f Dockerfile.dind --platform linux/amd64 -t bentolor/docker-dind-awscli:dind "."

FULLVER=$(sudo docker run -t --rm  bentolor/docker-dind-awscli aws --version)
#echo "AWS CLI complete versionstring: $FULLVER"
VER=$(echo $FULLVER | cut -f 1 -d ' ' | cut -f 2 -d '/')
#echo "Extracted AWS CLI Version: $VER"
DOCKERFULLVER=$(sudo docker run -t --rm  bentolor/docker-dind-awscli docker --version)
#echo "Docker CLI complete versionstring: $VER"
DOCKERVER=$(echo $DOCKERFULLVER | cut -f 3 -d ' ' | cut -f 1 -d ',')
#echo "Extracted Docker CLI Version: $DOCKERVER"

#echo "Tagging bentolor/docker-dind-awscli:$VER-$DOCKERVER"
sudo docker tag bentolor/docker-dind-awscli:latest bentolor/docker-dind-awscli:$VER-docker-$DOCKERVER
#echo "Tagging bentolor/docker-dind-awscli:dind-$VER-$DOCKERVER"
sudo docker tag bentolor/docker-dind-awscli:dind bentolor/docker-dind-awscli:$VER-dind-$DOCKERVER

sudo docker push bentolor/docker-dind-awscli:$VER-docker-$DOCKERVER
sudo docker push bentolor/docker-dind-awscli::$VER-dind-$DOCKERVER
sudo docker push bentolor/docker-dind-awscli:latest
sudo docker push bentolor/docker-dind-awscli:dind