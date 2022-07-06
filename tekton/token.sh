#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

set +x;
declare -a mandatory
mandatory=(
  NAMESPACE
  EMAIL
)

source .env

for var in "${mandatory[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Environment variable $var must be set"
    exit 1
  fi
done

echo "Deleting secret"
kubectl delete secret registry-credentials -n "$NAMESPACE"

echo "Updating Secret"
kubectl create secret docker-registry registry-credentials \
    --docker-username=oauth2accesstoken \
    --docker-password="$(gcloud auth print-access-token --impersonate-service-account="${EMAIL}")" \
    --docker-email="${EMAIL}" \
    --docker-server=gcr.io \
    -n "$NAMESPACE"
