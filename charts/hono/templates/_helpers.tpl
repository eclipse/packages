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
#
{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "hono.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hono.fullname" -}}
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
{{- define "hono.chart" }}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Adds an element to a Container array.
Sets "name" and "image" values and adds an "Always" "imagePullPolicy"
if the image tag contains "SNAPSHOT" and a custom image name
(not starting with "index.docker.io/eclipse/") is used.

The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root (".") scope
- (mandatory) "name": the value to use as the container's name
- (mandatory) "componentConfig": a dict with keys
  - (mandatory) "imageName"
  - (optional) "imageTag"
  - (optional) "containerRegistry"
  - (optional) "useImageType": should image type configuration be used
*/}}
{{- define "hono.container" }}
{{- $tag := default .dot.Chart.AppVersion ( default .dot.Values.honoImagesTag .componentConfig.imageTag ) }}
{{- $registry := default .dot.Values.honoContainerRegistry .componentConfig.containerRegistry }}
{{- $image := printf "%s/%s:%s" $registry .componentConfig.imageName $tag -}}
{{- if and .useImageType ( contains "quarkus" .dot.Values.honoImagesType ) }}
{{- $image = printf "%s/%s-%s:%s" $registry .componentConfig.imageName .dot.Values.honoImagesType $tag -}}
{{- end }}
- name: {{ .name | quote }}
  image: {{ $image | quote }}
{{- if and ( contains "SNAPSHOT" $tag ) ( not ( hasPrefix "index.docker.io/eclipse/" $image ) ) }}
  imagePullPolicy: "Always"
{{- end }}
{{- end }}


