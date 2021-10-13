#!/bin/bash
#
# use kubeval to validate helm generated kubernetes manifest
#

# Copyright (c) 2019, 2021 Contributors to the Eclipse Foundation
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
KUBEVAL_VERSION="v0.16.1"
SCHEMA_LOCATION="https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/"

# install kubeval
curl --silent --show-error --fail --location --output /tmp/kubeval.tar.gz https://github.com/instrumenta/kubeval/releases/download/"${KUBEVAL_VERSION}"/kubeval-linux-amd64.tar.gz
sudo tar -C /usr/local/bin -xf /tmp/kubeval.tar.gz kubeval

# add helm repos to resolve dependencies
helm repo add stable https://charts.helm.sh/stable
helm repo add packages https://eclipse.org/packages/charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# validate charts
for CHART_DIR in ${CHART_DIRS}; do
  echo "helm dependency build..."
  helm dependency build "${CHART_DIR}"

  echo "kubeval(idating) ${CHART_DIR##charts/} chart..."
  helm template "${CHART_DIR}" | kubeval --strict --ignore-missing-schemas --kubernetes-version "${KUBERNETES_VERSION#v}" --schema-location "${SCHEMA_LOCATION}"
done

