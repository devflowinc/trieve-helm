{{- define "trieve.worker.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .name }}
  labels:
    app.kubernetes.io/name: {{ .name }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
spec:
  replicas: {{ .replicas | default 1 }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ .name }}
      app.kubernetes.io/instance: {{ $.Release.Name }}
  template:
    metadata:
      annotations:
        {{- if $.Values.config.trieve.asSecret }}
        checksum/config: {{ include (print $.Template.BasePath "/settings/backend-secrets.yaml") . | sha256sum }}
        {{- else }}
        checksum/config: {{ include (print $.Template.BasePath "/settings/backend-configmap.yaml") . | sha256sum }}
        {{- end }}
        {{- with .Values.global.additionalAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        app.kubernetes.io/name: {{ .name }}
        app.kubernetes.io/instance: {{ $.Release.Name }}
        {{- with .Values.global.additionalLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- if $.Values.global.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml $.Values.global.imagePullSecrets | nindent 8 }}
      {{- end }}
      containers:
      - name: {{ .name }}
        image: {{ printf "%s/%s:%s" $.Values.global.image.registry .image.repository .image.tag }}
        imagePullPolicy: {{ $.Values.global.imagePullPolicy }}
        envFrom:
          {{- if $.Values.config.trieve.asSecret }}
          - secretRef:
              name: trieve-server-secret
          {{- else }}
          - configMapRef:
              name: trieve-server-config
          {{- end }}
        env:
          {{- include "trieve.secrets" . | nindent 10 }}
        {{- if .resources }}
        resources:
          {{- toYaml .resources | nindent 12 }}
        {{- end }}
{{- end -}}
