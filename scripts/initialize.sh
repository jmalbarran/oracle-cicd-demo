#!/usr/bin/env bash

# Initialize script
set -e
## Change current directory to current script. Rest of actions relative to current script
CURDIR=$(cd $(dirname "$0"); pwd -P)
cd "${CURDIR}"
## Set environment
source setenv.sh


echo "Initializing demo components"
# Execute script
sql -S ${ADMIN_USER}/${ADMIN_PASSWORD}@${TNS_SERVICE} @create_users.sql $DEV_USER $DEV_PASSWORD $PRE_USER $PRE_PASSWORD

echo "Creating environments origin (simulating remote origin), dev and pre"
# Create git environments
mkdir -p ../environments
rm -rf ../environments/origin
rm -rf ../environments/pre
rm -rf ../environments/dev

git init ../environments/origin
cp ../initial/initial_gitignore ../environments/origin/.gitignore
cd ../environments/origin
git add .gitignore 
git commit -m "First commit"
git branch pre
git branch dev

## Set pre enviroment cloning from origin
cd ..
git clone origin/.git pre
cd pre
git checkout -b pre 
git branch --set-upstream-to=origin/pre pre
cd "${CURDIR}"
## Set environment variables for pre
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
cd ..
git clone origin/.git dev
cd dev
git checkout -b dev 
git branch --set-upstream-to=origin/dev dev

## Set environment variables for dev
echo "TNS_ADMIN=${TNS_ADMIN}" >.env
echo "DB_USER=${DEV_USER}" >>.env
echo "DB_PASSWORD=${DEV_PASSWORD}" >>.env
echo "DB_URL=${DB_URL}" >>.env
echo "TNS_SERVICE=${TNS_SERVICE}" >>.env


# Deploy version v0 of application to dev environment
echo "Deploying initial version as v0"
cd "${CURDIR}"
cp -r ../v0/* ../environments/dev

sql -S ${DEV_USER}/${DEV_PASSWORD}@${TNS_SERVICE} @../environments/dev/database/scripts/initialize.sql

cd "${CURDIR}"
./dev-publish-version.sh v0
./pre-deploy-version-in-test.sh v0
./pre-deploy-version-for-all.sh









