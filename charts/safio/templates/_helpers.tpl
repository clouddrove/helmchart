{{/*
Expand the name of the chart.
*/}}
{{- define "safio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "safio.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return the chart name plus version for the chart label.
*/}}
{{- define "safio.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{/*
Common labels shared across resources.
*/}}
{{- define "safio.labels" -}}
helm.sh/chart: {{ include "safio.chart" . }}
app.kubernetes.io/name: {{ include "safio.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- if .Values.labels }}
{{- toYaml .Values.labels | nindent 0 }}
{{- end }}
{{- end -}}

{{/*
Selector labels.
*/}}
{{- define "safio.selectorLabels" -}}
app.kubernetes.io/name: {{ include "safio.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Service account name.
*/}}
{{- define "safio.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "safio.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}
