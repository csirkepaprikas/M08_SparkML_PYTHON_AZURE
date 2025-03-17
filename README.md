# Module 3: Spark ML
### Balázs Mikes

#### github link:
https://github.com/csirkepaprikas/M08_SparkML_PYTHON_AZURE.git
## This module is dedicated to Spark ML.

Machine Learning (ML) is an essential component of modern data platforms, and a valuable addition to Databricks. The ML task is designed to provide me with a basic understanding of data analysis, as well as practical skills in using the framework to visualize data and uncover valuable insights.
Through this assignment, I learned how to leverage the Databricks platform to discover hidden gems within my data.

## Preparation
First I created the source container, where the terraform's backend willbe stored.

![source_cont](https://github.com/user-attachments/assets/ccb0cde3-8bba-4375-98c4-bf411ba1bbf3)

Then modified the main.tf file:
´´´python
# Setup azurerm as a state backend
terraform {
  backend "azurerm" {
    resource_group_name  = "h" # <== Please provide the Resource Group Name.
    storage_account_name = "h" # <== Please provide Storage Account name, where Terraform Remote state is stored. Example: terraformstate<yourname>
    container_name       = "hw3"
    key                  = "bdcc.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "6" ## <== Please provide your Subscription ID.
}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 2
  special = false
  upper   = false
}

resource "azurerm_resource_group" "bdcc" {
  name     = "rg-${var.ENV}-${var.LOCATION}-${random_string.suffix.result}"
  location = var.LOCATION

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    region = var.BDCC_REGION
    env    = var.ENV
  }
}

resource "azurerm_storage_account" "bdcc" {
  depends_on = [
  azurerm_resource_group.bdcc]

  name                     = "${var.ENV}${var.LOCATION}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.bdcc.name
  location                 = azurerm_resource_group.bdcc.location
  account_tier             = "Standard"
  account_replication_type = var.STORAGE_ACCOUNT_REPLICATION_TYPE
  is_hns_enabled           = "true"

  network_rules {
    default_action = "Allow"
    ip_rules       = values(var.IP_RULES)
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    region = var.BDCC_REGION
    env    = var.ENV
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "gen2_data" {
  depends_on = [
  azurerm_storage_account.bdcc]

  name               = "data"
  storage_account_id = azurerm_storage_account.bdcc.id

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_databricks_workspace" "bdcc" {
  depends_on = [
    azurerm_resource_group.bdcc
  ]

  name                = "dbw-${var.ENV}-${var.LOCATION}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.bdcc.name
  location            = azurerm_resource_group.bdcc.location
  sku                 = "premium"

  tags = {
    region = var.BDCC_REGION
    env    = var.ENV
  }
}

output "resource_group_name" {
  description = "The name of the created Azure Resource Group."
  value       = azurerm_resource_group.bdcc.name
}
´´´
