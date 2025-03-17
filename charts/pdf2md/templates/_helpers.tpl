{{- define "pdf2md.redisUrl" -}}
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
{{ $.Values.redis.connection }}
{{- end -}}
{{- end -}}
