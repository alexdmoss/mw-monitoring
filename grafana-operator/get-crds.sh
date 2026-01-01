#!/usr/bin/env bash
set -euoE pipefail

curl -Lo ./crds/crd-grafanaalertrulegroups.yaml                 https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafanaalertrulegroups.yaml
curl -Lo ./crds/crd-grafanacontactpoints.yaml                   https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafanacontactpoints.yaml
curl -Lo ./crds/crd-grafanadashboards.yaml                      https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafanadashboards.yaml
curl -Lo ./crds/crd-grafanadatasources.yaml                     https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafanadatasources.yaml
curl -Lo ./crds/crd-grafanafolders.yaml                         https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafanafolders.yaml
curl -Lo ./crds/crd-grafanalibrarypanels.yaml                   https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafanalibrarypanels.yaml
curl -Lo ./crds/crd-grafanamutetimings.yaml                     https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafanamutetimings.yaml
curl -Lo ./crds/crd-grafananotificationpolicies.yaml            https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafananotificationpolicies.yaml
curl -Lo ./crds/crd-grafananotificationpolicyroutes.yaml        https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafananotificationpolicyroutes.yaml
curl -Lo ./crds/crd-grafananotificationtemplates.yaml           https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafananotificationtemplates.yaml
curl -Lo ./crds/crd-grafanas.yaml                               https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafanas.yaml
curl -Lo ./crds/crd-grafanaserviceaccounts.yaml                 https://raw.githubusercontent.com/grafana/grafana-operator/master/deploy/helm/grafana-operator/files/crds/grafana.integreatly.org_grafanaserviceaccounts.yaml
