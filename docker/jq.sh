#!/bin/bash

jq () {
    JQ_CONTAINER=imega/jq
    $DOCKER run -i $JQ_CONTAINER -r $1
}
