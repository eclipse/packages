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

CHART_DIRS="$(git diff --find-renames --name-only "$(git rev-parse --abbrev-ref HEAD)" remotes/origin/master -- charts packages | grep '[cC]hart.yaml' | sed -e 's#/[Cc]hart.yaml##g')"
ROOT=$(pwd)

for CHART_DIR in ${CHART_DIRS}; do
  if [ -x "$CHART_DIR/ci/init.sh" ]; then
    echo "Running CI init script: $CHART_DIR/ci/init.sh"
    pushd "$CHART_DIR/ci"
    "$ROOT/$CHART_DIR/ci/init.sh"
    popd
  fi
done
