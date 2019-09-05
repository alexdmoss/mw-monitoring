# Sample Queries

Capturing some sample queries as I learn more about how Prometheus works.

---

## Work

sum(kube_pod_container_resource_requests_memory_bytes) by (namespace)

---

## Don't Work (Yet)

sum(kube_pod_container_resource_requests_memory_bytes) by (namespace, pod, node) * on (pod) group_left()  (sum(kube_pod_status_phase{phase="Running"}) by (pod, namespace) == 1)

kube_pod_status_ready * on (namespace, pod) group_left(label_release)  kube_pod_labels
