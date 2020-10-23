provider "aviatrix" {
  controller_ip           = var.aviatrix_controller_ip
  username                = var.aviatrix_admin_account
  password                = var.aviatrix_admin_password
  skip_version_validation = false
  version                 = ">2.16.0"
}
provider "aws" {
  region     = var.region1["region"]
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  alias      = "us"
  region     = var.region4["region"]
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "azurerm" {
  version = ">=2.0.0"
  features {}

  subscription_id = var.azure_sub_id
  client_id       = var.azure_app_id
  client_secret   = var.azure_app_key
  tenant_id       = var.azure_dir_id
} /*
provider "dns" {
    update {
      server        = "8.8.8.8"
    }
}*/
provider "google" {
  credentials = var.gcp_creds
  project     = var.gcp_project
  region      = var.region2["region"]
}