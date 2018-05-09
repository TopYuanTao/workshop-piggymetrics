#!/bin/bash
source ../poc-cfg.sh

cd ${SHPATH}

# # Get source code for Piggymetrics
rm -fR code/unzip

mkdir -p code/unzip
tar xf code/source/${APPLICATION}-code-*.tar.gz -C code/unzip

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

