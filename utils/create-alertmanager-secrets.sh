#!/usr/bin/env bash
set -euoE pipefail

if [[ -z ${GCP_PROJECT_ID:-} ]]; then echo "-> [ERROR] GCP_PROJECT_ID not set"; exit 1; fi

if [[ -z ${1:-} ]]; then
  echo "Secret value not specified - supply it now:"
  read -r secret_str
else
  secret_str=${1}
fi

echo "Creating secret if doesn't exist ..."

gcloud secrets create ALERTMANAGER_SENDGRID_KEY --project="${GCP_PROJECT_ID}" || true

echo "Updating secret version ..."

echo -n "${secret_str}" | gcloud secrets versions add "ALERTMANAGER_SENDGRID_KEY" --data-file=- --project="${GCP_PROJECT_ID}"
