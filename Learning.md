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
