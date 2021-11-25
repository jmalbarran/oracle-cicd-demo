#!/usr/bin/env bash

# Initialize script
set -e
## Change current directory to current script. Rest of actions relative to current script
CURDIR=$(cd $(dirname "$0"); pwd -P)
cd "${CURDIR}"
## Set environment
source setenv.sh

# Execute script
echo "Initializing demo components: Creating database users/schemas"
${CURDIR}/disconnect-sessions.sh ${DEV_USER}
${CURDIR}/disconnect-sessions.sh ${PRE_USER}
sql -S ${ADMIN_USER}/${ADMIN_PASSWORD}@${TNS_SERVICE} @create_users.sql $DEV_USER $DEV_PASSWORD $PRE_USER $PRE_PASSWORD

# Create git environments
echo "Initializing demo components: Creating environments origin (simulating remote origin), dev and pre"
rm -rf ../environments
mkdir -p ../environments


echo "Initializing origin environment (simulated in local environment/origin)"
git init ../environments/origin
cp ../initial/initial_gitignore ../environments/origin/.gitignore
cd ../environments/origin
git add .gitignore 
git commit -m "First commit"
git branch pre
git branch dev

## Set pre enviroment cloning from origin
echo "Setting PRE enviroment: Pulling from origin"
cd ..
git clone origin/.git pre
cd pre
git checkout -b pre 
git branch --set-upstream-to=origin/pre pre
cd "${CURDIR}"
## Set environment variables for pre
echo "Setting PRE enviroment: Setting environment variables for PRE"
cp -r ../v0/setenv.sh ../environments/pre
chmod +x ../environments/pre/setenv.sh
cd ../environments/pre

## Setpre  environment variables 
echo "TNS_ADMIN=${TNS_ADMIN}" >.env
echo "DB_USER=${PRE_USER}" >>.env
echo "DB_PASSWORD=${PRE_PASSWORD}" >>.env
echo "DB_URL=${DB_URL}" >>.env
echo "TNS_SERVICE=${TNS_SERVICE}" >>.env

## Set dev environment cloning from origin
echo "Setting DEV enviroment: Pulling from origin"
cd ..
git clone origin/.git dev
cd dev
git checkout -b dev 
git branch --set-upstream-to=origin/dev dev

## Set environment variables for dev
echo "Setting DEV enviroment: Setting environment variables for DEV"
echo "TNS_ADMIN=${TNS_ADMIN}" >.env
echo "DB_USER=${DEV_USER}" >>.env
echo "DB_PASSWORD=${DEV_PASSWORD}" >>.env
echo "DB_URL=${DB_URL}" >>.env
echo "TNS_SERVICE=${TNS_SERVICE}" >>.env


# Deploy version v0 of application to dev environment
echo "Deploying initial version as v0"
cd "${CURDIR}"
cp -r ../v0/* ../environments/dev

# Initial code (Product table, Greeting and ProductCount functions)
sql -S ${DEV_USER}/${DEV_PASSWORD}@${TNS_SERVICE} @../environments/dev/database/scripts/initialize.sql

# Publish version v0 and deploy en PRE environment
cd "${CURDIR}"
./dev-publish-version.sh v0
./pre-deploy-version-in-test.sh v0
./pre-deploy-version-for-all.sh

echo "Success: Enviroments origin/dev/pre created"









