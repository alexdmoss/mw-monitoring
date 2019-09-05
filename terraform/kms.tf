resource "google_kms_key_ring" "grafana_key_ring" {
  project  = "${var.gcp_project_name}"
  name     = "mw-grafana-keyring"
  location = "europe-west1"
}

resource "google_kms_crypto_key" "grafana_crypto_key" {
  name     = "mw-grafana-key"
  key_ring = "${google_kms_key_ring.grafana_key_ring.id}"
}
