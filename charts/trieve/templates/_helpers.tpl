{{/*
Resolve a value, preferring a Secret reference if enabled.
Scope: . (dict "currentValue" val "valueRef" valRef "context" $)
*/}}
{{- define "trieve.resolveValue" -}}
{{- $resolvedValue := .currentValue -}}
{{- if and .valueRef .valueRef.enabled .valueRef.secretName .valueRef.secretKey -}}
{{- $secret := lookup "v1" "Secret" .context.Release.Namespace .valueRef.secretName -}}
{{- if $secret -}}
{{- $resolvedValue = index $secret.data .valueRef.secretKey | b64dec -}}
{{ else }}
  {{- if .context.Values.config.trieve.strictLookup -}}
    {{- fail (printf "resolveValue: Secret %s not found in namespace %s for key %s when attempting to resolve %s" .valueRef.secretName .context.Release.Namespace .valueRef.secretKey .valueRef) -}}
  {{ else }}
    {{/* In non-strict mode, if secret or key is not found, fall back to .currentValue.
         Emitting a warning might be good, but Helm's templating warnings are not always visible.
         For now, it silently falls back. */}}
  {{ end }}
{{- end -}}
{{- else if and .valueRef .valueRef.enabled (or (not .valueRef.secretName) (not .valueRef.secretKey)) }}
{{- if .context.Values.config.trieve.strictLookup -}}
{{- fail (printf "resolveValue: valueRef enabled but secretName or secretKey is missing for %s" .valueRef) -}}
{{- end -}}
{{- end -}}
{{- $resolvedValue -}}
{{- end -}}

{{/* TODO: Add other common helpers like fullname, chart, etc. if they don't exist,
     or ensure this file is correctly included if they are in a different helper file.
     For now, assuming standard Helm chart structure where this will be available.
*/}}

{{/*
Wrapper for .Values.config.trieve specific values that could be nil if not defined.
Safely access a value from .Values.config.trieve, returning a default if path is invalid or value is nil.
Usage: {{ include "trieve.config.get" (dict "path" "adminApiKey" "default" "" "context" $) }}
This is a basic version. A more robust one would handle deeper paths.
*/}}
{{- define "trieve.config.get" -}}
{{- $value := (index .context.Values.config.trieve .path) -}}
{{- default .default $value -}}
{{- end -}}

{{/*
Wrapper for .Values.config.smtp specific values.
*/}}
{{- define "trieve.config.smtp.get" -}}
{{- $value := (index .context.Values.config.smtp .path) -}}
{{- default .default $value -}}
{{- end -}}

{{/*
Wrapper for .Values.config.oidc specific values.
*/}}
{{- define "trieve.config.oidc.get" -}}
{{- $value := (index .context.Values.config.oidc .path) -}}
{{- default .default $value -}}
{{- end -}}

{{/*
Wrapper for .Values.config.llm specific values.
*/}}
{{- define "trieve.config.llm.get" -}}
{{- $value := (index .context.Values.config.llm .path) -}}
{{- default .default $value -}}
{{- end -}}

{{/*
Wrapper for .Values.config.openai specific values.
*/}}
{{- define "trieve.config.openai.get" -}}
{{- $value := (index .context.Values.config.openai .path) -}}
{{- default .default $value -}}
{{- end -}}

{{/*
Wrapper for .Values.config.s3 specific values.
*/}}
{{- define "trieve.config.s3.get" -}}
{{- $value := (index .context.Values.config.s3 .path) -}}
{{- default .default $value -}}
{{- end -}}

{{/*
Wrapper for .Values.pdf2md.config.pdf2md specific values.
*/}}
{{- define "trieve.pdf2md.config.pdf2md.get" -}}
{{- $value := (index .context.Values.pdf2md.config.pdf2md .path) -}}
{{- default .default $value -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "trieve.labels" -}}
helm.sh/chart: {{ include "trieve.chart" . }}
{{ include "trieve.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "trieve.selectorLabels" -}}
app.kubernetes.io/name: {{ include "trieve.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "trieve.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If worried about name collisions, include .Release.Name in the name.
*/}}
{{- define "trieve.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}} 