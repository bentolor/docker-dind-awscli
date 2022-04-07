#!/bin/bash
function deploy_image(){
    cluster_name=$1
    service_name=$2
    TASK_DEF_FAMILY_NAME=$3
    NEW_IMAGE=$4
    TASK_ARN=$(aws ecs describe-services --service $service_name --cluster $cluster_name | jq ".services[].taskDefinition" | sed -e 's/^"//' -e 's/"$//')
    aws ecs describe-task-definition --task-definition $TASK_ARN>describe-task.json
    sed -i -e "s|\"image\".*|\"image\":\"$NEW_IMAGE\"\,|g" describe-task.json
    CONTAINER_DEFS=$(cat describe-task.json | jq ".taskDefinition.containerDefinitions")
    echo "{\"containerDefinitions\":$CONTAINER_DEFS}" | cat>container-def.json
    NEW_TASK_DEF_VERSION=$(aws ecs register-task-definition --family $TASK_DEF_FAMILY_NAME --cli-input-json file://container-def.json | jq ".taskDefinition.revision")
    aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition "$TASK_DEF_FAMILY_NAME:$NEW_TASK_DEF_VERSION" --force-new-deployment
}