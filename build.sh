#!/bin/sh
sudo docker buildx build --no-cache --platform linux/amd64 -t bentolor/docker-dind-awscli:latest "."
sudo docker buildx build -f Dockerfile.dind --no-cache --platform linux/amd64 -t bentolor/docker-dind-awscli:dind "."

FULLVER=$(sudo docker run -t --rm  bentolor/docker-dind-awscli aws --version)
echo "Full version: $FULLVER"
VER=$(echo $FULLVER | cut -f 1 -d ' ' | cut -f 2 -d '/')
echo "Detected AWS CLI Version: $VER"

sudo docker tag bentolor/docker-dind-awscli:latest bentolor/docker-dind-awscli:$VER 
sudo docker tag bentolor/docker-dind-awscli:dind bentolor/docker-dind-awscli:dind-$VER

echo "Pushing..."
sudo docker push bentolor/docker-dind-awscli:$VER 
sudo docker push bentolor/docker-dind-awscli:dind-$VER
sudo docker push bentolor/docker-dind-awscli:latest
sudo docker push bentolor/docker-dind-awscli:dind