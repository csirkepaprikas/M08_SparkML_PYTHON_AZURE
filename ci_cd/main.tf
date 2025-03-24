terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg"
    storage_account_name = "d"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.AZURE_SUBSCRIPTION_ID
  tenant_id       = var.AZURE_TENANT_ID
  client_id       = var.AZURE_CLIENT_ID
  client_secret   = var.AZURE_CLIENT_SECRET
}

provider "databricks" {
  host  = var.DATABRICKS_HOST
  token = var.DATABRICKS_TOKEN
}


data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "cicd1" {
  cluster_name           = "Azure_Spark_ML"
  spark_version          = data.databricks_spark_version.latest_lts.id 
  node_type_id           = "Standard_DS3_v2"
  autotermination_minutes = 30

  spark_conf = {
    "spark.databricks.cluster.profile" = "singleNode"
    "spark.master"                     = "local[*]"
  }

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }
}

resource "azurerm_storage_account" "Azure_Spark_ML_storage" {
  name                     = var.STORAGE_ACCOUNT_NAME
  resource_group_name       = var.RESOURCE_GROUP_NAME
  location                 = "West Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.Azure_Spark_ML_storage.name
  container_access_type = "container"
}


resource "databricks_notebook" "cicd_ml" {
  path     = "/Users/m/cicd_ml"
  source   = "${path.module}/1by1_ML_1_cop.dbc"
}


resource "databricks_job" "cicd_ml" {
  name = "cicd_ml"

  task {
    task_key = "cicd_ml"
    
    notebook_task {
      notebook_path = databricks_notebook.cicd_ml.path
    }

    existing_cluster_id = databricks_cluster.cicd1.id
  }
}



output "job_ids" {
  value = {
    cicd_ml = databricks_job.cicd_ml.id

  }
}
