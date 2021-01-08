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

add_credentials 'DEFAULT_TENANT' '4711' \
                '[
                  {
                      "type": "hashed-password",
                      "auth-id": "sensor1",
                      "enabled": true,
                      "secrets": [
                          {
                              "not-before": "2017-05-01T14:00:00+01:00",
                              "not-after": "2037-06-01T14:00:00+01:00",
                              "hash-function": "bcrypt",
                              "comment": "pwd: hono-secret",
                              "pwd-hash": "$2a$10$N7UMjhZ2hYx.yuvW9WVXZ.4y33mr6MvnpAsZ8wgLHnkamH2tZ1jD."
                          }
                      ]
                  },
                  {
                      "type": "psk",
                      "auth-id": "sensor1",
                      "enabled": true,
                      "secrets": [
                          {
                              "not-before": "2018-01-01T00:00:00+01:00",
                              "not-after": "2037-06-01T14:00:00+01:00",
                              "comment": "key: hono-secret",
                              "key": "aG9uby1zZWNyZXQ="
                          }
                      ]
                  },
                  {
                      "type": "x509-cert",
                      "auth-id": "CN=Device 4711,OU=Hono,O=Eclipse IoT,L=Ottawa,C=CA",
                      "enabled": true,
                      "secrets": [
                          {
                              "comment": "The secrets array must contain an object, which can be empty."
                          }
                      ]
                  }]'

add_credentials 'DEFAULT_TENANT' 'gw-1' \
                '[
                      {
                          "type": "hashed-password",
                          "auth-id": "gw",
                          "enabled": true,
                          "secrets": [
                              {
                                  "not-before": "2018-01-01T00:00:00+01:00",
                                  "not-after": "2037-06-01T14:00:00+01:00",
                                  "hash-function": "bcrypt",
                                  "comment": "pwd: gw-secret",
                                  "pwd-hash": "$2a$10$GMcN0iV9gJV7L1sH6J82Xebc1C7CGJ..Rbs./vcTuTuxPEgS9DOa6"
                              }
                          ]
                      },
                      {
                          "type": "psk",
                          "auth-id": "gw",
                          "enabled": true,
                          "secrets": [
                              {
                                  "not-before": "2018-01-01T00:00:00+01:00",
                                  "not-after": "2037-06-01T14:00:00+01:00",
                                  "comment": "key: gw-secret",
                                  "key": "Z3ctc2VjcmV0"
                              }
                          ]
                      }
              ]'
