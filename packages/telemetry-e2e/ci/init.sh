#!/usr/bin/env bash

# Copyright (c) 2021 Contributors to the Eclipse Foundation
#
# See the NOTICE file(s) distributed with this work for additional
# information regarding copyright ownership.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License 2.0 which is available at
# http://www.eclipse.org/legal/epl-2.0
#
# SPDX-License-Identifier: EPL-2.0

set -o errexit
set -o pipefail

DOMAIN=.$(kubectl get node chart-testing-control-plane -o jsonpath='{.status.addresses[?(@.type == "InternalIP")].address}' | awk '// { print $1 }').nip.io

cat << __EOF__ > ci-values.yaml
global:
  domain: "$DOMAIN"
  cluster: kind
__EOF__

echo "Created CI values file:"
cat ci-values.yaml
