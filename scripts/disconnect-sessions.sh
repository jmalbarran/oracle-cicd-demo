#!/usr/bin/env bash
set -e

## Change current directory to current script. Rest of actions relative to current script
CURDIR=$(cd $(dirname "$0"); pwd -P)
cd "${CURDIR}"


# Set environment variables
source setenv.sh

# Check parameters

if [ -z "$1" ]
	then
		echo "Use: $0 DB_USER"
		exit 1
	else
		DB_USER=$(echo "$1" | tr [':lower:'] [':upper:'])
fi


# Start
echo "==============================================" 
echo "Disconnect session for user ${DB_USER}"  

# Get last edition
sql -S ${ADMIN_USER}/${ADMIN_PASSWORD}@${TNS_SERVICE} <<-EOF
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
SET ECHO ON
SET SERVEROUTPUT ON
BEGIN
	DBMS_OUTPUT.PUT_LINE('Killing user ${DB_USER} sessions');
	FOR r IN (SELECT sid,serial# FROM v\$session where username = '${DB_USER}')
	LOOP
		DBMS_OUTPUT.PUT_LINE('Killing session ' || r.sid || ',' || r.serial#);
		EXECUTE IMMEDIATE 'alter system kill session ''' || r.sid || ',' || r.serial# || ''' IMMEDIATE';
	END LOOP;	
END;
/
QUIT
EOF


echo "Sessions disconnected"


