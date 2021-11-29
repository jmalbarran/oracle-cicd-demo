#!/usr/bin/env bash
set -e

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
		VERSION=$(echo "$1" | tr [':lower:'] [':upper:'])
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
echo "Generating schema for liquibase"
sql -S ${DB_USER}/${DB_PASSWORD}@${TNS_SERVICE}<<-EOF
-- No output
SET PAGES 0
SET FEEDBACK OFF
SET TERM OFF
SET TIMING OFF
SET PAUSE OFF
SET TRIMSPOOL ON
SET HEAD OFF
SET FEED OFF
SET ECHO OFF
-- Exit on error
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;
-- Generate liquibase schema
CD database/liquibase
-- Disable physical DDL generation
SET DDL TABLESPACE OFF
SET DDL SEGMENT_ATTRIBUTES OFF
SET DDL STORAGE OFF
SET DDL SPECIFICATION OFF
SET DDL PARTITIONING OFF
-- Generate ChangeSet: Controlfile and Schema
-- LB gencontrolfile
LB genschema -label ${VERSION}
quit
EOF

# Commit and tag version
echo "Commit, Tagging and Publishing version ${VERSION} in GIT repository"
# TODO: Remove add all
git add -A
# Add newly added liquibase
git add -A database/liquibase
git commit -m "Deploy version ${VERSION}"
git tag -a ${VERSION} -m "Tagged version ${VERSION}"


git push
git push -f --tags

