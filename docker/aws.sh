#!/bin/bash

aws () { 
    AWS_CONTAINER=amazon/aws-cli
    AWS_WORKING_PATH=/aws
    $DOCKER run -v $HOME/.aws:/root/.aws:rw $AWS_CONTAINER
}
