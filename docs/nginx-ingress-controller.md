# NGINX

## Working Queries

Ingress Controller number of connections total (all pods):

`sum(avg_over_time(nginx_ingress_controller_nginx_process_connections{controller_class="nginx",namespace="ingress"}[1m]))`

Number of running ingress-controllers:

`count(up{pod=~"nginx-ingress-controller.*"})`

Successful Config Reloads:

`avg(nginx_ingress_controller_success{controller_class="nginx",namespace="ingress"})`

Whether the last reload was successful:

`count(nginx_ingress_controller_config_last_reload_successful)`

Request & Response Size:

`sum((irate (nginx_ingress_controller_response_size_sum[3m]))) by (exported_namespace)`

`sum((irate (nginx_ingress_controller_request_size_sum[3m]))) by (exported_namespace)`

Memory usage:

`avg(nginx_ingress_controller_nginx_process_resident_memory_bytes)`

CPU usage:

`sum (rate (nginx_ingress_controller_nginx_process_cpu_seconds_total[3m]))`

Client Requests by Status Code per namespace:

`sum(rate(nginx_ingress_controller_requests{status=~"[2-3].."}[5m])) by (exported_namespace)`
`sum(rate(nginx_ingress_controller_requests{status=~"4.."}[5m])) by (exported_namespace)`
`sum(rate(nginx_ingress_controller_requests{status=~"5.."}[5m])) by (exported_namespace)`
`sum by (status, namespace) (rate(nginx_ingress_controller_requests{status=~"5.*"}[5m]))`

Request Processing Time Percentiles:

`histogram_quantile(0.50, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=""}[3m])) by (le, host, path))`
`histogram_quantile(0.90, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=""}[3m])) by (le, host, path))`
`histogram_quantile(0.99, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=""}[3m])) by (le, host, path))`

Errors as a % of Requests (change status accordingly):

`sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!="",status="500"}[5m])) / sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=""}[5m]))`

Saturation - Connections:

`sum(nginx_ingress_controller_nginx_process_connections{namespace=~"$namespace"}) by (state)`

Path-based table:

`histogram_quantile(0.90, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=""}[3m])) by (le, host, path))`
`sum(irate(nginx_ingress_controller_request_size_sum{ingress!=""}[3m])) by (host, path)`
`sum(irate(nginx_ingress_controller_response_size_sum{ingress!=""}[3m])) by (host, path)`

## NYI

avg(kube_pod_container_resource_requests_memory_bytes{namespace=~"$namespace",pod=~"ingress-controller-.*"})
max(kube_pod_container_resource_limits_memory_bytes{namespace=~"$namespace",pod=~"ingress-controller-.*"})

avg(rate(container_cpu_user_seconds_total{namespace=~"$namespace",container_name="ingress-controller"}[1m]) * 100)
max(rate(container_cpu_user_seconds_total{namespace=~"$namespace",container_name="ingress-controller"}[1m]) * 100)

avg(container_fs_usage_bytes{namespace=~"$namespace",pod_name=~"ingress-controller-.*"})
max(container_fs_limit_bytes{namespace=~"$namespace",pod_name=~"ingress-controller-.*"})

sum (rate (container_cpu_usage_seconds_total{namespace=~"$namespace",image!="",pod_name=~"ingress-controller.*"}[1m])) by (pod_name)

sum by (namespace) (stackdriver_k_8_s_container_logging_googleapis_com_user_nginx_controller_emerg_log_errors{namespace=~"$namespace"})

## Unexplored Metrics

```txt
# HELP nginx_ingress_controller_bytes_sent The number of bytes sent to a client
# TYPE nginx_ingress_controller_bytes_sent histogram

# HELP nginx_ingress_controller_ingress_upstream_latency_seconds Upstream service latency per Ingress
# TYPE nginx_ingress_controller_ingress_upstream_latency_seconds summary

# HELP nginx_ingress_controller_nginx_process_num_procs number of processes
# TYPE nginx_ingress_controller_nginx_process_num_procs gauge

# HELP nginx_ingress_controller_nginx_process_read_bytes_total number of bytes read
# TYPE nginx_ingress_controller_nginx_process_read_bytes_total counter

# HELP nginx_ingress_controller_nginx_process_requests_total total number of client requests
# TYPE nginx_ingress_controller_nginx_process_requests_total counter

# HELP nginx_ingress_controller_nginx_process_write_bytes_total number of bytes written
# TYPE nginx_ingress_controller_nginx_process_write_bytes_total counter

# HELP nginx_ingress_controller_response_duration_seconds The time spent on receiving the response from the upstream server
# TYPE nginx_ingress_controller_response_duration_seconds histogram
```
