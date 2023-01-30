#!/bin/bash

source $HOME/common/common.sh

push_ecr () {
    ECR_URI=$(cat $CONFIG | jq .aws.ecr.uri)
    IMAGE_NAME=$(cat $CONFIG | jq .docker.image_name)
    VERSION=$1
    $DOCKER tag $IMAGE_NAME:$VERSION $ECR_URI/$IMAGE_NAME:$VERSION
	$DOCKER tag $IMAGE_NAME:$VERSION $ECR_URI/$IMAGE_NAME:latest
	$DOCKER push $ECR_URI/$IMAGE_NAME:$VERSION
	$DOCKER push $ECR_URI/$IMAGE_NAME:latest
}

push_ecr "$1"
