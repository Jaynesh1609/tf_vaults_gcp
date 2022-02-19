terraform {
  backend "gcs" {
    bucket  = "ur_bucket_name"
    prefix  = "terraform_vault/state.tfstate"
  }
}
