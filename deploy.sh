#!/usr/bin/env bash
set -euo pipefail

echo
echo "Creating operator ..."
echo

kubectl apply -f ./k8s/prometheus-operator/