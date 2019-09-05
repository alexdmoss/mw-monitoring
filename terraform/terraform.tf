terraform {
  required_version = "0.11.7"
  backend "gcs" {
    project = "moss-work"
    bucket = "moss-work-tfstate"
    prefix = "grafana"
  }
}
