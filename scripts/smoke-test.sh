#!/usr/bin/env bash
#
# Post-deploy smoke test, from alexos-cli/reference/scripts/smoke-test-operator.sh:
#
#   1. every Deployment/StatefulSet/DaemonSet in the namespace finishes rolling out
#   2. the Prometheus and Alertmanager CRs report Available (the operator has
#      reconciled them)
#   3. Grafana answers through the Gateway and runs the version just deployed
#
# Read-only: nothing here changes the cluster.

set -euo pipefail

NAMESPACE="${NAMESPACE:?NAMESPACE must be set}"
DOMAIN="${DOMAIN:?DOMAIN must be set}"
GRAFANA_VERSION="${GRAFANA_VERSION:?GRAFANA_VERSION must be set}"
TIMEOUT="${SMOKE_TIMEOUT:-180s}"

function main() {

  echo "-> [INFO] Waiting for workloads in ${NAMESPACE} to roll out ..."
  for kind in deployment statefulset daemonset; do
    for name in $(kubectl get "${kind}" -n "${NAMESPACE}" -o name); do
      kubectl rollout status "${name}" -n "${NAMESPACE}" --timeout="${TIMEOUT}"
    done
  done

  echo "-> [INFO] Checking Prometheus and Alertmanager report Available ..."
  kubectl wait --for=condition=Available prometheus/mw alertmanager/mw -n "${NAMESPACE}" --timeout="${TIMEOUT}"

  echo "-> [INFO] Checking https://${DOMAIN}/api/health ..."
  health=$(curl -sS --fail --retry 5 --retry-delay 10 --retry-all-errors "https://${DOMAIN}/api/health")
  version=$(echo "${health}" | jq -r .version)
  if [[ "$(echo "${health}" | jq -r .database)" != "ok" ]]; then
    echo "-> [ERROR] Test FAILED - Grafana database is not ok: ${health}"
    exit 1
  fi
  if [[ "${version}" != "${GRAFANA_VERSION}" ]]; then
    echo "-> [ERROR] Test FAILED - Grafana is on ${version}, expected ${GRAFANA_VERSION}"
    exit 1
  fi

  echo "-> [INFO] All tests passed!"

}

main "$@"
