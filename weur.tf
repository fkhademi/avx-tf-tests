module "transit_firenet_2" {
  source  = "terraform-aviatrix-modules/aws-transit-firenet/aviatrix"
  version = "2.0.0"

  cidr                  = cidrsubnet(var.weur["cidr"], 6, 0)
  region                = var.weur["region"]
  account               = var.aws_account_name
  firewall_image        = "Fortinet FortiGate Next-Generation Firewall"
  name                  = "weur"
  learned_cidr_approval = true
  ha_gw                 = false
}
resource "aviatrix_transit_external_device_conn" "home2cloud" {
  vpc_id             = module.transit_firenet_2.vpc.vpc_id
  connection_name    = "DC1"
  gw_name            = module.transit_firenet_2.transit_gateway.gw_name
  connection_type    = "bgp"
  bgp_local_as_num   = "65002"
  bgp_remote_as_num  = "65000"
  remote_gateway_ip  = data.dns_a_record_set.fqdn.addrs[0]
  pre_shared_key     = "frey123frey"
  local_tunnel_cidr  = "169.254.71.242/30"
  remote_tunnel_cidr = "169.254.71.241/30"
}
module "weur-spoke_aws_1" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke1"
  cidr       = cidrsubnet(var.weur["cidr"], 6, 1)
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}
module "weur1" {
  source = "git::https://github.com/fkhademi/terraform-aws-instance-module.git"

  name      = "weur1"
  region    = var.weur["region"]
  vpc_id    = module.spoke_aws_1.vpc.vpc_id
  subnet_id = module.spoke_aws_1.vpc.subnets[0].subnet_id
  ssh_key   = var.ssh_key
}
resource "aws_route53_record" "weur1" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "weur1.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.weur1.vm.private_ip]
}
module "weur-spoke_aws_2" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke2"
  cidr       = cidrsubnet(var.weur["cidr"], 6, 2)
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}
module "weur2" {
  source = "git::https://github.com/fkhademi/terraform-aws-instance-module.git"

  name      = "weur2"
  region    = var.weur["region"]
  vpc_id    = module.spoke_aws_2.vpc.vpc_id
  subnet_id = module.spoke_aws_2.vpc.subnets[0].subnet_id
  ssh_key   = var.ssh_key
}
resource "aws_route53_record" "weur2" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "weur2.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.weur2.vm.private_ip]
}
module "weur-spoke_aws_4" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke4"
  cidr       = "10.41.4.0/24"
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}
module "weur-spoke_aws_5" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke5"
  cidr       = "10.41.5.0/24"
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}
module "weur-spoke_aws_6" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke6"
  cidr       = "10.41.6.0/24"
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}
module "weur-spoke_aws_7" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke7"
  cidr       = "10.41.7.0/24"
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}
module "weur-spoke_aws_8" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke8"
  cidr       = "10.41.8.0/24"
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}
module "weur-spoke_aws_9" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke9"
  cidr       = "10.41.9.0/24"
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}
module "weur-spoke_aws_10" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke10"
  cidr       = "10.41.10.0/24"
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}
module "weur-spoke_aws_11" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke11"
  cidr       = "10.41.11.0/24"
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}
module "weur-spoke_aws_12" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke12"
  cidr       = "10.41.12.0/24"
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}
module "weur-spoke_aws_13" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "weur-spoke13"
  cidr       = "10.41.13.0/24"
  region     = var.weur["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_2.transit_gateway.gw_name
  ha_gw      = false
}