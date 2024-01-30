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
#
{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart using the Chart name.
If .Values.nameOverride is set use that instead of the Chart Name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "hono.name" -}}
  {{- $nameOverride := .Values.nameOverride -}}
  {{- $name := empty $nameOverride | ternary .Chart.Name $nameOverride -}}
  {{- trunc 63 $name | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hono.fullname" -}}
  {{- $fullnameOverride := .Values.fullnameOverride -}}
  {{- if $fullnameOverride  -}}
    {{- $fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $nameOverride := .Values.nameOverride -}}
    {{- $name := empty $nameOverride | ternary .Chart.Name $nameOverride -}}
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
Gets the port that the Hono components expose their readiness and liveness checks on.

NOTE: In order to change the actual port being used by Hono components,
the "quarkus.http.port" configuration property needs to be set to the desired
value when building Hono from source.
*/}}
{{- define "hono.healthCheckPort" -}}
{{- default "8088" .Values.healthCheckPort -}}
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
*/}}
{{- define "hono.container" }}
{{- $tag := default .dot.Chart.AppVersion ( default .dot.Values.honoImagesTag .componentConfig.imageTag ) }}
{{- $registry := default .dot.Values.honoContainerRegistry .componentConfig.containerRegistry }}
{{- $image := printf "%s/%s:%s" $registry .componentConfig.imageName $tag }}
- name: {{ .name | quote }}
  image: {{ $image | quote }}
{{- if and ( contains "SNAPSHOT" $tag ) ( not ( hasPrefix "index.docker.io/eclipse/" $image ) ) }}
  imagePullPolicy: "Always"
{{- end }}
{{- end }}


{{/*
Add standard labels for resources as recommended by Helm best practices.

The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root (".") scope
*/}}
{{- define "hono.std.labels" -}}
app.kubernetes.io/name: {{ include "hono.name" .dot | quote }}
helm.sh/chart: {{ include "hono.chart" .dot | quote }}
app.kubernetes.io/managed-by: {{ .dot.Release.Service | quote }}
app.kubernetes.io/instance: {{ .dot.Release.Name | quote }}
app.kubernetes.io/version: {{ .dot.Chart.AppVersion | quote }}
{{- end }}


{{/*
Add standard labels and name for resources as recommended by Helm best practices.
The scope passed in is expected to be a dict with keys
- "dot": the "." scope and
- "name": the value to use for the "name" metadata property
- "component": the value to use for the "app.kubernetes.io/component" label
*/}}
{{- define "hono.metadata" -}}
name: {{ printf "%s-%s" (include "hono.fullname" .dot ) .name | quote }}
namespace: {{ .dot.Release.Namespace | quote }}
labels:
  app.kubernetes.io/name: {{ include "hono.name" .dot | quote }}
  helm.sh/chart: {{ include "hono.chart" .dot | quote }}
  app.kubernetes.io/managed-by: {{ .dot.Release.Service | quote }}
  app.kubernetes.io/instance: {{ .dot.Release.Name | quote }}
  app.kubernetes.io/version: {{ .dot.Chart.AppVersion | quote }}
  {{- if .component }}
  app.kubernetes.io/component: {{ .component | quote }}
  {{- end }}
{{- end }}

{{/*
Add standard match labels to be used in podTemplateSpecs and serviceMatchers.
The scope passed in is expected to be a dict with keys
- "dot": the "." scope and
- "component": the value of the "app.kubernetes.io/component" label to match
*/}}
{{- define "hono.matchLabels" -}}
app.kubernetes.io/name: {{ include "hono.name" .dot | quote }}
app.kubernetes.io/instance: {{ .dot.Release.Name | quote }}
app.kubernetes.io/component: {{ .component | quote }}
{{- end }}

{{/*
Add standard annotations for Hono component pods.
This includes annotations for marking a pod to be scraped by Prometheus
and an annotation to define the default container.
The scope passed in is expected to be a dict with keys
- "dot": the "." scope and
- "name": the value to use for the "default-container" annotation
*/}}
{{- define "hono.podAnnotations" -}}
prometheus.io/scrape: "true"
prometheus.io/path: "/prometheus"
prometheus.io/port: {{ include "hono.healthCheckPort" .dot | quote }}
prometheus.io/scheme: "http"
kubectl.kubernetes.io/default-container: {{ .name | quote }}
{{- end }}

