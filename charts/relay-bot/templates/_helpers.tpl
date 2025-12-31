{{/*
Expand the name of the chart.
*/}}
{{- define "relaybot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "relaybot.fullname" -}}
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
{{- define "relaybot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "relaybot.labels" -}}
helm.sh/chart: {{ include "relaybot.chart" . }}
{{ include "relaybot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.clientName }}
app.kubernetes.io/client: {{ .Values.clientName }}
{{- end }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "relaybot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "relaybot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the secret to use
*/}}
{{- define "relaybot.secretName" -}}
{{- if .Values.existingSecret }}
{{- .Values.existingSecret }}
{{- else if .Values.secrets.create }}
{{- default (printf "%s-relaybot-secrets" .Release.Name) .Values.secrets.name }}
{{- else }}
{{- printf "%s-relaybot-secrets" .Release.Name }}
{{- end }}
{{- end }}

{{/*
Key names for Slack tokens (handles existing or chart-managed secrets)
*/}}
{{- define "relaybot.clientSlackTokenKey" -}}
{{- if and .Values.existingSecret .Values.existingSecretKeys.clientSlackTokenKey }}
{{- .Values.existingSecretKeys.clientSlackTokenKey }}
{{- else }}
{{- default "CLIENT_SLACK_TOKEN" .Values.secrets.clientSlackTokenKey }}
{{- end }}
{{- end }}

{{- define "relaybot.personalSlackTokenKey" -}}
{{- if and .Values.existingSecret .Values.existingSecretKeys.personalSlackTokenKey }}
{{- .Values.existingSecretKeys.personalSlackTokenKey }}
{{- else }}
{{- default "PERSONAL_SLACK_TOKEN" .Values.secrets.personalSlackTokenKey }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "relaybot.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "relaybot.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
