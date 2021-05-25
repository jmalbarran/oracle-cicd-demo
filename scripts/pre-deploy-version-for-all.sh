#!/usr/bin/env bash
set -ex


## Change current directory to current script. Rest of actions relative to current script
CURDIR=$(cd $(dirname "$0"); pwd -P)
cd "${CURDIR}"

## Change to dev environment
cd ../environments/pre

# Set environment variables
source setenv.sh

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
echo "Deploy last version for everybody"  

# Get last edition
sql ${DB_USER}/${DB_PASSWORD}@lbtest_tp >>pre-rollback-version.log <<-EOF
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
echo "Deploy last version ${LAST_VERSION} for everybody using edition ${LAST_EDITION}"  

# Update schema based in Liquibase controller
sql ${DB_USER}/${DB_PASSWORD}@lbtest_tp <<-EOF
SET ECHO ON
ALTER DATABASE DEFAULT EDITION = $LAST_EDITION;
QUIT
EOF

# End
echo "Deploy last version for everybody ended with no errors" 
echo "==============================================" 



