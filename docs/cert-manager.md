# cert-manager

Exposes only one metric: `certmanager_certificate_expiration_timestamp_seconds`

```txt
# HELP certmanager_certificate_expiration_timestamp_seconds The date after which the certificate expires. Expressed as a Unix Epoch Time
# TYPE certmanager_certificate_expiration_timestamp_seconds gauge
```

max((certmanager_certificate_expiration_timestamp_seconds - time()) / 60 / 60 / 24) by (exported_namespace)

In alerts, you'd need to `{{ $value | humanizeDuration }}` I believe.
