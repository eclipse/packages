#!/bin/sh
#*******************************************************************************
# Copyright (c) 2020, 2022 Contributors to the Eclipse Foundation
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

DEFAULT_TENANT_TRUSTED_CA=`cat default_tenant-trusted-ca.json`

add_tenant 'DEFAULT_TENANT' \
          "{
              \"enabled\": true,
              \"trusted-ca\": [
$DEFAULT_TENANT_TRUSTED_CA
              ]
            }"

add_tenant 'HTTP_TENANT' \
          '{
              "enabled": true,
              "adapters": [
                {
                  "type": "hono-amqp",
                  "enabled": false,
                  "device-authentication-required": true
                },
                {
                  "type": "hono-coap",
                  "enabled": false,
                  "device-authentication-required": true
                },
                {
                  "type": "hono-http",
                  "enabled": true,
                  "device-authentication-required": true
                },
                {
                  "type": "hono-lora",
                  "enabled": false,
                  "device-authentication-required": true
                },
                {
                  "type": "hono-mqtt",
                  "enabled": false,
                  "device-authentication-required": true
                }
              ]
            }'
