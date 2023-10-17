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

## Grafana

Is installed via an operator - see `./grafana-operator/generate-manifest.sh`. We apply the raw manifest generated locally via `helm template`.

... then CI takes care of the deployment via kustomize. The operator is deployed in namespaced mode, meaning any grafana resources (including dashboards) are only looked for in the `grafana` namespace.

---

### To Do

- [ ] Grafana Operator
- [ ] Controller to generate ServiceMonitors for apps
- [ ] ensure secret part of project migration
- [ ] something to generate servicemonitors
- [ ] remove servicemonitors from other repos
- [ ] AlertManager + Prometheus access via ingress with auth
- [ ] A default alert handler for no routes / reporting
- [ ] Alerts for:
  - [ ] Pods not scheduled
  - [ ] Crash Loop Backoff
  - [ ] 404
  - [ ] 5xx
  - [ ] Velero backup failed
  - [ ] Certs about to expire
  - [ ] High latency alert
  - [ ] OOMKill
  - [ ] PV Filling
  - [ ] Grafana not running
- [ ] Dashboard links for all alerts
- [ ] Grafana login through Google Account
- [ ] Availability Alert for mosstech
- [ ] Some tests for all this
- [ ] Remove the old terraformed stuff

### Instrumentation To Do

- [ ] `grafana`
- [ ] `prometheus`
- [ ] `prometheus-operator`
- [ ] `gcloud exporter`
- [ ] `gcp exporter`
- [ ] log-based metrics
- [ ] `contact-handler`
- [ ] `alchemyst`
- [ ] `alexandlou`
- [ ] `photos`
- [ ] `wug`
- [ ] `moss-work`
- [ ] `kube-ops-view`

### Maybe To Do

- [ ] promxy
- [ ] Can you control the Grafana URLs used for dashboards?
- [ ] Grafana plugins experimentation
- [ ] [Stackdriver](https://grafana.com/docs/grafana/v6.5/features/datasources/stackdriver/)

mosstech:

- defect with mosstech and 404'ing when e.g. /wibble
- not seeing the 404's come through
