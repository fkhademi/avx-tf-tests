data "dns_a_record_set" "fqdn" {
  host = var.onprem_fqdn
}
data "aws_route53_zone" "pub" {
  name         = "avxlab.de"
  private_zone = false
}
/* data "azurerm_subnet" "spoke_azure_fra" {
  name                 = module.spoke_azure_fra.vnet.subnets[3].name
  virtual_network_name = module.spoke_azure_fra.vnet.name
  resource_group_name  = split(":", module.spoke_azure_fra.vnet.vpc_id)[1]
} */