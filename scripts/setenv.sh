#!/usr/bin/env bash
set -e
echo "Setting environment"
source .env
export TNS_ADMIN=$TNS_ADMIN
export TNS_SERVICE=$TNS_SERVICE
export DB_URL=$DB_URL
export ADMIN_USER=$ADMIN_USER
export ADMIN_PASSWORD=$ADMIN_PASSWORD
export DEV_USER=$DEV_USER
export DEV_PASSWORD=$DEV_PASSWORD
export PRE_USER=$PRE_USER
export PRE_PASSWORD=$PRE_PASSWORD
echo "Environment set"




