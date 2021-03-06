#!/usr/bin/env bash
set -euo pipefail

function main() {

  _assert_variables_set DOMAIN GRAFANA_PASS

  _console_msg "Setting up namespaces ..."
  kubectl apply -f ./prometheus/namespace.yaml
  kubectl apply -f ./grafana/namespace.yaml
  kubectl apply -f ./metrics/namespace.yaml


  _console_msg "Installing Prometheus ..."
  pushd "prometheus/" > /dev/null 2>&1
  export NAMESPACE=prometheus
  cat ./*.yaml | envsubst | kubectl apply -f -
  popd > /dev/null 2>&1


  _console_msg "Installing Grafana ..."
  pushd "grafana/" > /dev/null 2>&1
  echo "user=admin" > ./secret.tmp
  echo "password=${GRAFANA_PASS}" >> ./secret.tmp
  cp base-kustomization.yaml kustomization.yaml # easier when developing locally - not necessary in CI
  kustomize edit add configmap grafana-dashboards-websites --from-file=./dashboards/websites/*.json
  kustomize edit add configmap grafana-dashboards-k8s-resources --from-file=./dashboards/k8s-resources/*.json
  kustomize edit add configmap grafana-dashboards-k8s-cluster --from-file=./dashboards/k8s-cluster/*.json
  kustomize edit add configmap grafana-dashboards-istio-control --from-file=./dashboards/istio-control/*.json
  kustomize edit add configmap grafana-dashboards-istio-services --from-file=./dashboards/istio-services/*.json
  kustomize edit add configmap grafana-dashboards-istio-workloads --from-file=./dashboards/istio-workloads/*.json
  kustomize build . | kubectl apply -f -
  rm -f ./secret.tmp
  popd > /dev/null 2>&1


  _console_msg "Installing Metric Collectors ..."
  pushd "metrics/" > /dev/null 2>&1
  kubectl apply -f ./kube-state-metrics/
  kubectl apply -f ./kubelet/
  kubectl apply -f ./node-exporter/rbac/
  kubectl apply -f ./node-exporter/
  popd > /dev/null 2>&1


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