#!/bin/bash

source $HOME/common/common.sh

authenticate() {

}

# Vault
config_vault () {
    VAULT_AUTH_PATH=$(cat $CONFIG | $JQ .vault.auth_path)
    VAULT_RUNNER_ROLE_NAME=$(cat $CONFIG | $JQ .vault.runner_role_name)
    VAULT_ADDR=$(cat $CONFIG | $JQ .vault.addr)
    VAULT_MOUNT=/var/run/secrets/kubernetes.io/serviceaccount/:/var/run/secrets/kubernetes.io/serviceaccount/
    VAULT_CLI=$DOCKER run --privileged -v $VAULT_MOUNT -e VAULT_ADDR=$VAULT_ADDR
}

config_aws () {
    ECR_URI=$(cat $CONFIG | $JQ .aws.ecr.uri)
    ECR_REGION=$(cat $(CONFIG) | $(JQ) .aws.ecr.region)
    AWS_ACCOUNT_ID=$(cat $(CONFIG) | $(JQ) .aws.account_id)
    AWS_ASSUMED_ENV=$(cat $(CONFIG) | $(JQ) .aws.assumed_env)
    AWS_ASSUMED_ROLE_NAME=$(cat $(CONFIG) | $(JQ) .aws.assumed_role_name)
    AWS_ASSUMED_ROLE_TTL=$(cat $(CONFIG) | $(JQ) .aws.assumed_role_ttl)
}

# Authenticate inside of Github Actions
authenticate_actions () {
    BUILD_PATH=/runner/$GITHUB_RUN_ID
	mkdir $BUILD_PATH/.aws
    ln -s $BUILD_PATH/.aws ~/.aws
	VAULT_TOKEN=`$(VAULT_CLI) vault write -format=json auth/$(VAULT_AUTH_PATH)/login role=$(VAULT_RUNNER_ROLE_NAME) jwt=@/var/run/secrets/kubernetes.io/serviceaccount/token | $(JQ) -c '.auth.client_token'` ; \
    ASSUMED_ROLE_CREDS=`$(VAULT_CLI) -e VAULT_TOKEN=$VAULT_TOKEN vault write -format=json aws-$(AWS_ASSUMED_ENV)-$(AWS_ACCOUNT_ID)/sts/$(AWS_ASSUMED_ROLE_NAME) ttl=$(AWS_ASSUMED_ROLE_TTL) | $(JQ) '.'` ; \
    AWS_ACCESS_KEY_ID=`echo $ASSUMED_ROLE_CREDS | $(JQ) '.data.access_key'` ; \
    AWS_SECRET_ACCESS_KEY=`echo $ASSUMED_ROLE_CREDS | $(JQ) '.data.secret_key'` ; \
    AWS_SESSION_TOKEN=`echo $ASSUMED_ROLE_CREDS | $(JQ) '.data.security_token'` ; \
	printf "[default]\naws_access_key_id = $AWS_ACCESS_KEY_ID\naws_secret_access_key = $AWS_SECRET_ACCESS_KEY\naws_session_token = $AWS_SESSION_TOKEN\n" > .aws/credentials
	printf "[default]\nregion=us-west-2\noutput=json\n" > .aws/config
}

# Only run if in actions, otherwise the local .aws directory will be used
if $[ GITHUB_ACTIONS  ]
then
    vault_config
    authenticate_actions
fi
