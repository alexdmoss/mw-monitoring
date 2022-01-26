# mw-monitoring

Telemetry stack for my personal GKE cluster - Prometheus + Grafana + other bits to get useful data out of this

I've deliberately used [CoreOS' Prometheus Operator](https://github.com/coreos/prometheus-operator) as I recognise how useful this is, but stopped short of deploying the full [CoreOS kube-prometheus stack](https://github.com/coreos/kube-prometheus) as - great concept though it is - I want to learn about how this stuff hangs together.

---

## Prometheus

This uses the [CoreOS Prometheus Operator](https://github.com/coreos/prometheus-operator/blob/master/bundle.yaml) and tweaked (namespace, resources, labels). Had to add `--config-reloader-cpu=20m` to fit it on my tiny cluster! There is no equivalent for the prometheus-config-reloader in the current Operator sadly, but just setting it for config-reloader was sufficient to get me up and running.

### Install

The operator CRDs are installed from a different repo - they are sourced from [bundle.yaml](https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml).

`Prometheus` itself is defined in (`./prometheus/`). I skimped on a dedicated `StorageClass` to save myself a few quid.

When this is up and running, you should be able to `kubectl port-forward svc/prometheus-operated 9090:9090` and then hit `http://localhost:9090/` and see one of the Promethei.

## Grafana

As I only envisage a small number of dashboards, I stuck with just loading via a `ConfigMap`. If this proves unwieldy, I'll load them from a GCS bucket periodically / in an `InitContainer` instead, but that's a little more config than I think I'll need in practice.

It's a `StatefulSet`, so changes to dashboards are persisted ... *however* when it goes to multiple replicas there is no automatic sync there, so complete dashboards need to be added to the `ConfigMap` by saving their JSON in `./grafana/dashboards/` and re-running the pipeline.

Multiple replicas are handled through stickiness configured on the `Ingress` - will see how this goes as I'd prefer not to have to [run a database behind Grafana](https://grafana.com/docs/grafana/latest/tutorials/ha_setup/) unless I have to.

---

### To Do

- [ ] AlertManager + Prometheus access via ingress with auth
- [ ] A default alert handler for no routes / reporting
- [ ] Alerts for:
  - [ ] Pods not scheduled
  - [ ] Crash Loop Backoff
  - [ ] 404
  - [ ] 5xx
  - [ ] Velero backup failed
  - [ ] Certs about to expire
- [ ] Grafana login through Google Account
- [ ] Test what happens when a prometheus pod is down
- [ ] Test what happens when a grafana pod is down
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
- [ ] `right-sizer`
- [ ] `kube-ops-view`

### Maybe To Do

- [ ] promxy
- [ ] Can you control the Grafana URLs used for dashboards?
- [ ] Grafana plugins experimentation
- [ ] https://grafana.com/docs/grafana/v6.5/features/datasources/stackdriver/

mosstech:

- defect with mosstech and 404'ing when e.g. /wibble
- not seeing the 404's come through
