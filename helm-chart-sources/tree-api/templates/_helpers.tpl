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

#Default values if not passed by the user in values.yaml
{{- define "default_env" -}}
DATABASE_URL: '{{ printf "mysql://root:4mz5IrvhZb@%s-mysql-sorba/tree" .Release.Name }}'
CLOUD_GRAFANA_API: '{{ printf "{\"URL\":\"http://%s-grafana:3000/api\",\"USER\":\"admin\",\"PASS\":\"sbrQp10\"}" .Release.Name }}'
HDFS_URL: '{{ "http://192.168.1.94:3003" }}'
#LICENSE_DECODER: '{{ "{\"port\": 8074,\"host\": \"sorbapp-license-decoder-auto-deploy-app-gitlab\",\"endpoint\": \"/api/decode\"}" }}'
LICENSE_DECODER: '{{ printf "{\"port\": %d,\"host\": \"sorbapp-license-decoder-auto-deploy-app-gitlab\",\"endpoint\": \"/api/decode\"}" 8074 }}'
REDIS: '{{ printf "{\"port\": 6379,\"host\":\"%s-redis-master\",\"db\":0,\"reconnectTime\":5000}" .Release.Name }}'
SORBA_INTEGRATION_AUTHORIZATION: '{{ "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IlNvcmJhIEludGVncmF0aW9uIiwiaWF0IjozNzM5NTcyMDAwMDB9.4A1X7l84wCJq7asgkGKaoYizlNBHnwGBm9Ex-YZRRzg" }}'
SORBA_INTEGRATION_URL: '{{ "http://sorbapp-sorba-dashboard-comm-auto-deploy-app-gitlab:5000" }}'
#DEFAULT_TENANT_SETTINGS: '{{ "{\"platformAPI\":\"https://ng-api-gateway.test-admin.fullstackcoder.net/tree\",\"mqttBrokerHost\":\"broker.sorba.ai\",\"grafanaURL\":\"https://dashboard.test-admin.fullstackcoder.net\",\"grafanaAPI\":\"https://dashboard.test-admin.fullstackcoder.net/api\",\"taskFlowAPI\":\"https://ng-api-gateway.test-admin.fullstackcoder.net/taskflow\",\"taskFlowAPIGlobal\":\"\"}" }}'
DEFAULT_TENANT_SETTINGS: '{{ printf "{\"platformAPI\":\"https://ng-api-gateway.%s.fullstackcoder.net/tree\",\"mqttBrokerHost\":\"broker.sorba.ai\",\"grafanaURL\":\"https://dashboard.%s.fullstackcoder.net\",\"grafanaAPI\":\"https://dashboard.%s.fullstackcoder.net/api\",\"taskFlowAPI\":\"https://ng-api-gateway.%s.fullstackcoder.net/taskflow\",\"taskFlowAPIGlobal\":\"\"}" test-admin }}'
{{- end -}}