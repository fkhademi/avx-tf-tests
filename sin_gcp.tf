# Deploy Aviatrix Transit and Spoke VPCs in GCP region Frankfurt

module "transit_gcp_sin" {
  source  = "terraform-aviatrix-modules/gcp-transit/aviatrix"
  version = "2.0.0"

  name          = "trans-gcp-sin"
  cidr          = cidrsubnet(var.cidr_range, 7, 20)
  region        = "asia-southeast1"
  account       = var.gcp_account_name
  instance_size = "n1-highcpu-16"
  az1           = "a"
  az2           = "b"
  insane_mode   = true
}
module "spoke_gcp_sin" {
  #source  = "terraform-aviatrix-modules/gcp-spoke/aviatrix"
  #version = "2.0.1"
  source         = "git::https://github.com/fkhademi/terraform-aviatrix-gcp-spoke.git"
  name           = "spoke-gcp-sin"
  account        = var.gcp_account_name
  cidr           = cidrsubnet(var.cidr_range, 7, 21)
  region         = "asia-southeast1"
  transit_gw     = module.transit_gcp_sin.transit_gateway.gw_name
  instance_size  = "n1-highcpu-16"
  az1            = "a"
  az2            = "b"
  insane_mode    = true
  single_ip_snat = true
}
## IPERF CLIENTS ##
module "gcp5" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp5"
  region        = "asia-southeast1"
  zone          = "a"
  vpc           = module.spoke_gcp_sin.vpc.vpc_id
  subnet        = module.spoke_gcp_sin.vpc.subnets[0].name
  instance_size = "e2-standard-8"
  ssh_key       = var.ssh_key
}
module "gcp6" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp6"
  region        = "asia-southeast1"
  zone          = "a"
  vpc           = module.spoke_gcp_sin.vpc.vpc_id
  subnet        = module.spoke_gcp_sin.vpc.subnets[0].name
  instance_size = "e2-standard-8"
  ssh_key       = var.ssh_key
}
module "gcp7" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp7"
  region        = "asia-southeast1"
  zone          = "b"
  vpc           = module.spoke_gcp_sin.vpc.vpc_id
  subnet        = module.spoke_gcp_sin.vpc.subnets[0].name
  instance_size = "e2-standard-8"
  ssh_key       = var.ssh_key
}
module "gcp8" {
  source = "git::https://github.com/fkhademi/terraform-gcp-instance-module.git"

  name          = "gcp8"
  region        = "asia-southeast1"
  zone          = "b"
  vpc           = module.spoke_gcp_sin.vpc.vpc_id
  subnet        = module.spoke_gcp_sin.vpc.subnets[0].name
  instance_size = "e2-standard-8"
  ssh_key       = var.ssh_key
}
## DNS RECORDS ##
resource "aws_route53_record" "gcp5" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp5.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp5.vm.network_interface[0].network_ip]
}
resource "aws_route53_record" "gcp6" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp6.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp6.vm.network_interface[0].network_ip]
}
resource "aws_route53_record" "gcp7" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp7.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp7.vm.network_interface[0].network_ip]
}
resource "aws_route53_record" "gcp8" {
  zone_id = data.aws_route53_zone.pub.zone_id
  name    = "gcp8.${data.aws_route53_zone.pub.name}"
  type    = "A"
  ttl     = "1"
  records = [module.gcp8.vm.network_interface[0].network_ip]
}
