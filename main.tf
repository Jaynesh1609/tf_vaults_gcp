/*
variable "project" {
    default = "add_ur_own"
    type = "string"
}
*/

variable "project_id" {
  default = "ur_Project_name"
}

terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.2.1"
    }
  }
}

 #this is for locals 

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "education"
}

resource "vault_gcp_secret_backend" "gcp" {
  #credentials = "${file("project_creds_json_fmt")}"
  credentials               = file("../path/of_security_gp")
  default_lease_ttl_seconds = "3600"
  max_lease_ttl_seconds     = "3600"
}

//enable iam google iam api

resource "vault_gcp_secret_roleset" "vault-test" {
  backend      = vault_gcp_secret_backend.gcp.path
  roleset      = "project_creater"
  project      =  var.project_id
  secret_type  = "access_token"
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"

    roles = [
      "roles/compute.instanceAdmin.v1",
      "roles/iam.serviceAccountUser",
      "roles/storage.objectAdmin",
      "roles/storage.legacyBucketReader",
    ]
  }
}

output "backend" {
  value = vault_gcp_secret_backend.gcp.path
}

output "role" {
  value = vault_gcp_secret_roleset.vault-test.roleset
}

