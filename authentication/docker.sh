#!/bin/bash

source $HOME/common/common.sh

# Login to ECR
docker_login () {
    ECR_REGION=$(cat $CONFIG | jq .aws.ecr.region)
    ECR_URI=$(cat $CONFIG | jq .aws.ecr.uri)
    DOCKER_PASSWORD=$(aws ecr get-login-password --region $ECR_REGION)
    $DOCKER login --username AWS -p $DOCKER_PASSWORD  $ECR_URI
}

docker_login
