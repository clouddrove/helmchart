{{/* vim: set filetype=mustache: */}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cronjob.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cronjob.labels" -}}
helm.sh/chart: {{ include "cronjob.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/created-by: "CloudDrove"
{{- end }}

{{/*
Expand the release name of the chart.
*/}}
{{- define "cronjob.releaseName" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create payload for any image pull secret.
One kube secret will be created containing all the auths
and will be shared by all the job pods requiring it.
*/}}
{{- define "cronjob.imageSecrets" -}}
    {{- $secrets := dict -}}
    {{- range $jobname, $job := .Values.jobs -}}
        {{- if hasKey $job "imagePullSecrets" -}}
            {{- range $ips := $job.imagePullSecrets -}}
                {{- $userInfo := dict "username" $ips.username "password" $ips.password "auth" (printf "%s:%s" $ips.username $ips.password | b64enc) -}}
                {{- if hasKey $ips "email" -}}
                    {{ $_ := set $userInfo  "email" $ips.email -}}
                {{- end -}}
                {{- $_ := set $secrets $ips.registry $userInfo -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if gt (len $secrets) 0 -}}
        {{- $auth := dict "auths" $secrets -}}
        {{/* Emit secret content as base64 */}}
        {{- print ($auth | toJson | b64enc) -}}
    {{- else -}}
        {{/* There are no secrets*/}}
        {{- print "" -}}
    {{- end -}}
{{- end -}}