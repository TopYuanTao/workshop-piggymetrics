#!/bin/bash
source ../poc-cfg.sh

cd ${SHPATH}


cd code/current/${GITLAB_PROJECT}
for srv in $(find . -name alaudaci.yml | awk -F'/' '{print $2}'); do
    FULLNAME="${PREFIX}${srv}"

    BUILD_CONFIG_ID=$(curl -s "$API_URL/private-build-configs/${ROOT_ACCOUNT}/${FULLNAME}" \
            -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
            -H "Cache-Control: no-cache" \
            -H "Content-Type: application/json" \
    |  jq '.config_id' | sed 's/"//g')
    
    
    
    # REGION_ID=$(curl -s "$API_URL/regions/${ROOT_ACCOUNT}/${REGION_NAME}" \
    REGION_ID=$(curl -s "$API_URL/regions/${ROOT_ACCOUNT}/dev" \
             -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
             -H "Cache-Control: no-cache" \
             -H "Content-Type: application/json" \
    | jq '.id' | sed 's/"//g')


    APPLICATION_UUID=$(curl -s "$API_URL/services/${ROOT_ACCOUNT}/registry?application=piggymetrics" \
             -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
             -H "Cache-Control: no-cache" \
             -H "Content-Type: application/json" \
    | jq '.application_uuid' | sed 's/"//g')
    
    SERVICE_UUID=$(curl -s "$API_URL/services/${ROOT_ACCOUNT}/registry?application=piggymetrics" \
             -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
             -H "Cache-Control: no-cache" \
             -H "Content-Type: application/json" \
    | jq '.unique_name' | sed 's/"//g')
    
    SYNC_REGISTRY_CONFIG_ID=$(curl -s "$API_URL/sync-registry/${ROOT_ACCOUNT}/configs/syncimage2ops-${srv}" \
         -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
         -H "Cache-Control: no-cache" \
         -H "Content-Type: application/json" \
         | jq '.config_id' | sed 's/"//g')
    
    

    curl -s -X POST "$API_URL/pipelines/${ROOT_ACCOUNT}/config" \
         -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
         -H "Cache-Control: no-cache" \
         -H "Content-Type: application/json" \
         -d '
             {
              "triggers": {
                "build": {
                  "type": "build",
                  "active": true,
                  "auto_trigger_enabled": true,
                  "build_config_uuid": "'"${BUILD_CONFIG_ID}"'",
                  "build_config_name": "'"${FULLNAME}"'"
                }
              },
              "stages": [{
                "order": 1,
                "name": "first-stage",
                "tasks": [{
                  "order": 1,
                  "name": "task-1",
                  "type": "update-service",
                  "data": {
                    "env_files": [],
                    "env_vars": {},
                    "mount_points": [],
                    "service": {
                      "name": "'"${srv}"'",
                      "type": "application-service",
                      "uuid": "'"${SERVICE_UUID}"'",
                      "parent": "'"${APPLICATION_TEMPLATE}"'",
                      "parent_uuid": "'"${APPLICATION_UUID}"'",
                      "image_name": "'"${REGISTRY_HOST}:${REGISTRY_PORT}/${REGISTRY_PROJECT}/${srv}"'",
                      "triggerImage": "'"${REGISTRY_HOST}:${REGISTRY_PORT}/${REGISTRY_PROJECT}/${srv}"'"
                    }
                  },
                  "region_uuid": "'"${REGION_ID}"'",
                  "region": "'"${REGION_NAME}"'",
                  "timeout": 0
                }, {
                  "order": 2,
                  "name": "task-2",
                  "type": "manual-control",
                  "data": {
                    "exec_enabled": false
                  },
                  "timeout": 0
                }, {
                  "order": 3,
                  "name": "task-3",
                  "type": "sync-registry",
                  "data": {
                    "share_path": "",
                    "config_name": "'"syncimage2ops-${srv}"'",
                    "config_uuid": "'"${SYNC_REGISTRY_CONFIG_ID}"'"
                  },
                  "timeout": 0
                }]
              }],
              "on_end": [],
              "artifact_enabled": true,
              "space_name": "'"${SPACE_NAME}"'",
              "name": "'"${srv}"'",
              "namespace": "'"${ROOT_ACCOUNT}"'"
             }
              '
done
