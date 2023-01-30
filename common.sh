#!/bin/bash

# Docker
DOCKER=docker
CONFIG="makefile.json"

source $HOME/common/docker/jq.sh

if [ -n "$GITHUB_ACTIONS"  ]
then
    if [ ! -d "/runner/$GITHUB_RUN_ID" ]
    then
        mkdir /runner/$GITHUB_RUN_ID
    fi
fi
