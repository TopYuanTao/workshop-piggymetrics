#!/bin/bash
source ../poc-cfg.sh

cd ${SHPATH}

#   ->
for RP in $REGISTRY_PROJECT $REGISTRY_PROJECT_COMMON $REGISTRY_PROJECT_BUILD; do
    curl -s -X POST                                         \
             -H "Authorization: Token $ROOT_ACCOUNT_TOKEN"               \
             -H "Cache-Control: no-cache"                   \
             -H "Content-Type: application/json"            \
             -d '{"name": "'"$RP"'"}'                    \
             "$API_URL/registries/$ROOT_ACCOUNT/$SYNC_IMAGE_DEST_REPO/projects" |\
             grep -qiv errors || {
                    echo "Failed to create the project -> $RP"
                    # exit 1
             }
done

# 平台上最后注册的为目标镜像仓库
REGISTRY_ID=$(curl -s ${API_URL}/registries/$ROOT_ACCOUNT \
     -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
     -H "Cache-Control: no-cache" \
     -H "Content-Type: application/json" \
| jq '.[].uuid' | sed -n '$s/"//gp')
# | jq . | awk -F '"' '/uuid/{print $4}' | tail -n 1)

echo ${REGISTRY_ID}

cd code/current/${GITLAB_PROJECT}
> ${SHPATH}/script/dest_id4image_sync.list
for srv in $(find . -name alaudaci.yml | awk -F'/' '{print $2}'); do
    DEST_ID=$(curl -s -X POST ${API_URL}/sync-registry/${ROOT_ACCOUNT}/configs \
            -H "Authorization: Token $ROOT_ACCOUNT_TOKEN"               \
            -H "Cache-Control: no-cache"                   \
            -H "Content-Type: application/json"            \
            -d '
                {
                  "source": {
                    "type": "repository",
                    "info": {
                      "registry_name": "'"${IMG_REPO}"'",
                      "project_name": "'"${REGISTRY_PROJECT}"'",
                      "repository_name": "'"${srv}"'"
                    }
                  },
                  "dest": [{
                    "dest_type": "INTERNAL_REGISTRY",
                    "internal_id": "'"${REGISTRY_ID}"'"
                  }],
                  "space_name": "dev-space",
                  "config_name": "'"syncimage2ops-${srv}"'",
                  "cpu": 0.5,
                  "memory": 512,
                  "namespace": "demo"
                }
                ' | jq '.dest[].dest_id' | sed 's/"//g')
    echo ${DEST_ID} >> ${SHPATH}/script/dest_id4image_sync.list
done
