#!/usr/bin/env bash
set -euoE pipefail

function main() {

  local component=$1

  _assert_variables_set DOMAIN GRAFANA_PASS GCP_PROJECT_ID

  case $component in
    "gmp")
      deploy_gmp;;
    "prometheus")
      deploy_prometheus;;
    "grafana")
      deploy_grafana;;
    "grafana-operator")
      deploy_grafana_operator;;
    "collectors")
      deploy_collectors;;
    "alertmanager")
      deploy_alertmanager;;
    "alerts")
      deploy_alerts;;
    "service-monitors")
      deploy_service_monitors;;
    "webhook")
      deploy_webhook;;
    *)
      _console_msg "Missing which component to deploy (first argument) in deploy.sh";
      exit 1;;
  esac

}

function deploy_prometheus() {

  _console_msg "Installing Prometheus ..."

  pushd "prometheus/" > /dev/null 2>&1

  kubectl apply -f .
  kubectl rollout status sts/prometheus-mw -n=metrics --timeout=120s

  popd > /dev/null 2>&1

}

function deploy_gmp() {
  _console_msg "Installing Google-Managed Prometheus resources ..."
  pushd "gmp/" > /dev/null 2>&1
  kubectl apply -f .
  popd > /dev/null 2>&1
}

function deploy_grafana_operator() {

  _console_msg "Deploying Grafana Operator ..."

  kubectl apply --server-side=true -f grafana-operator/crds/
  kubectl apply -n=metrics -f grafana-operator/manifest.yaml
  
}

function deploy_grafana() {

  _console_msg "Installing Grafana ..."

  pushd "grafana/" > /dev/null 2>&1

  echo "GF_SECURITY_ADMIN_USER=admin" > ./secret.tmp
  echo "GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASS}" >> ./secret.tmp

  kustomize build . | kubectl apply -f -

  rm -f ./secret.tmp

  popd > /dev/null 2>&1

  _console_msg "Waiting for sync (30s) ..."
  sleep 30

  _console_msg "Installing Dashboards ..."

  pushd "dashboards/" > /dev/null 2>&1

  kubectl apply -n=metrics -f .

  popd > /dev/null 2>&1

}

function deploy_collectors() {

  _console_msg "Installing Metric Collectors ..."

  pushd "metrics/" > /dev/null 2>&1

  kubectl apply -f ./kube-state-metrics/
  kubectl rollout status deploy/kube-state-metrics -n=metrics --timeout=60s

  kubectl apply -f ./kubelet/

  kubectl apply -f ./node-exporter/

  popd > /dev/null 2>&1

}

function deploy_webhook() {
  _console_msg "Deploying test-webhook ..."
  cat ./test-webhook/test-webhook.yaml | envsubst "\$GCP_PROJECT_ID" | kubectl apply -n=metrics -f -
  kubectl rollout status deploy/alertmanager-test-webhook -n=metrics --timeout=60s
}


function deploy_alertmanager() {

  _console_msg "Installing AlertManager ..."

  pushd "alertmanager/" > /dev/null 2>&1

  SECRET_CONFIG=$(gcloud secrets versions access latest --secret="alert-manager" --project="${GCP_PROJECT_ID}")

  POSTMARK_ACCESS_KEY=$(echo "${SECRET_CONFIG}" | grep POSTMARK_ACCESS_KEY | awk -F= '{print $2}')
  POSTMARK_SECRET_KEY=$(echo "${SECRET_CONFIG}" | grep POSTMARK_SECRET_KEY | awk -F= '{print $2}')
  SLACK_WEBHOOK_URL=$(echo "${SECRET_CONFIG}" | grep SLACK_WEBHOOK_URL | awk -F= '{print $2}')
  export POSTMARK_KEY SLACK_WEBHOOK_URL

  kustomize build . | envsubst "\$POSTMARK_ACCESS_KEY \$POSTMARK_SECRET_KEY \$SLACK_WEBHOOK_URL" | kubectl apply -f -
  sleep 5
  kubectl rollout restart sts/alertmanager-mw -n=metrics
  kubectl rollout status sts/alertmanager-mw -n=metrics --timeout=120s

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


function deploy_service_monitors() {

  _console_msg "Deploying Service Monitors ..."

  kubectl apply -f service-monitors/ -n=metrics
  
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