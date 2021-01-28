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
{{- printf "%s" $releaseName | trunc 63 | trimSuffix "-" -}}
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
Get a hostname from URL
*/}}
{{- define "hostname" -}}
{{- . | trimPrefix "http://" |  trimPrefix "https://" | trimSuffix "/" | trim | quote -}}
{{- end -}}

{{/*
Get a hostname from URL without quote
*/}}
{{- define "hostname1" -}}
{{- . | trimPrefix "http://" |  trimPrefix "https://" | trimSuffix "/" | -}}
{{- end -}}

{{/*
Get SecRule's arguments with unescaped single&double quotes
*/}}
{{- define "secrule" -}}
{{- $operator := .operator | quote | replace "\"" "\\\"" | replace "'" "\\'" -}}
{{- $action := .action | quote | replace "\"" "\\\"" | replace "'" "\\'" -}}
{{- printf "SecRule %s %s %s" .variable $operator $action -}}
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

{{- define "c9.storageClass" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
*/}}
{{- if .Values.global -}}
    {{- if .Values.global.storageClass -}}
        {{- if (eq "-" .Values.global.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .Values.global.storageClass -}}
        {{- end -}}
    {{- else -}}
        {{- if .Values.persistence.storageClass -}}
              {{- if (eq "-" .Values.persistence.storageClass) -}}
                  {{- printf "storageClassName: \"\"" -}}
              {{- else }}
                  {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
              {{- end -}}
        {{- end -}}
    {{- end -}}
{{- else -}}
    {{- if .Values.persistence.storageClass -}}
        {{- if (eq "-" .Values.persistence.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}