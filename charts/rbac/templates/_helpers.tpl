{{- define "rbac.labels" -}}
app.kubernetes.io/managed-by: "Helm"
rbac-homelab: "member"
{{- end -}}

{{/*
Validate uniqueness of namespaces
*/}}
{{- define "rbac.validateNamespaces" -}}
{{- if . }}
  {{- $seen := dict -}}
  {{- range $u := . }}
    {{- if hasKey $seen $u.namespace | default (printf "ns-%s" $u.name) }}
      {{- fail (printf "ERROR: >>>>>>> Duplicate namespace found: %s" $u.namespace) }}
    {{- else }}
      {{- $_ := set $seen $u.namespace true }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
