# Helm Secrets Demo

My demo collection in using [helm-secrets](https://github.com/jkroepke/helm-secrets)with Kubernetes and GitOps workflow

## Required tools

- [sops](https://github.com/mozilla/sops)
- [Hashicorp Vault](https://www.vaultproject.io)
- [Argocd](https://argo-cd.readthedocs.io)

## Install Argocd

```shell
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argo argo/argo-cd \
  --namespace=argocd \
  --create-namespace=true \
  --values helm_vars/argocd/values.yaml
```
