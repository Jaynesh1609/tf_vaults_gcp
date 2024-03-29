terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.23.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.2.1"
    }
  }
}

/*

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "vault-test" {
  backend = "local"
  config = {
    path = "../Vault-setup/terraform.tfstate"
  }
}

*/
  
    
// this is about vault tfstate file and ec2.tf will contact with @vault-setup state file whose tfsate file is saved in s3 bucket

data "terraform_remote_state" "vaul-test" {
  backend = "gcs"
  config = {
    bucket = "your_bucket_name"
    key = "terraform_vault/terraform.tfstate"
    #region = "ap-south-1"
  }
}

//this will contact with you vault an trying to give you key in accordance with

data "vault_gcp_auth_backend_role" "token-vault" {
  backend   = data.terraform_remote_state.vault-test.outputs.backend
  role_name = data.terraform_remote_state.vault-test.outputs.role
}

provider "google" {
  region       = "asia-south2"
  #access_token =  data.vault_gcp_auth_backend_role.token-vault.outputs.service_account_email
  access_token  = data.vault_gcp_auth_backend_role.token-vault
  project      = "add_ur_Project_ name"   #use ur vaiables.. should be prefer over here
}


resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}