{{/*
Add additional annotations for Hono component pods.
The scope passed in is expected to be a dict with keys
- (mandatory) "componentConfig": the component's configuration properties from the values.yaml file
*/}}
{{- define "hono.podAdditionalAnnotations" -}}
{{- if .componentConfig.pod.annotations }}
{{- with .componentConfig.pod.annotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Add additional labels for Hono component pods.
The scope passed in is expected to be a dict with keys
- (mandatory) "componentConfig": the component's configuration properties from the values.yaml file
*/}}
{{- define "hono.podAdditionalLabels" -}}
{{- if .componentConfig.pod.labels }}
{{- with .componentConfig.pod.labels }}
{{- toYaml . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Add affinity rules for Hono component pods.
The scope passed in is expected to be a dict with keys
- (mandatory) "componentConfig": the component's configuration properties from the values.yaml file
*/}}
{{- define "hono.pod.affinity" -}}
{{- if .componentConfig.pod.affinity }}
{{- with .componentConfig.pod.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Add annotations for Hono component deployments.
The scope passed in is expected to be a dict with keys
- (mandatory) "componentConfig": the component's configuration properties from the values.yaml file
*/}}
{{- define "hono.deploymentAnnotations" -}}
{{- if .componentConfig.deployment.annotations }}
annotations:
{{- with .componentConfig.deployment.annotations }}
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
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
  clusterIP: "None"
  selector:
    {{- include "hono.matchLabels" $args | nindent 4 }}
{{- end }}


