#!/bin/sh


# Script to delete a login to ldap. 
# Not recommended for anything beyound casual use. ;)
# Author: Rilindo Foster
# Contact:  rilindo.foster@monzell.com
# Date: 09/25/2011

CONFIG="/root/ldap/config"

. $CONFIG

if [ -z $1 ];  then
	echo "delldapuser.sh <username>"
	exit 1
fi

USERNAME=$1

$LDAPDELCMD -x -w $LDAPPASS -D "cn=root,dc=$DOMAIN,dc=$ORG" "uid=$USERNAME,ou=$UNIT,dc=$DOMAIN,dc=$ORG"

$LDAPDELCMD -x -w $LDAPPASS -D "cn=root,dc=$DOMAIN,dc=$ORG" "cn=$USERNAME,ou=$GROUP,dc=$DOMAIN,dc=$ORG"


if [ ! -e $HOMEDIR/$ARCHIVE ]; then
	echo "Creating archive directory"
	mkdir -p $HOMEDIR/$ARCHIVE
fi 
mv -v $HOMEDIR/$USERNAME $HOMEDIR/$ARCHIVE/$USERNAME.$MODDATE
