#!/bin/bash
source ../poc-cfg.sh

TMPDIR=$(mktemp -d)

cd ${SHPATH}


#get endpoint_id
endpoint_id=$(
curl -s "$API_URL/private-build-endpoints/$ROOT_ACCOUNT" \
         -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
         -H "Cache-Control: no-cache" \
         -H "Content-Type: text/html;charset:utf-8" \
         | ./jq ".[0].endpoint_id" \
         | sed 's/"//g'
        )
echo ${endpoint_id}

# cd ./images
# for srv in $(ls -1 *.gz  | grep piggymetrics | awk -F'.tar.gz' '{print $1}' | awk -F'-' '{print $2}') 
cd code/current/${GITLAB_PROJECT}
for srv in $(find . -name alaudaci.yml | awk -F'/' '{print $2}'); do
echo ${srv}
FULLNAME="${BUILD_PREFIX}-${srv}"
cat > $TMPDIR/$FULLNAME.json <<EOF
{
    "name": "$FULLNAME",
    "image_cache_enabled": true,
    "auto_build_enabled": true,
    "build_image_enabled": ${BUILD_IMAGE_ENABLED},
    "code_repo": {
        "code_repo_client": "SIMPLE_GIT",
        "code_repo_path": "http://$GITLAB_ADDR/root/$GITLAB_PROJECT.git",
        "code_repo_type": "BRANCH",
        "code_repo_type_value": "${CODE_BRANCH}",
        "build_context_path": "/$srv",
        "dockerfile_location": "/$srv",
        "code_repo_username": "root",
        "code_repo_password": "alauda1234"
    },
    "auto_tag_type": "TIME",
    "customize_tag": "latest",
    "image_repo": {
        "name": "$srv",
        "registry": {
            "name": "$IMG_REPO"
        },
        "project": {
            "name": "$REGISTRY_PROJECT"
        }
    },
    "endpoint_id": "$endpoint_id",
    "ci_enabled": true,
    "ci_config_file_location": "/$srv",
    "space_name": "$SPACE_NAME",
    "namespace": "$ROOT_ACCOUNT"
}
EOF

curl -s -X POST \
-H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
-H "Cache-Control: no-cache" \
-H "Content-Type: application/json" \
-d @$TMPDIR/$FULLNAME.json \
"$API_URL/private-build-configs/$ROOT_ACCOUNT" \
| grep -qiv errors || {
    echo "Create $FULLNAME failed."
}

done

cd ${SHPATH}
