# 🚀 Deploy de Prometheus, Grafana e Ingress-NGINX com Helmfile e Kind

Este projeto configura um ambiente **Kubernetes local** utilizando **Kind** e implanta **Prometheus, Grafana e Ingress-NGINX** com **Helmfile**.

---

## 📌 Pré-requisitos

Certifique-se de ter instalado:

- **[Docker](https://docs.docker.com/get-docker/)**
- **[Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)**
- **[kubectl](https://kubernetes.io/docs/tasks/tools/)**
- **[Helm](https://helm.sh/docs/intro/install/)**
- **[Helmfile](https://github.com/helmfile/helmfile)**

---

## 🏗️ Criando o Cluster Kind com 3 Nós

1. Crie o arquivo de configuração do cluster:

```yaml
# kind-cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
  apiServerAddress: "127.0.0.1"
  apiServerPort: 6443

	2.	Crie o cluster no Kind:

kind create cluster --name helmfile-cluster --config kind-cluster.yaml

	3.	Verifique se os nós foram criados corretamente:

kubectl get nodes

📦 Instalando Helm e Helmfile

Se ainda não tiver o Helm e Helmfile instalados:

# Instalar Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x get_helm.sh
./get_helm.sh

# Instalar Helmfile
curl -Lo helmfile https://github.com/helmfile/helmfile/releases/latest/download/helmfile_linux_amd64
chmod +x helmfile
sudo mv helmfile /usr/local/bin/

📜 Instalando CRDs do Prometheus Operator

Antes de rodar o Helmfile, é obrigatório instalar os CRDs do Prometheus Operator:

kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml

Isso garante que as Custom Resource Definitions (CRDs) necessárias estarão disponíveis antes da instalação.

⚙️ Arquivo helmfile.yaml

Este Helmfile instala:

✅ Prometheus: Coleta e armazena métricas
✅ Grafana: Dashboard de métricas
✅ Ingress-NGINX: Controlador de tráfego

Crie o arquivo helmfile.yaml com o seguinte conteúdo:

repositories:
  - name: prometheus-community
    url: https://prometheus-community.github.io/helm-charts
  - name: grafana
    url: https://grafana.github.io/helm-charts
  - name: ingress-nginx
    url: https://kubernetes.github.io/ingress-nginx

releases:
  - name: prometheus
    namespace: monitoring
    chart: prometheus-community/kube-prometheus-stack
    version: "57.0.2"
    values:
      - prometheus:
          prometheusSpec:
            storageSpec:
              volumeClaimTemplate:
                spec:
                  accessModes: ["ReadWriteOnce"]
                  resources:
                    requests:
                      storage: 10Gi
      - grafana:
          enabled: false
      - alertmanager:
          enabled: true
      - kubeStateMetrics:
          enabled: true
      - nodeExporter:
          enabled: true

  - name: grafana
    namespace: monitoring
    chart: grafana/grafana
    version: "7.3.6"
    values:
      - persistence:
          enabled: true
          size: 5Gi
      - adminPassword: "admin123"
      - service:
          type: ClusterIP
      - ingress:
          enabled: true
          annotations:
            kubernetes.io/ingress.class: "nginx"
          hosts:
            - grafana.local
          paths:
            - "/"

  - name: ingress-nginx
    namespace: ingress
    chart: ingress-nginx/ingress-nginx
    version: "4.8.3"
    values:
      - controller:
          replicaCount: 2
          service:
            type: LoadBalancer
          ingressClass: "nginx"
          admissionWebhooks:
            enabled: false

🚀 Implantando os Serviços com Helmfile
	1.	Criar os namespaces necessários:

kubectl create namespace monitoring
kubectl create namespace ingress

	2.	Executar o Helmfile para deploy:

helmfile apply

	3.	Verificar os pods implantados:

kubectl get pods -n monitoring
kubectl get pods -n ingress

🌍 Expondo os Serviços

O Kind não possui LoadBalancer nativo, então podemos expor os serviços via port-forward.

Acessar o Grafana

kubectl port-forward svc/grafana 3000:80 -n monitoring

	•	Acesse: http://localhost:3000
	•	Usuário: admin
	•	Senha: admin123

Acessar o Prometheus

kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090 -n monitoring

	•	Acesse: http://localhost:9090

📡 Configurando Ingress

Se quiser acessar via Ingress-NGINX, aplique esta configuração:

kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: grafana.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: grafana
            port:
              number: 80
EOF

Depois, adicione esta entrada no /etc/hosts (Linux/macOS):

sudo echo "127.0.0.1 grafana.local" >> /etc/hosts

Agora, você pode acessar http://grafana.local diretamente! 🎉

Se necessario forçar a sincronização:

helmfile sync
helmfile apply

🗑️ Removendo Tudo

Se quiser remover os recursos:

helmfile destroy
kind delete cluster --name helmfile-cluster

🎯 Conclusão

✅ Kind + Helmfile para testes locais
✅ Deploy automatizado de Prometheus, Grafana e Ingress
✅ Acesso via port-forward ou Ingress

Agora, você pode validar monitoramento localmente antes de migrar para um ambiente real! 🚀
Caso precise de suporte, abra um issue ou contribua com melhorias.

💡 Criado por: Carlos Bruno
