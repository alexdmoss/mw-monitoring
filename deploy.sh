#!/usr/bin/env bash
set -euo pipefail

function main() {

  _assert_variables_set DOMAIN GRAFANA_PASS

  _console_msg "Installing Prometheus ..."
  export NAMESPACE=prometheus
  kubectl apply -f ./prometheus/namespace.yaml
  cat ./prometheus/operator/*.yaml | envsubst | kubectl apply -f -
  cat ./prometheus/*.yaml | envsubst | kubectl apply -f -

  _console_msg "Installing Grafana ..."
  pushd "grafana/"
  cp base-kustomization.yaml kustomization.yaml # easier when developing locally - not necessary in CI
  kustomize edit add configmap grafana-dashboards --from-file=./dashboards/*.json
  kubectl apply -f ./namespace.yaml
  echo "user=admin" > ./secret.tmp
  echo "password=${GRAFANA_PASS}" >> ./secret.tmp
  kustomize build . | envsubst | kubectl apply -f -
  rm -f ./secret.tmp
  popd > /dev/null

  _console_msg "Installing Metric Collectors ..."
  kubectl apply -f ./metrics/namespace.yaml
  kubectl apply -f ./metrics/kube-state-metrics/
  kubectl apply -f ./metrics/kubelet/

  # _console_msg "Creating kube-state-metrics ..."
  # kubectl apply -f ./k8s/kube-state-metrics/

  # _console_msg "Creating alertmanager ..."
  # kubectl apply -f ./k8s/alertmanager/

  # _console_msg "Creating platform Service Monitors ..."
  # kubectl apply -f ./k8s/servicemonitors/

  # _console_msg "Creating Grafana ..."
  # export DATASOURCE=$(cat ./grafana/datasource.txt | base64)  
  # cat ./k8s/grafana/*.yaml | envsubst | kubectl apply -f -

  # _console_msg "Creating Grafana Dashboards ..."
  # kubectl apply -f ./k8s/dashboards/

  # _console_msg "Creating Alert Rules ..."
  # kubectl apply -f ./k8s/alerts/

}

function _assert_variables_set() {
  local error=0
  local varname
  for varname in "$@"; do
    if [[ -z "${!varname-}" ]]; then
      echo "${varname} must be set" >&2
      error=1
    fi
  done
  if [[ ${error} = 1 ]]; then
    exit 1
  fi
}

function _console_msg() {

  local msg=${1}
  local level=${2:-}
  local ts=${3:-}

  if [[ -z ${level} ]]; then level=INFO; fi
  if [[ -n ${ts} ]]; then ts=" [$(date +"%Y-%m-%d %H:%M")]"; fi

  echo

  if [[ ${level} == "ERROR" ]] || [[ ${level} == "CRIT" ]] || [[ ${level} == "FATAL" ]]; then
    (echo 2>&1)
    (echo >&2 "-> [${level}]${ts} ${msg}")
  else 
    (echo "-> [${level}]${ts} ${msg}")
  fi

  echo

}

main "$@"