####
## LH POC
####
# Deploy Aviatrix Transit and Spoke VPCs in GCP region Frankfurt
####
module "gcp_transit_fra" {
  source  = "terraform-aviatrix-modules/gcp-transit/aviatrix"
  version = "2.0.0"

  name          = "gcp-trans"
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
  #az1           = "a"
  #az2           = "b"
  #insane_mode   = true
  ha_gw = false
}
####
# Deploy Aviatrix Transit and Spoke VPCs in Azure region Frankfurt
####
data "azurerm_subnet" "transit_azure_fra" {
  name                 = module.transit_azure_fra.vpc.subnets[3].name
  virtual_network_name = module.transit_azure_fra.vpc.name
  resource_group_name  = split(":", module.transit_azure_fra.vpc.vpc_id)[1]
}
module "transit_azure_fra" {
  source  = "terraform-aviatrix-modules/azure-transit/aviatrix"
  version = "2.0.0"

  name                  = var.azure_region_fra["name"]
  cidr                  = cidrsubnet(var.azure_region_fra["cidr"], 1, 0)
  region                = var.azure_region_fra["region"]
  account               = var.azure_account_name
  instance_size         = "Standard_D4_v2"
  learned_cidr_approval = true
  #insane_mode   = true
}
/* data "azurerm_subnet" "spoke_azure_fra" {
  name                 = module.spoke_azure_fra.vnet.subnets[3].name
  virtual_network_name = module.spoke_azure_fra.vnet.name
  resource_group_name  = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
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
 */###
# Transit Peerings - Will create full mesh transit
###
module "transit-peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.0"

  transit_gateways = [module.gcp_transit_fra.transit_gateway.gw_name, module.transit_azure_fra.transit_gateway.gw_name]
}
########
# Enable Egress
########
# Create an Aviatrix Gateway FQDN filter
/* resource "aviatrix_fqdn" "enable_egress" {
  fqdn_tag     = "allow-egress"
  fqdn_enabled = true
  fqdn_mode    = "black"

  gw_filter_tag_list {
    gw_name = module.gcp_spoke_fra.spoke_gateway.gw_name
  }
  gw_filter_tag_list {
    gw_name = module.spoke_azure_fra.spoke_gateway.gw_name
  }
}
 */#########
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
  local_tunnel_cidr  = "169.254.69.242/30, 169.254.70.242/30"
  remote_tunnel_cidr = "169.254.69.241/30, 169.254.70.241/30"
}
########
## Deploy Clients and Servers
########
module "gcp1" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp1"
  region        = var.gcp_region_fra["region"]
  zone          = "a"
  vpc           = module.gcp_transit_fra.vpc.vpc_id
  subnet        = module.gcp_transit_fra.vpc.subnets[0].name
  #vpc           = module.gcp_spoke_fra.vpc.vpc_id
  #subnet        = module.gcp_spoke_fra.vpc.subnets[0].name
  instance_size = "e2-standard-8"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "gcp1" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp1.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp1.vm.network_interface[0].network_ip]
}
module "gcp2" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp2"
  region        = var.gcp_region_fra["region"]
  zone          = "a"
  vpc           = module.gcp_transit_fra.vpc.vpc_id
  subnet        = module.gcp_transit_fra.vpc.subnets[0].name
  instance_size = "e2-standard-8"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "gcp2" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp2.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp2.vm.network_interface[0].network_ip]
}

module "gcp3" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp3"
  region        = var.gcp_region_fra["region"]
  zone          = "b"
  vpc           = module.gcp_transit_fra.vpc.vpc_id
  subnet        = module.gcp_transit_fra.vpc.subnets[0].name
  instance_size = "e2-standard-8"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "gcp3" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp3.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp3.vm.network_interface[0].network_ip]
}
module "gcp4" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp4"
  region        = var.gcp_region_fra["region"]
  zone          = "b"
  vpc           = module.gcp_transit_fra.vpc.vpc_id
  subnet        = module.gcp_transit_fra.vpc.subnets[0].name
  instance_size = "e2-standard-8"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "gcp4" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp4.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp4.vm.network_interface[0].network_ip]
}



## Azure Clients
module "azure1" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure1"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.transit_azure_fra.vpc.vpc_id)[1]
  vnet          = module.transit_azure_fra.vpc.name
  subnet        = data.azurerm_subnet.transit_azure_fra.id
  #rg            = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
  #vnet          = module.spoke_azure_fra.vnet.name
  #subnet        = data.azurerm_subnet.spoke_azure_fra.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "azure1" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure1.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure1.nic.private_ip_address]
}
module "azure2" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure2"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.transit_azure_fra.vpc.vpc_id)[1]
  vnet          = module.transit_azure_fra.vpc.name
  subnet        = data.azurerm_subnet.transit_azure_fra.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "azure2" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure2.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure2.nic.private_ip_address]
}
module "azure3" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure3"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.transit_azure_fra.vpc.vpc_id)[1]
  vnet          = module.transit_azure_fra.vpc.name
  subnet        = data.azurerm_subnet.transit_azure_fra.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "azure3" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure3.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure3.nic.private_ip_address]
}
module "azure4" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure4"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.transit_azure_fra.vpc.vpc_id)[1]
  vnet          = module.transit_azure_fra.vpc.name
  subnet        = data.azurerm_subnet.transit_azure_fra.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "azure4" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure4.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure4.nic.private_ip_address]
}