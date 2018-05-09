#!/bin/bash
source ../poc-cfg.sh

cd ${SHPATH}

MONITOR_DASHBOARD_ID=$(curl -s -X POST "$API_URL_V2/monitor/${ROOT_ACCOUNT}/dashboards" \
     -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
     -H "Cache-Control: no-cache" \
     -H "Content-Type: application/json" \
     -d '
         {
           "dashboard_name": "'"${APPLICATION_TEMPLATE}"'",
           "display_name": "'"${APPLICATION_TEMPLATE}"'",
           "space_name": "'"${SPACE_NAME}"'",
           "namespace": "'"${ROOT_ACCOUNT}"'"
         }
          ' | jq '.data.uuid' | sed 's/"//g')


TMPDIR=$(mktemp -d)

echo "service.net.bytes_sent:网络发送
service.net.bytes_rcvd:网络接收
service.mem.utilization:MEM使用
service.cpu.utilization:CPU使用" > ${TMPDIR}/METRIC.LIST

cat ${TMPDIR}/METRIC.LIST | while read line; do
    cat > ${TMPDIR}/METRIC.CFG <<EOF
     {
       "metrics": [{
         "type": "line",
         "metric": "$(echo ${line} | cut -d: -f1)",
         "over": "region_name=dev",
         "group_by": "service_name",
         "aggregator": "avg"
       }],
       "display_name": "$(echo ${line} | cut -d: -f2)",
       "namespace": "${ROOT_ACCOUNT}"
     }
EOF

curl -s -X POST "$API_URL_V2/monitor/${ROOT_ACCOUNT}/dashboards/${MONITOR_DASHBOARD_ID}/charts" \
     -H "Authorization: Token $ROOT_ACCOUNT_TOKEN" \
     -H "Cache-Control: no-cache" \
     -H "Content-Type: application/json" \
     -d @${TMPDIR}/METRIC.CFG
done
         
cd ${SHPATH}
