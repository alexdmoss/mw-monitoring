# mw-monitoring

Telemetry stack for my personal GKE cluster - Prometheus + Grafana + other bits to get useful data out of this.

I've deliberately used [CoreOS' Prometheus Operator](https://github.com/coreos/prometheus-operator) as I recognise how useful this is, but stopped short of deploying the full [CoreOS kube-prometheus stack](https://github.com/coreos/kube-prometheus) as - great concept though it is - I want to learn about how this stuff hangs together.

---

## Prometheus

This uses the [CoreOS Prometheus Operator](https://github.com/coreos/prometheus-operator/blob/master/bundle.yaml) and tweaked (namespace, resources, labels). Had to add `--config-reloader-cpu=20m` to fit it on my tiny cluster! There is no equivalent for the prometheus-config-reloader in the current Operator sadly, but just setting it for config-reloader was sufficient to get me up and running.

### Install

The operator CRDs are installed from a different repo as the `ServiceMonitor` resource needs to exist for several other pipelines to work successfully.

`Prometheus` itself is defined in (`./prometheus/`). I skimped on a dedicated `StorageClass` to save myself a few quid.

When this is up and running, you should be able to `kubectl port-forward svc/prometheus-operated 9090:9090` and then hit `http://localhost:9090/` and see one of the Promethei.

## Alert Manager

AlertManager requires the SendGrid API key to be set up - see `./utils/create-alertmanager-secrets.sh`. This value can be regenerated from the SendGrid UI if necessary.

When this is up and running, you should be able to `kubectl port-forward svc/alertmanager-operated 9093:9093` and then hit `http://localhost:9093/` and see one of the Promethei.

IAP auth has now been configured also:

### Authentication

Basic Auth has been replaced with Google's Identity Aware Proxy across my shared `Gateway`. If looking for that config, look at commits before October 2023.

Set up has been done manually for now - may revisit this later. General gist is:

- Enable IAP via the Console
- find the Backend Service for this workload in the IAP panel and toggle IAP to On. _This should create a credential in [API Credentials](https://console.cloud.google.com/apis/credentials) automatically_
- Within the credential that's automatically created:
  - Copy the client ID from the credential that's created into `ingress.yaml` - `GCPBackendPolicy`
  - Create a secret from the client secret, and make sure the name matches up - `kubectl create secret generic iap-client --from-file=iap-secret.txt`
- Apply the `GCPBackendPolicy`

## Grafana

Is installed via an operator - see `./grafana-operator/generate-manifest.sh`. We apply the raw manifest generated locally via `helm template`.

... then CI takes care of the deployment via kustomize. The operator is deployed in namespaced mode, meaning any grafana resources (including dashboards) are only looked for in the `grafana` namespace.

---

### To Do

- [x] Grafana Operator
- [ ] Controller to generate ServiceMonitors for apps
- [ ] remove servicemonitors from other repos
- [x] ensure secret part of project migration
- [x] AlertManager access via ingress with auth
- [x] A default alert handler for no routes
  - [ ] Tests for this!
  - [ ] Dashboard for it being called
- [ ] Alerts for:
  - [x] Pods not scheduled
  - [x] Crash Loop Backoff
  - [ ] 404
  - [ ] 5xx
  - [x] Velero backup failed
  - [-] _No longer using cert-manager_ Certs about to expire
  - [ ] High latency alert
  - [ ] OOMKill
  - [ ] PV Filling
- [x] Slack integration
- [ ] Slack integration improvements to formatting - own app?
- [ ] Dashboard links for all alerts
- [ ] Grafana login through Google Account
- [ ] Remove the old terraformed stuff

### Maybe To Do

- [ ] Grafana plugins experimentation
- [ ] [Stackdriver](https://grafana.com/docs/grafana/v6.5/features/datasources/stackdriver/)
