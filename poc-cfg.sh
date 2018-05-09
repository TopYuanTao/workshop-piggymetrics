# # You should update and check these parameters before running piggymetrics.sh
export SHPATH='/mnt/resource/piggymetrics-demo-v9'
# export SHPATH=${SHPATH:-${PWD}}
export PREFIX='dev-'  # 用在构建项目名称
# export SUFFIX='-ops'  # 用在镜像的路径

export API_URL='http://10.0.0.4:81/v1'  # jakiro
export API_URL_V2='http://10.0.0.4:81/v2'
export ROOT_ACCOUNT='demo'
export ROOT_ACCOUNT_PWD='demo'
export ROOT_ACCOUNT_TOKEN='b95f438770d500f45e06ec50c38f4b1bcecac582'
export SPACE_NAME="${PREFIX}space"  # 演示应用使用的 SPACE 
# export SPACE_NAME="dev-space"  # 演示应用使用的 SPACE 

export APPLICATION_TEMPLATE="piggymetrics"  # 应用模板

export ALB_HOST="10.0.0.6"  # 演示应用使用的 LB
export ALB_TYPE="nginx"  # 演示应用使用的 LB

export GITLAB_HOST="10.0.0.9"
export GITLAB_PORT="9988"
export GITLAB_HTTPS_PORT="9443"
export GITLAB_SSH_PORT="9922"
export CODE_BRANCH=master

export REGISTRY_HOST="10.0.0.6"  # 演示应用构建的镜像存放服务器
export REGISTRY_PORT="5000"
export REGISTRY_PROJECT="piggymetrics"	# 镜像仓库项目，使用应用的名称
# export REGISTRY_PROJECT="piggy${SUFFIX}"
export IMG_REPO="${PREFIX}registry"  # 根据实际镜像仓库的名称定义
# export IMG_REPO="dev-registry"  # 根据实际镜像仓库的名称定义
export BUILD_IMAGE_ENABLED=true	# 构建项目要构建镜像
export REGISTRY_PROJECT_COMMON='common'
export REGISTRY_PROJECT_BUILD='build'
export REGISTRY_USER=${REGISTRY_USER:-$ROOT_ACCOUNT}
export REGISTRY_PASS=${REGISTRY_PASS:-$ROOT_ACCOUNT_PWD}
export REGISTRY_ADDR=${REGISTRY_HOST}:${REGISTRY_PORT}
export GITLAB_ADDR=${GITLAB_HOST}:${GITLAB_PORT}
export GITLAB_PROJECT=${GITLAB_PROJECT:-$REGISTRY_PROJECT}

# 镜像同步，**最后**创建的集群为目的仓库
export SYNC_IMAGE_DEST_REPO="ops-registry"
