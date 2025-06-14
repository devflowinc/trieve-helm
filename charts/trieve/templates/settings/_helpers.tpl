{{- define "trieve.redisUrl" -}}
{{- if .Values.redis.enabled -}}
{{- $svcName := printf "%s-redis-master" .Release.Name -}}
{{- $redisSecretName := printf "%s-redis" .Release.Name -}}
{{- $redisSecretKey := "redis-password" -}}
{{- $redisUri := printf "redis://%s@%s" .Release.Name -}}
{{- with (lookup "v1" "Secret" .Release.Namespace $redisSecretName) -}}
{{- $redisPassword := index .data $redisSecretKey | b64dec -}}
redis://:{{ $redisPassword }}@{{ $svcName }}:6379
{{- end -}}
{{- else -}}
{{ .Values.config.redis.uri }}
{{- end -}}
{{- end -}}

{{- define "trieve.databaseUrl" -}}
{{- if $.Values.postgres.dbURI -}}
{{ .Values.postgres.dbURI }}
{{- else if $.Values.postgres.secretKeyRef -}}
{{- $secretName := .Values.postgres.secretKeyRef.name -}}
{{- $secretKey := .Values.postgres.secretKeyRef.key -}}
{{- with (lookup "v1" "Secret" .Release.Namespace $secretName) -}}
{{- index .data $secretKey | b64dec -}}
{{- end -}}
{{- else -}}
{{- $secretName := printf "%s-trieve-postgres-app" .Release.Name -}}
{{- with (lookup "v1" "Secret" .Release.Namespace $secretName) -}}
{{- index .data "uri" | b64dec -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "trieve.secrets" -}}
{{- if .Values.config.trieve.adminApiKeyRef.enabled -}}
- name: ADMIN_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.trieve.adminApiKeyRef.secretName }}
      key: {{ .Values.config.trieve.adminApiKeyRef.secretKey }}
{{- end }}
{{- if .Values.config.trieve.jinaCodeApiKeyRef.enabled }}
- name: JINA_CODE_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.trieve.jinaCodeApiKeyRef.secretName }}
      key: {{ .Values.config.trieve.jinaCodeApiKeyRef.secretKey }}
{{- end }}
{{- if .Values.config.oidc.clientSecretRef.enabled }}
- name: OIDC_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.oidc.clientSecretRef.secretName }}
      key: {{ .Values.config.oidc.clientSecretRef.secretKey }}
{{- end }}
{{- if .Values.config.llm.apiKeyRef.enabled }}
- name: LLM_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.llm.apiKeyRef.secretName }}
      key: {{ .Values.config.llm.apiKeyRef.secretKey }}
{{- end }}
{{- if .Values.config.openai.apiKeyRef.enabled }}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.openai.apiKeyRef.secretName }}
      key: {{ .Values.config.openai.apiKeyRef.secretKey }}
{{- end }}
{{- if .Values.config.s3.accessKeyRef.enabled }}
- name: S3_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.s3.accessKeyRef.secretName }}
      key: {{ .Values.config.s3.accessKeyRef.secretKey }}
{{- end }}
{{- if .Values.config.s3.secretKeyRef.enabled }}
- name: S3_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.s3.secretKeyRef.secretName }}
      key: {{ .Values.config.s3.secretKeyRef.secretKey }}
{{- end }}
{{- if .Values.config.stripe.secretRef.enabled }}
- name: STRIPE_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.stripe.secretRef.secretName }}
      key: {{ .Values.config.stripe.secretRef.secretKey }}
{{- end }}
{{- if .Values.config.stripe.webhookSecretRef.enabled }}
- name: STRIPE_WEBHOOK_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.stripe.webhookSecretRef.secretName }}
      key: {{ .Values.config.stripe.webhookSecretRef.secretKey }}
{{- end }}
{{- if .Values.config.smtp.passwordRef.enabled }}
- name: SMTP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.smtp.passwordRef.secretName }}
      key: {{ .Values.config.smtp.passwordRef.secretKey }}
{{- end }}
{{- if .Values.config.trieve.anthropicAPIKeyRef.enabled }}
- name: ANTHROPIC_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.trieve.anthropicAPIKeyRef.secretName }}
      key: {{ .Values.config.trieve.anthropicAPIKeyRef.secretKey }}
{{- end }}
{{- if .Values.config.trieve.subtraceTokenRef.enabled }}
- name: SUBTRACE_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.trieve.subtraceTokenRef.secretName }}
      key: {{ .Values.config.trieve.subtraceTokenRef.secretKey }}
{{- end }}

{{ if .Values.pdf2md.enabled }}
{{- if .Values.pdf2md.config.llm.apiKeyRef.enabled }}
- name: PDF2MD_LLM_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.pdf2md.config.llm.apiKeyRef.secretName }}
      key: {{ .Values.pdf2md.config.llm.apiKeyRef.secretKey }}
{{- end }}
{{- if .Values.pdf2md.s3.accessKeyRef.enabled }}
- name: PDF2MD_S3_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.pdf2md.s3.accessKeyRef.secretName }}
      key: {{ .Values.pdf2md.s3.accessKeyRef.secretKey }}
{{- end }}
{{- if .Values.pdf2md.s3.secretKeyRef.enabled }}
- name: PDF2MD_S3_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.pdf2md.s3.secretKeyRef.secretName }}
      key: {{ .Values.pdf2md.s3.secretKeyRef.secretKey }}
{{- end }}
{{- end }}
{{- if .Values.redis.auth.secretKeyRef.enabled }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.redis.auth.secretKeyRef.secretName }}
      key: {{ .Values.redis.auth.secretKeyRef.secretKey }}
{{- end }}
{{- if .Values.clickhouse.connection.clickhousePasswordRef.enabled }}
- name: CLICKHOUSE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.clickhouse.connection.clickhousePasswordRef.secretName }}
      key: {{ .Values.clickhouse.connection.clickhousePasswordRef.secretKey }}
{{- end }}
- name: QDRANT_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-qdrant-apikey
      key: api-key
{{- end -}}
