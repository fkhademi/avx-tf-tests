# Deploy Aviatrix Transit and Spoke VPCs in Azure region Singapore

module "transit_azure_sin" {
  source  = "terraform-aviatrix-modules/azure-transit/aviatrix"
  version = "2.0.0"

  name                  = "trans-azure-sin"
  cidr                  = cidrsubnet(var.cidr_range, 7, 30)
  region                = "South East Asia"
  account               = var.azure_account_name
  instance_size         = "Standard_D5_v2"
  learned_cidr_approval = true
  insane_mode           = true
}
module "spoke_azure_sin" {
  #source  = "terraform-aviatrix-modules/azure-spoke/aviatrix"
  #version = "2.0.0"
  source         = "git::https://github.com/fkhademi/terraform-aviatrix-azure-spoke.git"
  name           = "spoke-azure-sin"
  cidr           = cidrsubnet(var.cidr_range, 7, 31)
  region         = "South East Asia"
  account        = var.azure_account_name
  transit_gw     = module.transit_azure_sin.transit_gateway.gw_name
  instance_size  = "Standard_D5_v2"
  insane_mode    = true
  single_ip_snat = true
}
data "azurerm_subnet" "spoke_azure_sin1" {
  name                 = module.spoke_azure_sin.vnet.subnets[3].name
  virtual_network_name = module.spoke_azure_sin.vnet.name
  resource_group_name  = split(":", module.spoke_azure_sin.vnet.vpc_id)[1]
}
data "azurerm_subnet" "spoke_azure_sin2" {
  name                 = module.spoke_azure_sin.vnet.subnets[4].name
  virtual_network_name = module.spoke_azure_sin.vnet.name
  resource_group_name  = split(":", module.spoke_azure_sin.vnet.vpc_id)[1]
}

#######
module "azure5" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure5"
  region        = module.spoke_azure_sin.vnet.region
  rg            = split(":", module.spoke_azure_sin.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_sin.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_sin1.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
module "azure6" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure6"
  region        = module.spoke_azure_sin.vnet.region
  rg            = split(":", module.spoke_azure_sin.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_sin.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_sin1.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
module "azure7" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure7"
  region        = module.spoke_azure_sin.vnet.region
  rg            = split(":", module.spoke_azure_sin.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_sin.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_sin2.id
  instance_size = "Standard_D4_v2"
  ssh_key       = var.ssh_key
}
module "azure8" {
  source = "git::https://github.com/fkhademi/terraform-azure-instance-module.git"

  name          = "azure8"
  region        = module.spoke_azure_sin.vnet.region
  rg            = split(":", module.spoke_azure_sin.vnet.vpc_id)[1]
  vnet          = module.spoke_azure_sin.vnet.name
  subnet        = data.azurerm_subnet.spoke_azure_sin2.id
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
resource "aws_route53_record" "azure6" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure6.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure6.nic.private_ip_address]
}
resource "aws_route53_record" "azure7" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure7.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure7.nic.private_ip_address]
}
resource "aws_route53_record" "azure8" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "azure8.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.azure8.nic.private_ip_address]
}