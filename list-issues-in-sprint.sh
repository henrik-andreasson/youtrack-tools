#!/bin/bash

YTURL="https://youtrack.yourdomain.com/api"

INPUTARGS=`/usr/bin/getopt --options "t:s:a:" --long "token,sprintname,agile" -- "$@"`
if [ $? != 0 ] ; then
    echo "help:"
    exit
fi
eval set -- "$INPUTARGS"

while true; do
  case "$1" in
    -s|--sprint  ) SPRINT=$2; shift 2;;
    -t|--token )   TOKEN=$2 ; shift 2;;
    -a|--agileid ) AGILEID=$2 ; shift 2;;
    --) break;;
  esac
done
if [ -z "$TOKEN" ]  ;then
    echo "TOKEN -t|--token must supplied"
    exit
fi

if [ -z "$SPRINT" ]  ;then
    echo "SPRINT -s|--sprint must supplied (name)"
    exit
fi
if [ -z "$AGILEID" ]  ;then
    echo "AGILEID -a|--agileid must supplied"
    exit
fi

curl -X GET \
"${YTURL}/agiles/${AGILEID}/sprints?fields=id,name,isDefault,issues(idReadable),goal,start,finish" \
-H 'Accept: application/json' \
-H "Authorization: ${TOKEN}" \
-H 'Content-Type: application/json' | jq ".[] | select(.name | contains(\"${SPRINT}\")) | .issues[].idReadable" | tr -d '"'
