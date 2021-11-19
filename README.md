# Helm Secrets Demo

A simple demo to show  to how to use [helm-secrets](https://github.com/jkroepke/helm-secrets) with Kubernetes as part of the GitOps workflow.

## Required tools

The demo requires the following tools, have them installed and added to `$PATH ` before proceeding with the demo,

- [sops](https://github.com/mozilla/sops)
- [age](https://github.com/FiloSottile/age)
- [Argocd](https://argo-cd.readthedocs.io)
- [yq](https://github.com/mikefarah/yq)
- [Hashicorp Vault](https://www.vaultproject.io)
- [Helm](https://helm.sh/docs/intro/install/)
- [minikube](https://minikube.sigs.k8s.io/docs/)

Install `helm` secrets plugin,

```shell
helm plugin install https://github.com/jkroepke/helm-secrets --version v3.10.0
```

## Fork my repository

```shell
git clone https://github.com/kameshsampath/helm-secret-demo
cd helm-secret-demo
```

You can use [hub-tool](https://github.com/github/hub) to easily fork my repo. For the rest of the document we refer to this repo folder as `$PROJECT_HOME`.

## Start minikube Kubernetes Cluster

```shell
$PROJECT_HOME/start-cluster.sh
```

## Create age key

```shell
age-keygen -o key.txt
```

Move the `key.txt` to secure place, preferably `$HOME/.ssh`. Assuming you moved it to `$HOME/.ssh`, lets set that as local environment variables for convinience:

```bash
export SOPS_AGE_KEY_FILE="$HOME/.ssh/key.txt"
```

Also note and export the **publickey** in the `$SOPS_AGE_KEY_FILE` as `$SOPS_AGE_RECIPIENTS`

```bash
export SOPS_AGE_RECIPIENTS=$(cat $SOPS_AGE_KEY_FILE  | awk 'NR==2{ print $4}')
```

Ensure the sops configration `.sops.yml` is updated with your *age* publickey,

```shell
yq eval '.creation_rules[0].age |= strenv(SOPS_AGE_RECIPIENTS)' .sops.yml 
```

We need to make the age key to be available to the Argocd repo server so that it can decrypt the secrets,

```shell
kubectl create ns argocd
```

```shell
kubectl create secret generic helm-secrets-private-keys \
  --namespace=argocd \
  --from-file=key.txt="$SOPS_AGE_KEY_FILE"
```

## Install Argocd

__NOTE__:
	
	The [values.yaml](./helm_vars/argocd/values.yaml) 

	- does patch the Argocd's argocd-repo-server deployment to mount the secret-keys as repo-server volume
	- install the helm plugin and age tools and make it available as `custom-tools` volumes

```shell
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argo argo/argo-cd \
  --namespace=argocd \
  --values helm_vars/argocd/values.yaml
```

## Deploy Keycloak

Update the repo in the [keycloak-argo-app.yaml](./manifests/keycloak-argo-app.yaml) to your match your fork. 

Remove the existing [secrets.yaml](./helm_vars/keycloak/secrets.yaml) and copy the `$PROJECT_HOME/helm_vars/keycloak/secrets-example.yaml` to `$PROJECT_HOME/helm_vars/keycloak/secrets.yaml`

Update `secrets.yaml`  values to match your settings and run the following command to encrypt it,

```shell
helm secrets env $PROJECT_HOME/helm_vars/keycloak/secrets.yaml
```

Wait for the `keycloak` application to be synched and now you can open the service,

```shell
minikube -p helm-secret-demo -n keycloak
```

Click the `Administration Console` and use the username/password that you provided as part of your `secrets.yaml` settings.

## References

- [helm-secrets](https://github.com/jkroepke/helm-secrets)
- [Using with Argo](https://github.com/jkroepke/helm-secrets/blob/main/docs/ARGOCD.md)
- [sops](https://github.com/mozilla/sops)
- [age](https://github.com/FiloSottile/age)