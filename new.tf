###
# Transit Peerings - Will create full mesh transit
###
module "transit-peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.0"

  #transit_gateways = [module.transit_gcp_fra.transit_gateway.gw_name, module.transit_azure_fra.transit_gateway.gw_name, module.transit_gcp_sin.transit_gateway.gw_name, module.transit_azure_sin.transit_gateway.gw_name]
  transit_gateways = [module.transit_gcp_fra.transit_gateway.gw_name, module.transit_azure_fra.transit_gateway.gw_name]
}
#########
## S2C
#########
resource "aviatrix_transit_external_device_conn" "home2cloud" {
  vpc_id             = module.transit_azure_fra.vpc.vpc_id
  connection_name    = "DC1"
  gw_name            = module.transit_azure_fra.transit_gateway.gw_name
  connection_type    = "bgp"
  bgp_local_as_num   = "65001"
  bgp_remote_as_num  = "65000"
  remote_gateway_ip  = data.dns_a_record_set.fqdn.addrs[0]
  pre_shared_key     = "frey123frey"
  local_tunnel_cidr  = "169.254.69.242/30,169.254.70.242/30"
  remote_tunnel_cidr = "169.254.69.241/30,169.254.70.241/30"
}
########
## other
########

data "dns_a_record_set" "fqdn" {
  host = var.onprem_fqdn
}
data "aws_route53_zone" "pub" {
  name         = "avxlab.de"
  private_zone = false
}

########
## Cloud Accounts
########
/* resource "aviatrix_account" "azure" {
  account_name        = "azure-fk"
  cloud_type          = 8
  arm_subscription_id = var.azure_sub_id
  arm_directory_id    = var.azure_dir_id
  arm_application_id  = var.azure_app_id
  arm_application_key = var.azure_app_key
}
resource "aviatrix_account" "gcp" {
  account_name                        = "freyviatrix-sc"
  cloud_type                          = 4
  gcloud_project_id                   = var.gcp_project
  gcloud_project_credentials_filepath = var.gcp_json
} */