#!/usr/bin/env bash
set -euoE pipefail

function main() {

  local component=$1

  _assert_variables_set DOMAIN GRAFANA_PASS GCP_PROJECT_ID

  _console_msg "Ensuring prometheus namespace exists ..."
  kubectl apply -f ./prometheus/namespace.yaml

  case $component in
    "prometheus")
      deploy_prometheus;;
    "grafana")
      deploy_grafana;;
    "collectors")
      deploy_collectors;;
    "alertmanager")
      deploy_alertmanager;;
    "alerts")
      deploy_alerts;;
    *)
      _console_msg "Missing which component to deploy (first argument) in deploy.sh";
      exit 1;;
  esac

}

function deploy_prometheus() {

  _console_msg "Installing Prometheus ..."

  pushd "prometheus/" > /dev/null 2>&1

  kubectl apply -f .
  kubectl rollout status sts/prometheus-mw -n=prometheus --timeout=120s

  popd > /dev/null 2>&1

}

function deploy_grafana() {
  _console_msg "Installing Grafana ..."

  pushd "grafana/" > /dev/null 2>&1

  echo "user=admin" > ./secret.tmp
  echo "password=${GRAFANA_PASS}" >> ./secret.tmp

  kubectl apply -f ./namespace.yaml

  cp base-kustomization.yaml kustomization.yaml # easier when developing locally - not necessary in CI
  kustomize edit add configmap grafana-dashboards-websites --from-file=./dashboards/websites/*.json
  kustomize edit add configmap grafana-dashboards-k8s-resources --from-file=./dashboards/k8s-resources/*.json
  kustomize edit add configmap grafana-dashboards-k8s-cluster --from-file=./dashboards/k8s-cluster/*.json
  kustomize edit add configmap grafana-dashboards-istio-control --from-file=./dashboards/istio-control/*.json
  kustomize edit add configmap grafana-dashboards-istio-services --from-file=./dashboards/istio-services/*.json
  kustomize edit add configmap grafana-dashboards-istio-workloads --from-file=./dashboards/istio-workloads/*.json
  kustomize edit add configmap grafana-dashboards-control-plane --from-file=./dashboards/control-plane/*.json

  kustomize build . | kubectl apply -f -

  rm -f ./secret.tmp

  popd > /dev/null 2>&1

}

function deploy_collectors() {

  _console_msg "Installing Metric Collectors ..."

  pushd "metrics/" > /dev/null 2>&1

  kubectl apply -f ./namespace.yaml
  kubectl apply -f ./kube-state-metrics/
  kubectl apply -f ./kubelet/
  kubectl apply -f ./node-exporter/rbac/
  kubectl apply -f ./node-exporter/

  popd > /dev/null 2>&1

}

function deploy_alertmanager() {

  _console_msg "Installing AlertManager ..."

  pushd "alertmanager/" > /dev/null 2>&1

  SENDGRID_KEY=$(gcloud secrets versions access latest --secret="ALERTMANAGER_SENDGRID_KEY" --project="${GCP_PROJECT_ID}")
  export SENDGRID_KEY
  kustomize build . | envsubst "\$SENDGRID_KEY" | kubectl apply -f -
  sleep 5
  kubectl rollout restart sts/alertmanager-mw -n=prometheus
  kubectl rollout status sts/alertmanager-mw -n=prometheus --timeout=120s

  popd > /dev/null 2>&1

}

function deploy_alerts() {

 _console_msg "Deploying Alerts ..."

  pushd "alerts/" > /dev/null 2>&1

  pip install pipenv
  pipenv install
  pipenv run ./render-rules.py
  if [[ -f /tmp/alert-rules.yaml ]]; then
    kubectl apply -f /tmp/alert-rules.yaml
  else
    _console_msg "/tmp/alert-rules.yaml does not exist. Check for validation errors above" ERROR
  fi

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