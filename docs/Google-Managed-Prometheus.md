# Google Managed Prometheus

---

## To Do

- [x] Enable GMP
- [x] Disable/delete KSM, Kubelet & Node Exporter scrapes
- [x] Delete AlertManager + Prometheus
- [ ] Remove ServiceMonitor/PodMonitor from repos (probably just velero + contact)
- [ ] Remove Prometheus Operator from bootstrap
- [ ] Get Grafana pointing at GMP
- [ ] KSM from Google
- [ ] Kubelet scrapes
- [ ] Node Exporter from Google?
- [ ] Replicate scrapes (see below)
- [ ] Bring alerts into Grafana (see below)

### Scrapes to Replicate

- [ ] Contact Handler
- [ ] Alchemyst
- [ ] Alexmoss
- [ ] Alexos
- [ ] KSM
- [ ] Kubelet
- [ ] Node Exporter
- [ ] Velero
- [ ] Alertmanager?

### Scrapes to Add

- [ ] Postgres for WUG/Plausible
- [ ] Clickhouse?

### Alerts to Assure

- [ ] always-firing
- [ ] cronjob-failures
- [ ] daemonset-failures
- [ ] deployment-failures
- [ ] k8s-recording-rules
- [ ] k8s-resources
- [ ] k8s-storage
- [ ] metrics-stack-error
- [ ] pod-not-ready
- [ ] pod-restarting
- [ ] prometheus
- [ ] statefulset-failures
- [ ] velero
