#!/bin/bash
ARGOCD_VERSION=v2.1.7

eval "$(minikube -p helm-secret-demo docker-env)"

docker build --rm -t "ghcr.io/kameshsampath/argocd-helm-secrets:${ARGOCD_VERSION}" argocd -f argocd/Dockerfile

docker tag "ghcr.io/kameshsampath/argocd-helm-secrets:${ARGOCD_VERSION}" ghcr.io/kameshsampath/argocd-helm-secrets:latest

docker push "ghcr.io/kameshsampath/argocd-helm-secrets:${ARGOCD_VERSION}"
docker push "ghcr.io/kameshsampath/argocd-helm-secrets:latest"
