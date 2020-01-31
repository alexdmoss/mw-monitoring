# NGINX (App)

Metrics from the custom instrumentation in `nginx-with-prometheus` image:

```txt
# [gauge] nginx_http_connections Number of HTTP connections
# [histogram - bucket/count/sum] nginx_http_request_duration_seconds HTTP request latency
# [counter] nginx_http_requests_total Number of HTTP requests
```

---

Traffic:

Total: `sum(rate(nginx_http_requests_total{service="mosstech-metrics"}[5m]))`
By status: `sum(rate(nginx_http_requests_total{service="mosstech-metrics",status!=""}[5m])) by (status)`

Availability:

`sum(rate(nginx_http_requests_total{job=~"(.*/)?mosstech",code!~"5.*"}[1m])) / sum(rate(nginx_http_requests_total{job=~"(.*/)?mosstech"}[1m]))`

Latency:

`histogram_quantile(0.5,max(increase(nginx_http_request_duration_seconds_bucket{service="mosstech-metrics"}[5m])) by (le))`
`histogram_quantile(0.95,max(increase(nginx_http_request_duration_seconds_bucket{service="mosstech-metrics"}[5m])) by (le))`
`histogram_quantile(1,max(increase(nginx_http_request_duration_seconds_bucket{service="mosstech-metrics"}[5m])) by (le))`

% Errors:

`sum(rate(nginx_http_requests_total{service="mosstech-metrics",status="500"}[5m])) / sum(rate(nginx_http_requests_total{service="mosstech-metrics"}[5m]))`

> Change 500 to codes to suit

Saturation - Connections:

`sum(nginx_http_connections) by (state)`

Saturation - CPU:

`avg(rate(container_cpu_usage_seconds_total{pod_name=~"mosstech-\\w+-\\w+$"}[1m])) by (container_name) / avg by(container_name) (label_replace (kube_pod_container_resource_requests_cpu_cores{pod=~"mosstech-\\w+-\\w+$"}, "container_name", "$1", "container", "(.*)"))`

Saturation - Memory:

`avg by (container_name) (container_memory_usage_bytes {pod_name=~"mosstech-\\w+-\\w+$"}) / avg by (container_name) (label_replace(kube_pod_container_resource_requests_memory_bytes{pod=~"mosstech-\\w+-\\w+$"}, "container_name", "$1", "container", "(.*)")) * 100`

Saturation - IO:

`avg(container_fs_usage_bytes{pod_name=~"mosstech.*"})`
`max(container_fs_limit_bytes{pod_name=~"mosstech.*"})`

Replicas:

`count(kube_pod_info{pod=~"mosstech-.*"})`
