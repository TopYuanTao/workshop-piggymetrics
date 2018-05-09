#!/bin/bash
source ../poc-cfg.sh

cd ${SHPATH}


cd code/current/${GITLAB_PROJECT}
for srv in $(find . -name alaudaci.yml | awk -F'/' '{print $2}'); do
    FULLNAME="${PREFIX}${srv}"
    
    BUILD_ID=$(curl -s -X POST "$API_URL/private-builds/$ROOT_ACCOUNT" \
            -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
            -H "Cache-Control: no-cache" \
            -H "Content-Type: application/json" \
            -d '
                {
                    "build_config_name":"'"${FULLNAME}"'",
                    "namespace":"'"${ROOT_ACCOUNT}"'"
                }
               ' \
    |  jq '.build_id' | sed 's/"//g')

    STATUS="INIT"
    until [ ${STATUS} == "S" ]; do
       STATUS=$(curl -s "$API_URL/private-builds/$ROOT_ACCOUNT/$BUILD_ID" \
            -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
            -H "Cache-Control: no-cache" \
            -H "Content-Type: application/json" \
       | jq '.status' | sed 's/"//g')
       sleep 15
    done

done

cd ${SHPATH}
