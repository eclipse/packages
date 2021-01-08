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

register_device 'DEFAULT_TENANT' '4711' \
                '{
                    "enabled": true,
                    "defaults": {
                        "content-type": "application/vnd.bumlux",
                        "importance": "high"
                    }
                }'

register_device 'DEFAULT_TENANT' '4712' \
                '{
                    "enabled": true,
                    "via": [
                        "gw-1"
                    ]
                }'

register_device 'DEFAULT_TENANT' 'gw-1' \
                '{
                    "enabled": true
                }'
