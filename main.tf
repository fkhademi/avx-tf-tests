####
## LH POC
####
# Deploy Aviatrix Transit and Spoke VPCs in GCP region Frankfurt
####
module "gcp_transit_fra" {
  source  = "terraform-aviatrix-modules/gcp-transit/aviatrix"
  version = "2.0.0"

  name          = var.gcp_region_fra["name"]
  cidr          = cidrsubnet(var.gcp_region_fra["cidr"], 1, 0)
  region        = var.gcp_region_fra["region"]
  account       = var.gcp_account_name
  instance_size = "n1-highcpu-8"
  az1           = "a"
  az2           = "b"
  #ha_gw         = true
}
module "gcp_spoke_fra" {
  source        = "git::https://github.com/fkhademi/terraform-aviatrix-gcp-spoke.git"
  name          = var.gcp_region_fra["name"]
  account       = var.gcp_account_name
  cidr          = cidrsubnet(var.gcp_region_fra["cidr"], 1, 1)
  region        = var.gcp_region_fra["region"]
  transit_gw    = module.gcp_transit_fra.transit_gateway.gw_name
  instance_size = "n1-highcpu-8"
  az1           = "a"
  az2           = "b"
  #insane_mode   = true
}
####
# Deploy Aviatrix Transit and Spoke VPCs in Azure region Frankfurt
####
module "transit_azure_fra" {
  source  = "terraform-aviatrix-modules/azure-transit/aviatrix"
  version = "2.0.0"

  name          = var.azure_region_fra["name"]
  cidr          = cidrsubnet(var.azure_region_fra["cidr"], 1, 0)
  region        = var.azure_region_fra["region"]
  account       = var.azure_account_name
  instance_size = "Standard_D4_v2"
  #insane_mode   = true
}
module "spoke_azure_fra" {
  source  = "terraform-aviatrix-modules/azure-spoke/aviatrix"
  version = "2.0.0"

  name          = var.azure_region_fra["name"]
  cidr          = cidrsubnet(var.azure_region_fra["cidr"], 1, 1)
  region        = var.azure_region_fra["region"]
  account       = var.azure_account_name
  transit_gw    = module.transit_azure_fra.transit_gateway.gw_name
  instance_size = "Standard_D4_v2"
  #insane_mode   = true
}
