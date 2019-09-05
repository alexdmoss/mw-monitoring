# mw-monitoring

Telemetry stack for my personal GKE cluster - Prometheus + Grafana + other bits to get useful data out of this

I've deliberately used [CoreOS' Prometheus Operator](https://github.com/coreos/prometheus-operator) as I recognise how useful this is, but stopped short of deploying the full [CoreOS kube-prometheus stack](https://github.com/coreos/kube-prometheus) as - great concept though it is - I want to learn about how this stuff hangs together!

---

## To Do

- [x] Install Operator for CoreOS Prometheus
- [x] Create a Prometheus
- [x] A simple service monitor to test its working *(used cert-manager)*
- [x] Grafana
  - [x] Use password that's not the default!
  - [ ] Some default dashboards to test things out
- [ ] AlertManager
- [x] kube-state-metrics
- [ ] *needs building* kube-event-metrics
- [ ] *not working* kubelet metrics
- [ ] Log-based metrics creation & detection
- [ ] What's needed for existing workloads to expose
- [ ] CI
- [ ] Smoke Tests

## Maybe To Do

- [ ] promxy
- [ ] Ingress for Prometheus
- [ ] DB for Grafana & replicas > 1
- [ ] Google OAuth setup for Grafana
- [ ] Better dashboard loading for Grafana
- [ ] Grafana plugins experimentation

---

## More Detail

- Operator itself taken from https://github.com/coreos/prometheus-operator/blob/master/bundle.yaml and tweaked (namespace, resources, labels). Had to add `--config-reloader-cpu=20m` to fit it on my tiny cluster! There is no equivalent for the prometheus-config-reloader in the current Operator sadly, but just setting it for config-reloader was sufficient to get me up and running
