module "transit_firenet_3" {
  source  = "terraform-aviatrix-modules/aws-transit-firenet/aviatrix"
  version = "2.0.0"

  cidr                  = cidrsubnet(var.us["cidr"], 6, 0)
  region                = var.us["region"]
  account               = var.aws_account_name
  firewall_image        = "Fortinet FortiGate Next-Generation Firewall"
  name                  = "us"
  learned_cidr_approval = true
  ha_gw                 = false
}
/* resource "aviatrix_transit_external_device_conn" "home2cloud" {
  vpc_id                = module.transit_firenet_3.vpc.vpc_id
  connection_name       = "DC1"
  gw_name               = module.transit_firenet_3.transit_gateway.gw_name
  connection_type       = "bgp"
  bgp_local_as_num      = "65002"
  bgp_remote_as_num     = "65000"
  remote_gateway_ip     = data.dns_a_record_set.fqdn.addrs[0]
  pre_shared_key        = "frey123frey"
  local_tunnel_cidr     = "169.254.71.242/30"
  remote_tunnel_cidr    = "169.254.71.241/30"
} */
/* module "us-spoke_aws_1" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke1"
  cidr       = cidrsubnet(var.us["cidr"], 6, 1)
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
}
module "us1" {
  source = "git::https://github.com/fkhademi/terraform-aws-instance-module.git"

  name      = "us1"
  region    = var.us["region"]
  vpc_id    = module.spoke_aws_1.vpc.vpc_id
  subnet_id = module.spoke_aws_1.vpc.subnets[0].subnet_id
  ssh_key   = var.ssh_key
}
resource "aws_route53_record" "us1" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "us1.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.us1.vm.private_ip]
}
module "us-spoke_aws_2" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke2"
  cidr       = cidrsubnet(var.us["cidr"], 6, 2)
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
}
module "us2" {
  source = "git::https://github.com/fkhademi/terraform-aws-instance-module.git"

  name      = "us2"
  region    = var.us["region"]
  vpc_id    = module.spoke_aws_2.vpc.vpc_id
  subnet_id = module.spoke_aws_2.vpc.subnets[0].subnet_id
  ssh_key   = var.ssh_key
}
resource "aws_route53_record" "us2" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "us2.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.us2.vm.private_ip]
}
module "us-spoke_aws_4" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke4"
  cidr       = "10.42.4.0/24"
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
}
module "us-spoke_aws_5" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke5"
  cidr       = "10.42.5.0/24"
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
}
module "us-spoke_aws_6" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke6"
  cidr       = "10.42.6.0/24"
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
}
module "us-spoke_aws_7" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke7"
  cidr       = "10.42.7.0/24"
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
}
module "us-spoke_aws_8" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke8"
  cidr       = "10.42.8.0/24"
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
}
module "us-spoke_aws_9" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke9"
  cidr       = "10.42.9.0/24"
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
}
module "us-spoke_aws_10" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke10"
  cidr       = "10.42.10.0/24"
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
}
module "us-spoke_aws_11" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke11"
  cidr       = "10.42.11.0/24"
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
}
module "us-spoke_aws_12" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke12"
  cidr       = "10.42.12.0/24"
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
}
module "us-spoke_aws_13" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "2.0.0"

  name       = "us-spoke13"
  cidr       = "10.42.13.0/24"
  region     = var.us["region"]
  account    = var.aws_account_name
  transit_gw = module.transit_firenet_3.transit_gateway.gw_name
  ha_gw      = false
} */