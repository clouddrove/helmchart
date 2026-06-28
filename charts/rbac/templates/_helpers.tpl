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
    {{- $ns := $u.namespace | default (printf "ns-%s" $u.name) }}
    {{- if hasKey $seen $ns }}
      {{- fail (printf "ERROR: >>>>>>> Duplicate namespace found: %s" $ns) }}
    {{- else }}
      {{- $_ := set $seen $ns true }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}