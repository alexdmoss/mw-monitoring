#!/usr/bin/env bash
#
# Offline manifest check for branch pipelines: render each directory (kustomize
# if it has a kustomization, otherwise the raw YAML) and validate it against the
# Kubernetes schemas plus the community CRD catalogue. No cluster access needed.
#
# Usage: ./scripts/validate-manifests.sh <dir|file> [<dir|file> ...]
#
# Until kubeconform is in the ci-tools image, the schema check is skipped with
# a warning; the render still has to succeed.
#
# Placeholders that alexos-cli/envsubst fill in at deploy time (SET_BY_CI,
# ${VAR}) are fine in string fields; anything else fails here, as it should.

set -euo pipefail

KUBERNETES_VERSION="${KUBERNETES_VERSION:-1.35.0}"

function main() {

  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <dir> [<dir> ...]" >&2
    exit 1
  fi

  if ! command -v kubeconform >/dev/null; then
    echo "-> [WARN] kubeconform is not installed: rendering only, no schema check"
    for dir in "$@"; do
      echo "-> [INFO] Rendering ${dir} ..."
      _render "${dir}" >/dev/null
    done
    echo "-> [INFO] All manifests render"
    return
  fi

  for dir in "$@"; do
    echo "-> [INFO] Validating ${dir} ..."
    _render "${dir}" | kubeconform \
      -strict \
      -summary \
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
