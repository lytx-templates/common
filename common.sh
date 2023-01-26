#!/bin/bash

# Docker
DOCKER=docker
CONFIG="makefile.json"

# jq
JQ_CONTAINER=imega/jq
JQ=$(DOCKER) run -i $(JQ_CONTAINER) -r
