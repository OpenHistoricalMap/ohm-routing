{{- define "ohm-routing.fullname" -}}
{{- printf "%s-ohm-routing" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ohm-routing.labels" -}}
app.kubernetes.io/name: ohm-routing
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{- define "ohm-routing.image" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- end -}}

{{- define "ohm-routing.scheduling" -}}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
