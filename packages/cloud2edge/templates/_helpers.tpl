#
# Copyright (c) 2020, 2023 Contributors to the Eclipse Foundation
#
# See the NOTICE file(s) distributed with this work for additional
# information regarding copyright ownership.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License 2.0 which is available at
# http://www.eclipse.org/legal/epl-2.0
#
# SPDX-License-Identifier: EPL-2.0
#
{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "c2e.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "c2e.chart" }}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Get the full name of the Hono sub chart.
*/}}
{{- define "c2e.hono.fullname" -}}
  {{- include "hono.fullname" .Subcharts.hono -}}
{{- end -}}

{{/*
Get the full name of the Kafka sub chart (referenced by the Hono chart).
*/}}
{{- define "c2e.kafka.fullname" -}}
  {{- include "common.names.fullname" .Subcharts.hono.Subcharts.kafka -}}
{{- end -}}

{{/*
Get the full name of the Ditto sub chart.
*/}}
{{- define "c2e.ditto.fullname" -}}
  {{- include "ditto.fullname" .Subcharts.ditto -}}
{{- end -}}
