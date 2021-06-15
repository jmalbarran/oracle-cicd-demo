#!/usr/bin/env bash
set -e

## Change current directory to current script. Rest of actions relative to current script
CURDIR=$(cd $(dirname "$0"); pwd -P)
cd "${CURDIR}"

## Change to dev environment
cd ../environments/pre

# Set environment variables
source setenv.sh

# Check environment and parameters
CURRENT_ENV=${PWD##*/}
if [ "${CURRENT_ENV}" != "pre" ]
	then
		>&2 echo "This script can only run in pre environment"
		exit 2
fi


# Temp file
TEMPFILE=$(mktemp)

# Start
echo "==============================================" 
echo "Rolling back last version on $(date)"

# Get last edition
sql -S ${DB_USER}/${DB_PASSWORD}@${TNS_SERVICE}  <<-EOF
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
LAST_VERSION=$(echo $LAST_EDITION|sed 's/EDITION_//g')

# Get previous edition
sql -S ${DB_USER}/${DB_PASSWORD}@${TNS_SERVICE} <<-EOF
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
SELECT PARENT_EDITION_NAME FROM ALL_EDITIONS WHERE EDITION_NAME='${LAST_EDITION}';
SPOOL OFF
QUIT
EOF

PREVIOUS_EDITION=$(cat $TEMPFILE && rm $TEMPFILE)
PREVIOUS_VERSION=$(echo $PREVIOUS_EDITION|sed 's/EDITION_//g')

LAST_GIT_VERSION=$(git describe --abbrev=0 --tags)

if [ ${LAST_VERSION} != ${LAST_GIT_VERSION} ]
	then
		>&2 echo "Inconsistent state: Last GIT version=${LAST_GIT_VERSION} is different from the last edition version ${LAST_VERSION}" 
		exit 3
fi
echo "Rolling back ${LAST_VERSION} for everybody using edition ${LAST_EDITION}"
echo "Returning to version ${PREVIOUS_VERSION}"  

# Rolling back: EDITION, LIQUIBASE (SCHEMA) AND GIT
## Return to previous edition and drop last edition
echo "Replace current edition with $PREVIOUS_EDITION"  
sql -S ${DB_USER}/${DB_PASSWORD}@${TNS_SERVICE}  <<-EOF
SET ECHO ON
ALTER DATABASE DEFAULT EDITION = $PREVIOUS_EDITION;
ALTER SESSION SET EDITION = $PREVIOUS_EDITION;
DROP EDITION $LAST_EDITION CASCADE;
QUIT
EOF

## Get last tag count
sql -S ${DB_USER}/${DB_PASSWORD}@${TNS_SERVICE} <<-EOF
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
SELECT COUNT(*) FROM DATABASECHANGELOG WHERE TAG='${LAST_VERSION}';
SPOOL OFF
QUIT
EOF

COUNTLASTTAG=$(cat $TEMPFILE && rm $TEMPFILE)

if [ ${COUNTLASTTAG} -eq 0 ]
	then
		>&2 echo "WARNING: No DDLs pending to rollback"
	else
		## Rolling back schema based in Liquibase controller
		echo "Rolling back $COUNTLASTTAG updates from version $LAST_VERSION"
		sql -S ${DB_USER}/${DB_PASSWORD}@${TNS_SERVICE} <<-EOF
		set echo on
		cd database/liquibase
		lb rollback -changelog controller.xml -log -count $COUNTLASTTAG
		QUIT
EOF
fi 

## Return source code to previous version
echo "Return GIT repository to ${PREVIOUS_VERSION}"
git reset --hard ${PREVIOUS_VERSION}
git push -f 
git push -f --tags


