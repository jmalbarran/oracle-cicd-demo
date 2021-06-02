#!/usr/bin/env bash
set -e

## Change current directory to current script. Rest of actions relative to current script
CURDIR=$(cd $(dirname "$0"); pwd -P)
cd "${CURDIR}"

## Change to dev environment
cd ../environments/pre

# Set environment variables
source setenv.sh

# Check parameters
if [ -z "$1" ]
	then
		echo "Use: $0 versionlabel"
		exit 1
	else
		VERSION=$(echo "$1" | tr [':lower:'] [':upper:'])
fi

CURRENT_ENV=${PWD##*/}
if [ "${CURRENT_ENV}" != "pre" ]
	then
		echo "This script can only run in pre environment"
		exit 2
fi

# Temp file
TEMPFILE=$(mktemp)

# Start
echo "==============================================" 
echo "Deploy version in test on $(date)"  

# Get last edition
sql -S ${DB_USER}/${DB_PASSWORD}@lbtest_tp >>pre-rollback-version.log <<-EOF
-- Exit on error
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;
SET PAGES 0
SET FEEDBACK OFF
SET TERM OFF
SET TIMING OFF
SET PAUSE OFF
SET TRIMSPOOL ON
SET HEAD OFF
SET FEED OFF
SET ECHO OFF
SPOOL $TEMPFILE
SELECT LastEdition() FROM DUAL;
SPOOL OFF
QUIT
EOF

LAST_EDITION=$(cat $TEMPFILE && rm $TEMPFILE)
NEW_EDITION="EDITION_${VERSION}"

echo "The version will be deployed in edition ${NEW_EDITION} AS CHILD OF ${LAST_EDITION}"

# Move GIT repository to the selected version
git fetch --all
git merge -q origin/dev
git reset --hard ${VERSION}
git push -f 
git push -f --tags

# Create EDITION
echo "Creating edition ${NEW_EDITION}"
sql -S ${DB_USER}/${DB_PASSWORD}@lbtest_tp  <<-EOF
-- Exit on error
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;
SET PAGES 0
SET FEEDBACK OFF
SET TERM OFF
SET TIMING OFF
SET PAUSE OFF
SET TRIMSPOOL ON
SET HEAD OFF
SET FEED OFF
SET ECHO OFF
CREATE EDITION $NEW_EDITION AS CHILD OF $LAST_EDITION;
QUIT
EOF


# Update schema based in Liquibase controller
echo "Updating schema (DDL and code)"
sql -S ${DB_USER}/${DB_PASSWORD}@lbtest_tp  <<-EOF
-- Exit on error
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;
SET PAGES 0
SET FEEDBACK OFF
SET TERM OFF
SET TIMING OFF
SET PAUSE OFF
SET TRIMSPOOL ON
SET HEAD OFF
SET FEED OFF
SET ECHO OFF
CD database/liquibase
ALTER SESSION SET EDITION = $NEW_EDITION;
LB update -changelog controller.xml -log
UPDATE DATABASECHANGELOG SET TAG='${VERSION}' WHERE TAG IS NULL;
QUIT
EOF



