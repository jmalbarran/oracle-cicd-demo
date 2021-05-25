#!/usr/bin/env bash
set -ex


## Change current directory to current script. Rest of actions relative to current script
CURDIR=$(cd $(dirname "$0"); pwd -P)
cd "${CURDIR}"

## Change to dev environment
cd ../environments/dev


if [ -z "$1" ]
	then
		echo "Use: $0 versionlabel"
		exit 1
	else
		VERSION="$1"
		VERSION=${VERSION^^}
fi

CURRENT_ENV=${PWD##*/}
if [ "${CURRENT_ENV}" != "dev" ]
	then
		echo "This script can only run in dev environment"
		exit 2
fi


# Set environment variables
source setenv.sh

# Generate Liquibase controller and schema
sql ${DB_USER}/${DB_PASSWORD}@lbtest_tp<<-EOF
set echo on
CD database/liquibase
LB gencontrolfile
LB genschema
quit
EOF

# Commit and tag version
# TODO: Remove add all
git add -A
# Add newly added liquibase
git add -A database/liquibase
git commit -m "Deploy version ${VERSION}"
git tag -f $VERSION
git push
git push -f --tags

