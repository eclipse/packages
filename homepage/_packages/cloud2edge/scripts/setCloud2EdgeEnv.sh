#!/bin/bash
#*******************************************************************************
# Copyright (c) 2020 Contributors to the Eclipse Foundation
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

RELEASE=$1
NS=${2:-default}

NODE_IP=$(kubectl get node -n $NS --output jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2> /dev/null)

function getPorts {
  SERVICENAME=$1
  PORT_NAMES=$2
  ENV_VAR_PREFIX=$3
  TYPE=$4

  for NAME in $PORT_NAMES
  do
    PORT=$(kubectl get service $SERVICENAME -n $NS --output jsonpath='{.spec.ports[?(@.name=='"'$NAME'"')].'$TYPE'}' 2> /dev/null)
    if [ $? -eq 0 -a "$PORT" != '' ]
    then
      UPPERCASE_PORT_NAME=$(echo $NAME | tr [a-z\-] [A-Z_])
      echo "export ${ENV_VAR_PREFIX}_PORT_${UPPERCASE_PORT_NAME}=\"$PORT\""
    fi
  done

}

function getService {
  SERVICENAME=${RELEASE}-$1
  PORT_NAMES=$2
  ENV_VAR_PREFIX=$3

  SERVICE_TYPE=$(kubectl get service $SERVICENAME -n $NS --output jsonpath='{.spec.type}' 2> /dev/null)
  if [ $? -eq 0 ]
  then
    case $SERVICE_TYPE in
      NodePort)
        echo "export ${ENV_VAR_PREFIX}_IP=\"$NODE_IP\""
        getPorts $SERVICENAME "$PORT_NAMES" $ENV_VAR_PREFIX nodePort
        ;;
      LoadBalancer)
        IP=$(kubectl get service $SERVICENAME --output='jsonpath={.status.loadBalancer.ingress[0].ip}' -n $NS 2> /dev/null)
        if [ $? -eq 0 -a "$IP" != '' ]
        then
          echo "export ${ENV_VAR_PREFIX}_IP=\"$IP\""
          getPorts $SERVICENAME "$PORT_NAMES" $ENV_VAR_PREFIX port
        fi
        ;;
    esac
  fi
}

getService dispatch-router-ext "amqp amqps" AMQP_NETWORK
getService service-device-registry-ext "http https" REGISTRY
getService adapter-amqp-vertx "amqp amqps" AMQP_ADAPTER
getService adapter-coap-vertx "coap coaps" COAP_ADAPTER
getService adapter-http-vertx "http https" HTTP_ADAPTER
getService adapter-mqtt-vertx "mqtt secure-mqtt" MQTT_ADAPTER
getService ditto-nginx "http" DITTO_API

echo "# Run this command to populate environment variables"
echo "# with the NodePorts of Hono's and Ditto's API endpoints:"
echo "# eval \"\$(./setCloude2EdgeEnv.sh RELEASE_NAME [NAMESPACE])\""
echo "# with NAMESPACE being the Kubernetes name space that you installed Hono to"
echo "# if no name space is given, the default name space is used"

