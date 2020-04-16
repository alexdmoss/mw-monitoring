# Sample Queries

Capturing some sample queries as I learn more about how Prometheus works.

---

## PromQL Learning

- add `offset 7d` - 7 days ago
- can use regex in metric names or query names, e.g. `"node_network_(receive|transmit)_bytes_total"` or `node_network_receive_bytes_total{device=~"eth1|lo"}`
- `rate()` on `Counters` - e.g. `rate(node_network_receive_bytes_total[5m])`. Not for use on `Gauges`. `irate()` should be used for volatile, spiky counters
- for gauges, look to `min_over_time`, `max_over_time`, `avg_over_time`, `quantile_over_time` - e.g. `min_over_time(node_memory_MemFree_bytes[5m])`
- group by using `sum()`, e.g. `sum(rate(node_network_receive_bytes_total[5m])) by (instance)`
- you can manipulate labels with `label_replace` and `label_join`
- it is common (required?) for metrics endpoints to have help text, e.g. `kubectl port-forward <pod> <port>:<port>` and then hitting `/metrics` is useful!

## Grafana Tricks

To get drop-down for namespace:

Variable - prometheus --> kube_namespace_labels --> /namespace="([a-zA-Z0-9\-_]*)"/

## To Do

- [x] *it's a rule!* Understand what this is supposed to do `sum(namespace_pod_name_container_name:container_cpu_usage_seconds_total:sum_rate{namespace="$ns"}) by (pod_name)` vs `sum(rate(container_cpu_usage_seconds_total{namespace="$ns"}[5m])) by (pod_name)`

## Some Suggestions From a Blog

These all rely on a working `metrics-server` in the cluster.

Composing CPU usage:

```sh
    rate(container_cpu_usage_seconds_total{container_name!="POD",pod_name!=""}[5m])                         # CPU usage per container
sum(rate(container_cpu_usage_seconds_total{container_name!="POD",pod_name!=""}[5m]))                        # CPU usage across all containers
sum(rate(container_cpu_usage_seconds_total{container_name!="POD",pod_name!=""}[5m])) by (container_name)    # CPU usage per container name
sum(rate(container_cpu_usage_seconds_total{container_name!="POD",pod_name!=""}[5m])) by (pod_name)          # CPU usage per pod
sum(rate(container_cpu_usage_seconds_total{container_name!="POD",namespace!=""}[5m])) by (namespace)        # CPU usage per namespace
```

And similarly with Requests/Limits:

```sh
sum(kube_pod_container_resource_requests_cpu_cores)
sum(kube_pod_container_resource_requests_cpu_cores) by (pod)
sum(kube_pod_container_resource_requests_cpu_cores) by (namespace)

sum(kube_pod_container_resource_limits_cpu_cores)
sum(kube_pod_container_resource_limits_cpu_cores) by (namespace)
```

We can use these to measure CPU commitment:

```sh
(sum(kube_pod_container_resource_requests_cpu_cores) / sum(node:node_num_cpu:sum)) * 100                    # whole cluster
(sum(kube_pod_container_resource_requests_cpu_cores) by (node) / node:node_num_cpu:sum) * 100               # by node
```

CPU saturation for the cluster:

```sh
sum(node_load1) by (node) / count(node_cpu{mode="system"}) by (node) * 100
```

Similar metrics for memory:

```sh
sum(container_memory_usage_bytes{container_name!="POD",container_name!=""}) # all pods
sum(container_memory_usage_bytes{container_name!="POD",container_name!=""}) by (node) # by node

sum(kube_pod_container_resource_requests_memory_bytes)
sum(kube_pod_container_resource_requests_memory_bytes) by (node)

sum(kube_pod_container_resource_limits_memory_bytes)
sum(kube_pod_container_resource_limits_memory_bytes) by (node)

(sum(kube_pod_container_resource_limits_memory_bytes) / :node_memory_MemTotal:sum)*100
```
