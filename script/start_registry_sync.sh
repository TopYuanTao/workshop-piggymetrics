#!/bin/bash
source ../poc-cfg.sh

cd ${SHPATH}

cd code/current/${GITLAB_PROJECT}
n=0
for srv in $(find . -name alaudaci.yml | awk -F'/' '{print $2}'); do

    let n++

    DEST_ID=$(sed -n ${n}p ${SHPATH}/script/dest_id4image_sync.list)
    
    RESULT=$(curl -s -X POST ${API_URL}/sync-registry/${ROOT_ACCOUNT}/histories \
            -H "Authorization: Token $ROOT_ACCOUNT_TOKEN"               \
            -H "Cache-Control: no-cache"                   \
            -H "Content-Type: application/json"            \
            -d '
                {
                  "config_name": "'"syncimage2ops-${srv}"'",
                  "tag": "latest",
                  "dest_id_list": ["'"${DEST_ID}"'"],
                  "namespace": "'"${ROOT_ACCOUNT}"'"
                }
                 ' | jq '.[]' | sed 's/"//g')

    STATUS="INIT"
    until [[ ${STATUS} == "S" ]]; do
       STATUS=$(curl -s $API_URL/sync-registry/${ROOT_ACCOUNT}/histories/${RESULT} \
            -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
            -H "Cache-Control: no-cache" \
            -H "Content-Type: application/json" \
       | jq '.status' | sed 's/"//g')
       sleep 15
    done
done
