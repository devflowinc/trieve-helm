# Trieve Helm Chart

```bash
helm repo add trieve https://devflowinc.github.io/trieve-helm
helm repo update
helm upgrade trieve-local -i trieve/trieve
```

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quickstart](#quickstart)
- [Configuration Reference](#configuration-reference)
- [Post-Installation](#post-installation)
- [Troubleshooting](#troubleshooting)

## Overview

This helm chart provides a complete Trieve installation with the following components:

### Built-in Dependencies
For an easy 1-click install process, this chart includes:

- `qdrant` - Vector database via officially supported subchart
- `postgres` - Database using CloudNative-PG operator
- `clickhouse` - Analytics database using Clickhouse operator
- `redis` - Caching layer via Bitnami Redis subchart
- `keycloak` - Optional bundled OIDC provider

**Note**: For production environments, we recommend installing these dependencies as separate releases for easier database migration and management.

## 🚨 Quick Summary: What You MUST Change

Before proceeding, you need to modify these specific sections in your `values.yaml`:

1. **config.vite** - Domains that the frontends use URLs (apiHost, searchUiUrl, chatUiUrl, dashboardUrl)
2. **config.trieve.baseServerUrl** - Domain that the server uses
3. **config.trieve** security keys:
   - `adminApiKey` - Generate with: `openssl rand -hex 24` (**config.trieve.adminApiKeyRef** to configure as a secret)
4. **config.s3** - Your S3 bucket credentials (endpoint, accessKey, secretKey, bucket, region)
  - **config.s3.accessKeyRef** To configure as a secret using the `config.s3.accessKeyRef` option
  - **config.s3.secretKey** To configure as a secret using the `config.s3.secretKeyRef` option
5. **config.llm.apiKey** - Your OpenRouter API key (**config.llm.apiKeyRef** to configure as a secret)
6. **config.openai.apiKey** - Your OpenAI API key (**config.openai.apiKeyRef** to configure as a secret)
7. **config.oidc** - Your OIDC provider settings (clientSecret, clientId, issuerUrl, authRedirectUrl)
  - `config.oidc.clientSecretRef` can be used to configure as a secret
8. **pdf2md.s3** - S3 credentials for PDF processing (if using PDF2MD (`pdf2md.enabled`)
9. **pdf2md.config.llm.apiKey** - LLM API key for PDF processing (if using PDF2MD)
  - `pdf2md.config.llm.apiKeyRef` can be used to configure as a secret

**For production**: Also change database passwords for clickhouse, qdrant, and redis.

## Prerequisites

Before installing Trieve, ensure you have the following:

1. **Kubernetes Cluster**: A working Kubernetes cluster (1.20+)
2. **Helm 3**: Installed on your local machine
3. **kubectl**: Configured to connect to your cluster
4. **GPU Nodes** (Optional but recommended): For embedding servers
5. **Domain Names**: If exposing services externally
6. **SSL Certificates**: For HTTPS (cert-manager recommended)

### For GPU Support (NVIDIA)
If using GPU nodes for embedding servers, install the NVIDIA device plugin:

```bash
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml
```

## Quickstart

⚠️ **CRITICAL CONFIGURATION REQUIRED** ⚠️

### 1. Add Trieve Helm Repository

```bash
helm repo add trieve https://devflowinc.github.io/trieve-helm
helm repo update
```

### 2. Create / Update the values.yaml file

You **MUST** modify the following in your `values.yaml` before installation:
1. **All domain URLs** - Replace `yourdomain.com` with your actual domain
2. **S3 credentials** - Both for main Trieve and PDF2MD service
3. **LLM API keys** - OpenRouter and/or OpenAI keys
4. **OIDC settings** - Your identity provider configuration
5. **Security keys** - Generate new salt, secretKey, and adminApiKey
6. **Database passwords** - Change all default passwords

### 3. CRITICAL: Configure OIDC Redirect URLs

Before installing, ensure your OIDC provider allows the following redirect URLs:
- `https://api.yourdomain.com/*`
- `https://dashboard.yourdomain.com/*`
- `https://chat.yourdomain.com/*`
- `https://search.yourdomain.com/*`

### 4. Install Trieve

```bash
# Install the chart (run twice to ensure CRDs and ConfigMaps are properly updated)
helm upgrade -i trieve-local trieve/trieve -f values.yaml --version 0.2.20
helm upgrade -i trieve-local trieve/trieve -f values.yaml --version 0.2.20
```

### 5. Verify Installation

```bash
kubectl rollout status deployment/server --timeout=300s
```

### 6. Configure DNS / Ingress

#### Ingress 
If you used the `domains`: for ingress run 

```bash
kubectl get ingress
```

To get the records you need to add.

#### Custom Ingress

For any other custom ingress solution, you'll need to expose the following services:

- `server-service` - Port 8090 (API)
- `dashboard-service` - Port 3002 (Dashboard UI)
- `chat-service` - Port 3000 (Chat UI)  
- `search-service` - Port 3001 (Search UI)

Ensure all domain names point to your ingress controller's external IP:

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

### 7. Access Your Installation

- Dashboard: `http(s)://dashboard.yourdomain.com`
- API: `http(s)://api.yourdomain.com`
- Search UI: `http(s)://search.yourdomain.com`
- Chat UI: `http(s)://chat.yourdomain.com`

## Configuration Reference

### Global Settings

```yaml
global:
  image:
    registry: trieve                 # Docker registry for Trieve images
    imagePullPolicy: Always         # Image pull policy
    # imagePullSecrets:             # Optional: Pull secrets for private registries
    #   - name: pull-secret-name
```

### Database Configuration

#### PostgreSQL
```yaml
postgres:
  enabled: true                     # Enable built-in PostgreSQL
  installCrds: true                 # Install CloudNative-PG operator
  clusterSpec:
    instances: 1                    # Number of PostgreSQL instances
    storage:
      size: 10Gi                    # Storage size per instance
```

#### Clickhouse
```yaml
clickhouse:
  enabled: true                     # Enable built-in Clickhouse
  installCrds: true                 # Install Clickhouse operator
  connection:
    clickhouseDB: default
    clickhouseUser: default
    clickhousePassword: clickhouse  # CHANGE THIS IN PRODUCTION
    clickhouseUrl: http://clickhouse-trieve-local-trieve:8123
```

#### Qdrant (Vector Database)
```yaml
qdrant:
  enabled: true                     # Enable built-in Qdrant
  url: http://trieve-local-qdrant:6334
  apiKey: "qdrant-api-key"         # CHANGE THIS IN PRODUCTION
  replicaCount: 3                   # Number of Qdrant replicas
  persistence:
    size: "10Gi"                    # Storage per Qdrant instance
```

#### Redis
```yaml
redis:
  enabled: true                     # Enable built-in Redis
  auth:
    password: "password"            # CHANGE THIS IN PRODUCTION
  master:
    persistence:
      enabled: false                # Enable persistence for Redis
    resources:
      limits:
        memory: 5Gi
```

### Service Configuration

#### Required External Services

1. **LLM Configuration**
   ```yaml
   config:
     llm:
       apiKey: "sk-..."            # OpenRouter API key (recommended)
     openai:
       apiKey: "sk-..."            # OpenAI API key
       baseUrl: https://api.openai.com/v1
   ```

2. **S3 Storage**
   ```yaml
   config:
     s3:
       endpoint: "https://s3.amazonaws.com"
       accessKey: "YOUR_ACCESS_KEY"
       secretKey: "YOUR_SECRET_KEY"
       bucket: "your-bucket-name"
       region: "us-east-1"         # Optional
   ```

3. **OIDC Authentication**
   ```yaml
   config:
     oidc:
       clientId: "trieve"
       clientSecret: "your-secret"
       issuerUrl: "http://your-oidc-provider/realms/trieve"
       authRedirectUrl: "http://your-oidc-provider/realms/trieve/protocol/openid-connect/auth"
   ```

   **Important**: Configure your OIDC provider to allow redirect URLs for:
   - `http(s)://api.yourdomain.com/*`
   - `http(s)://dashboard.yourdomain.com/*`
   - `http(s)://chat.yourdomain.com/*`
   - `http(s)://search.yourdomain.com/*`

4. **SMTP (Optional - for email invites)**
   ```yaml
   config:
     smtp:
       relay: "smtp.example.com"
       username: "your-username"
       password: "your-password"
       emailAddress: "noreply@example.com"
   ```

### Domain Configuration (optional for setting up Ingresses)

```yaml
domains:
  dashboard:
    disabled: false
    host: dashboard.yourdomain.com
    class: nginx                    # Ingress class
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
    tls:
      - hosts:
          - dashboard.yourdomain.com
        secretName: dashboard-tls
  # Repeat similar configuration for server, search, and chat domains
```

### Container Configuration

Each service can be configured individually:

```yaml
containers:
  server:
    tag: sha-408a679               # Image tag
    repository: server             # Repository name
    replicas: 3                    # Number of replicas
    resources:                     # Resource limits
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 2
        memory: 4Gi
```

### Embedding Servers Configuration

Trieve uses Text Embeddings Inference (TEI) for embedding models:

```yaml
embeddings:
  - name: jina
    model: jinaai/jina-embeddings-v2-base-en
    tag: "89-1.4"                  # Architecture-specific tag
    useGpu: true                   # Enable GPU support
    tolerations:                   # Optional: Node tolerations
      - key: "gpu-node"
        operator: "Exists"
        effect: "NoSchedule"
```

#### TEI Docker Image Selection

Choose the appropriate tag based on your GPU architecture:

| GPU Architecture | Tag | Notes |
|-----------------|-----|-------|
| CPU only | `cpu-1.7` | No GPU acceleration |
| Turing (T4, RTX 2000) | `turing-1.7` | Experimental, Flash Attention off by default |
| Ampere 80 (A100, A30) | `1.7` | Default for most GPUs |
| Ampere 86 (A10, A40) | `86-1.7` | |
| Ada Lovelace (RTX 4000) | `89-1.7` | |
| Hopper (H100) | `hopper-1.7` | Experimental |

### PDF2MD Service (Optional)

Enable automatic PDF processing:

```yaml
pdf2md:
  enabled: true
  config:
    llm:
      baseUrl: https://openrouter.ai/api/v1
      apiKey: "sk-..."
      model: "gpt-4"
    s3:
      # Same S3 configuration as main Trieve
      endpoint: "https://s3.amazonaws.com"
      accessKey: "YOUR_ACCESS_KEY"
      secretKey: "YOUR_SECRET_KEY"
      bucket: "pdf2md-bucket"
```

## Support

For additional help:
- Check the [Trieve documentation](https://docs.trieve.ai)
- Join the [Trieve community](https://discord.gg/trieve)
- Open an issue on [GitHub](https://github.com/devflowinc/trieve)
