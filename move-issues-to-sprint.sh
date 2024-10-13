#!/bin/bash

YTURL="https://youtrack.yourdomain.com/api"

INPUTARGS=`/usr/bin/getopt --options "t:s:a:" --long "token,sprintname,agile" -- "$@"`
if [ $? != 0 ] ; then
    echo "help:"
    exit
fi
eval set -- "$INPUTARGS"

SPRINT=""
TOKEN=""
while true; do
  case "$1" in
    -s|--sprint  ) SPRINT=$2; shift 2;;
    -t|--token )   TOKEN=$2 ; shift 2;;
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

for issue in $(cat $1) ; do

    curl -X GET \
        "${YTURL}/issues?fields=id,idReadable,summary,resolved,description,project(name),customFields(name,value(name,minutes))&customFields=type&customFields=assignee&customFields=Estimation&query=issue%20ID:$issue" \
        -H 'Accept: application/json' \
        -H "Authorization: Bearer ${TOKEN}" \
        -H 'Content-Type: application/json' \
        --output issue.json --silent

        resolved=$(cat  issue.json | jq -c '.[].resolved'  | tr -d '"')
        assignee=$(cat  issue.json | jq -c '.[].customFields | .[] |select( [ .name | contains("Assignee") ] |any) | .value.name' | tr -d '"')
        estimation=$(cat  issue.json | jq -c '.[].customFields | .[] |select( [ .name | contains("Estimation") ] |any) | .value.minutes' | tr -d '"')

    # update if it is not resolved
    if [ "$resolved" == "null" ] ; then

        curl -X POST "${YTURL}/issues/$issue" \
            -H 'Accept: application/json' \
            -H "Authorization: Bearer ${TOKEN}" \
            -H 'Content-Type: application/json' \
            -d "{
                \"customFields\":[
                    { \"name\":\"global sprint\",\"$type\":\"MultiVersionIssueCustomField\",\"value\":[{\"name\":\"${SPRINT}\"}]}
                ]
                }"

        echo "$issue"
    fi
done
