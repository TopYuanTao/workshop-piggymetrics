#!/bin/bash
source ../poc-cfg.sh

cd ${SHPATH}

#   ->
#Create org_project -> "$REGISTRY_PROJECT"
curl -s -X POST                                         \
         -H "Authorization: Token $ROOT_ACCOUNT_TOKEN"               \
         -H "Cache-Control: no-cache"                   \
         -H "Content-Type: application/json"            \
         -d '{"name": "piggymetrics"}'                    \
         "$API_URL/registries/$ROOT_ACCOUNT/$IMG_REPO/projects" |\
         grep -qiv errors || {
                echo "Failed to create the project -> $REGISTRY_PROJECT"
                exit 1
         }

#Create org_project -> "$REGISTRY_PROJECT_COMMON"
curl -s -X POST                                         \
         -H "Authorization: Token $ROOT_ACCOUNT_TOKEN"               \
         -H "Cache-Control: no-cache"                   \
         -H "Content-Type: application/json"            \
         -d '{"name": "common"}'                    \
         "$API_URL/registries/$ROOT_ACCOUNT/$IMG_REPO/projects" |\
         grep -qiv errors || {
                echo "Failed to create the project -> $REGISTRY_PROJECT_COMMON"
                exit 1
         }

#Create org_project -> "$REGISTRY_PROJECT_BUILD"
curl -s -X POST                                         \
         -H "Authorization: Token $ROOT_ACCOUNT_TOKEN"               \
         -H "Cache-Control: no-cache"                   \
         -H "Content-Type: application/json"            \
         -d '{"name": "build"}'                    \
         "$API_URL/registries/$ROOT_ACCOUNT/$IMG_REPO/projects" |\
         grep -qiv errors || {
                echo "Failed to create the project -> $REGISTRY_PROJECT_BUILD"
                exit 1
         }
