#!/usr/bin/env bash
set -euoE pipefail

if [[ -z ${GCP_PROJECT_ID:-} ]]; then echo "-> [ERROR] GCP_PROJECT_ID not set"; exit 1; fi

echo "Creating secret if doesn't exist ..."

gcloud secrets create alert-manager --project="${GCP_PROJECT_ID}" || true

echo "Updating secret version ..."

if [[ -z ${1:-} ]]; then
  echo "Secret value not specified - value will not be set"
else
  echo -n "${1}" | gcloud secrets versions add "alert-manager" --data-file=- --project="${GCP_PROJECT_ID}"
fi
