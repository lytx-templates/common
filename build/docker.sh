#!/bin/bash

source $HOME/common/common.sh

build_docker () {
    IMAGE_NAME=$(cat $CONFIG | jq .docker.image_name)
    VERSION=$1
    $DOCKER build . -t $IMAGE_NAME:$VERSION
}

build_docker "$1"
