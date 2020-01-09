#!/usr/bin/env bash
#
# check for chart changes to speedup ci
#

# Copyright (c) 2019 Contributors to the Eclipse Foundation
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

CHART_REPO="https://github.com/eclipse/packages.git"

echo "Check for chart changes to speedup ci..."

git remote add chart-changes "${CHART_REPO}"
git fetch chart-changes master

if [ -z "$(git diff --find-renames --name-only "$(git rev-parse --abbrev-ref HEAD)" remotes/chart-changes/master -- charts)" ]; then
  echo -e "\n\n Error! No chart changes detected! Exiting... \n"
  exit 1
else
  echo -e "\n Changes found... Continue with next job... \n"
fi
