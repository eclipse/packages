#!/usr/bin/env bash

# liveness-probe - checks if a given ActiveMQ Artemis broker instance is running
#
# Copyright (c) 2022 Contributors to the Eclipse Foundation
##
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License 2.0 which is available at
# http://www.eclipse.org/legal/epl-2.0
#
# SPDX-License-Identifier: EPL-2.0
#
# liveness-probe [broker_name]
#

brokerName=${1:-hono-broker}
url="http://localhost:8161/console/jolokia/read/org.apache.activemq.artemis:broker=%22${brokerName}%22/Version"

curl -s --user artemis:artemis -H "Origin: http://0.0.0.0" ${url}

