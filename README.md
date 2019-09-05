# mw-monitoring

Telemetry stack for my personal GKE cluster - Prometheus + Grafana + other bits to get useful data out of this

I've deliberately used [CoreOS' Prometheus Operator](https://github.com/coreos/prometheus-operator) as I recognise how useful this is, but stopped short of deploying the full [CoreOS kube-prometheus stack](https://github.com/coreos/kube-prometheus) as - great concept though it is - I want to learn about how this stuff hangs together!

---

## To Do

- [x] Install Operator for CoreOS Prometheus
- [ ] A simple service monitor to test its working - perhaps Elastic
- [ ] Grafana
- [ ] AlertManager
- [ ] kube-state-metrics
- [ ] kube-event-metrics
- [ ] Log-based metrics creation & detection
- [ ] What's needed for existing workloads to expose
- [ ] CI
- [ ] Smoke Tests

---

## More Detail

- Operator itself taken from https://github.com/coreos/prometheus-operator/blob/master/bundle.yaml and tweaked (namespace, resources, labels)
