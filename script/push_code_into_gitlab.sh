#!/bin/bash
source ../poc-cfg.sh

cd ${SHPATH}

# # # # Generate Git Project in Gitlab
# # #get_token
# # private_token=$(
# # curl -s -L -X POST \
# # "http://${GITLAB_ADDR}/api/v3/session?login=root&password=alauda1234" |\
# # grep -Po '(?<="private_token":")[^"]*'
# # )
# # # echo "private_token: $private_token"

# # #create_project
# # curl --header "PRIVATE-TOKEN: $private_token" -X POST \
# # "http://${GITLAB_ADDR}/api/v3/projects?name=${GITLAB_PROJECT}&description='It%20is%20used%20by%20PoC%20for%20demostrate%20Spring%20Cloud%20Sample%20based%20on%20AlaudaEE.%20Microservice%20Architecture%20with%20Spring%20Boot,%20Spring%20Cloud%20and%20Docker%20'&public=true" |\
# # grep "created_at" || {
# # echo "==FAILED: Create Project in Gitlab! Please check it SOON"
# # exit 1
# # }
# # echo "==SUCCESS: Create Project in Gitlab! =="

# # Get source code for Piggymetrics
rm -fR code/unzip

mkdir -p code/unzip
tar xf code/source/piggymetrics-code-*.tar.gz -C code/unzip

# # Replace alaudaci.yml & Dockerfile
cd ${SHPATH}/code/unzip
find ./ ! -path *mongodb/Dockerfile -name "Dockerfile" -exec grep FROM {} \;

find ./ ! -path *mongodb/Dockerfile \
-name "Dockerfile" \
-exec sed -i '/^FROM/ s/^.*$/FROM '"${REGISTRY_ADDR}\/${REGISTRY_PROJECT_COMMON}"'\/java:8-jre/' {} \;

find ./ ! -path *mongodb/Dockerfile -name "Dockerfile" -exec grep FROM {} \;

find ./ -name "alaudaci.yml" -exec grep 'image:' {} \;

find ./ -name "alaudaci.yml" \
-exec sed -i '/image:/ s/image:.*$/image: '"${REGISTRY_ADDR}\/${REGISTRY_PROJECT_BUILD}\/maven"'/g' {} \;

find ./ -name "alaudaci.yml" \
-exec sed -i '/tag:/ s/tag:.*$/tag: SCDalstonSR4/g' {} \;

find ./ -name "alaudaci.yml" -exec grep 'image:' {} \;

# yum install -y git
cd ${SHPATH}

docker load < gittools.tar.gz

rm -fR code/current

docker run --rm --name=gittools --net=host \
-it \
--privileged=true \
-e GITLAB_ADDR=${GITLAB_ADDR} \
-e GITLAB_PROJECT=${GITLAB_PROJECT} \
-v ${SHPATH}/code:/code \
gittools \
sh -x /code/push_code.sh


# # # # PRIVATE-TOKEN: bZssu4bNBXGDRzrasnFr
# # # # root/alauda1234
# curl --header "PRIVATE-TOKEN: bZssu4bNBXGDRzrasnFr" -X POST  "http://172.20.6.10:9988/api/v3/projects?name=piggymetrics&description='It%20is%20used%20by%20PoC%20for%20demostrate%20Spring%20Cloud%20Sample%20based%20on%20AlaudaEE.%20Microservice%20Architecture%20with%20Spring%20Boot,%20Spring%20Cloud%20and%20Docker%20'&public=true"
# curl --header "PRIVATE-TOKEN: bZssu4bNBXGDRzrasnFr" -X POST  "http://172.20.6.10:9988/api/v3/projects?name=piggymetrics-config&description='It%20is%20used%20by%20PoC%20for%20demostrate%20Spring%20Cloud%20Sample%20based%20on%20AlaudaEE.%20Microservice%20Architecture%20with%20Spring%20Boot,%20Spring%20Cloud%20and%20Docker%20'&public=true"
# {"id":3,"description":"'It is used by PoC for demostrate Spring Cloud Sample based on AlaudaEE. Microservice Architecture with Spring Boot, Spring Cloud and Docker '","default_branch":null,"tag_list":[],"public":true,"archived":false,"visibility_level":20,"ssh_url_to_repo":"ssh://git@gitlab.alauda.io:10022/root/piggymetrics-config.git","http_url_to_repo":"http://gitlab.alauda.io:10080/root/piggymetrics-config.git","web_url":"http://gitlab.alauda.io:10080/root/piggymetrics-config","owner":{"name":"Administrator","username":"root","id":1,"state":"active","avatar_url":null},"name":"piggymetrics-config","name_with_namespace":"Administrator / piggymetrics-config","path":"piggymetrics-config","path_with_namespace":"root/piggymetrics-config","issues_enabled":true,"merge_requests_enabled":true,"wiki_enabled":true,"snippets_enabled":false,"created_at":"2017-12-06T14:02:04.667Z","last_activity_at":"2017-12-06T14:02:04.667Z","creator_id":1,"namespace":{"id":1,"name":"root","path":"root","owner_id":1,"created_at":"2017-04-10T17:10:07.132Z","updated_at":"2017-04-10T17:10:07.132Z","description":"","avatar":null},"avatar_url":null}
# curl --header "PRIVATE-TOKEN: bZssu4bNBXGDRzrasnFr" -X POST  "http://172.20.6.10:9988/api/v3/projects?name=test&description='It%20is%20used%20by%20PoC%20for%20demostrate%20Spring%20Cloud%20Sample%20based%20on%20AlaudaEE.%20Microservice%20Architecture%20with%20Spring%20Boot,%20Spring%20Cloud%20and%20Docker%20'&public=true" | python -m json.tool
# {
    # "archived": false,
    # "avatar_url": null,
    # "created_at": "2017-12-06T14:03:10.676Z",
    # "creator_id": 1,
    # "default_branch": null,
    # "description": "'It is used by PoC for demostrate Spring Cloud Sample based on AlaudaEE. Microservice Architecture with Spring Boot, Spring Cloud and Docker '",
    # "http_url_to_repo": "http://gitlab.alauda.io:10080/root/test.git",
    # "id": 4,
    # "issues_enabled": true,
    # "last_activity_at": "2017-12-06T14:03:10.676Z",
    # "merge_requests_enabled": true,
    # "name": "test",
    # "name_with_namespace": "Administrator / test",
    # "namespace": {
        # "avatar": null,
        # "created_at": "2017-04-10T17:10:07.132Z",
        # "description": "",
        # "id": 1,
        # "name": "root",
        # "owner_id": 1,
        # "path": "root",
        # "updated_at": "2017-04-10T17:10:07.132Z"
    # },
    # "owner": {
        # "avatar_url": null,
        # "id": 1,
        # "name": "Administrator",
        # "state": "active",
        # "username": "root"
    # },
    # "path": "test",
    # "path_with_namespace": "root/test",
    # "public": true,
    # "snippets_enabled": false,
    # "ssh_url_to_repo": "ssh://git@gitlab.alauda.io:10022/root/test.git",
    # "tag_list": [],
    # "visibility_level": 20,
    # "web_url": "http://gitlab.alauda.io:10080/root/test",
    # "wiki_enabled": true
# }
