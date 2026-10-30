#!/usr/bin/env bash
#
# Offline manifest check for branch pipelines: render each directory (kustomize
# if it has a kustomization, otherwise the raw YAML) and validate it against the
# Kubernetes schemas plus the community CRD catalogue. No cluster access needed.
#
# Usage: ./scripts/validate-manifests.sh <dir|file> [<dir|file> ...]
#
# Placeholders that alexos-cli/envsubst fill in at deploy time (SET_BY_CI,
# ${VAR}) are fine in string fields; anything else fails here, as it should.
#
# CustomResourceDefinitions are skipped: the schema repo has no schema for
# them, and they're vendored upstream manifests. Resources of those kinds are
# still checked against the CRD catalogue.

set -euo pipefail

KUBERNETES_VERSION="${KUBERNETES_VERSION:-1.36.0}"

function main() {

  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <dir> [<dir> ...]" >&2
    exit 1
  fi

  for dir in "$@"; do
    echo "-> [INFO] Validating ${dir} ..."
    _render "${dir}" | kubeconform \
      -strict \
      -summary \
      -skip CustomResourceDefinition \
      -kubernetes-version "${KUBERNETES_VERSION}" \
      -schema-location default \
      -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
      -
  done

  echo "-> [INFO] All manifests valid"

}

function _render() {

  local dir=$1

  if [[ -f "${dir}" ]]; then
    cat "${dir}"
  elif [[ -f "${dir}/kustomization.yaml" ]]; then
    kustomize build "${dir}"
  else
    find "${dir}" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 \
      | xargs -0 -I{} sh -c 'cat "{}"; echo; echo "---"'
  fi

}

main "$@"
