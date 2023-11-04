# Deploy with kustomize

Need to grab manifests manually, helm does not include (yet?):

```sh
curl -sLo crd-dashboard.yaml https://raw.githubusercontent.com/grafana-operator/grafana-operator/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanadashboards.yaml
curl -sLo crd-datasource.yaml https://raw.githubusercontent.com/grafana-operator/grafana-operator/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanadatasources.yaml
curl -sLo crd-folder.yaml https://raw.githubusercontent.com/grafana-operator/grafana-operator/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanafolders.yaml
curl -sLo crd-list.yaml https://raw.githubusercontent.com/grafana-operator/grafana-operator/master/deploy/helm/grafana-operator/crds/grafana.integreatly.org_grafanas.yaml
```
