{{/*
Expand the name of the chart.
*/}}
{{- define "cloudflared-tunnel.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cloudflared-tunnel.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cloudflared-tunnel.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cloudflared-tunnel.labels" -}}
helm.sh/chart: {{ include "cloudflared-tunnel.chart" . }}
{{ include "cloudflared-tunnel.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cloudflared-tunnel.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cloudflared-tunnel.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cloudflared-tunnel.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cloudflared-tunnel.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Determine the secret name to use for the tunnel token.
*/}}
{{- define "cloudflared-tunnel.secretName" -}}
{{- if .Values.secret.existingSecret -}}
{{- .Values.secret.existingSecret -}}
{{- else if and .Values.secret.name (ne .Values.secret.name "cloudflared-token") -}}
{{- .Values.secret.name -}}
{{- else -}}
{{- printf "%s-secret" (include "cloudflared-tunnel.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
Backwards-compatible aliases for legacy helmchart.* helpers
*/}}
{{- define "helmchart.name" -}}
{{- include "cloudflared-tunnel.name" . }}
{{- end }}

{{- define "helmchart.fullname" -}}
{{- include "cloudflared-tunnel.fullname" . }}
{{- end }}

{{- define "helmchart.chart" -}}
{{- include "cloudflared-tunnel.chart" . }}
{{- end }}

{{- define "helmchart.labels" -}}
{{- include "cloudflared-tunnel.labels" . }}
{{- end }}

{{- define "helmchart.selectorLabels" -}}
{{- include "cloudflared-tunnel.selectorLabels" . }}
{{- end }}

{{- define "helmchart.namespace" -}}
{{- .Release.Namespace }}
{{- end }}
