#!/usr/bin/env bash
set -euoE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")"/ > /dev/null

if [[ -z ${GRAFANA_OPERATOR_VERSION} ]]; then
  echo "-> [ERROR] Must export GRAFANA_OPERATOR_VERSION, e.g. v5.4.2"
  exit 1
fi

helm template oci://ghcr.io/grafana/helm-charts/grafana-operator --version "${GRAFANA_OPERATOR_VERSION}" \
  --name-template mw \
  --namespace metrics \
  -f values.yaml \
  > manifest-"${GRAFANA_OPERATOR_VERSION}".yaml

echo "****************************************************************************"
echo "Now RENAME this file to `manifest.yaml` to avoid issues with snyk reporting"
echo "after comparing to the previous version."
echo "****************************************************************************"

popd > /dev/null
