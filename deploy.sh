#!/usr/bin/env bash
set -euoE pipefail

function main() {

  _assert_variables_set DOMAIN GRAFANA_PASS GCP_PROJECT_ID

  _console_msg "Setting up namespaces ..."
  kubectl apply -f ./prometheus/namespace.yaml
  kubectl apply -f ./grafana/namespace.yaml
  kubectl apply -f ./metrics/namespace.yaml

  _console_msg "Installing Prometheus ..."
  pushd "prometheus/" > /dev/null 2>&1
  export NAMESPACE=prometheus
  cat ./*.yaml | envsubst | kubectl apply -f -
  kubectl rollout status sts/prometheus-mw -n=${NAMESPACE} --timeout=120s
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

  _console_msg "Installing AlertManager ..."
  pushd "alertmanager/" > /dev/null 2>&1
  SENDGRID_KEY=$(gcloud secrets versions access latest --secret="ALERTMANAGER_SENDGRID_KEY" --project="${GCP_PROJECT_ID}")
  export SENDGRID_KEY
  kustomize build . | envsubst "\$SENDGRID_KEY" | kubectl apply -f -
  sleep 5
  kubectl rollout restart sts/alertmanager-mw -n=${NAMESPACE}
  kubectl rollout status sts/alertmanager-mw -n=${NAMESPACE} --timeout=120s
  popd > /dev/null 2>&1

 _console_msg "Deploying Alerts ..."
  pushd "alerts/" > /dev/null 2>&1
  # TODO: should be some rule tests here with promtool
  kubectl apply -f .
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