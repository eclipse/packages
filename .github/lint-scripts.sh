#!/bin/sh
#
# lint bash scripts
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

CONFIG_DIR=".github"

TMP_FILE="$(mktemp)"

find "${CONFIG_DIR}" -type f -name "*.sh" > "${TMP_FILE}"

while read -r FILE; do
  echo lint "${FILE}"
  shellcheck -x "${FILE}"
done < "${TMP_FILE}"
