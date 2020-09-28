#!/bin/sh
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
HTTP_BASE_URL="http://{{ .Release.Name }}-service-device-registry:8080/v1"

check_status() {
  EXIT_STATUS=$1
  HTTP_RESPONSE=$2

  if [ $EXIT_STATUS -ne 0 ]
  then
    echo "Curl command failed [exit-code: $EXIT_STATUS]"
    exit 1
  elif [ $HTTP_RESPONSE -ne "201" || $HTTP_RESPONSE -ne "204" || $HTTP_RESPONSE -ne "409"]
  then
    echo "Http request failed [http-response: $HTTP_RESPONSE]"
    exit 1
  fi
}

echo "Device Registry Http endpoint base url: [$HTTP_BASE_URL]"

add_tenant(){
  TENANT_ID=$1
  HTTP_REQUEST_BODY=$2

  echo "Adding tenant [$TENANT_ID]"
  HTTP_RESPONSE=$(curl -w "%{http_code}" \
                    -X POST "$HTTP_BASE_URL/tenants/$TENANT_ID" \
                    --header 'Content-Type: application/json' \
                    --data-raw "$HTTP_REQUEST_BODY")

  check_status $? $HTTP_RESPONSE
}

register_device(){
  TENANT_ID=$1
  DEVICE_ID=$2
  HTTP_REQUEST_BODY=$3

  echo "Registering device [$TENANT_ID:$DEVICE_ID]"
  HTTP_RESPONSE=$(curl -w "%{http_code}" \
                  -X POST "$HTTP_BASE_URL/devices/$TENANT_ID/$DEVICE_ID" \
                  --header 'Content-Type: application/json' \
                  --data-raw "$HTTP_REQUEST_BODY")

  check_status $? $HTTP_RESPONSE
}


add_credentials(){
  TENANT_ID=$1
  DEVICE_ID=$2
  HTTP_REQUEST_BODY=$3

  echo "Adding credentials [$TENANT_ID:$DEVICE_ID]"
  HTTP_RESPONSE=$(curl -w "%{http_code}" \
                -X PUT "$HTTP_BASE_URL/credentials/$1/$2" \
                --header 'Content-Type: application/json' \
                --data-raw "$3")

  check_status $? $HTTP_RESPONSE
}

. ./example-tenants.sh
. ./example-devices.sh
. ./example-credentials.sh
