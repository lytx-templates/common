#!/bin/bash

# Login to ECR
docker_login () {
    export DOCKER_PASSWORD=`$(AWS) ecr get-login-password --region $(ECR_REGION)` ; \
    $(DOCKER) login --username AWS -p $$DOCKER_PASSWORD  $(ECR_URI)
}
