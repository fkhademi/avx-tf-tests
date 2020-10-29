variable "aviatrix_admin_account" { default = "admin" }
variable "aviatrix_admin_password" {}
variable "aviatrix_controller_ip" { default = "ctrl.avxlab.de" }
variable "ssh_key" {}
variable "onprem_fqdn" { default = "home.dooner.de" }

# AVX Cloud Accounts
variable "azure_account_name" { default = "azure-fk" }
variable "gcp_account_name" { default = "freyviatrix-sc" }
variable "aws_account_name" { default = "aws-fk" }

# GCP
variable "gcp_creds" {}
variable "gcp_project" { default = "freyviatrix-2020" }
# AWS
variable "aws_access_key" {}
variable "aws_secret_key" {}
# Azure
variable "azure_sub_id" {}
variable "azure_app_id" {}
variable "azure_app_key" {}
variable "azure_dir_id" {}

# Regions, Transits and Spokes
variable "region1" {
  type = map
  default = {
    "name"   = "aws"
    "cidr"   = "10.10.0.0/16"
    "region" = "eu-central-1"
  }
}
variable "weur" {
  type = map
  default = {
    "name"   = "aws"
    "cidr"   = "10.11.0.0/16"
    "region" = "eu-west-1"
  }
}
variable "us" {
  type = map
  default = {
    "name"   = "aws"
    "cidr"   = "10.12.0.0/16"
    "region" = "us-east-1"
  }
}
variable "region2" {
  type = map
  default = {
    "name"   = "gcp"
    "cidr"   = "10.20.0.0/16"
    "region" = "europe-west3"
  }
}
variable "region3" {
  type = map
  default = {
    "name"   = "azure"
    "cidr"   = "10.30.0.0/16"
    "region" = "Germany West Central"
  }
}
variable "region4" {
  type = map
  default = {
    "name"   = "us"
    "cidr"   = "10.40.0.0/16"
    "region" = "us-east-1"
  }
}
variable "gcp_region_fra" {
  type = map
  default = {
    "name"   = "gcp"
    "cidr"   = "10.20.0.0/16"
    "region" = "europe-west3"
  }
}
variable "azure_region_fra" {
  type = map
  default = {
    "name"   = "azure"
    "cidr"   = "10.30.0.0/16"
    "region" = "Germany West Central"
  }
}
