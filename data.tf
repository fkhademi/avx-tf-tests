data "dns_a_record_set" "fqdn" {
  host = var.onprem_fqdn
}

data "azurerm_subnet" "spoke_azure_1" {
  name                 = module.spoke_azure_1.vnet.subnets[3].name
  virtual_network_name = module.spoke_azure_1.vnet.name
  resource_group_name  = split(":", module.spoke_azure_1.vnet.vpc_id)[1]
}