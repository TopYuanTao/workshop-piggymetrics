# # You should update and check these parameters before running piggymetrics.sh
export SHPATH='/top/workshop-demo-v1'
# export SHPATH=${SHPATH:-${PWD}}

# 创建本地的GitLab
export GITLAB_HOST="10.0.2.11"
export GITLAB_PORT="9988"
export GITLAB_HTTPS_PORT="9443"
export GITLAB_SSH_PORT="9922"
export CODE_BRANCH=master

export DEV_PREFIX='dev'  # Used by cluster, spacename, registry, build cfg
export OPS_PREFIX='ops'  # Used by cluster, spacename, registry, build cfg
export APPLICATION="piggymetrics"	# Used by code/Gitlab Project/Application Template/Application
export SPACE_NAME="${DEV_PREFIX}-space"  # 演示应用使用的 SPACE 
export REGION=${REGION:-$DEV_PREFIX}

# Alauda EE Account
export API_URL='http://10.0.2.4:81/v1'  # jakiro
export API_URL_V2='http://10.0.2.4:81/v2'
export ROOT_ACCOUNT='demo'
export ROOT_ACCOUNT_PWD='demo'
export ROOT_ACCOUNT_TOKEN='f94fb220fdd6a03092bfe7a43b33b630205ecb22'

# Alauda EE ALB & Registry
export ALB_HOST="10.0.2.7"  # 演示应用使用的 LB
export ALB_TYPE="nginx"  # 演示应用使用的 LB
export REGISTRY_HOST="10.0.2.7"  # 演示应用构建的镜像存放服务器
export REGISTRY_PORT="5000"
export IMG_REPO="${DEV_PREFIX}-registry"  # 根据实际镜像仓库的名称定义
export REGISTRY_USER=${REGISTRY_USER:-$ROOT_ACCOUNT}
export REGISTRY_PASS=${REGISTRY_PASS:-$ROOT_ACCOUNT_PWD}
export REGISTRY_ADDR=${REGISTRY_HOST}:${REGISTRY_PORT}
export REGISTRY_PROJECT=${REGISTRY_PROJECT:-$APPLICATION}	# 镜像仓库项目，使用应用的名称
export REGISTRY_PROJECT_COMMON='common'
export REGISTRY_PROJECT_BUILD='build'
# export REGISTRY_PROJECT_TEST='test'

# Alauda EE Build
export BUILD_IMAGE_ENABLED=true	# 构建项目要构建镜像
export BUILD_PREFIX=${BUILD_PREFIX:-$DEV_PREFIX}
export GITLAB_ADDR=${GITLAB_HOST}:${GITLAB_PORT}
export GITLAB_PROJECT=${GITLAB_PROJECT:-$REGISTRY_PROJECT}

# Alauda EE application & service
export APPLICATION_TEMPLATE=${APPLICATION_TEMPLATE:-$APPLICATION}

# 镜像同步，**最后**创建的集群为目的仓库
export SYNC_IMAGE_DEST_REPO="${OPS_PREFIX}-registry"
export SYNC_PREFIX=${SYNC_PREFIX:-$DEV_PREFIX}

# Alauda EE pipeline
export PIPELINE_PREFIX=${PIPELINE_PREFIX:-$DEV_PREFIX}


echo "SHPATH:$SHPATH"
echo "API_URL:$API_URL"
echo "ALB_HOST:$ALB_HOST"
echo "ROOT_ACCOUNT_TOKEN:$ROOT_ACCOUNT_TOKEN"
echo "REGISTRY_USER:$REGISTRY_USER"
echo "REGISTRY_PASS:$REGISTRY_PASS"
echo "REGISTRY_ADDR:$REGISTRY_ADDR"
echo "GITLAB_ADDR:$GITLAB_ADDR"
echo "IMG_REPO:$IMG_REPO"
echo "SPACE_NAME:$SPACE_NAME"
echo "----------------------------------------------"