#!/usr/bin/with-contenv bash

## Set defaults for environmental variables in case they are undefined
#USER=${USER:=rstudio}
#PASSWORD=${PASSWORD:=rstudio}
USERID=${USERID:=1000}
#GROUPID=${GROUPID:=1000}
#ROOT=${ROOT:=FALSE}
#UMASK=${UMASK:=022}

if [ "$USERID" -ne 1000 ]
## Configure user with a different USERID if requested.
  then
    usermod -u $UISERID xclient
	find /home/xclient -user 1000 -exec chown -h $USERID {} \;
fi
