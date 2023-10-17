#!/usr/bin/env bash
set -euoE pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")"/ > /dev/null

VERSION=v5.4.0

helm template oci://ghcr.io/grafana-operator/helm-charts/grafana-operator --version "${VERSION}" \
  --name-template mw \
  --namespace grafana \
  -f values.yaml \
  > manifest-${VERSION}.yaml

popd > /dev/null
