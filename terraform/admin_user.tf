data "google_kms_secret" "admin_password" {
  crypto_key = "${google_kms_crypto_key.grafana_crypto_key.id}"
  ciphertext = "${var.admin_password_encrypted}"
}

resource "kubernetes_secret" "admin_user" {
  provider = "kubernetes.mw"

  metadata {
    name      = "grafana-admin-user"
    namespace = "monitoring"

    labels {
      app = "grafana"
    }
  }

  data {
    user     = "admin"
    password = "${data.google_kms_secret.admin_password.plaintext}"
  }
}
