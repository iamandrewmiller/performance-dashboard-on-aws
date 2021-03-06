#!/bin/bash
set -e

# Set workspace paths
WORKSPACE=$(pwd)
CDK_DIR=$WORKSPACE/cdk
FRONTEND_DIR=$WORKSPACE/frontend
BACKEND_DIR=$WORKSPACE/backend

# Validate environment name from input
environment=$1
if [ "$environment" != "" ]; then
    echo "Environment = $environment"
    export CDK_ENV_NAME=$environment
else
    echo "Please specify environment name as first argument (i.e. dev)"
    exit 0
fi

verify_prereqs() {
    # Verify necessary commands
    echo "node version"
    node --version
    echo "npm version"
    npm --version
    echo "cdk version"
    cdk --version
}

create_build_directories() {
    # CDK complains if the backend/build and frontend/build
    # directories don't exist during synth. So we need to trick
    # CDK by creating empty directories for now. Later on, these
    # directories will be populated by building the backend and 
    # frontend for real.
    mkdir -p $FRONTEND_DIR/build
    mkdir -p $BACKEND_DIR/build
}

deploy_auth() {
    # Deploys the Authentication stack with CDK.
    # Auth stack definition is in cdk/lib/auth-stack.ts
    echo "Deploying auth stack"
    cd $CDK_DIR
    cdk deploy Auth --require-approval never
}

deploy_backend() {
    echo "Building backend application"
    cd $BACKEND_DIR
    npm run build

    cd $CDK_DIR
    echo "Deploying backend stack"
    cdk deploy Backend --require-approval never --outputs-file outputs-backend.json
}

deploy_frontend() {
    echo "Building frontend application"
    cd $FRONTEND_DIR
    yarn build

    cd $CDK_DIR
    cdk deploy Frontend --require-approval never
    echo "Deploying frontend stack"
}

deploy_ops() {
    echo "Deploying ops stack"
    cd $CDK_DIR
    cdk deploy Ops --require-approval never
}

build_cdk() {
    cd $CDK_DIR
    npm run build
}

# Start execution
verify_prereqs
create_build_directories
build_cdk
deploy_auth
deploy_backend
deploy_frontend
deploy_ops
