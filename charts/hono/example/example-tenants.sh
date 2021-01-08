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

add_tenant 'DEFAULT_TENANT' \
          '{
              "enabled": true,
              "trusted-ca": [
                {
                  "subject-dn": "CN=DEFAULT_TENANT_CA,OU=Hono,O=Eclipse IoT,L=Ottawa,C=CA",
                  "public-key": "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAElkwCSPlO563eQb6ONdULAISm2XngGGSoAAz+I1s8zkS9guPUpNKoxeczLtKlObelHqBgIZtRXdrPRgXidGOnmQ==",
                  "algorithm": "EC",
                  "not-before": "2019-09-18T10:35:40+02:00",
                  "not-after": "2020-09-17T10:35:40+02:00"
                }
              ]
            }'

add_tenant 'HTTP_TENANT' \
          '{
              "enabled": true,
              "adapters": [
                {
                  "type": "hono-http",
                  "enabled": true,
                  "device-authentication-required": true
                },
                {
                  "type": "hono-mqtt",
                  "enabled": false,
                  "device-authentication-required": true
                },
                {
                  "type": "hono-kura",
                  "enabled": false,
                  "device-authentication-required": true
                },
                {
                  "type": "hono-coap",
                  "enabled": false,
                  "device-authentication-required": true
                }
              ]
            }'
