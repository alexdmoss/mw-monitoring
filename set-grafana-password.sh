#!/usr/bin/env bash
set -euo pipefail

echo "Enter new admin password:"
read pass

echo -n ${pass} | gcloud kms encrypt \
        --plaintext-file - \
        --ciphertext-file - \
        --keyring mw-grafana-keyring \
        --key mw-grafana-key \
        --location europe-west1 \
        --project moss-work \
        | base64 -w0