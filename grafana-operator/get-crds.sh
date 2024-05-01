#!/usr/bin/env bash
set -euoE pipefail

curl -Lo crd-dashboard.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanadashboards.yaml
curl -Lo crd-datasource.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanadatasources.yaml
curl -Lo crd-folder.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanafolders.yaml
curl -Lo crd-list.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanas.yaml
curl -Lo crd-alertrulegroups.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanaalertrulegroups.yaml
curl -Lo crd-contactpoints.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanacontactpoints.yaml
