data "dns_a_record_set" "fqdn" {
  host = var.onprem_fqdn
}
data "aws_route53_zone" "pub" {
  name         = "avxlab.de"
  private_zone = false
}