# Kubernetes ResourceQuota Generator

Este projeto gera arquivos YAML de **ResourceQuota** para Kubernetes dinamicamente com base em um arquivo de configuração (`config.yaml`), utilizando **Python** e **Jinja2**.

## 📌 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Python 3.x** (Recomenda-se a versão mais recente)
- **pip** (gerenciador de pacotes do Python)

## 🚀 Instalação

Clone o repositório e navegue até o diretório:

```sh
git clone https://github.com/seu-usuario/resource-quota.git
cd resource-quota
```

### 🛠️ Criar e ativar um ambiente virtual (opcional, mas recomendado)

```sh

python3 -m venv venv
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows
```

### 📦 Instalar as dependências

```sh
pip install -r requirements.txt
```

## ⚙️ Configuração

Crie um arquivo `config.yaml` com as quotas desejadas. Exemplo:

```yaml
quotas:
  - name: quota-small
    namespace: dev
    requests:
      cpu: "2"
      memory: "4Gi"
    limits:
      cpu: "4"
      memory: "8Gi"

  - name: quota-medium
    namespace: staging
    requests:
      cpu: "4"
      memory: "8Gi"
    limits:
      cpu: "6"
      memory: "12Gi"

  - name: quota-large
    namespace: production
    requests:
      cpu: "8"
      memory: "16Gi"
    limits:
      cpu: "12"
      memory: "24Gi"
```

## 📜 Template Jinja2 (`resource_quota_template.yaml`)

O template define a estrutura dos arquivos YAML gerados:

```yaml
{% for quota in quotas %}
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: {{ quota.name }}
  namespace: {{ quota.namespace }}
spec:
  hard:
    requests.cpu: "{{ quota.requests.cpu }}"
    requests.memory: "{{ quota.requests.memory }}"
    limits.cpu: "{{ quota.limits.cpu }}"
    limits.memory: "{{ quota.limits.memory }}"
{% endfor %}
```

## ▶️ Execução

Para gerar os arquivos `resource_quota.yaml`, execute:

```sh
python3 generate_quota.py

or 

python3 ci/generate_quota.py --config config.yaml --template ci/resource_quota_template.yaml
```

### 📄 Exemplo de saída (`resource_quota.yaml`)

```yaml
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota-small
  namespace: dev
spec:
  hard:
    requests.cpu: "2"
    requests.memory: "4Gi"
    limits.cpu: "4"
    limits.memory: "8Gi"
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota-medium
  namespace: staging
spec:
  hard:
    requests.cpu: "4"
    requests.memory: "8Gi"
    limits.cpu: "6"
    limits.memory: "12Gi"
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota-large
  namespace: production
spec:
  hard:
    requests.cpu: "8"
    requests.memory: "16Gi"
    limits.cpu: "12"
    limits.memory: "24Gi"
```

## 🛑 Erros Comuns e Soluções

### ❌ `ModuleNotFoundError: No module named 'yaml'`
✅ Execute:
```sh
pip install pyyaml
```

### ❌ `ModuleNotFoundError: No module named 'jinja2'`
✅ Execute:
```sh
pip install jinja2
```

### ❌ `error: externally-managed-environment`
✅ Se estiver no macOS, use um ambiente virtual:
```sh
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 📜 Licença

Este projeto é de uso livre. Fique à vontade para modificar e contribuir!

