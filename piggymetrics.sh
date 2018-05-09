#!/bin/bash
source ./poc-cfg.sh

# Prerequisite 1: Check Registry Access
# -----------------------------------------
docker login \
-u ${REGISTRY_USER} \
-p ${REGISTRY_PASS} \
${REGISTRY_ADDR} |\
grep "Login Succeeded" || {
echo "==Registry Access FAILED: Please add ${REGISTRY_ADDR} into /etc/docker/daemon.json "
exit 1
}

# Prerequisite 2: API URL Acess
# -----------------------------------------
curl ${API_URL} || {
echo "==API gateway Access FAILED: Please check soon "
exit 1
}

# read -t 10 -p "Parameters, OK?"

#1. Deploy Gitlab and push code automatically
# -----------------------------------------
# 1.1 Deploy Gitlab
rm -rf gitlab

tar xf gitlab.tar.gz
cd gitlab
sh initgitlab || {
echo "==FAILED.1.1: Deploy Gitlab failed, Please check it soon"
exit 1
}
echo "==SUCCESS.1.1: Deploy Gitlab in loacal, ${GITLAB_ADDR}! =="

read -p "Gitlab UI, OK?"

cd ${SHPATH}

# 1.2 Push code
cd script
./push_code_into_gitlab.sh || {
echo "==FAILED.1.2: Push code failed, Please check it soon"
exit 1
}
echo "==SUCCESS.1.2: Push code into Gitlab! =="

cd ${SHPATH}

#2. Registry
# -----------------------------------------
cd script
./create_registry_project.sh || {
echo "==FAILED.2.1: Please check it before running .sh"
exit 1
}
echo "==SUCCESS.2.1: Create Registry Project! =="

cd ${SHPATH}/images

for image_file in $(ls -1 *.gz  | awk -F'.tar.gz' '{print $1}'); do
    IMAGE=$(docker load < ${image_file}.tar.gz | awk 'END{print $NF}')
    REPO_RROJECT=$(echo ${image_file} | awk -F'-' '{print $1}')
    REPOSITORY_TARGET=${REPO_RROJECT}/${IMAGE}
    docker tag ${IMAGE} ${REGISTRY_ADDR}/${REPOSITORY_TARGET}
    docker push $_
done

cd ${SHPATH}

#3. Add Build Project Definition in Alauda EE
# -----------------------------------------
cd script
./create_build_cfg.sh  || {
echo "==FAILED.3: Create Build Project failed. "
exit 1
}
echo "==SUCCESS.3: Create Build Project in Alauda EE! =="

cd ${SHPATH}

#4. Build Project in Alauda EE
# -----------------------------------------
cd script
./start_build-project.sh || {
echo "==FAILED.4"
exit 1
}
echo "==SUCCESS.4: Build Project"

cd ${SHPATH}


#4.1 Images Sync project
cd script
./create_registry_sync.sh || {
echo "==FAILED.4-1"
exit 1
}
echo "SUCCESS.4-1"

cd ${SHPATH}


# 4.2 Start Images Sync
cd script
./start_registry_sync.sh || {
echo "==FAILED.4-2"
exit 1
}
echo "SUCCESS.4-2"

cd ${SHPATH}


#5. Add Application Template in Alauda EE
# -----------------------------------------
cd script
./create_application_template.sh || {
echo "==FAILED.5: Please check it before running .sh"
exit 1
}
echo "==SUCCESS.5: Create application template in Alauda EE! =="

cd ${SHPATH}


#6. Create Application From Template
cd script 
./start_application.sh || {
echo "==FAILED.6"
exit 1
}
echo "==SUCCESS.6"

cd ${SHPATH}


#7. Create Pipeline profile & Start
cd script
./create_pipeline.sh || {
echo "==FAILED.7"
exit 1
}
echo "==SUCCESS.7"

cd ${SHPATH}


#8. Create Monitor dashboard
cd script 
./create_monitro_dashboard.sh || {
echo "==FAILED.8"
exit 1
}
echo "==SUCCESS.8"

cd ${SHPATH}

#9. Test




cd ${SHPATH}