{{/*
Configuration for the messaging network clients.
It configures for either AMQP based or Kafka based messaging.
The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".") and
- (mandatory) "component": the name of the component
- (optional) "kafkaMessagingSpec": the configuration properties to use for the component's
                                   Kafka producers/consumers/admin clients
*/}}
{{- define "hono.messagingNetworkClientConfig" -}}
{{- if has "amqp" .dot.Values.messagingNetworkTypes -}}
  {{- include "hono.amqpMessagingNetworkClientConfig" . }}
{{- end }}
{{- if has "kafka" .dot.Values.messagingNetworkTypes -}}
  {{ include "hono.kafkaMessagingConfig" . }}
{{- end -}}
{{- if not ( or ( has "amqp" .dot.Values.messagingNetworkTypes ) ( has "kafka" .dot.Values.messagingNetworkTypes ) ) -}}
  {{- required "Property messagingNetworkTypes MUST contain 'amqp' and/or 'kafka'" nil }}
{{- end -}}
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
  name: {{ printf "Hono %s" .component | quote }}
  amqpHostname: "hono-internal"
  host: {{ printf "%s-dispatch-router" ( include "hono.fullname" .dot ) | quote }}
  port: 5673
  keyPath: {{ .dot.Values.adapters.amqpMessagingNetworkSpec.keyPath | quote }}
  certPath: {{ .dot.Values.adapters.amqpMessagingNetworkSpec.certPath | quote }}
  trustStorePath: {{ .dot.Values.adapters.amqpMessagingNetworkSpec.trustStorePath | quote }}
  hostnameVerificationRequired: {{ .dot.Values.adapters.amqpMessagingNetworkSpec.hostnameVerificationRequired }}
  useLegacyTraceContextFormat: {{ .dot.Values.useLegacyAmqpTraceContextFormat }}
{{- else }}
  {{- required ".Values.adapters.amqpMessagingNetworkSpec MUST be set if example AMQP Messaging Network is disabled" .dot.Values.adapters.amqpMessagingNetworkSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}


{{/*
Add configuration properties for Kafka based messaging to YAML file.

The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".") and
- (mandatory) "component": the name of the component
- (optional) "kafkaMessagingSpec": the configuration properties to use for the component's
                                   Kafka producers/consumers/admin clients
*/}}
{{- define "hono.kafkaMessagingConfig" -}}
{{- include "hono.kafkaConfigCheck" . }}
kafka:
{{- if .dot.Values.kafkaMessagingClusterExample.enabled }}
  commonClientConfig:
    {{- $bootstrapServers := printf "%[1]s-%[2]s-controller-headless:%d" .dot.Release.Name .dot.Values.kafka.nameOverride ( .dot.Values.kafka.service.ports.client | int ) }}
    bootstrap.servers: {{ $bootstrapServers | quote }}
  {{- if eq .dot.Values.kafka.listeners.client.protocol "SASL_SSL" }}
    security.protocol: "SASL_SSL"
    sasl.mechanism: "SCRAM-SHA-512"
    sasl.jaas.config: "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"{{ first .dot.Values.kafka.sasl.client.users }}\" password=\"{{ first .dot.Values.kafka.sasl.client.passwords }}\";"
    ssl.truststore.type: "PEM"
    ssl.truststore.location: "/opt/hono/tls/ca.crt"
    ssl.endpoint.identification.algorithm: "" # Disables hostname verification. Don't do this in productive setups!
  {{- else if eq .dot.Values.kafka.listeners.client.protocol "SASL_PLAINTEXT" }}
    security.protocol: "SASL_PLAINTEXT"
    sasl.mechanism: "SCRAM-SHA-512"
    sasl.jaas.config: "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"{{ first .dot.Values.kafka.sasl.client.users }}\" password=\"{{ first .dot.Values.kafka.sasl.client.passwords }}\";"
  {{- else }}
    {{- required ".Values.kafka.listeners.client.protocol has unsupported value" nil }}
  {{- end }}
{{- else }}
  {{- $bootstrapServers := dig "kafkaMessagingSpec" "commonClientConfig" "bootstrap.servers" "" . }}
  {{- $fallbackBootstrapServers := dig "commonClientConfig" "bootstrap.servers" "" .dot.Values.adapters.kafkaMessagingSpec }}
  {{- if not ( any $bootstrapServers $fallbackBootstrapServers ) }}
    {{- required "At least 'bootstrap.servers' MUST be provided if example Kafka cluster is disabled" nil }}
  {{- else if $bootstrapServers }}
    {{- .kafkaMessagingSpec | toYaml | nindent 2 }}
  {{- else }}
  commonClientConfig:
    {{- .dot.Values.adapters.kafkaMessagingSpec.commonClientConfig | toYaml | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}


{{/*
Check configuration for consistency in case of Kafka based messaging.

The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".")
*/}}
{{- define "hono.kafkaConfigCheck" -}}
  {{- if and (has "kafka" .dot.Values.messagingNetworkTypes) .dot.Values.kafkaMessagingClusterExample.enabled .dot.Values.kafka.externalAccess.enabled }}
    {{- if .dot.Values.useLoadBalancer }}
      {{- if not (and (eq .dot.Values.kafka.externalAccess.controller.service.type "LoadBalancer") (eq .dot.Values.kafka.externalAccess.broker.service.type "LoadBalancer") )}}
        {{- required ".Values.kafka.externalAccess.(controller|broker).service.type MUST be 'LoadBalancer' if .Values.useLoadBalancer is true" nil }}
      {{- end }}
    {{- else if not (and (eq .dot.Values.kafka.externalAccess.controller.service.type "NodePort") (eq .dot.Values.kafka.externalAccess.broker.service.type "NodePort") )}}
      {{- required ".Values.kafka.externalAccess.(controller|broker).service.type MUST be 'NodePort' if .Values.useLoadBalancer is false" nil }}
    {{- end }}
  {{- end }}
{{- end }}


{{/*
Configuration for the clients accessing the example Device Registry.
The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".") and
- (mandatory) "component": the name of the component
*/}}
{{- define "hono.deviceRegistryExampleClientConfig" -}}
name: {{ printf "Hono %s" .component | quote }}
host: {{ printf "%s-service-device-registry" ( include "hono.fullname" .dot ) | quote }}
port: 5671
credentialsPath: "/opt/hono/config/adapter.credentials"
trustStorePath: {{ .dot.Values.deviceRegistryExample.clientTrustStorePath | default "/opt/hono/tls/ca.crt" | quote }}
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
{{- include "hono.messagingNetworkClientConfig" ( dict "dot" .dot "component" $adapter "kafkaMessagingSpec" .dot.Values.adapters.kafkaMessagingSpec ) }}
{{- if has "amqp" .dot.Values.messagingNetworkTypes }}
command:
{{- if .dot.Values.amqpMessagingNetworkExample.enabled }}
  name: {{ printf "Hono %s" $adapter | quote }}
  amqpHostname: "hono-internal"
  host: {{ printf "%s-dispatch-router" ( include "hono.fullname" .dot ) | quote }}
  port: 5673
  keyPath: {{ .dot.Values.adapters.commandAndControlSpec.keyPath | quote }}
  certPath: {{ .dot.Values.adapters.commandAndControlSpec.certPath | quote }}
  trustStorePath: {{ .dot.Values.adapters.commandAndControlSpec.trustStorePath | quote }}
  hostnameVerificationRequired: {{ .dot.Values.adapters.commandAndControlSpec.hostnameVerificationRequired }}
  useLegacyTraceContextFormat: {{ .dot.Values.useLegacyAmqpTraceContextFormat }}
{{- else }}
  {{- required ".Values.adapters.commandAndControlSpec MUST be set if example AMQP Messaging Network is disabled" .dot.Values.adapters.commandAndControlSpec | toYaml | nindent 2 }}
{{- end -}}
{{/* commands with Kafka use the config from hono.messagingNetworkClientConfig */}}
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
commandRouter:
{{- if .dot.Values.adapters.commandRouterSpec }}
  {{/* user has provided connection params for third party Command Router service */}}
  {{- .dot.Values.adapters.commandRouterSpec | toYaml | nindent 2 }}
{{- else }}
  name: {{ printf "Hono %s" $adapter | quote }}
  host: {{ printf "%s-service-command-router" ( include "hono.fullname" .dot ) | quote }}
  port: 5671
  credentialsPath: "/opt/hono/config/adapter.credentials"
  trustStorePath: {{ .dot.Values.commandRouterService.clientTrustStorePath | default "/opt/hono/tls/ca.crt" | quote }}
  hostnameVerificationRequired: false
{{- end }}
{{- if .dot.Values.prometheus.createInstance }}
resourceLimits:
  prometheusBased:
    host: {{ include "hono.prometheus.server.fullname" .dot | quote }}
{{- else if .dot.Values.prometheus.host }}
resourceLimits:
  prometheusBased:
    host: {{ .dot.Values.prometheus.host | quote }}
    port: {{ default "9090" .dot.Values.prometheus.port }}
{{- end }}
{{- end }}


{{/*
Adds environment variables for configuring the application development framework
used by a component.

The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".")
- (mandatory) "componentConfig": the component's configuration properties from the values.yaml file
*/}}
{{- define "hono.component.frameworkEnv" }}
{{- $loggingProfile := default "dev" .componentConfig.quarkusLoggingProfile }}
- name: "QUARKUS_CONFIG_LOCATIONS"
  value: {{ default ( printf "/opt/hono/default-logging-config/logging-quarkus-%s.yml" $loggingProfile ) .componentConfig.quarkusConfigLocations | quote }}
{{- end }}

{{/*
Adds environment variables from a given configmap and/or secret
to a component's container.

The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".")
- (mandatory) "componentConfig": the component's configuration properties from the values.yaml file
*/}}
{{- define "hono.component.envFrom" }}
{{- if or .componentConfig.envConfigMap .componentConfig.envSecret }}
envFrom:
{{- if .componentConfig.envConfigMap }}
- configMapRef:
    name: {{ .componentConfig.envConfigMap | quote }}
{{- end }}
{{- if .componentConfig.envSecret }}
- secretRef:
    name: {{ .componentConfig.envSecret | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Add Quarkus related configuration properties to YAML file.

The scope passed in is expected to be a dict with keys
- (mandatory ) "dot": the root scope (".")
*/}}
{{- define "hono.quarkusConfig" }}
quarkus:
  console:
    color: {{ .dot.Values.console.color }}
  log:
    min-level: TRACE
    level: INFO
    category:
      "io.quarkus.vertx.core.runtime":
        level: DEBUG
  {{- if or .dot.Values.jaegerBackendExample.enabled .dot.Values.otelCollectorAgentConfigMap }}
  opentelemetry:
    tracer:
      exporter:
        otlp:
          {{- if .dot.Values.jaegerBackendExample.enabled }}
          endpoint: {{ printf "http://%s-jaeger-collector:4317" ( include "hono.fullname" .dot ) | quote }}
          {{- else }}
          endpoint: "http://127.0.0.1:4317"
          {{- end }}
  {{- end }}
  vertx:
    prefer-native-transport: true
    resolver:
      cache-max-time-to-live: 0
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
Adds an OpenTelemetry Collector Agent container to a template spec.
*/}}
{{- define "hono.otel.agent" }}
{{- $deploySidecar := and .Values.otelCollectorAgentConfigMap ( not .Values.jaegerBackendExample.enabled ) }}
{{- if $deploySidecar }}
- name: "otel-collector-agent-sidecar"
  image: {{ .Values.otelCollectorAgentImage | quote }}
  args:
  - "--config=/opt/hono/config/otel-collector-config.yaml"
  ports:
  - name: "grpc"
    containerPort: 4317
    protocol: "TCP"
  - name: "health"
    containerPort: 13133
    protocol: "TCP"
  readinessProbe:
    httpGet:
      path: "/"
      port: health
    initialDelaySeconds: 5
  volumeMounts:
  - name: "otel-collector-config"
    mountPath: "/opt/hono/config"
    readOnly: true
{{- end }}
{{- end }}

