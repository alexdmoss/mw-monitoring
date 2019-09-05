data "google_client_config" "current" {}

data "terraform_remote_state" "mw" {
  backend   = "gcs"

  config {
    bucket = "moss-work-tfstate"
    prefix = "grafana"
  }
}


data "terraform_remote_state" "cluster" {
  backend   = "gcs"

  config {
    bucket = "moss-work-tfstate"
    prefix = "mw-platform"
  }
}