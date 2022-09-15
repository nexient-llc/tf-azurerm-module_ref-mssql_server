# Copyright 2022 Nexient LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module "resource_name" {
  source = "github.com/nexient-llc/tf-module-resource_name.git?ref=0.1.0"

  for_each = var.resource_types

  logical_product_name  = var.logical_product_name
  region                = var.resource_group.location
  class_env             = var.class_env
  cloud_resource_type   = each.value.type
  instance_env          = var.instance_env
  instance_resource     = var.instance_resource
  maximum_length        = each.value.maximum_length
  use_azure_region_abbr = var.use_azure_region_abbr
}

module "resource_group" {
  source = "github.com/nexient-llc/tf-azurerm-module-resource_group.git?ref=0.1.0"

  resource_group      = var.resource_group
  resource_group_name = local.resource_group_name

  tags = local.tags

}

module "storage_account" {
  source = "github.com/nexient-llc/tf-azurerm-module-storage_account.git?ref=0.2.0"

  resource_group       = local.resource_group
  storage_account_name = local.storage_account_name
  storage_account      = local.storage_account_properties
  access_tier          = var.access_tier
  account_kind         = var.account_kind
}

module "mssql_server" {
  source = "git@github.com:nexient-llc/tf-azurerm-module-mssql_server.git?ref=0.1.0"

  sql_server_name                      = local.sql_server_name
  resource_group                       = local.resource_group
  sql_server_version                   = var.sql_server_version
  administrator_login_username         = var.administrator_login_username
  administrator_login_password         = var.administrator_login_password
  connection_policy                    = var.connection_policy
  enable_system_managed_identity       = var.enable_system_managed_identity
  minimum_tls_version                  = var.minimum_tls_version
  public_network_access_enabled        = var.public_network_access_enabled
  outbound_network_restriction_enabled = var.outbound_network_restriction_enabled
  extended_auditing_enabled            = var.extended_auditing_enabled
  retention_in_days                    = var.retention_in_days
  storage_endpoint                     = module.storage_account.storage_account.primary_blob_endpoint
  storage_account_access_key           = module.storage_account.storage_account.primary_access_key
  allow_access_to_azure_services       = var.allow_access_to_azure_services
  allow_firewall_ip_list               = var.allow_firewall_ip_list
  allow_firewall_ip_ranges_list        = var.allow_firewall_ip_ranges_list

  custom_tags = local.tags

}