{{/*
Adds liveness/readiness checks to a Hono component's container.

The scope passed in is expected to be a dict with keys
- (mandatory) "dot": the root scope (".")
- (mandatory) "componentConfig": the component's configuration properties from the values.yaml file
*/}}
{{- define "hono.component.healthChecks" }}
{{- $global := .dot.Values -}}
{{- $component := .componentConfig -}}
{{- $probes := mergeOverwrite ( $global.probes | deepCopy ) ( $component.probes | default dict | deepCopy ) -}}
{{- $deprecatedLivenessProbeInitialDelaySeconds := default .dot.Values.livenessProbeInitialDelaySeconds .componentConfig.livenessProbeInitialDelaySeconds -}}
{{- $deprecatedReadinessProbeInitialDelaySeconds := default .dot.Values.readinessProbeInitialDelaySeconds .componentConfig.readinessProbeInitialDelaySeconds -}}
livenessProbe:
  httpGet:
    path: {{ $probes.livenessProbe.httpGet.path }}
    port: {{ $probes.livenessProbe.httpGet.port }}
    scheme: {{ $probes.livenessProbe.httpGet.scheme }}
  periodSeconds: {{ $probes.livenessProbe.periodSeconds }}
  failureThreshold: {{ $probes.livenessProbe.failureThreshold }}
  initialDelaySeconds: {{ default $probes.livenessProbe.initialDelaySeconds $deprecatedLivenessProbeInitialDelaySeconds }}
  successThreshold: {{ $probes.livenessProbe.successThreshold }}
  timeoutSeconds: {{ $probes.livenessProbe.timeoutSeconds }}
