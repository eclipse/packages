{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "hawkbit.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hawkbit.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hawkbit.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "hawkbit.labels" -}}
app.kubernetes.io/name: {{ include "hawkbit.name" . }}
helm.sh/chart: {{ include "hawkbit.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "hawkbit.ingressAPIVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress" -}}
{{- print "networking.k8s.io/v1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret with the Hawkbit credentials.
*/}}
{{- define "hawkbit.secretName" -}}
  {{- if .Values.auth.existingSecret -}}
    {{ print (tpl .Values.auth.existingSecret $) -}}
  {{- else -}}
    {{ printf "%s" (include "hawkbit.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{/*
Database helpers — switch between externalDatabase and the bundled mysql subchart.
*/}}

{{- define "hawkbit.database.url" -}}
  {{- if .Values.externalDatabase.url -}}
    {{- .Values.externalDatabase.url -}}
  {{- else if and .Values.externalDatabase.host (eq (.Values.externalDatabase.type | default "mysql") "postgresql") -}}
    {{- printf "jdbc:postgresql://%s:%v/%s" .Values.externalDatabase.host (.Values.externalDatabase.port | default 5432) (.Values.externalDatabase.database | default "hawkbit") -}}
  {{- else if .Values.externalDatabase.host -}}
    {{- printf "jdbc:mariadb://%s:%v/%s" .Values.externalDatabase.host (.Values.externalDatabase.port | default 3306) (.Values.externalDatabase.database | default "hawkbit") -}}
  {{- else if .Values.mysql.enabled -}}
    {{- printf "jdbc:mariadb://%s-mysql:3306/%s" (include "hawkbit.fullname" .) .Values.mysql.auth.database -}}
  {{- else -}}
    {{- fail "Either externalDatabase.host or mysql.enabled must be set" -}}
  {{- end -}}
{{- end -}}

{{- define "hawkbit.database.user" -}}
  {{- if .Values.externalDatabase.user -}}
    {{- .Values.externalDatabase.user -}}
  {{- else if .Values.mysql.enabled -}}
    {{- "root" -}}
  {{- else -}}
    {{- fail "externalDatabase.user is required when mysql.enabled=false" -}}
  {{- end -}}
{{- end -}}

{{- define "hawkbit.database.secretName" -}}
  {{- if .Values.externalDatabase.existingSecret -}}
    {{- .Values.externalDatabase.existingSecret -}}
  {{- else if .Values.mysql.enabled -}}
    {{- include "mysql.secretName" .Subcharts.mysql -}}
  {{- else -}}
    {{- printf "%s-external-db" (include "hawkbit.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "hawkbit.database.secretPasswordKey" -}}
  {{- if .Values.externalDatabase.existingSecretPasswordKey -}}
    {{- .Values.externalDatabase.existingSecretPasswordKey -}}
  {{- else if .Values.mysql.enabled -}}
    {{- "mysql-root-password" -}}
  {{- else -}}
    {{- "password" -}}
  {{- end -}}
{{- end -}}

{{- define "hawkbit.database.secretUsernameKey" -}}
  {{- if .Values.externalDatabase.existingSecretUsernameKey -}}
    {{- .Values.externalDatabase.existingSecretUsernameKey -}}
  {{- end -}}
{{- end -}}

{{- define "hawkbit.spring.profiles" -}}
  {{- if .Values.spring.profiles -}}
    {{- .Values.spring.profiles -}}
  {{- else if eq (.Values.externalDatabase.type | default "mysql") "postgresql" -}}
    {{- "postgresql" -}}
  {{- else -}}
    {{- "mysql" -}}
  {{- end -}}
{{- end -}}
