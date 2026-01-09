{{/*
Expand the name of the chart.
*/}}
{{- define "helmchart.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helmchart.fullname" -}}
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
{{- define "helmchart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helmchart.labels" -}}
helm.sh/chart: {{ include "helmchart.chart" . }}
{{ include "helmchart.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/created-by: "CloudDrove"
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helmchart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helmchart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "helmchart.serviceAccountName" -}}
{{- if .Values.serviceAccount.enabled }}
{{- default (include "helmchart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for Horizontal Pod Autoscaler.
*/}}
{{- define "helmchart.hpa.apiVersion" -}}
{{- if $.Capabilities.APIVersions.Has "autoscaling/v2" }}
{{- print "autoscaling/v2" }}
{{- else if $.Capabilities.APIVersions.Has "autoscaling/v2beta2" }}
{{- print "autoscaling/v2beta2" }}
{{- else if $.Capabilities.APIVersions.Has "autoscaling/v2beta1" }}
{{- print "autoscaling/v2beta1" }}
{{- else }}
{{- print "autoscaling/v1" }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for Storage Class.
*/}}
{{- define "helmchart.storageClass.apiVersion" -}}
{{- if $.Capabilities.APIVersions.Has "storage.k8s.io/v1" }}
{{- print "storage.k8s.io/v1" }}
{{- else }}
{{- print "storage.k8s.io/v1beta1" }}
{{- end }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "helmchart.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}
{{/*
Pod labels
*/}}
{{- define "helmchart.podLabels" -}}
{{- range $key, $value := .Values.podLabels -}}
{{ $key }}: {{ $value | quote }}
{{- end -}}
{{- end -}}