readinessProbe:
  httpGet:
    path: {{ $probes.readinessProbe.httpGet.path }}
    port: {{ $probes.readinessProbe.httpGet.port }}
    scheme: {{ $probes.readinessProbe.httpGet.scheme }}
  periodSeconds: {{ $probes.readinessProbe.periodSeconds }}
  failureThreshold: {{ $probes.readinessProbe.failureThreshold }}
  initialDelaySeconds: {{ default $probes.readinessProbe.initialDelaySeconds $deprecatedReadinessProbeInitialDelaySeconds }}
  successThreshold: {{ $probes.readinessProbe.successThreshold }}
  timeoutSeconds: {{ $probes.readinessProbe.timeoutSeconds }}
{{- end }}

{{/*
Adds volume mounts to a component's container.

The scope passed in is expected to be a dict with keys
- (mandatory) "name": the name of the component
- (mandatory) "componentConfig": the component's configuration properties as defined in .Values
- (optional) "configMountPath": the mount path to use for the component's config secret
                                instead of the default "/opt/hono/config"
*/}}
{{- define "hono.container.volumeMounts" }}
{{- $keySecretName := ( default "none" .componentConfig.tlsKeysSecret | toString ) }}
{{- if ( ne $keySecretName "none" ) }}
- name: "tls-keys"
  mountPath: "/opt/hono/tls/tls.key"
  subPath: "tls.key"
  readOnly: true
