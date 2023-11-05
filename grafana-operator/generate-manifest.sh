#!/usr/bin/env bash
set -euoE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")"/ > /dev/null

if [[ -z ${GRAFANA_OPERATOR_VERSION} ]]; then
  echo "-> [ERROR] Must export GRAFANA_OPERATOR_VERSION, e.g. v5.4.2"
  exit 1
fi

helm template oci://ghcr.io/grafana-operator/helm-charts/grafana-operator --version "${GRAFANA_OPERATOR_VERSION}" \
  --name-template mw \
  --namespace grafana \
  -f values.yaml \
  > manifest-"${GRAFANA_OPERATOR_VERSION}".yaml

popd > /dev/null
