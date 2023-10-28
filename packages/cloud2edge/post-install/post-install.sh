#!/bin/sh
#*******************************************************************************
# Copyright (c) 2023 Contributors to the Eclipse Foundation
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

DITTO_DEVOPS_USER_PW="devops:$(cat /var/run/c2e/ditto-gw-users/devops-password)"
DEVICE_REGISTRY_URL_SCHEME="{{- if ( eq .Values.hono.deviceRegistryExample.hono.registry.http.insecurePortEnabled true ) }}http{{ else }}https{{ end }}"
DEVICE_REGISTRY_PORT=$([ "${DEVICE_REGISTRY_URL_SCHEME}" = "http" ] && echo "8080" || echo "8443")
DEVICE_REGISTRY_BASE_URL="${DEVICE_REGISTRY_URL_SCHEME}://{{ include "c2e.hono.fullname" . }}-service-device-registry:${DEVICE_REGISTRY_PORT}/v1"
DITTO_CONNECTIONS_BASE_URL="http://{{ include "c2e.ditto.fullname" . }}-nginx:8080/api/2/connections"
DITTO_THINGS_BASE_URL="http://{{ include "c2e.ditto.fullname" . }}-nginx:8080/api/2/things"

DEMO_TENANT="{{ .Values.demoDevice.tenant }}"
DEMO_DEVICE="$DEMO_TENANT:{{ .Values.demoDevice.deviceId }}"
IS_USING_AMQP="{{- if ( has "amqp" .Values.hono.messagingNetworkTypes ) }}true{{ else }}false{{ end }}"
IS_USING_KAFKA="{{- if ( has "kafka" .Values.hono.messagingNetworkTypes ) }}true{{ else }}false{{ end }}"

check_status() {
  exit_code="$1"
  response_body_and_status="$2"

  if [ "$exit_code" -ne 0 ]; then
    echo "curl command failed [exit-code: $exit_code]"
    exit 1
  fi
  http_code=$(echo "$response_body_and_status" | tail -n1) # get last line
  body=$(echo "$response_body_and_status" | sed '$ d') # get all but last line
  # echo "DEBUG: Got [status: $http_code, response: $body]"
  if [ "$http_code" -eq "409" ]; then
    # HTTP 409 Conflict (e.g. "device already exists") ignored here
    echo "Ignoring Http response 409 [$body]"
  elif [ "$http_code" -ge "400" ]; then
    echo "Http request failed [status: $http_code, response: $body]"
    exit 1
  fi
}

add_hono_tenant(){
  tenant_id="$1"
  http_request_body="$2"

  echo "Adding tenant [$tenant_id]"
  response_body_and_status=$(curl --silent --write-out "\n%{http_code}" -k \
                    -X POST --header 'Content-Type: application/json' \
                    --data-raw "$http_request_body" "$DEVICE_REGISTRY_BASE_URL/tenants/$tenant_id")
  check_status $? "$response_body_and_status"
}

register_hono_device(){
  tenant_id="$1"
  device_id="$2"
  http_request_body="$3"

  echo "Registering device [tenant: $tenant_id, device: $device_id]"
  response_body_and_status=$(curl --silent --write-out "\n%{http_code}" -k \
                  -X POST --header 'Content-Type: application/json' \
                  --data-raw "$http_request_body" "$DEVICE_REGISTRY_BASE_URL/devices/$tenant_id/$device_id")
  check_status $? "$response_body_and_status"
}

add_hono_device_credentials(){
  tenant_id="$1"
  device_id="$2"
  http_request_body_file="$3"

  echo "Adding credentials [tenant: $tenant_id, device: $device_id]"
  response_body_and_status=$(curl --silent --write-out "\n%{http_code}" -k \
                -X PUT --header 'Content-Type: application/json' \
                --data-binary "@$http_request_body_file" "$DEVICE_REGISTRY_BASE_URL/credentials/$tenant_id/$device_id")
  check_status $? "$response_body_and_status"
}

add_connection_in_ditto(){
  connection_id_prefix="$1"
  tenant_id="$2"
  http_request_body_file="$3"

  tenant_adapted=$(echo "$tenant_id" | sed "s/\./_/g")
  connection_id="${connection_id_prefix}${tenant_adapted}"
  echo "Adding ditto connection '$connection_id' [URL: ${DITTO_CONNECTIONS_BASE_URL}/${connection_id}]"
  response_body_and_status=$(curl --silent --write-out "\n%{http_code}" \
                -X PUT -u "$DITTO_DEVOPS_USER_PW" --header 'Content-Type: application/json' \
                --data-binary "@$http_request_body_file" "${DITTO_CONNECTIONS_BASE_URL}/${connection_id}")
  check_status $? "$response_body_and_status"
}

add_ditto_device(){
  device="$1"
  http_request_body_file="$2"
  
  echo "Adding ditto thing '$device' [URL: $DITTO_THINGS_BASE_URL/$device]"
  response_body_and_status=$(curl --silent --write-out "\n%{http_code}" \
                -X PUT -u ditto:ditto --header 'Content-Type: application/json' \
                --data-binary "@$http_request_body_file" "$DITTO_THINGS_BASE_URL/$device")
  check_status $? "$response_body_and_status"
}

# ----------------------------------------------

echo "Device Registry Http endpoint base url: $DEVICE_REGISTRY_BASE_URL"
add_hono_tenant "$DEMO_TENANT" "{}"
register_hono_device "$DEMO_TENANT" "$DEMO_DEVICE" "{}"
add_hono_device_credentials "$DEMO_TENANT" "$DEMO_DEVICE" "demo-device-credentials.json"

if [ "$IS_USING_AMQP" = "true" ]; then
  add_connection_in_ditto "hono-amqp-connection-for-" "$DEMO_TENANT" "hono-amqp-connection.json"
fi
if [ "$IS_USING_KAFKA" = "true" ]; then
  cp hono-kafka-connection.json /tmp/hono-kafka-connection.json
  chmod 777 /tmp/hono-kafka-connection.json
  certPath=/var/run/c2e/kafka-connection-cert/tls.crt
  if [ -e $certPath ]; then
      echo "Adapting hono-kafka-connection.json"
      # Necessary transformation in order to comply with the expected format of certificates
      # imposed by the Ditto connectivity API: "ca": "-----BEGIN CERTIFICATE-----\n<trusted certificate>\n-----END CERTIFICATE-----"
      cert="$(< $certPath tr -d '\n' | sed 's/E-----/E-----\\\\n/g' | sed 's/-----END/\\\\n-----END/g')"
      sed -i '/uri/ a '"\"ca\": \"$cert\","'' /tmp/hono-kafka-connection.json
  fi
  add_connection_in_ditto "hono-kafka-connection-for-" "$DEMO_TENANT" "/tmp/hono-kafka-connection.json"
fi

add_ditto_device "$DEMO_DEVICE" "demo-device-thing.json"

echo "DONE"
