# Deploy Aviatrix Transit and Spoke VPCs in GCP region Frankfurt

module "transit_gcp_fra" {
  source  = "terraform-aviatrix-modules/gcp-transit/aviatrix"
  version = "2.0.0"

  name          = "trans-gcp-fra"
  cidr          = cidrsubnet(var.cidr_range, 7, 0)
  region        = "europe-west3"
  account       = var.gcp_account_name
  instance_size = "n1-highcpu-16"
  az1           = "a"
  az2           = "b"
  insane_mode   = true
}
module "spoke_gcp_fra" {
  #source  = "terraform-aviatrix-modules/gcp-spoke/aviatrix"
  #version = "2.0.1"
  source         = "git::https://github.com/fkhademi/terraform-aviatrix-gcp-spoke.git"
  name           = "spoke-gcp-fra"
  account        = var.gcp_account_name
  cidr           = cidrsubnet(var.cidr_range, 7, 1)
  region         = "europe-west3"
  transit_gw     = module.transit_gcp_fra.transit_gateway.gw_name
  instance_size  = "n1-highcpu-16"
  az1            = "a"
  az2            = "b"
  insane_mode    = true
  single_ip_snat = true
}
## IPERF CLIENTS ##
module "gcp1" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp1"
  region        = "europe-west3"
  zone          = "a"
  vpc           = module.spoke_gcp_fra.vpc.vpc_id
  subnet        = module.spoke_gcp_fra.vpc.subnets[0].name
  instance_size = "n1-highcpu-4"
  ssh_key       = var.ssh_key
}
module "gcp2" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp2"
  region        = "europe-west3"
  zone          = "a"
  vpc           = module.spoke_gcp_fra.vpc.vpc_id
  subnet        = module.spoke_gcp_fra.vpc.subnets[0].name
  instance_size = "n1-highcpu-4"
  ssh_key       = var.ssh_key
}
module "gcp3" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp3"
  region        = "europe-west3"
  zone          = "b"
  vpc           = module.spoke_gcp_fra.vpc.vpc_id
  subnet        = module.spoke_gcp_fra.vpc.subnets[0].name
  instance_size = "n1-highcpu-4"
  ssh_key       = var.ssh_key
}
module "gcp4" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp4"
  region        = "europe-west3"
  zone          = "b"
  vpc           = module.spoke_gcp_fra.vpc.vpc_id
  subnet        = module.spoke_gcp_fra.vpc.subnets[0].name
  instance_size = "n1-highcpu-4"
  ssh_key       = var.ssh_key
}
## DNS RECORDS ##
resource "aws_route53_record" "gcp1" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp1.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp1.vm.network_interface[0].network_ip]
}
resource "aws_route53_record" "gcp2" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp2.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp2.vm.network_interface[0].network_ip]
}
resource "aws_route53_record" "gcp3" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp3.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp3.vm.network_interface[0].network_ip]
}
resource "aws_route53_record" "gcp4" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp4.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp4.vm.network_interface[0].network_ip]
}

module "gcp9" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp9"
  region        = "europe-west3"
  zone          = "a"
  vpc           = module.spoke_gcp_fra.vpc.vpc_id
  subnet        = module.spoke_gcp_fra.vpc.subnets[0].name
  instance_size = "n1-highcpu-4"
  ssh_key       = var.ssh_key
}
module "gcp10" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp10"
  region        = "europe-west3"
  zone          = "b"
  vpc           = module.spoke_gcp_fra.vpc.vpc_id
  subnet        = module.spoke_gcp_fra.vpc.subnets[0].name
  instance_size = "n1-highcpu-4"
  ssh_key       = var.ssh_key
}
resource "aws_route53_record" "gcp9" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp0.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp9.vm.network_interface[0].network_ip]
}
resource "aws_route53_record" "gcp10" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp10.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp10.vm.network_interface[0].network_ip]
}
