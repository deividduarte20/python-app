#!/bin/bash

# Script para instalar ArgoCD com configurações corretas
# Este script garante que o ArgoCD seja instalado com a URL correta

echo "🚀 Instalando ArgoCD com configurações customizadas..."

# 1. Adicionar repositório do ArgoCD Helm
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# 2. Criar namespace se não existir
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# 3. Instalar ArgoCD com valores customizados
helm install argocd argo/argo-cd -n argocd -f values-argo.yaml

# 4. Aguardar deployments ficarem prontos
echo "⏳ Aguardando ArgoCD ficar pronto..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-applicationset-controller -n argocd

# 5. Verificar se o Ingress foi criado corretamente
echo "🔍 Verificando Ingress..."
INGRESS_HOST=$(kubectl get ingress argocd-server -n argocd -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)

if [ "$INGRESS_HOST" != "argocd.test.com" ]; then
    echo "⚠️  Corrigindo host do Ingress..."
    kubectl patch ingress argocd-server -n argocd --type='merge' -p='{"spec":{"rules":[{"host":"argocd.test.com","http":{"paths":[{"path":"/","pathType":"Prefix","backend":{"service":{"name":"argocd-server","port":{"number":80}}}}]}}]}}'
fi

# 6. Obter senha inicial
echo "🔑 Obtendo credenciais de acesso..."
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "✅ ArgoCD instalado com sucesso!"
echo ""
echo "📋 Informações de acesso:"
echo "   URL: http://argocd.test.com"
echo "   Usuário: admin"
echo "   Senha: $ADMIN_PASSWORD"
echo ""
echo "💡 Para acesso local, adicione ao /etc/hosts:"
echo "   echo '127.0.0.1 argocd.test.com' | sudo tee -a /etc/hosts"
echo ""
echo "🔄 Para reinstalar, execute:"
echo "   helm uninstall argocd -n argocd && kubectl delete namespace argocd"
echo "   Em seguida, execute este script novamente."
