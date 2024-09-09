#!/usr/bin/env bash
set -euoE pipefail

curl -Lo ./crds/crd-dashboard.yaml                  https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanadashboards.yaml
curl -Lo ./crds/crd-datasource.yaml                 https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanadatasources.yaml
curl -Lo ./crds/crd-folder.yaml                     https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanafolders.yaml
curl -Lo ./crds/crd-list.yaml                       https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanas.yaml
curl -Lo ./crds/crd-alertrulegroups.yaml            https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanaalertrulegroups.yaml
curl -Lo ./crds/crd-contactpoints.yaml              https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanacontactpoints.yaml
curl -Lo ./crds/crd-notificationpolicies.yaml       https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafananotificationpolicies.yaml