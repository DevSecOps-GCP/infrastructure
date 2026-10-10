#!/usr/bin/env bash
# Opens a port-forward to the active Vault pod through the ops cluster's DNS endpoint and
# exports a GitHub OIDC token for Vault's JWT login (TF_VAR_vault_jwt). Vault stays private:
# GKE checks the job's Google identity (IAM), Kubernetes RBAC limits it to port-forwarding
# to Vault, and Vault checks the GitHub token's repository, branch and environment.
set -euo pipefail

: "${OPS_CLUSTER:?}" "${OPS_ZONE:?}" "${OPS_PROJECT:?}" "${VAULT_HOST:?}" "${VAULT_AUDIENCE:?}"

endpoint=$(gcloud container clusters describe "$OPS_CLUSTER" --zone "$OPS_ZONE" --project "$OPS_PROJECT" \
  --format='value(controlPlaneEndpointsConfig.dnsEndpointConfig.endpoint)')

export KUBECONFIG="$RUNNER_TEMP/kubeconfig"
kubectl config set-cluster ops --server="https://$endpoint" >/dev/null
kubectl config set-credentials pipeline --token="$(gcloud auth print-access-token)" >/dev/null
kubectl config set-context ops --cluster=ops --user=pipeline >/dev/null
kubectl config use-context ops >/dev/null

nohup kubectl -n vault port-forward svc/vault-active 8200:8200 > "$RUNNER_TEMP/vault-port-forward.log" 2>&1 &

for _ in $(seq 1 30); do
  if curl -sf --resolve "$VAULT_HOST:8200:127.0.0.1" "https://$VAULT_HOST:8200/v1/sys/health" -o /dev/null; then
    break
  fi
  sleep 1
done
curl -sf --resolve "$VAULT_HOST:8200:127.0.0.1" "https://$VAULT_HOST:8200/v1/sys/health" -o /dev/null \
  || { cat "$RUNNER_TEMP/vault-port-forward.log"; echo "::error::Vault is not reachable"; exit 1; }

jwt=$(curl -sSf -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
  "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=$VAULT_AUDIENCE" | jq -r .value)
echo "::add-mask::$jwt"
echo "TF_VAR_vault_jwt=$jwt" >> "$GITHUB_ENV"
echo "Vault tunnel open on 127.0.0.1:8200"
