{{- define "ditto.app-host" -}}
    {{- with .Values.ditto.ingress.host -}}
        {{- . -}}
    {{- else -}}
        ditto-{{ .Release.Namespace }}{{ .Values.ditto.ingress.domain | default .Values.global.domain -}}
    {{- end }}
{{- end }}

{{- define "ditto.app-url" -}}
{{- .Values.ditto.ingress.protocol | default "http" -}}://{{ include "ditto.app-host" . -}}
{{- end }}

{{- define "iofog.viewer-host" -}}
    {{- with .Values.iofog.ingress.viewer.host -}}
        {{- . -}}
    {{- else -}}
        iofog-viewer-{{ .Release.Namespace }}{{ .Values.iofog.ingress.domain | default .Values.global.domain -}}
    {{- end }}
{{- end }}

{{- define "iofog.viewer-url" -}}
{{- .Values.iofog.ingress.viewer.protocol | default "http" -}}://{{ include "iofog.viewer-host" . -}}
{{- end }}

{{- define "iofog.api-host" -}}
    {{- with .Values.iofog.ingress.api.host -}}
        {{- . -}}
    {{- else -}}
        iofog-api-{{ .Release.Namespace }}{{ .Values.iofog.ingress.domain | default .Values.global.domain -}}
    {{- end }}
{{- end }}

{{- define "iofog.api-url" -}}
{{- .Values.iofog.ingress.api.protocol | default "http" -}}://{{ include "iofog.api-host" . -}}
{{- end }}
