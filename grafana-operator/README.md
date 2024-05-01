# Deploy with kustomize

Need to grab manifests manually, helm does not include (yet?):

```sh
curl -sLo crd-dashboard.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanadashboards.yaml
curl -sLo crd-datasource.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanadatasources.yaml
curl -sLo crd-folder.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanafolders.yaml
curl -sLo crd-list.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanas.yaml
curl -sLo crd-alertrulegroups.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanaalertrulegroups.yaml
curl -sLo crd-contactpoints.yaml https://github.com/grafana/grafana-operator/blob/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanacontactpoints.yaml
```
