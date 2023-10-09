#!/bin/bash
#*******************************************************************************
# Copyright (c) 2020, 2023 Contributors to the Eclipse Foundation
#
# See the NOTICE file(s) distributed with this work for additional
# information regarding copyright ownership.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License 2.0 which is available at
# http://www.eclipse.org/legal/epl-2.0
#
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

RELEASE=${1:-$RELEASE}
NS=${2:-$NS}
TRUSTSTORE_PATH=${3:-$TRUSTSTORE_PATH}

if [[ -z "$RELEASE" ]] || [[ -z "$NS" ]] || [[ -z "$TRUSTSTORE_PATH" ]]; then
  echo "# Usage: $(basename "$0") [RELEASE] [NS] [TRUSTSTORE_PATH]"
  echo "#   RELEASE is the release name used for the cloud2edge deployment"
  echo "#   NS is the namespace the cloud2edge chart was deployed in"
  echo "#   TRUSTSTORE_PATH is the file path that the hono example truststore will be written to"
  echo "#  If arguments are omitted, the values of RELEASE, NS and TRUSTSTORE_PATH environment variables are used, respectively."
  exit 1
fi

NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}' 2> /dev/null)
if [[ -z "$NODE_IP" ]] ; then
  NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2> /dev/null)
fi

function getPorts {
  SERVICENAME=$1
  IP=$2
  PORT_NAMES=$3
  ENV_VAR_PREFIX=$4
  TYPE=$5

  for NAME in $PORT_NAMES; do
    PORT=$(kubectl get service $SERVICENAME -n $NS -o jsonpath='{.spec.ports[?(@.name=='"'$NAME'"')].'$TYPE'}' 2> /dev/null)
    if [ $? -eq 0 ] && [ "$PORT" != '' ]; then
      NAME=${NAME/secure-mqtt/mqtts}
      NAME=${NAME/query-http/http}
      UPPERCASE_PORT_NAME=$(echo $NAME | tr [a-z\-] [A-Z_])
      echo "export ${ENV_VAR_PREFIX}_PORT_${UPPERCASE_PORT_NAME}=\"$PORT\""
      if [[ $NAME == http* ]]; then
        if [ "$PORT" = '80' ]; then
          echo "export ${ENV_VAR_PREFIX}_BASE_URL=\"$NAME://$IP\""
          declare -g ${ENV_VAR_PREFIX}_BASE_URL="$NAME://$IP"
        else
          echo "export ${ENV_VAR_PREFIX}_BASE_URL=\"$NAME://$IP:$PORT\""
          declare -g ${ENV_VAR_PREFIX}_BASE_URL="$NAME://$IP:$PORT"
        fi
      fi
    fi
  done

}

function getService {
  SERVICENAME=${RELEASE}-$1
  PORT_NAMES=$2
  ENV_VAR_PREFIX=$3

  SERVICE_TYPE=$(kubectl get service $SERVICENAME -n $NS -o jsonpath='{.spec.type}' 2> /dev/null)
  if [ $? -eq 0 ]; then
    case $SERVICE_TYPE in
      NodePort)
        echo "export ${ENV_VAR_PREFIX}_IP=\"$NODE_IP\""
        getPorts $SERVICENAME "$NODE_IP" "$PORT_NAMES" $ENV_VAR_PREFIX nodePort
        ;;
      LoadBalancer)
        IP=$(kubectl get service $SERVICENAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}' -n $NS 2> /dev/null)
        if [ $? -eq 0 ] && [ "$IP" != '' ]; then
          echo "export ${ENV_VAR_PREFIX}_IP=\"$IP\""
          getPorts $SERVICENAME "$IP" "$PORT_NAMES" $ENV_VAR_PREFIX port
        fi
        ;;
    esac
  fi
}

getService hono-dispatch-router-ext "amqp amqps" AMQP_NETWORK
getService kafka-0-external "tcp-kafka" KAFKA
getService hono-service-device-registry-ext "http https" REGISTRY
getService hono-adapter-amqp "amqp amqps" AMQP_ADAPTER
getService hono-adapter-coap "coap coaps" COAP_ADAPTER
getService hono-adapter-http "http https" HTTP_ADAPTER
getService hono-adapter-mqtt "mqtt secure-mqtt" MQTT_ADAPTER
getService ditto-nginx "http" DITTO_API
getService hono-jaeger-query "query-http" JAEGER_QUERY

DITTO_DEVOPS_PWD=$(kubectl --namespace ${NS} get secret ${RELEASE}-ditto-gateway-secret -o jsonpath="{.data.devops-password}" | base64 --decode)
echo "export DITTO_DEVOPS_PWD=\"$DITTO_DEVOPS_PWD\""
echo "export DITTO_UI_ENV_JSON=\"{\\\"api_uri\\\":\\\"${DITTO_API_BASE_URL}\\\",\\\"defaultUsernamePassword\\\":\\\"ditto:ditto\\\",\\\"defaultDittoPreAuthenticatedUsername\\\":null,\\\"defaultUsernamePasswordDevOps\\\":\\\"devops:${DITTO_DEVOPS_PWD}\\\",\\\"mainAuth\\\":\\\"basic\\\",\\\"devopsAuth\\\":\\\"basic\\\"}\""

kubectl get configmaps --namespace ${NS} ${RELEASE}-hono-example-trust-store --template="{{index .data \"ca.crt\"}}" > "${TRUSTSTORE_PATH}"
echo "export MOSQUITTO_OPTIONS=\"--cafile ${TRUSTSTORE_PATH} --insecure\""

echo
echo "# Run this command to populate environment variables"
echo "# for accessing Hono's and Ditto's API endpoints:"
echo "#"
echo "# eval \$(./$(basename "$0") $*)"
echo