- name: "tls-keys"
  mountPath: "/opt/hono/tls/tls.crt"
  subPath: "tls.crt"
  readOnly: true
{{- end }}
{{- $trustStoreConfigMapName := ( default "none" .componentConfig.tlsTrustStoreConfigMap | toString ) }}
{{- if ( ne $trustStoreConfigMapName "none" ) }}
- name: "tls-trust-store"
  mountPath: "/opt/hono/tls/ca.crt"
  subPath: "ca.crt"
  readOnly: true
{{- end }}
- name: "default-logging-config"
  mountPath: "/opt/hono/default-logging-config"
  readOnly: true
{{- $volumeName := printf "%s-conf" .name }}
- name: {{ $volumeName | quote }}
  mountPath: {{ default "/opt/hono/config" .configMountPath | quote }}
  readOnly: true
{{- with .componentConfig.extraVolumeMounts }}
{{ . | toYaml }}
{{- end }}
{{- end }}


{{/*
Adds volume declarations to a component's pod spec.

The scope passed in is expected to be a dict with keys
- (mandatory) "name": the name of the component
- (mandatory) "componentConfig": the component's configuration properties as defined in .Values
- (mandatory) "dot": the root scope (".")
*/}}
{{- define "hono.pod.volumes" }}
{{- $keySecretName := ( default "none" .componentConfig.tlsKeysSecret | toString ) }}
{{- if ( ne $keySecretName "none" ) }}
- name: "tls-keys"
  secret:
    secretName: {{ ternary ( printf "%s-%s-example-keys" ( include "hono.fullname" .dot ) .name ) $keySecretName ( eq $keySecretName "example" ) | quote }}
{{- end }}
{{- $trustStoreConfigMapName := ( default "none" .componentConfig.tlsTrustStoreConfigMap | toString ) }}
{{- if ( ne $trustStoreConfigMapName "none" ) }}
- name: "tls-trust-store"
  configMap:
    name: {{ ternary ( printf "%s-example-trust-store" ( include "hono.fullname" .dot )) $trustStoreConfigMapName ( eq $trustStoreConfigMapName "example" ) | quote }}
{{- end }}
- name: "default-logging-config"
  configMap:
    name: {{ printf "%s-default-logging-config" ( include "hono.fullname" .dot ) | quote }}
    optional: true
{{- $volumeName := printf "%s-conf" .name }}
- name: {{ $volumeName | quote }}
  secret:
    secretName: {{ printf "%s-%s" ( include "hono.fullname" .dot ) $volumeName | quote }}
{{- if and .dot.Values.otelCollectorAgentConfigMap ( not .dot.Values.jaegerBackendExample.enabled ) }}
- name: "otel-collector-config"
  configMap:
    name: {{ .dot.Values.otelCollectorAgentConfigMap | quote }}
{{- end }}
{{- with .componentConfig.extraVolumes }}
{{ . | toYaml }}
{{- end }}
{{- end }}

{{/*
Adds a priority class name to a component's pod spec.
The scope passed in is expected to be a dict with keys
- (mandatory) "componentConfig": the component's configuration properties as defined in .Values
*/}}
{{- define "hono.pod.priorityClassName" }}
{{- if .componentConfig.pod.priorityClassName }}
priorityClassName: {{ .componentConfig.pod.priorityClassName | quote }}
{{- end }}
{{- end }}

{{/*
Adds port type declarations to a component's service spec.
*/}}
{{- define "hono.serviceType" }}
{{- if .Values.serviceType }}
  type: {{ .Values.serviceType | quote }}
{{- else if eq .Values.platform "openshift" }}
  type: "ClusterIP"
{{- else if eq .Values.useLoadBalancer true }}
  type: "LoadBalancer"
{{- else }}
  type: "NodePort"
{{- end }}
{{- end }}

{{/*
Configures NodePort on component's service spec.
*/}}
{{- define "hono.nodePort" }}
{{- if ne .dot.Values.platform "openshift" }}
{{- if any ( eq (default "nil" .dot.Values.serviceType) "NodePort" ) ( eq .dot.Values.useLoadBalancer false ) }}
nodePort: {{ .port }}
{{- end }}
{{- end }}
{{- end }}
