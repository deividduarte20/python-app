# ArgoCD Setup Guide

## 📋 Informações de Acesso Atual
- **URL**: http://argocd.test.com  
- **Usuário**: admin
- **Senha**: ypdlO4ju7G1R9OGh

## 🚀 Para Reinstalar do Zero

1. **Remover instalação atual:**
   ```bash
   helm uninstall argocd -n argocd
   kubectl delete namespace argocd
   ```

2. **Instalar com configurações corretas:**
   ```bash
   ./install-argocd.sh
   ```

## 🔧 Configurações Importantes

### values-argo.yaml
O arquivo `values-argo.yaml` está configurado com:
- Host: `argocd.test.com`
- Modo inseguro (HTTP) para ambiente de desenvolvimento
- Ingress com nginx
- SSL desabilitado

### Problema Conhecido
O chart oficial do ArgoCD às vezes ignora a configuração de `hosts` no Ingress. O script `install-argocd.sh` inclui uma correção automática que aplica um patch se necessário.

## 🌐 Acesso Local

Para acessar localmente, adicione ao `/etc/hosts`:
```bash
echo "127.0.0.1 argocd.test.com" | sudo tee -a /etc/hosts
```

## 🔄 Comandos Úteis

### Verificar status
```bash
kubectl get all,ingress -n argocd
```

### Obter nova senha (se necessário)
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Corrigir Ingress manualmente
```bash
kubectl patch ingress argocd-server -n argocd --type='merge' \
  -p='{"spec":{"rules":[{"host":"argocd.test.com","http":{"paths":[{"path":"/","pathType":"Prefix","backend":{"service":{"name":"argocd-server","port":{"number":80}}}}]}}]}}'
```

## 📝 Notas
- O ArgoCD está configurado em modo inseguro (HTTP) para facilitar o desenvolvimento
- Para produção, configure TLS adequadamente
- Lembre-se de deletar o secret inicial após o primeiro acesso
