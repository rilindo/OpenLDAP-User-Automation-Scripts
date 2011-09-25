#!/bin/sh


# Script to add a login to ldap. 
# Not meant for anything beyound causal use
# Author: Rilindo Foster
# Contact:  rilindo.foster@monzell.com
# Date: 09/11/2011

CONFIG="/root/ldap/config"

. $CONFIG

if [ -z $1 ];  then
	echo "addldapuser.sh <username>"
	exit 1
fi

USERNAME=$1

stty_orig=`stty -g`
echo -n "Enter Password: "
stty -echo
read USERPASS
stty $stty_orig

echo


PASSWORD=`$SLAPPASSWORD -h "{crypt}" -s $USERPASS`

# Generate a ID between 1000 and 65535. Its okay for home and maybe a small offie. For a medium to large company, you need a bigger number or try something different.

LUID=`echo $[ 1000 + $[ RANDOM % 65535 ]]`

(
cat <<add-user
dn: uid=$USERNAME,ou=People,dc=$DOMAIN,dc=$ORG
uid: $USERNAME
cn: $USERNAME
objectClass: account
objectClass: posixAccount
objectClass: top
objectClass: shadowAccount
userPassword: $PASSWORD
shadowLastChange: 15192
shadowMin: 0
shadowMax: 99999
shadowWarning: 7
loginShell: /bin/bash
uidNumber: $LUID
gidNumber: $LUID
homeDirectory: /home/users/$USERNAME

dn: cn=$USERNAME,ou=Group,dc=$DOMAIN,dc=$ORG
objectClass: posixGroup
objectClass: top
cn: $USERNAME 
userPassword: {crypt}x
gidNumber: $LUID
add-user
) > $TMP/adduser.ldif

$LDAPADDCMD -x -w $LDAPPASS -D "cn=root,dc=$DOMAIN,dc=$ORG" -f $TMP/adduser.ldif && rm $TMP/adduser.ldif 

if [ $? -ne "0" ]; then
	echo "Add user failed"
	echo "Please review $TMP/adduser.ldif and add the account manually"
else
#	mkdir -p $HOMEDIR/$USERNAME
	cp -Rv $SKEL $HOMEDIR/$USERNAME
	chown -Rv $LUID:$LUID $HOMEDIR/$USERNAME
fi
