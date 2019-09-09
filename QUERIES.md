# Sample Queries

Capturing some sample queries as I learn more about how Prometheus works.

---

## TO-DO: Metrics Exporters

- [ ] gcloud exporter
- [ ] node exporter
- [ ] gcp exporter
- [ ] nginx
- [ ] stackdriver exporter
- [ ] Istio?

## Grafana Tricks

To get drop-down for namespace:

Variable - prometheus --> kube_namespace_labels --> /namespace="([a-zA-Z0-9\-_]*)"/

---

## Working On A Dashboard

sum(kube_pod_container_resource_limits_memory_bytes{namespace=~"$ns"})

sum(kube_pod_container_resource_requests_cpu_cores{namespace="mosstech"})

count(kube_node_info)
sum(kube_node_info)

sum(kube_node_status_condition{condition="Ready"})/sum(kube_node_info)*100

sum(kube_replicaset_status_replicas) - sum(kube_replicaset_status_ready_replicas)

max((certmanager_certificate_expiration_timestamp_seconds - time()) / 60 / 60 / 24) by (exported_namespace)

---

## Repaired But Not On A Dashboard Yet

Kubelet - `sum(container_cpu_usage_seconds_total{pod_name=~".*"}) by (namespace)`

NGINX Ingress Controller - `histogram_quantile(0.5,max(increase(nginx_ingress_controller_request_duration_seconds_bucket{ingress!="",controller_class="nginx"}[5m])) by (le))`

---

## Don't Work (Yet)

```sh
sum(kube_pod_container_resource_requests_memory_bytes) by (namespace, pod, node) * on (pod) group_left()  (sum(kube_pod_status_phase{phase="Running"}) by (pod, namespace) == 1)
```

```sh
kube_pod_status_ready * on (namespace, pod) group_left(label_release)  kube_pod_labels
```

The namespace: && ratio_sum elements of this:  `namespace:kube_pod_container_resource_requests_cpu_cores:ratio_sum{namespace="add-to-basket"}`

`ignoring(namespace)`

Stackdriver exporter is not set up yet - e.g. `max(stackdriver_pubsub_subscription_pubsub_googleapis_com_subscription_num_undelivered_messages{subscription_id=~"$env-.*$",namespace="catalogue"}) by (subscription_id)`

NGINX Metrics are absent - e.g. `sum(rate(nginx_http_requests_total{service="$env-atg-proxy"}[5m]))`

GCP Exporter not set up yet - e.g. `gcp_exporter_project_quota_usage{quota="BACKEND_SERVICES"}/gcp_exporter_project_quota_limit{quota="BACKEND_SERVICES"} * 100`
