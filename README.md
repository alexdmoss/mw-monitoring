# mw-monitoring

Telemetry stack for my personal GKE cluster - Prometheus + Grafana + other bits to get useful data out of this

I've deliberately used [CoreOS' Prometheus Operator](https://github.com/coreos/prometheus-operator) as I recognise how useful this is, but stopped short of deploying the full [CoreOS kube-prometheus stack](https://github.com/coreos/kube-prometheus) as - great concept though it is - I want to learn about how this stuff hangs together!

---

## Prometheus

The Operator is from https://github.com/coreos/prometheus-operator/blob/master/bundle.yaml and tweaked (namespace, resources, labels). Had to add `--config-reloader-cpu=20m` to fit it on my tiny cluster! There is no equivalent for the prometheus-config-reloader in the current Operator sadly, but just setting it for config-reloader was sufficient to get me up and running.

### Install

1. Install the operator (`./prometheus-operator/`)
2. Define a `Prometheus` itself (`./prometheus/`). I skimped on a dedicated `StorageClass` to save myself a few quid.

When this is up and running, you should be able to `kubectl port-forward svc/prometheus-operated 9090:9090` and then hit http://localhost:9090/ and see one of the Promethei.

## Grafana

As I only envisage a small number of dashboards, I stuck with just loading via a `ConfigMap`. If this proves unwieldy, I'll load them from a GCS bucket periodically / in an `InitContainer` instead, but that's a little more config than I think I'll need in practice.

It's a `StatefulSet`, so changes to dashboards are persisted ... *however* when it goes to multiple replicas there is no automatic sync there, so complete dashboards need to be added to the `ConfigMap` by saving their JSON in `./grafana/dashboards/` and re-running the pipeline.

---

### To Do

- [x] Instrument mosstech nginx
- [x] Install Operator for CoreOS Prometheus
- [x] Define a `ServiceMonitor`
- [x] Create a Prometheus pair
- [x] Get a Grafana `StatefulSet` up and running
- [x] Expose Grafana externally with auth
- [x] Grafana saves dashboards permanently - how update them
- [x] Create a 4GS dashboard for mosstech
- [x] Persist that dashboard somewhere
- [x] Some CI for all this
- [x] kubernetes-mixin dashboards
  - nodes (needs node-exporter)
  - resources-by-cluster-2
  - resources-by-namespace-2
  - cluster-resource-usage-2
  - node-resource-usage-2
  - resources-by-pod-2
  - capacity-planning
  - cluster-health
- [ ] Grafana with multiple replicas (issue with login) - DB vs stickiness in LB
- [ ] Grafana login through Google Account
- [ ] Test what happens when a prometheus pod is down
- [ ] Test what happens when a grafana pod is down
- [ ] Set up AlertManager
- [ ] Availability Alert for mosstech
- [ ] Some tests for all this
- [ ] Remove the old terraformed stuff

### Instrumentation To Do

- [x] `mosstech`
- [x] `kubelet` metrics
- [x] `kube-state-metrics`
- [x] `nginx-ingress-controller`
- [x] `cert-manager`
- [ ] `grafana`
- [ ] `prometheus`
- [ ] `prometheus-operator`
- [ ] `kube-event-metrics`
- [ ] `gcloud exporter`
- [ ] `node exporter`
- [ ] `gcp exporter`
- [ ] log-based metrics
- [ ] `contact-handler`
- [ ] `alchemyst`
- [ ] `alexandlou`
- [ ] `photos`
- [ ] `wug`
- [ ] `moss-work`
- [ ] `right-sizer`
- [ ] `kube-ops-view`

### Maybe To Do

- [ ] promxy
- [ ] Can you control the Grafana URLs used for dashboards?
- [ ] Grafana plugins experimentation
- [ ] https://grafana.com/docs/grafana/v6.5/features/datasources/stackdriver/
- [ ] https://grafana.com/docs/grafana/latest/tutorials/ha_setup/
- [ ] https://kubernetes.github.io/ingress-nginx/examples/affinity/cookie/

mosstech:
defect with mosstech and 404'ing when e.g. /wibble
not seeing the 404's come through
