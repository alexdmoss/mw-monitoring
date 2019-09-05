#!/usr/bin/env bash
set -euo pipefail

function main() {

  _console_msg "Creating namespace ..."
  
  kubectl apply -f ./k8s/namespace.yaml

  _console_msg "Installing prometheus operator ..."
  
  kubectl apply -f ./k8s/prometheus-operator/

  _console_msg "Creating prometheus ..."
  
  kubectl apply -f ./k8s/prometheus/

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