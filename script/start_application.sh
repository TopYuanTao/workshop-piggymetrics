#!/bin/bash
source ../poc-cfg.sh

TMPDIR=$(mktemp -d)

cd ${SHPATH}

#echo "------ Template -----"
cat > $TMPDIR/app_template.tpl <<EOF
rabbitmq:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT_COMMON}/rabbitmq:3-management
  ports:
    - '15672'
    - '5672'
  net: flannel

data-mongodb:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT_COMMON}/mongodb
  environment:
    INIT_DUMP: account-service-dump.js
    MONGODB_PASSWORD: admin 
  ports:
    - '27017'
  net: flannel

elasticsearch:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT_COMMON}/elasticsearch:update
  size: M
  environment:
    ES_JAVA_OPTS: -Xms384m -Xmx384m
  alauda_lb: ALB
  ports:
    - '${ALB_TYPE}-${ALB_HOST//./-}:9200:9200/http'
    - '${ALB_TYPE}-${ALB_HOST//./-}:9300:9300/http'
  net: flannel

config:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT}/config
  size: M
  environment:
    CONFIG_SERVICE_PASSWORD: admin
    RUN_ARGS: --spring.profiles.active=docker --ALAUDA_GIT=http://${GITLAB_ADDR}/root/${GITLAB_PROJECT}-config.git --ALAUDA_GIT_USER=root --ALAUDA_GIT_PASSWORD=alauda1234
  links:
    - 'rabbitmq:rabbitmq'
    - 'data-mongodb:data-mongodb'
  ports:
    - '8888'
  net: flannel

registry:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT}/registry
  size: M
  environment:
    CONFIG_SERVICE_PASSWORD: admin
    RUN_ARGS: --spring.profiles.active=docker --ALAUDA_EUREKA_DNS=eureka-hl-01.${REGISTRY_PROJECT}--${SPACE_NAME}.svc.cluster.local
  kubernetes_config:
    services:
    - name: eureka-hl-01
      type: Headless  
  links:
    - 'config:config'
  alauda_lb: ALB
  ports:
    - '${ALB_TYPE}-${ALB_HOST//./-}:8761:8761/http'
  number: 2
  net: flannel

gateway:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT}/gateway
  size: L
  environment:
    CONFIG_SERVICE_PASSWORD: admin 
    RUN_ARGS: --spring.profiles.active=docker
  links:
    - 'registry:registry'
  alauda_lb: ALB
  ports:
    - '${ALB_TYPE}-${ALB_HOST//./-}:80:4000/http'
  domain:
    - piggymetrics.test.com
    - piggymetrics.demo.com
  net: flannel
 
auth-service:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT}/auth-service
  size: L
  environment:
      CONFIG_SERVICE_PASSWORD: admin
      NOTIFICATION_SERVICE_PASSWORD: admin
      STATISTICS_SERVICE_PASSWORD: admin
      ACCOUNT_SERVICE_PASSWORD: admin
      MONGODB_PASSWORD: admin
      RUN_ARGS: --spring.profiles.active=docker
  links:
    - 'registry:registry'
  ports:
    - '5000'
  net: flannel
 
account-service:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT}/account-service
  size: L
  environment:
    CONFIG_SERVICE_PASSWORD: admin
    ACCOUNT_SERVICE_PASSWORD: admin
    MONGODB_PASSWORD: admin
    RUN_ARGS: --spring.profiles.active=docker
  links:
    - 'auth-service:auth-service'
  ports:
    - '6000'
  net: flannel
 
statistics-service:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT}/statistics-service
  size: L
  environment:
    CONFIG_SERVICE_PASSWORD: admin
    MONGODB_PASSWORD: admin
    STATISTICS_SERVICE_PASSWORD: admin
    RUN_ARGS: --spring.profiles.active=docker
  links:
    - 'auth-service:auth-service'
  ports:
    - '7000'
  net: flannel
 
notification-service:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT}/notification-service
  size: L
  environment:
    CONFIG_SERVICE_PASSWORD: admin
    MONGODB_PASSWORD: admin
    NOTIFICATION_SERVICE_PASSWORD: admin
    RUN_ARGS: --spring.profiles.active=docker
  links:
    - 'auth-service:auth-service'
  ports:
    - '8000'
  net: flannel
 
monitoring:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT}/monitoring
  size: M
  environment:
    CONFIG_SERVICE_PASSWORD: admin
    RUN_ARGS: --spring.profiles.active=docker
  links:
    - 'registry:registry'
  alauda_lb: ALB
  ports:
    - '${ALB_TYPE}-${ALB_HOST//./-}:8970:8080/http'
    - '8989'
  net: flannel

zipkin:
  image: ${REGISTRY_ADDR}/${REGISTRY_PROJECT}/zipkin
  size: L
  environment:
    CONFIG_SERVICE_PASSWORD: admin
    RUN_ARGS: --spring.profiles.active=docker
  links:
    - 'elasticsearch:elasticsearch'
    - 'registry:registry'
  alauda_lb: ALB
  ports:
    - '${ALB_TYPE}-${ALB_HOST//./-}:8989:9411/tcp'
  net: flannel
EOF


curl -s -X POST "${API_URL}/applications/${ROOT_ACCOUNT}" \
     -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
     -H "Cache-Control: no-cache" \
     -H "Content-Type: multipart/form-data;charset=UTF-8" \
     -F "services=@$TMPDIR/app_template.tpl" \
     -F "app_name=${APPLICATION}" \
     -F "region=${REGION}" \
     -F "space_name=${SPACE_NAME}"

STATUS="INIT"
until [ ${STATUS} == "Running" ]; do
    STATUS=$(curl -s "$API_URL/applications/${ROOT_ACCOUNT}?project_name=${APPLICATION}&region=${REGION}" \
        -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
        -H "Cache-Control: no-cache" \
        -H "Content-Type: application/json" \
    | jq '.[].current_status' | sed 's/"//g')

   echo "${APPLICATION} ${STATUS}"
   sleep 60
done 



echo "---- done. ----"
