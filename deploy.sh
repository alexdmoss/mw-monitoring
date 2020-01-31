#!/usr/bin/env bash
set -euo pipefail

function main() {

  _assert_variables_set DOMAIN GRAFANA_PASS

  if [[ ${DRONE:-} == "true" ]]; then
    _assert_variables_set K8S_DEPLOYER_CREDS K8S_CLUSTER_NAME GCP_PROJECT_ID
    _console_msg "-> Authenticating with GCloud"
    echo "${K8S_DEPLOYER_CREDS}" | gcloud auth activate-service-account --key-file -
    trap "gcloud auth revoke --verbosity=error" EXIT
    region=$(gcloud container clusters list --project=${GCP_PROJECT_ID} --filter "NAME=${K8S_CLUSTER_NAME}" --format "value(zone)") 
    _console_msg "-> Authenticating to cluster ${K8S_CLUSTER_NAME} in project ${GCP_PROJECT_ID} in ${region}"
    gcloud container clusters get-credentials ${K8S_CLUSTER_NAME} --project=${GCP_PROJECT_ID} --region=${region}
  fi

  _console_msg "Installing Prometheus ..."
  export NAMESPACE=prometheus
  kubectl apply -f ./prometheus/namespace.yaml
  cat ./prometheus/operator/*.yaml | envsubst | kubectl apply -f -
  cat ./prometheus/*.yaml | envsubst | kubectl apply -f -

  _console_msg "Installing Grafana ..."
  pushd "grafana/"
  cp base-kustomization.yaml kustomization.yaml # easier when developing locally - not necessary in CI
  kustomize edit add configmap grafana-dashboards-mw --from-file=./dashboards/mw/*.json
  kustomize edit add configmap grafana-dashboards-workloads --from-file=./dashboards/workloads/*.json
  kustomize edit add configmap grafana-dashboards-new --from-file=./dashboards/new/*.json
  kustomize edit add configmap grafana-dashboards-newer --from-file=./dashboards/newer/*.json
  kustomize edit add configmap grafana-dashboards-usage --from-file=./dashboards/resource-usage/*.json
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

  # _console_msg "Creating alertmanager ..."
  # kubectl apply -f ./k8s/alertmanager/

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