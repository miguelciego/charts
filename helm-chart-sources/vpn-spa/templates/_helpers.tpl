{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trimSuffix "-app" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "appname" -}}
{{- $releaseName := default .Release.Name .Values.releaseOverride -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" $releaseName $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "imagename" -}}
{{- if eq .Values.image.tag "" -}}
{{- .Values.image.repository -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- end -}}
{{- end -}}

{{- define "trackableappname" -}}
{{- $trackableName := printf "%s-%s" (include "appname" .) .Values.application.track -}}
{{- $trackableName | trimSuffix "-stable" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Templates for cronjob
*/}}

{{- define "cronjobimagename" -}}
{{- if hasKey .job "image" -}}
{{-   if and (hasKey .job.image "repository") (hasKey .job.image "tag") -}}
{{- printf "%s:%s" .job.image.repository .job.image.tag -}}
{{-   end -}}
{{- else -}}
{{- printf "%s:%s" .glob.image.repository .glob.image.tag -}}
{{- end -}}
{{- end -}}

{{/*
Get a hostname from URL
*/}}
{{- define "hostname" -}}
{{- . | trimPrefix "http://" |  trimPrefix "https://" | trimSuffix "/" | trim | quote -}}
{{- end -}}

{{/*
Get SecRule's arguments with unescaped single&double quotes
*/}}
{{- define "secrule" -}}
{{- $operator := .operator | quote | replace "\"" "\\\"" | replace "'" "\\'" -}}
{{- $action := .action | quote | replace "\"" "\\\"" | replace "'" "\\'" -}}
{{- printf "SecRule %s %s %s" .variable $operator $action -}}
{{- end -}}

{{/*
Generate a name for a Persistent Volume Claim
*/}}
{{- define "pvcName" -}}
{{- printf "%s-%s" (include "fullname" .context) .name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "sharedlabels" -}}
app: {{ template "appname" . }}
chart: "{{ .Chart.Name }}-{{ .Chart.Version| replace "+" "_" }}"
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
app.kubernetes.io/name: {{ template "appname" . }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version| replace "+" "_" }}"
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Values.extraLabels }}
{{ toYaml $.Values.extraLabels }}
{{- end }}
{{- end -}}

{{- define "ingress.annotations" -}}
{{- $defaults := include (print $.Template.BasePath "/_ingress-annotations.yaml") . | fromYaml -}}
{{- $custom := .Values.ingress.annotations | default dict -}}
{{- $merged := deepCopy $custom | mergeOverwrite $defaults -}}
{{- $merged | toYaml -}}
{{- end -}}

# Default values if not passed by the user in values.yaml
{{- define "default_env" -}}
database_url: '{{ printf "mysql://root:4mz5IrvhZb@%s-mysql-sorba/tree" .Release.Name }}'
redis: '{{ printf "{\"port\": 6379,\"host\":\"%s-redis-master\",\"db\":0,\"reconnectTime\":5000}" .Release.Name }}'
identityURL: '{{ printf "http://%s-identity-api:5000/api" .Release.Name }}'
proxies: '{{ "{\"/identity-server\":{\"target\":\"https://wso2am-pattern-1-am-service:8243/identity/v1/\",\"pathRewrite\":{\"^/identity-server\":\"\"},\"secure\":false,\"changeOrigin\":true,\"logLevel\":\"debug\"},\"/api/tree\":{\"target\":\"https://wso2am-pattern-1-am-service:8243/tree/v1/\",\"pathRewrite\":{\"^/api/tree\":\"\"},\"secure\":false,\"changeOrigin\":true,\"logLevel\":\"debug\"},\"/api/vpnservice\":{\"target\":\"http://52.191.30.247/\",\"pathRewrite\":{\"^/api/vpnservice\":\"\"},\"secure\":false,\"changeOrigin\":true,\"logLevel\":\"debug\"},\"/api/commands\":{\"target\":\"https://websoc.{{ .Release.Name}}.sorba.ai/api/commands\",\"pathRewrite\":{\"^/api/commands\":\"\"},\"secure\":false,\"changeOrigin\":true,\"logLevel\":\"debug\"},\"/api/influx\":{\"target\":\"http://{{ .Release.Namespace}}-influxdb:8086\",\"pathRewrite\":{\"^/api/influx\":\"\"},\"secure\":false,\"changeOrigin\":true,\"logLevel\":\"debug\"},\"/api/rtdb\":{\"target\":\"http://webdis:7379\",\"pathRewrite\":{\"^/api/rtdb\":\"\"},\"secure\":false,\"changeOrigin\":true,\"logLevel\":\"debug\"}}" }}'
socketUrl: '{{ printf "wss://websoc.%s.sorbapp.com/websocket" .Release.Name }}'
{{- end -}}

