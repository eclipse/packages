
{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eclipse-iot-telemetry.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Labels to be used in selectors.

Arguments: (dict)
 * root - .
 * name - name of the resource
 * component - component this resource belongs to
*/}}
{{- define "eclipse-iot-telemetry.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/component: {{ .component }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end }}


{{/*
Common labels, includes the selector labels.

Arguments: (dict)
 * root - .
 * name - name of the resource
 * component - component this resource belongs to
 * partOf - (optional) part of label value, defaults to "eclipse-iot-telemetry"
*/}}
{{- define "eclipse-iot-telemetry.labels" -}}
{{ include "eclipse-iot-telemetry.selectorLabels" . }}
{{- if .root.Chart.AppVersion }}
app.kubernetes.io/version: {{ .root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
app.kubernetes.io/part-of: {{ .partOf | default "eclipse-iot-telemetry" }}
{{- end }}
