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
  insane_mode           = true
}
module "spoke_azure_fra" {
  #source  = "terraform-aviatrix-modules/azure-spoke/aviatrix"
  #version = "2.0.0"
  source         = "git::https://github.com/fkhademi/terraform-aviatrix-azure-spoke.git"
  name           = "spoke-azure-fra"
  cidr           = cidrsubnet(var.cidr_range, 7, 11)
  region         = "Germany West Central"
  account        = var.azure_account_name
  transit_gw     = module.transit_azure_fra.transit_gateway.gw_name
  instance_size  = "Standard_D5_v2"
  insane_mode    = true
  single_ip_snat = true
}
data "azurerm_subnet" "spoke_azure_fra1" {
  name                 = module.spoke_azure_fra.vnet.subnets[3].name
  virtual_network_name = module.spoke_azure_fra.vnet.name
  resource_group_name  = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
}
data "azurerm_subnet" "spoke_azure_fra2" {
  name                 = module.spoke_azure_fra.vnet.subnets[4].name
  virtual_network_name = module.spoke_azure_fra.vnet.name
  resource_group_name  = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
}
/* module "spoke_azure_fra_vpn" {
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
 */
## IPERF CLIENTS ##
module "azure1" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure1"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_fra.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_fra1.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
module "azure2" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure2"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_fra.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_fra1.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
module "azure3" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure3"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_fra.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_fra2.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
module "azure4" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure4"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_fra.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_fra2.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
## DNS RECORDS ##
resource "aws_route53_record" "azure1" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure1.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure1.nic.private_ip_address]
}
resource "aws_route53_record" "azure2" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure2.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure2.nic.private_ip_address]
}
resource "aws_route53_record" "azure3" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure3.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure3.nic.private_ip_address]
}
resource "aws_route53_record" "azure4" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure4.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure4.nic.private_ip_address]
}



module "azure9" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure9"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_fra.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_fra2.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
module "azure10" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure10"
  region        = var.azure_region_fra["region"]
  rg            = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_fra.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_fra2.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
## DNS RECORDS ##
resource "aws_route53_record" "azure9" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure9.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure9.nic.private_ip_address]
}
resource "aws_route53_record" "azure10" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure10.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure10.nic.private_ip_address]
}
