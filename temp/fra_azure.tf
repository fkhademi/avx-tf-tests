# Deploy Aviatrix Transit and Spoke VPCs in Azure region Frankfurt

module "transit_azure_fra" {
  source  = "terraform-aviatrix-modules/azure-transit/aviatrix"
  version = "2.0.0"

  name                  = "trans-azure-fra"
  cidr                  = cidrsubnet(var.cidr_range, 7, 10)
  region                = "Germany West Central"
  account               = var.azure_account_name
  instance_size         = "Standard_D5_v2"
  learned_cidr_approval = true
  insane_mode   = true
}
module "spoke_azure_fra" {
  source  = "terraform-aviatrix-modules/azure-spoke/aviatrix"
  version = "2.0.0"

  name          = "spoke-azure-fra"
  cidr          = cidrsubnet(var.cidr_range, 7, 11)
  region        = "Germany West Central"
  account       = var.azure_account_name
  transit_gw    = module.transit_azure_fra.transit_gateway.gw_name
  instance_size = "Standard_D5_v2"
  insane_mode = true
}
data "azurerm_subnet" "spoke_azure_fra1" {
  name                 = module.spoke_azure_fra.vnet.subnets[1].name
  virtual_network_name = module.spoke_azure_fra.vnet.name
  resource_group_name  = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
}
data "azurerm_subnet" "spoke_azure_fra2" {
  name                 = module.spoke_azure_fra.vnet.subnets[2].name
  virtual_network_name = module.spoke_azure_fra.vnet.name
  resource_group_name  = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
}
module "spoke_azure_fra_vpn" {
  source        = "git::https://github.com/tomaszklimczyk/terraform-aviatrix-azure-uservpn.git"
  name          = "azure-vpn"
  cidr          = cidrsubnet(var.cidr_range, 7, 12)
  region        = "Germany West Central"
  account       = var.azure_account_name
  transit_gw    = module.transit_azure_fra.transit_gateway.gw_name
  instance_size = "Standard_B2ms"
  insane_mode   = false
}
resource "aviatrix_vpn_user" "lhs-vpn-user" {
  user_name = "LHS-VPN-user"
  gw_name   = module.spoke_azure_fra_vpn.vpn_gateway[0].elb_name
  vpc_id    = module.spoke_azure_fra_vpn.vnet.vpc_id
}

#######
module "azure5" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure5"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_fra.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_fra1.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "azure5" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure5.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure5.nic.private_ip_address]
}
module "azure6" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure6"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_fra.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_fra1.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "azure6" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure6.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure6.nic.private_ip_address]
}
module "azure7" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure7"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_fra.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_fra2.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "azure7" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure7.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure7.nic.private_ip_address]
}
module "azure8" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure8"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_fra.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_fra2.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "azure8" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure8.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure8.nic.private_ip_address]
}