{{/*
Add standard labels for resources as recommended by Helm best practices.
*/}}
{{- define "hono.std.labels" -}}
app.kubernetes.io/name: {{ template "hono.name" . }}
helm.sh/chart: {{ template "hono.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}


{{/*
Add standard labels and name for resources as recommended by Helm best practices.
The scope passed in is expected to be a dict with keys
- "dot": the "." scope and
- "name": the value to use for the "name" metadata property
- "component": the value to use for the "app.kubernetes.io/component" label
*/}}
{{- define "hono.metadata" -}}
name: {{ .dot.Release.Name }}-{{ .name }}
namespace: {{ .dot.Release.Namespace }}
labels:
  app.kubernetes.io/name: {{ template "hono.name" .dot }}
  helm.sh/chart: {{ template "hono.chart" .dot }}
  app.kubernetes.io/managed-by: {{ .dot.Release.Service }}
  app.kubernetes.io/instance: {{ .dot.Release.Name }}
  app.kubernetes.io/version: {{ .dot.Chart.AppVersion }}
  {{- if .component }}
  app.kubernetes.io/component: {{ .component }}
  {{- end }}
{{- end }}

{{/*
Add standard match labels to be used in podTemplateSpecs and serviceMatchers.
The scope passed in is expected to be a dict with keys
- "dot": the "." scope and
- "component": the value of the "app.kubernetes.io/component" label to match
*/}}
{{- define "hono.matchLabels" -}}
app.kubernetes.io/name: {{ template "hono.name" .dot }}
app.kubernetes.io/instance: {{ .dot.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Add annotations for marking an object to be scraped by Prometheus.
*/}}
{{- define "hono.monitoringAnnotations" -}}
prometheus.io/scrape: "true"
prometheus.io/path: "/prometheus"
prometheus.io/port: {{ default .Values.healthCheckPort .Values.monitoring.prometheus.port | quote }}
{{- end }}


{{/*
Creates a headless Service for a Hono component.
The scope passed in is expected to be a dict with keys
- "dot": the "." scope and
- "name": the value to use for the "name" metadata property
- "component": the value of the "app.kubernetes.io/component" label to match
*/}}
{{- define "hono.headless.service" }}
{{- $args := dict "dot" .dot "component" .component "name" (printf "%s-headless" .name) }}
---
apiVersion: v1
kind: Service
metadata:
  {{- include "hono.metadata" $args | nindent 2 }}
spec:
  clusterIP: None
  selector:
    {{- include "hono.matchLabels" $args | nindent 4 }}
{{- end }}


{{/*
Configuration for the health check server of service components.
If the scope passed in is not 'nil', then its value is
used as the configuration for the health check server.
Otherwise, a secure health check server will be configured to bind to all
interfaces on the default port using the component's key and cert.
*/}}
{{- define "hono.healthServerConfig" -}}
healthCheck:
{{- if . }}
  {{- toYaml . | nindent 2 }}
{{- else }}
  port: 8088
  bindAddress: "0.0.0.0"
  keyPath: "/etc/hono/key.pem"
  certPath: "/etc/hono/cert.pem"
{{- end }}
{{- end }}


{{/*
Configuration for the AMQP messaging network clients.
The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".") and
- (mandatory) "component": the name of the component
*/}}
{{- define "hono.amqpMessagingNetworkClientConfig" -}}
messaging:
{{- if .dot.Values.amqpMessagingNetworkExample.enabled }}
  name: Hono {{ .component }}
  amqpHostname: hono-internal
  host: {{ .dot.Release.Name }}-dispatch-router
  port: 5673
  keyPath: {{ .dot.Values.adapters.amqpMessagingNetworkSpec.keyPath }}
  certPath: {{ .dot.Values.adapters.amqpMessagingNetworkSpec.certPath }}
  trustStorePath: {{ .dot.Values.adapters.amqpMessagingNetworkSpec.trustStorePath }}
  hostnameVerificationRequired: {{ .dot.Values.adapters.amqpMessagingNetworkSpec.hostnameVerificationRequired }}
{{- else }}
  {{- required ".Values.adapters.amqpMessagingNetworkSpec MUST be set if example AMQP Messaging Network is disabled" .dot.Values.adapters.amqpMessagingNetworkSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}


{{/*
Configuration for the clients accessing the example Device Registry.
The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".") and
- (mandatory) "component": the name of the component
*/}}
{{- define "hono.deviceRegistryExampleClientConfig" -}}
name: Hono {{ .component }}
host: {{ .dot.Release.Name }}-service-device-registry
port: 5671
credentialsPath: /etc/hono/adapter.credentials
trustStorePath: /etc/hono/trusted-certs.pem
hostnameVerificationRequired: false
{{- end }}


{{/*
Configuration for the service clients of protocol adapters.
The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".") and
- (optional) "component": the name of the adapter
*/}}
{{- define "hono.serviceClientConfig" -}}
{{- $adapter := default "adapter" .component -}}
{{- include "hono.amqpMessagingNetworkClientConfig" ( dict "dot" .dot "component" $adapter ) }}
command:
{{- if .dot.Values.amqpMessagingNetworkExample.enabled }}
  name: Hono {{ $adapter }}
  amqpHostname: hono-internal
  host: {{ .dot.Release.Name }}-dispatch-router
  port: 5673
  keyPath: {{ .dot.Values.adapters.commandAndControlSpec.keyPath }}
  certPath: {{ .dot.Values.adapters.commandAndControlSpec.certPath }}
  trustStorePath: {{ .dot.Values.adapters.commandAndControlSpec.trustStorePath }}
  hostnameVerificationRequired: {{ .dot.Values.adapters.commandAndControlSpec.hostnameVerificationRequired }}
{{- else }}
  {{- required ".Values.adapters.commandAndControlSpec MUST be set if example AMQP Messaging Network is disabled" .dot.Values.adapters.commandAndControlSpec | toYaml | nindent 2 }}
{{- end }}
tenant:
{{- if .dot.Values.adapters.tenantSpec }}
  {{- .dot.Values.adapters.tenantSpec | toYaml | nindent 2 }}
{{- else if .dot.Values.deviceRegistryExample.enabled }}
  {{- include "hono.deviceRegistryExampleClientConfig" ( dict "dot" .dot "component" $adapter ) | nindent 2 }}
{{- else }}
  {{- required ".Values.adapters.tenantSpec MUST be set if example Device Registry is disabled" .dot.Values.adapters.tenantSpec | toYaml | nindent 2 }}
{{- end }}
registration:
{{- if .dot.Values.adapters.deviceRegistrationSpec }}
  {{- .dot.Values.adapters.deviceRegistrationSpec | toYaml | nindent 2 }}
{{- else if .dot.Values.deviceRegistryExample.enabled }}
  {{- include "hono.deviceRegistryExampleClientConfig" ( dict "dot" .dot "component" $adapter ) | nindent 2 }}
{{- else }}
  {{- required ".Values.adapters.deviceRegistrationSpec MUST be set if example Device Registry is disabled" .dot.Values.adapters.deviceRegistrationSpec | toYaml | nindent 2 }}
{{- end }}
credentials:
{{- if .dot.Values.adapters.credentialsSpec }}
  {{- .dot.Values.adapters.credentialsSpec | toYaml | nindent 2 }}
{{- else if .dot.Values.deviceRegistryExample.enabled }}
  {{- include "hono.deviceRegistryExampleClientConfig" ( dict "dot" .dot "component" $adapter ) | nindent 2 }}
{{- else }}
  {{- required ".Values.adapters.credentialsSpec MUST be set if example Device Registry is disabled" .dot.Values.adapters.credentialsSpec | toYaml | nindent 2 }}
{{- end }}
{{- if .dot.Values.useCommandRouter }}
commandRouter:
{{- if .dot.Values.adapters.commandRouterSpec }}
  {{/* user has provided connection params for third party Command Router service */}}
  {{- .dot.Values.adapters.commandRouterSpec | toYaml | nindent 2 }}
{{- else if .dot.Values.commandRouterService.enabled }}
  name: Hono {{ $adapter }}
  host: {{ .dot.Release.Name }}-service-command-router
  port: 5671
  credentialsPath: /etc/hono/adapter.credentials
  trustStorePath: /etc/hono/trusted-certs.pem
  hostnameVerificationRequired: false
{{- else }}
  {{- required "Either .Values.adapters.commandRouterSpec MUST be set or .Values.commandRouterService.enabled MUST be 'true' if useCommandRouter is 'true'" nil }}
{{- end }}
{{- else }}
  {{/* useCommandRouter is false - device connection service will be used */}}
deviceConnection:
{{- if .dot.Values.dataGridSpec }}
  {{/* user has specified connection parameters for existing data grid */}}
  {{- .dot.Values.dataGridSpec | toYaml | nindent 2 }}
{{- else if .dot.Values.dataGridExample.enabled }}
  {{/* connect directly to example data grid */}}
  {{- $serverName := printf "%s-data-grid" .dot.Release.Name }}
  serverList: {{ printf "%s:11222" $serverName | quote }}
  authServerName: {{ $serverName | quote }}
  authUsername: {{ .dot.Values.dataGridExample.authUsername | quote }}
  authPassword: {{ .dot.Values.dataGridExample.authPassword | quote }}
  authRealm: "ApplicationRealm"
  saslMechanism: "DIGEST-MD5"
  socketTimeout: 5000
  connectTimeout: 5000
{{- else if .dot.Values.adapters.deviceConnectionSpec }}
  {{/* user has provided connection params for third party Device Connection service */}}
  {{- .dot.Values.adapters.deviceConnectionSpec | toYaml | nindent 2 }}
{{- else }}
  name: Hono {{ $adapter }}
  {{- if .dot.Values.deviceConnectionService.enabled }}
  host: {{ .dot.Release.Name }}-service-device-connection
  {{- else if .dot.Values.deviceRegistryExample.enabled }}
  host: {{ .dot.Release.Name }}-service-device-registry
  {{- else }}
  {{- required ".Values.deviceConnectionService.enabled MUST be set to true if example Device Registry is disabled and no other Device Connection service is configured" nil }}
  {{- end }}
  port: 5671
  credentialsPath: /etc/hono/adapter.credentials
  trustStorePath: /etc/hono/trusted-certs.pem
  hostnameVerificationRequired: false
{{- end }}
{{- end }}
{{- if .dot.Values.prometheus.createInstance }}
resourceLimits:
  prometheusBased:
    host: {{ template "hono.prometheus.server.fullname" .dot }}
{{- else if .dot.Values.prometheus.host }}
resourceLimits:
  prometheusBased:
    host: {{ .dot.Values.prometheus.host }}
    port: {{ default "9090" .dot.Values.prometheus.port }}
{{- end }}
{{- end }}


{{/*
Adds environment variables for Spring Boot
to a component's container.

The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".")
- (mandatory) "componentConfig": the component's configuration properties from the values.yaml file
- (optional) "useImageType": indicates if image type (Quarkus, Spring) should be considered (defaults to false)
- (optional) "additionalProfile": any additional application profile to add
*/}}
{{- define "hono.component.springEnv" }}
{{- if not ( and ( default false .useImageType ) ( contains "quarkus" .dot.Values.honoImagesType ) ) }}
{{- $applicationProfiles := default "dev" ( default .dot.Values.adapters.applicationProfiles .componentConfig.applicationProfiles ) }}
- name: SPRING_CONFIG_LOCATION
  value: {{ default "file:///etc/hono/" .componentConfig.springConfigLocation | quote }}
- name: LOGGING_CONFIG
  value: {{ default "classpath:logback-spring.xml" .componentConfig.loggingConfig | quote }}
- name: SPRING_PROFILES_ACTIVE
  value: {{ print $applicationProfiles ( ( empty .additionalProfile ) | ternary "" "," ) ( default "" .additionalProfile ) | quote }}
{{- end }}
{{- end }}


{{/*
Add Quarkus related configuration properties to YAML file.

The scope passed in is expected to be a dict with keys
- (mandatory ) "dot": the root scope (".")
*/}}
{{- define "hono.quarkusConfig" -}}
{{- if ( contains "quarkus" .dot.Values.honoImagesType ) }}
quarkus:
  jaeger:
    service-name: {{ printf "%s-%s" .dot.Release.Name .component | quote }}
  log:
    console:
      color: true
    level: INFO
    category:
      "org.eclipse.hono":
        level: INFO
      "org.eclipse.hono.adapter":
        level: INFO
      "org.eclipse.hono.service":
        level: INFO
  vertx:
    prefer-native-transport: true
{{- end }}
{{- end }}


{{/*
Create a fully qualified Prometheus server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "hono.prometheus.server.fullname" -}}
{{- if .Values.prometheus.server.fullnameOverride -}}
{{- .Values.prometheus.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "prometheus" .Values.prometheus.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.prometheus.server.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.prometheus.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Adds a Jaeger Agent container to a template spec.
*/}}
{{- define "hono.jaeger.agent" }}
{{- $jaegerEnabled := or .Values.jaegerBackendExample.enabled .Values.jaegerAgentConf }}
{{- if $jaegerEnabled }}
- name: jaeger-agent-sidecar
  image: {{ .Values.jaegerAgentImage }}
  ports:
  - name: agent-compact
    containerPort: 6831
    protocol: UDP
  - name: agent-binary
    containerPort: 6832
    protocol: UDP
  - name: agent-configs
    containerPort: 5778
    protocol: TCP
  - name: admin-http
    containerPort: 14271
    protocol: TCP
  readinessProbe:
    httpGet:
      path: "/"
      port: admin-http
    initialDelaySeconds: 5
  env:
  {{- if .Values.jaegerBackendExample.enabled }}
  - name: REPORTER_GRPC_HOST_PORT
    value: {{ printf "%s-jaeger-collector:14250" .Release.Name | quote }}
  - name: REPORTER_GRPC_DISCOVERY_MIN_PEERS
    value: "1"
  {{- else }}
  {{- range $key, $value := .Values.jaegerAgentConf }}
  - name: {{ $key }}
    value: {{ $value | quote }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Adds Jaeger client configuration to a container's "env" properties.
The scope passed in is expected to be a dict with keys
- "dot": the root scope (".") and
- "name": the value to use for the JAEGER_SERVICE_NAME (prefixed with the release name).
*/}}
{{- define "hono.jaeger.clientConf" }}
{{- $agentHost := printf "%s-jaeger-agent" .dot.Release.Name }}
{{/* Note that for quarkus containers, the "quarkus.jaeger.service-name" property needs to be set instead, see https://github.com/quarkusio/quarkus/issues/17400 */}}
- name: JAEGER_SERVICE_NAME
  value: {{ printf "%s-%s" .dot.Release.Name .component | quote }}
{{- if and .dot.Values.jaegerBackendExample.enabled ( eq .dot.Values.honoImagesType "quarkus-native" ) }}
- name: JAEGER_SAMPLER_TYPE
  value: "const"
- name: JAEGER_SAMPLER_PARAM
  value: "1"
{{- else if and ( not .dot.Values.jaegerBackendExample.enabled ) ( empty .dot.Values.jaegerAgentConf ) }}
- name: JAEGER_SAMPLER_TYPE
  value: "const"
- name: JAEGER_SAMPLER_PARAM
  value: "0"
{{- end }}
{{- end }}


{{/*
Adds liveness/readiness checks to a Hono component's container.

The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".")
- (mandatory) "componentConfig": the component's configuration properties from the values.yaml file
*/}}
{{- define "hono.component.healthChecks" }}
livenessProbe:
  httpGet:
    path: /liveness
    port: health
    scheme: HTTPS
  initialDelaySeconds: {{ default .dot.Values.livenessProbeInitialDelaySeconds .componentConfig.livenessProbeInitialDelaySeconds }}
readinessProbe:
  httpGet:
    path: /readiness
    port: health
    scheme: HTTPS
  initialDelaySeconds: {{ default .dot.Values.readinessProbeInitialDelaySeconds .componentConfig.readinessProbeInitialDelaySeconds }}
{{- end }}

{{/*
Adds volume mounts to a component's container.

The scope passed in is expected to be a dict with keys
- (mandatory) "name": the name of the component
- (mandatory) "componentConfig": the component's configuration properties as defined in .Values
- (optional) "dot": the root scope (".")
- (optional) "configMountPath": the mount path to use for the component's config secret
                                instead of the default "/etc/hono"
*/}}
{{- define "hono.container.secretVolumeMounts" }}
{{- $volumeName := printf "%s-conf" .name }}
- name: {{ $volumeName | quote }}
  mountPath: {{ default "/etc/hono" .configMountPath | quote }}
  readOnly: true
{{- with .componentConfig.extraSecretMounts }}
{{- range $name,$spec := . }}
- name: {{ $name | quote }}
  mountPath: {{ $spec.mountPath | quote }}
{{- if $spec.subPath }}
  subPath: {{ $spec.subPath | quote }}
{{- end }}
  readOnly: true
{{- end }}
{{- end }}
{{-  with .dot }}
{{- if ( contains "quarkus" .Values.honoImagesType ) }}
- name: {{ $volumeName | quote }}
  mountPath: "/opt/hono/config"
  readOnly: true
{{- end }}
{{- end }}
{{- end }}


{{/*
Adds volume declarations to a component's pod spec.

The scope passed in is expected to be a dict with keys
- (mandatory) "name": the name of the component
- (mandatory) "componentConfig": the component's configuration properties as defined in .Values
- (mandatory) "dot": the root scope (".")
*/}}
{{- define "hono.pod.secretVolumes" }}
{{- $volumeName := printf "%s-conf" .name }}
- name: {{ $volumeName | quote }}
  secret:
    secretName: {{ printf "%s-%s" .dot.Release.Name $volumeName | quote }}
{{- with .componentConfig.extraSecretMounts }}
{{- range $name,$spec := . }}
- name: {{ $name | quote }}
  secret:
    secretName: {{ $spec.secretName | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Adds port type declarations to a component's service spec.
*/}}
{{- define "hono.serviceType" }}
{{- if eq .Values.platform "openshift" }}
  type: ClusterIP
{{- else if eq .Values.useLoadBalancer true }}
  type: LoadBalancer
{{- else }}
  type: NodePort
{{- end }}
{{- end }}

{{/*
Configures NodePort on component's service spec.
*/}}
{{- define "hono.nodePort" }}
{{- if ne .dot.Values.platform "openshift" }}
nodePort: {{ .port  }}
{{- end }}
{{- end }}




