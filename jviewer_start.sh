#!/bin/sh

if [ $# -ne 3 ]; then
  echo "Usage: $0 <ip> <username> <password>"
  exit 1
fi

IP=$1
USERNAME=$2
PASSWORD=$3
CONNECT_TIMEOUT=5

LOGIN_RES=$(curl --silent \
                 --connect-timeout $CONNECT_TIMEOUT \
                 --data "WEBVAR_USERNAME=$USERNAME&WEBVAR_PASSWORD=$PASSWORD" \
                 "http://$IP/rpc/WEBSES/create.asp") 

if [ $? -ne 0 ]; then
  echo "Connect too $IP failed"
  exit 1
fi

SESSION_COOKIE=$(echo "$LOGIN_RES" | awk -F "'" '/SESSION_COOKIE/ { print $4 }')
HAPI_STATUS=$(echo "$LOGIN_RES" | awk -F "[: ]" '/HAPI_STATUS/ { print $3 }') 

if [ "$HAPI_STATUS" != 0 ]; then 
  echo "Login to $IP failed"
  exit 1
fi

TMPFILE=$(mktemp)

curl --output "$TMPFILE" \
     --silent \
     --connect-timeout $CONNECT_TIMEOUT \
     --header "Cookie: SessionCookie=$SESSION_COOKIE;" \
     "http://$IP/Java/jviewer.jnlp?EXTRNIP=$IP&JNLPSTR=JViewer"

javaws "$TMPFILE"
