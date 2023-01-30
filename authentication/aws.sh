#!/bin/bash

source $HOME/common/common.sh
source $HOME/common/docker/aws.sh

authenticate() {
    :
}

config_vault () {
    VAULT_AUTH_PATH=$(cat $CONFIG | jq .vault.auth_path)
    VAULT_RUNNER_ROLE_NAME=$(cat $CONFIG | jq .vault.runner_role_name)
    VAULT_ADDR=$(cat $CONFIG | jq .vault.addr)
    VAULT_MOUNT=/var/run/secrets/kubernetes.io/serviceaccount/:/var/run/secrets/kubernetes.io/serviceaccount/
    VAULT_CLI="$DOCKER run --privileged -v $VAULT_MOUNT -e VAULT_ADDR=$VAULT_ADDR"
}

config_aws () {
    ECR_URI=$(cat $CONFIG | jq .aws.ecr.uri)
    ECR_REGION=$(cat $CONFIG | jq .aws.ecr.region)
    AWS_ACCOUNT_ID=$(cat $CONFIG | jq .aws.account_id)
    AWS_ASSUMED_ENV=$(cat $CONFIG | jq .aws.assumed_env)
    AWS_ASSUMED_ROLE_NAME=$(cat $CONFIG | jq .aws.assumed_role_name)
    AWS_ASSUMED_ROLE_TTL=$(cat $CONFIG | jq .aws.assumed_role_ttl)
}

config_build_path () {
    BUILD_PATH=/runner/$GITHUB_RUN_ID
}

# Authenticate inside of Github Actions
authenticate_actions () {
	mkdir $BUILD_PATH/.aws
    ln -s $BUILD_PATH/.aws ~/.aws
    VAULT_TOKEN=$($VAULT_CLI vault write -format=json auth/$VAULT_AUTH_PATH/login role=$VAULT_RUNNER_ROLE_NAME jwt=@/var/run/secrets/kubernetes.io/serviceaccount/token | jq '.auth.client_token')
    ASSUMED_ROLE_CREDS=$($VAULT_CLI -e VAULT_TOKEN=$VAULT_TOKEN vault write -format=json aws-$AWS_ASSUMED_ENV-$AWS_ACCOUNT_ID/sts/$AWS_ASSUMED_ROLE_NAME ttl=$AWS_ASSUMED_ROLE_TTL | jq '.')
    AWS_ACCESS_KEY_ID=$(echo $ASSUMED_ROLE_CREDS | jq '.data.access_key')
    AWS_SECRET_ACCESS_KEY=$(echo $ASSUMED_ROLE_CREDS | jq '.data.secret_key')
    AWS_SESSION_TOKEN=$(echo $ASSUMED_ROLE_CREDS | jq '.data.security_token')
	printf "[default]\naws_access_key_id = $AWS_ACCESS_KEY_ID\naws_secret_access_key = $AWS_SECRET_ACCESS_KEY\naws_session_token = $AWS_SESSION_TOKEN\n" > ~/.aws/credentials
	printf "[default]\nregion=us-west-2\noutput=json\n" > ~/.aws/config
}

# Only run if in actions, otherwise the local .aws directory will be used
if [ -n "$GITHUB_ACTIONS"  ]
then
    config_build_path
    config_vault
    config_aws
    authenticate_actions
else 
    authenticate
fi
