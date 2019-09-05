provider "google" {
  version = "~> 1.16.2"
  project = "${var.gcp_project_name}"
}

provider "kubernetes" {
  version = "~> 1.9"  
}

provider "kubernetes" {
  alias                  = "mw"
  host                   = "https://${data.terraform_remote_state.cluster.cluster_endpoint}"
  config_context_cluster = "${data.terraform_remote_state.cluster.cluster_name}"

  cluster_ca_certificate = "${base64decode(data.terraform_remote_state.cluster.cluster_ca_certificate)}"
  token                  = "${data.google_client_config.current.access_token}"
  config_path            = "/tmp/tf-kube-config"
}
