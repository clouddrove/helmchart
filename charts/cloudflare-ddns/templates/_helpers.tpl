{{- define "cloudflare-ddns.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cloudflare-ddns.fullname" -}}
{{- if .Release.Name }}{{ printf "%s-%s" .Release.Name (include "cloudflare-ddns.name" .) | trunc 63 | trimSuffix "-" }}{{ end -}}
{{- end -}}

{{- define "cloudflare-ddns.labels" -}}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
app.kubernetes.io/name: "{{ include "cloudflare-ddns.name" . }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/managed-by: "Helm"
{{- end -}}

