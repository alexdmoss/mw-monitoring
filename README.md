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
- [ ] kubernetes-mixin dashboards
- [ ] Grafana with multiple replicas (issue with login) - DB vs stickiness in LB
- [ ] Grafana login through Google Account
- [ ] Test what happens when a prometheus pod is down
- [ ] Test what happens when a grafana pod is down
- [ ] Set up AlertManager
- [ ] Availability Alert for mosstech
- [ ] Some CI for all this
- [ ] Some tests for all this
- [ ] Remove the old terraformed stuff

### Instrumentation To Do

- [x] `mosstech`
- [x] `kubelet` metrics
- [x] `kube-state-metrics`
- [ ] `nginx-ingress-controller`
- [ ] `cert-manager`
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

mosstech:
defect with mosstech and 404'ing when e.g. /wibble
not seeing the 404's come through
filtering of background noise?

        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-basic-resource
          name: grafana-dashboard-basic-resources
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-k8s-resources-cluster
          name: grafana-dashboard-k8s-resources-cluster
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-apiserver
          name: grafana-dashboard-apiserver
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-controller-manager
          name: grafana-dashboard-controller-manager
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-k8s-resources-namespace
          name: grafana-dashboard-k8s-resources-namespace
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-k8s-resources-pod
          name: grafana-dashboard-k8s-resources-pod
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-k8s-resources-workload
          name: grafana-dashboard-k8s-resources-workload
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-k8s-resources-workloads-namespace
          name: grafana-dashboard-k8s-resources-workloads-namespace
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-kubelet
          name: grafana-dashboard-kubelet
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-node-cluster-rsrc-use
          name: grafana-dashboard-node-cluster-rsrc-use
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-node-rsrc-use
          name: grafana-dashboard-node-rsrc-use
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-persistentvolumesusage
          name: grafana-dashboard-persistentvolumesusage
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-nodes
          name: grafana-dashboard-nodes
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-pods
          name: grafana-dashboard-pods
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-prometheus-remote-write
          name: grafana-dashboard-prometheus-remote-write
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-prometheus
          name: grafana-dashboard-prometheus
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-proxy
          name: grafana-dashboard-proxy
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0/grafana-dashboard-scheduler
          name: grafana-dashboard-scheduler
          readOnly: false
        - mountPath: /grafana-dashboard-statefulset
          name: grafana-dashboard-statefulset
          readOnly: false
