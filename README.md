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
```python
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
```

Then created the infrastructure with the "terraform init", "terraform plan" and "terraform apply" commands:

```python
c:\data_eng\házi\3\terraform>terraform init
Initializing the backend...

Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "~> 4.3.0"...
- Finding latest version of hashicorp/random...
- Installing hashicorp/azurerm v4.3.0...
- Installed hashicorp/azurerm v4.3.0 (signed by HashiCorp)
- Installing hashicorp/random v3.7.1...
- Installed hashicorp/random v3.7.1 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.


c:\data_eng\házi\3\terraform>terraform plan
Acquiring state lock. This may take a few moments...
data.azurerm_client_config.current: Reading...
data.azurerm_client_config.current: Read complete after 0s [id=Y2xpZW50

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_databricks_workspace.bdcc will be created
  + resource "azurerm_databricks_workspace" "bdcc" {
      + customer_managed_key_enabled      = false
      + disk_encryption_set_id            = (known after apply)
      + id                                = (known after apply)
      + infrastructure_encryption_enabled = false
      + location                          = "westeurope"
      + managed_disk_identity             = (known after apply)
      + managed_resource_group_id         = (known after apply)
      + managed_resource_group_name       = (known after apply)
      + name                              = (known after apply)
      + public_network_access_enabled     = true
      + resource_group_name               = (known after apply)
      + sku                               = "premium"
      + storage_account_identity          = (known after apply)
      + tags                              = {
          + "env"    = "dev"
          + "region" = "global"
        }
      + workspace_id                      = (known after apply)
      + workspace_url                     = (known after apply)

      + custom_parameters (known after apply)
    }

  # azurerm_resource_group.bdcc will be created
  + resource "azurerm_resource_group" "bdcc" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = (known after apply)
      + tags     = {
          + "env"    = "dev"
          + "region" = "global"
        }
    }

  # azurerm_storage_account.bdcc will be created
  + resource "azurerm_storage_account" "bdcc" {
      + access_tier                        = (known after apply)
      + account_kind                       = "StorageV2"
      + account_replication_type           = "LRS"
      + account_tier                       = "Standard"
      + allow_nested_items_to_be_public    = true
      + cross_tenant_replication_enabled   = false
      + default_to_oauth_authentication    = false
      + dns_endpoint_type                  = "Standard"
      + https_traffic_only_enabled         = true
      + id                                 = (known after apply)
      + infrastructure_encryption_enabled  = false
      + is_hns_enabled                     = true
      + large_file_share_enabled           = (known after apply)
      + local_user_enabled                 = true
      + location                           = "westeurope"
      + min_tls_version                    = "TLS1_2"
      + name                               = (known after apply)
      + nfsv3_enabled                      = false
      + primary_access_key                 = (sensitive value)
      + primary_blob_connection_string     = (sensitive value)
      + primary_blob_endpoint              = (known after apply)
      + primary_blob_host                  = (known after apply)
      + primary_blob_internet_endpoint     = (known after apply)
      + primary_blob_internet_host         = (known after apply)
      + primary_blob_microsoft_endpoint    = (known after apply)
      + primary_blob_microsoft_host        = (known after apply)
      + primary_connection_string          = (sensitive value)
      + primary_dfs_endpoint               = (known after apply)
      + primary_dfs_host                   = (known after apply)
      + primary_dfs_internet_endpoint      = (known after apply)
      + primary_dfs_internet_host          = (known after apply)
      + primary_dfs_microsoft_endpoint     = (known after apply)
      + primary_dfs_microsoft_host         = (known after apply)
      + primary_file_endpoint              = (known after apply)
      + primary_file_host                  = (known after apply)
      + primary_file_internet_endpoint     = (known after apply)
      + primary_file_internet_host         = (known after apply)
      + primary_file_microsoft_endpoint    = (known after apply)
      + primary_file_microsoft_host        = (known after apply)
      + primary_location                   = (known after apply)
      + primary_queue_endpoint             = (known after apply)
      + primary_queue_host                 = (known after apply)
      + primary_queue_microsoft_endpoint   = (known after apply)
      + primary_queue_microsoft_host       = (known after apply)
      + primary_table_endpoint             = (known after apply)
      + primary_table_host                 = (known after apply)
      + primary_table_microsoft_endpoint   = (known after apply)
      + primary_table_microsoft_host       = (known after apply)
      + primary_web_endpoint               = (known after apply)
      + primary_web_host                   = (known after apply)
      + primary_web_internet_endpoint      = (known after apply)
      + primary_web_internet_host          = (known after apply)
      + primary_web_microsoft_endpoint     = (known after apply)
      + primary_web_microsoft_host         = (known after apply)
      + public_network_access_enabled      = true
      + queue_encryption_key_type          = "Service"
      + resource_group_name                = (known after apply)
      + secondary_access_key               = (sensitive value)
      + secondary_blob_connection_string   = (sensitive value)
      + secondary_blob_endpoint            = (known after apply)
      + secondary_blob_host                = (known after apply)
      + secondary_blob_internet_endpoint   = (known after apply)
      + secondary_blob_internet_host       = (known after apply)
      + secondary_blob_microsoft_endpoint  = (known after apply)
      + secondary_blob_microsoft_host      = (known after apply)
      + secondary_connection_string        = (sensitive value)
      + secondary_dfs_endpoint             = (known after apply)
      + secondary_dfs_host                 = (known after apply)
      + secondary_dfs_internet_endpoint    = (known after apply)
      + secondary_dfs_internet_host        = (known after apply)
      + secondary_dfs_microsoft_endpoint   = (known after apply)
      + secondary_dfs_microsoft_host       = (known after apply)
      + secondary_file_endpoint            = (known after apply)
      + secondary_file_host                = (known after apply)
      + secondary_file_internet_endpoint   = (known after apply)
      + secondary_file_internet_host       = (known after apply)
      + secondary_file_microsoft_endpoint  = (known after apply)
      + secondary_file_microsoft_host      = (known after apply)
      + secondary_location                 = (known after apply)
      + secondary_queue_endpoint           = (known after apply)
      + secondary_queue_host               = (known after apply)
      + secondary_queue_microsoft_endpoint = (known after apply)
      + secondary_queue_microsoft_host     = (known after apply)
      + secondary_table_endpoint           = (known after apply)
      + secondary_table_host               = (known after apply)
      + secondary_table_microsoft_endpoint = (known after apply)
      + secondary_table_microsoft_host     = (known after apply)
      + secondary_web_endpoint             = (known after apply)
      + secondary_web_host                 = (known after apply)
      + secondary_web_internet_endpoint    = (known after apply)
      + secondary_web_internet_host        = (known after apply)
      + secondary_web_microsoft_endpoint   = (known after apply)
      + secondary_web_microsoft_host       = (known after apply)
      + sftp_enabled                       = false
      + shared_access_key_enabled          = true
      + table_encryption_key_type          = "Service"
      + tags                               = {
          + "env"    = "dev"
          + "region" = "global"
        }

      + blob_properties (known after apply)

      + network_rules {
          + bypass                     = (known after apply)
          + default_action             = "Allow"
          + ip_rules                   = [
              + "174.128.60.160",
              + "174.128.60.162",
              + "185.44.13.36",
              + "195.56.119.209",
              + "195.56.119.212",
              + "203.170.48.2",
              + "204.153.55.4",
              + "213.184.231.20",
              + "85.223.209.18",
              + "86.57.255.94",
            ]
          + virtual_network_subnet_ids = (known after apply)
        }

      + queue_properties (known after apply)

      + routing (known after apply)

      + share_properties (known after apply)
    }

  # azurerm_storage_data_lake_gen2_filesystem.gen2_data will be created
  + resource "azurerm_storage_data_lake_gen2_filesystem" "gen2_data" {
      + default_encryption_scope = (known after apply)
      + group                    = (known after apply)
      + id                       = (known after apply)
      + name                     = "data"
      + owner                    = (known after apply)
      + storage_account_id       = (known after apply)

      + ace (known after apply)
    }

  # random_string.suffix will be created
  + resource "random_string" "suffix" {
      + id          = (known after apply)
      + length      = 2
      + lower       = true
      + min_lower   = 0
      + min_numeric = 0
      + min_special = 0
      + min_upper   = 0
      + number      = true
      + numeric     = true
      + result      = (known after apply)
      + special     = false
      + upper       = false
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + resource_group_name = (known after apply)

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if
you run "terraform apply" now.
Releasing state lock. This may take a few moments...

c:\data_eng\házi\3\terraform>terraform apply
Acquiring state lock. This may take a few moments...
data.azurerm_client_config.current: Reading...
data.azurerm_client_config.current: Read complete after 0s [id=Y2xpZW50Q29uZmlncy9
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_databricks_workspace.bdcc will be created
  + resource "azurerm_databricks_workspace" "bdcc" {
      + customer_managed_key_enabled      = false
      + disk_encryption_set_id            = (known after apply)
      + id                                = (known after apply)
      + infrastructure_encryption_enabled = false
      + location                          = "westeurope"
      + managed_disk_identity             = (known after apply)
      + managed_resource_group_id         = (known after apply)
      + managed_resource_group_name       = (known after apply)
      + name                              = (known after apply)
      + public_network_access_enabled     = true
      + resource_group_name               = (known after apply)
      + sku                               = "premium"
      + storage_account_identity          = (known after apply)
      + tags                              = {
          + "env"    = "dev"
          + "region" = "global"
        }
      + workspace_id                      = (known after apply)
      + workspace_url                     = (known after apply)

      + custom_parameters (known after apply)
    }

  # azurerm_resource_group.bdcc will be created
  + resource "azurerm_resource_group" "bdcc" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = (known after apply)
      + tags     = {
          + "env"    = "dev"
          + "region" = "global"
        }
    }

  # azurerm_storage_account.bdcc will be created
  + resource "azurerm_storage_account" "bdcc" {
      + access_tier                        = (known after apply)
      + account_kind                       = "StorageV2"
      + account_replication_type           = "LRS"
      + account_tier                       = "Standard"
      + allow_nested_items_to_be_public    = true
      + cross_tenant_replication_enabled   = false
      + default_to_oauth_authentication    = false
      + dns_endpoint_type                  = "Standard"
      + https_traffic_only_enabled         = true
      + id                                 = (known after apply)
      + infrastructure_encryption_enabled  = false
      + is_hns_enabled                     = true
      + large_file_share_enabled           = (known after apply)
      + local_user_enabled                 = true
      + location                           = "westeurope"
      + min_tls_version                    = "TLS1_2"
      + name                               = (known after apply)
      + nfsv3_enabled                      = false
      + primary_access_key                 = (sensitive value)
      + primary_blob_connection_string     = (sensitive value)
      + primary_blob_endpoint              = (known after apply)
      + primary_blob_host                  = (known after apply)
      + primary_blob_internet_endpoint     = (known after apply)
      + primary_blob_internet_host         = (known after apply)
      + primary_blob_microsoft_endpoint    = (known after apply)
      + primary_blob_microsoft_host        = (known after apply)
      + primary_connection_string          = (sensitive value)
      + primary_dfs_endpoint               = (known after apply)
      + primary_dfs_host                   = (known after apply)
      + primary_dfs_internet_endpoint      = (known after apply)
      + primary_dfs_internet_host          = (known after apply)
      + primary_dfs_microsoft_endpoint     = (known after apply)
      + primary_dfs_microsoft_host         = (known after apply)
      + primary_file_endpoint              = (known after apply)
      + primary_file_host                  = (known after apply)
      + primary_file_internet_endpoint     = (known after apply)
      + primary_file_internet_host         = (known after apply)
      + primary_file_microsoft_endpoint    = (known after apply)
      + primary_file_microsoft_host        = (known after apply)
      + primary_location                   = (known after apply)
      + primary_queue_endpoint             = (known after apply)
      + primary_queue_host                 = (known after apply)
      + primary_queue_microsoft_endpoint   = (known after apply)
      + primary_queue_microsoft_host       = (known after apply)
      + primary_table_endpoint             = (known after apply)
      + primary_table_host                 = (known after apply)
      + primary_table_microsoft_endpoint   = (known after apply)
      + primary_table_microsoft_host       = (known after apply)
      + primary_web_endpoint               = (known after apply)
      + primary_web_host                   = (known after apply)
      + primary_web_internet_endpoint      = (known after apply)
      + primary_web_internet_host          = (known after apply)
      + primary_web_microsoft_endpoint     = (known after apply)
      + primary_web_microsoft_host         = (known after apply)
      + public_network_access_enabled      = true
      + queue_encryption_key_type          = "Service"
      + resource_group_name                = (known after apply)
      + secondary_access_key               = (sensitive value)
      + secondary_blob_connection_string   = (sensitive value)
      + secondary_blob_endpoint            = (known after apply)
      + secondary_blob_host                = (known after apply)
      + secondary_blob_internet_endpoint   = (known after apply)
      + secondary_blob_internet_host       = (known after apply)
      + secondary_blob_microsoft_endpoint  = (known after apply)
      + secondary_blob_microsoft_host      = (known after apply)
      + secondary_connection_string        = (sensitive value)
      + secondary_dfs_endpoint             = (known after apply)
      + secondary_dfs_host                 = (known after apply)
      + secondary_dfs_internet_endpoint    = (known after apply)
      + secondary_dfs_internet_host        = (known after apply)
      + secondary_dfs_microsoft_endpoint   = (known after apply)
      + secondary_dfs_microsoft_host       = (known after apply)
      + secondary_file_endpoint            = (known after apply)
      + secondary_file_host                = (known after apply)
      + secondary_file_internet_endpoint   = (known after apply)
      + secondary_file_internet_host       = (known after apply)
      + secondary_file_microsoft_endpoint  = (known after apply)
      + secondary_file_microsoft_host      = (known after apply)
      + secondary_location                 = (known after apply)
      + secondary_queue_endpoint           = (known after apply)
      + secondary_queue_host               = (known after apply)
      + secondary_queue_microsoft_endpoint = (known after apply)
      + secondary_queue_microsoft_host     = (known after apply)
      + secondary_table_endpoint           = (known after apply)
      + secondary_table_host               = (known after apply)
      + secondary_table_microsoft_endpoint = (known after apply)
      + secondary_table_microsoft_host     = (known after apply)
      + secondary_web_endpoint             = (known after apply)
      + secondary_web_host                 = (known after apply)
      + secondary_web_internet_endpoint    = (known after apply)
      + secondary_web_internet_host        = (known after apply)
      + secondary_web_microsoft_endpoint   = (known after apply)
      + secondary_web_microsoft_host       = (known after apply)
      + sftp_enabled                       = false
      + shared_access_key_enabled          = true
      + table_encryption_key_type          = "Service"
      + tags                               = {
          + "env"    = "dev"
          + "region" = "global"
        }

      + blob_properties (known after apply)

      + network_rules {
          + bypass                     = (known after apply)
          + default_action             = "Allow"
          + ip_rules                   = [
              + "174.128.60.160",
              + "174.128.60.162",
              + "185.44.13.36",
              + "195.56.119.209",
              + "195.56.119.212",
              + "203.170.48.2",
              + "204.153.55.4",
              + "213.184.231.20",
              + "85.223.209.18",
              + "86.57.255.94",
            ]
          + virtual_network_subnet_ids = (known after apply)
        }

      + queue_properties (known after apply)

      + routing (known after apply)

      + share_properties (known after apply)
    }

  # azurerm_storage_data_lake_gen2_filesystem.gen2_data will be created
  + resource "azurerm_storage_data_lake_gen2_filesystem" "gen2_data" {
      + default_encryption_scope = (known after apply)
      + group                    = (known after apply)
      + id                       = (known after apply)
      + name                     = "data"
      + owner                    = (known after apply)
      + storage_account_id       = (known after apply)

      + ace (known after apply)
    }

  # random_string.suffix will be created
  + resource "random_string" "suffix" {
      + id          = (known after apply)
      + length      = 2
      + lower       = true
      + min_lower   = 0
      + min_numeric = 0
      + min_special = 0
      + min_upper   = 0
      + number      = true
      + numeric     = true
      + result      = (known after apply)
      + special     = false
      + upper       = false
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + resource_group_name = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

random_string.suffix: Creating...
random_string.suffix: Creation complete after 0s [id=sm]
azurerm_resource_group.bdcc: Creating...
azurerm_resource_group.bdcc: Still creating... [10s elapsed]
azurerm_resource_group.bdcc: Creation complete after 10s [id=/subscriptions/69d1c/resourceGroups/rg-dev-westeu]
azurerm_databricks_workspace.bdcc: Creating...
azurerm_storage_account.bdcc: Creating...
azurerm_databricks_workspace.bdcc: Still creating... [10s elapsed]
azurerm_storage_account.bdcc: Still creating... [10s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [20s elapsed]
azurerm_storage_account.bdcc: Still creating... [20s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [30s elapsed]
azurerm_storage_account.bdcc: Still creating... [30s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [40s elapsed]
azurerm_storage_account.bdcc: Still creating... [40s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [50s elapsed]
azurerm_storage_account.bdcc: Still creating... [50s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [1m0s elapsed]
azurerm_storage_account.bdcc: Still creating... [1m0s elapsed]
azurerm_storage_account.bdcc: Creation complete after 1m4s [id=/subscriptions/69db/resourceGroups/rg-dev-westeurope-sm/providers/Microsoft.Storage/storageAccounts/devwe]
azurerm_storage_data_lake_gen2_filesystem.gen2_data: Creating...
azurerm_storage_data_lake_gen2_filesystem.gen2_data: Creation complete after 1s [id=https://devwesteuropesm.dfs.core.windows.net/data]
azurerm_databricks_workspace.bdcc: Still creating... [1m10s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [1m20s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [1m30s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [1m40s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [1m50s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [2m0s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [2m10s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [2m20s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [2m30s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [2m40s elapsed]
azurerm_databricks_workspace.bdcc: Still creating... [2m50s elapsed]
azurerm_databricks_workspace.bdcc: Creation complete after 2m52s [id=/subscriptions/69d9b/resourceGroups/rg-dev-westem/providers/Microsoft.Databricks/workspaces/dbwm]
Releasing state lock. This may take a few moments...

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.


Outputs:

resource_group_name = "r"
```

Here you can see the newly created resource groups in the West Europe location:

![new_RGs](https://github.com/user-attachments/assets/32252426-f2ab-4b00-aa87-e5f563ed3f66)

And the source and the destination containers:

![new_containers](https://github.com/user-attachments/assets/04ce7c92-4359-4a90-b78b-fc826ff086d0)

I also uploaded the source files:

![Uploading source_files.png…]()

Then I started to work on the notebook related tasks. First I created the tables from the source files: winequality-red.csv and winequality-white.csv:

![table_create_red](https://github.com/user-attachments/assets/41e5cf39-d5c9-419d-9a37-20e76e8a5a11)
![table_create_white](https://github.com/user-attachments/assets/8e18e8b9-b383-4b1e-bd1e-5fa7b7df6d72)

Here you can see the created tables:

![created_tables](https://github.com/user-attachments/assets/4b2ce6e0-4d49-4cf2-8270-7439748513f5)

Also uploaded the files in the DBFS:

![dfbs_file_save](https://github.com/user-attachments/assets/5907abf8-ead2-4d63-ad65-a16d5864a1b3)

I reviewd the whole ML notebook via articles, tutorials and AI. The notebook ingest the data from two datasets, which are related to red and white variants of the Portuguese "Vinho Verde" wine.
Then I created a new notebook where I devided the original to smaller parts.
The first is the Seaborn:
```python
# COMMAND ----------

import pandas as pd

white_wine = pd.read_csv("/databricks-datasets/wine-quality/winequality-white.csv", sep=";")
red_wine = pd.read_csv("/databricks-datasets/wine-quality/winequality-red.csv", sep=";")

# COMMAND ----------

# MAGIC %md
# MAGIC Merge the two DataFrames into a single dataset, with a new binary feature "is_red" that indicates whether the wine is red or white.

# COMMAND ----------

red_wine['is_red'] = 1
white_wine['is_red'] = 0

data = pd.concat([red_wine, white_wine], axis=0)

# Remove spaces from column names
data.rename(columns=lambda x: x.replace(' ', '_'), inplace=True)

# COMMAND ----------

data.head()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Visualize data
# MAGIC
# MAGIC Before training a model, explore the dataset using Seaborn and Matplotlib.

# COMMAND ----------

# MAGIC %md
# MAGIC Plot a histogram of the dependent variable, quality.

# COMMAND ----------

import seaborn as sns
sns.displot(data.quality, kde=False)

# COMMAND ----------

# MAGIC %md
# MAGIC Looks like quality scores are normally distributed between 3 and 9. 
# MAGIC
# MAGIC Define a wine as high quality if it has quality >= 7.

# COMMAND ----------

high_quality = (data.quality >= 7).astype(int)
data.quality = high_quality

# MAGIC %md
# MAGIC Box plots are useful for identifying correlations between features and a binary label. Create box plots for each feature to compare high-quality and low-quality wines. Significant differences in the box plots indicate good predictors of quality.
```
This script loads two wine quality datasets (red and white wine) from Databricks' sample datasets. It merges them into a single DataFrame while adding a new binary feature (is_red) to distinguish between red and white wines. The script then cleans column names by replacing spaces with underscores. Finally, it visualizes the distribution of the quality variable and converts it into a binary classification: wines with a quality score of 7 or higher are labeled as high quality (1), while others are labeled as low quality (0).

![1_st_visual](https://github.com/user-attachments/assets/35a911ab-aea2-4384-a6a0-0470242ce039)

We can observe a normal ditrubition (Gaussian), where the highest data count is the 6, which can be considered as average quality.

The second cell is thematplotlib part of visualization:
```python
import matplotlib.pyplot as plt

dims = (3, 4)

f, axes = plt.subplots(dims[0], dims[1], figsize=(25, 15))
axis_i, axis_j = 0, 0
for col in data.columns:
  if col == 'is_red' or col == 'quality':
    continue # Box plots cannot be used on indicator variables
  sns.boxplot(x=high_quality, y=data[col], ax=axes[axis_i, axis_j])
  axis_j += 1
  if axis_j == dims[1]:
    axis_i += 1
    axis_j = 0

# COMMAND ----------

# MAGIC %md
# MAGIC In the above box plots, a few variables stand out as good univariate predictors of quality. 
# MAGIC
# MAGIC - In the alcohol box plot, the median alcohol content of high quality wines is greater than even the 75th quantile of low quality wines. High alcohol content is correlated with quality.
# MAGIC - In the density box plot, low quality wines have a greater density than high quality wines. Density is inversely correlated with quality.

# COMMAND ----------

# MAGIC %md
# MAGIC ## Preprocess data
# MAGIC Before training a model, check for missing values and split the data into training and validation sets.

# COMMAND ----------

data.isna().any()

# COMMAND ----------

# MAGIC %md
# MAGIC There are no missing values.
```
![2_görbék](https://github.com/user-attachments/assets/a3e82fe6-dce0-48f5-b7f8-384efae67155)

Above are the boxplots, as the comments suggested the median alcohol content of high quality wines is greater than even the 75th quantile of low quality wines. High alcohol content is correlated with quality. In the density box plot, low quality wines have a greater density than high quality wines. Density is inversely correlated with quality. Also, the pH values distribution is similar, but by the high quality wines' values are a litle bit higher. This assumption also valid regarding the sulphates. But as for the chlorides, the quality wines have slightly smaller values.

As the comment says the check for missing values resulted as false for all the collumns:

```python
fixed_acidity           False
volatile_acidity        False
citric_acid             False
residual_sugar          False
chlorides               False
free_sulfur_dioxide     False
total_sulfur_dioxide    False
density                 False
pH                      False
sulphates               False
alcohol                 False
quality                 False
is_red                  False
```
The third cell is the Running a parallel hyperparameter sweep to train machine learning:
```python
from sklearn.model_selection import train_test_split

X = data.drop(["quality"], axis=1)
y = data.quality

# Split out the training data
X_train, X_rem, y_train, y_rem = train_test_split(X, y, train_size=0.6, random_state=123)

# Split the remaining data equally into validation and test
X_val, X_test, y_val, y_test = train_test_split(X_rem, y_rem, test_size=0.5, random_state=123)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Train a baseline model
# MAGIC This task seems well suited to a random forest classifier, since the output is binary and there may be interactions between multiple variables.
# MAGIC
# MAGIC Build a simple classifier using scikit-learn and use MLflow to keep track of the model's accuracy, and to save the model for later use.

# COMMAND ----------

import mlflow
import mlflow.pyfunc
import mlflow.sklearn
import numpy as np
import sklearn
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import roc_auc_score
from mlflow.models.signature import infer_signature
from mlflow.utils.environment import _mlflow_conda_env
import cloudpickle
import time

# The predict method of sklearn's RandomForestClassifier returns a binary classification (0 or 1). 
# The following code creates a wrapper function, SklearnModelWrapper, that uses 
# the predict_proba method to return the probability that the observation belongs to each class. 

class SklearnModelWrapper(mlflow.pyfunc.PythonModel):
  def __init__(self, model):
    self.model = model
    
  def predict(self, context, model_input):
    return self.model.predict_proba(model_input)[:,1]

# mlflow.start_run creates a new MLflow run to track the performance of this model. 
# Within the context, you call mlflow.log_param to keep track of the parameters used, and
# mlflow.log_metric to record metrics like accuracy.
with mlflow.start_run(run_name='untuned_random_forest'):
  n_estimators = 10
  model = RandomForestClassifier(n_estimators=n_estimators, random_state=np.random.RandomState(123))
  model.fit(X_train, y_train)

  # predict_proba returns [prob_negative, prob_positive], so slice the output with [:, 1]
  predictions_test = model.predict_proba(X_test)[:,1]
  auc_score = roc_auc_score(y_test, predictions_test)
  mlflow.log_param('n_estimators', n_estimators)
  # Use the area under the ROC curve as a metric.
  mlflow.log_metric('auc', auc_score)
  wrappedModel = SklearnModelWrapper(model)
  # Log the model with a signature that defines the schema of the model's inputs and outputs. 
  # When the model is deployed, this signature will be used to validate inputs.
  signature = infer_signature(X_train, wrappedModel.predict(None, X_train))
  
  # MLflow contains utilities to create a conda environment used to serve models.
  # The necessary dependencies are added to a conda.yaml file which is logged along with the model.
  conda_env =  _mlflow_conda_env(
        additional_conda_deps=None,
        additional_pip_deps=["cloudpickle=={}".format(cloudpickle.__version__), "scikit-learn=={}".format(sklearn.__version__)],
        additional_conda_channels=None,
    )
  mlflow.pyfunc.log_model("random_forest_model", python_model=wrappedModel, conda_env=conda_env, signature=signature)

# COMMAND ----------

# MAGIC %md
# MAGIC Review the learned feature importances output by the model. As illustrated by the previous boxplots, alcohol and density are important in predicting quality.

# COMMAND ----------

feature_importances = pd.DataFrame(model.feature_importances_, index=X_train.columns.tolist(), columns=['importance'])
feature_importances.sort_values('importance', ascending=False)

# COMMAND ----------

# MAGIC %md
# MAGIC You logged the Area Under the ROC Curve (AUC) to MLflow. Click the Experiment icon <img src="https://docs.databricks.com/_static/images/icons/experiment.png"/> in the right sidebar to display the Experiment Runs sidebar. 
# MAGIC
# MAGIC The model achieved an AUC of 0.854.
# MAGIC
# MAGIC A random classifier would have an AUC of 0.5, and higher AUC values are better. For more information, see [Receiver Operating Characteristic Curve](https://en.wikipedia.org/wiki/Receiver_operating_characteristic#Area_under_the_curve).

# COMMAND ----------

# MAGIC %md
# MAGIC #### Register the model in MLflow Model Registry
# MAGIC
# MAGIC By registering this model in Model Registry, you can easily reference the model from anywhere within Databricks.
# MAGIC
# MAGIC The following section shows how to do this programmatically.

# COMMAND ----------

run_id = mlflow.search_runs(filter_string='tags.mlflow.runName = "untuned_random_forest"').iloc[0].run_id

# COMMAND ----------

# If you see the error "PERMISSION_DENIED: User does not have any permission level assigned to the registered model", 
# the cause may be that a model already exists with the name "wine_quality". Try using a different name.
model_name = "wine_quality"
model_version = mlflow.register_model(f"runs:/{run_id}/random_forest_model", model_name)

# Registering the model takes a few seconds, so add a small delay
time.sleep(15)

# COMMAND ----------

# MAGIC %md
# MAGIC You should now see the model in the Models page. To display the Models page, click **Models** in the left sidebar. 
# MAGIC
# MAGIC Next, transition this model to production and load it into this notebook from Model Registry.

# COMMAND ----------

from mlflow.tracking import MlflowClient

client = MlflowClient()
client.transition_model_version_stage(
  name=model_name,
  version=model_version.version,
  stage="Production",
)

# COMMAND ----------

# MAGIC %md
# MAGIC The Models page now shows the model version in stage "Production".
# MAGIC
# MAGIC You can now refer to the model using the path "models:/wine_quality/production".

# COMMAND ----------

model = mlflow.pyfunc.load_model(f"models:/{model_name}/production")

# Sanity-check: This should match the AUC logged by MLflow
print(f'AUC: {roc_auc_score(y_test, model.predict(X_test))}')
```
The output of the cell was:

```python
/databricks/python/lib/python3.11/site-packages/mlflow/types/utils.py:393: UserWarning: Hint: Inferred schema contains integer column(s). Integer columns in Python cannot represent missing values. If your input data contains missing values at inference time, it will be encoded as floats and will cause a schema enforcement error. The best way to avoid this problem is to infer the model schema based on a realistic data sample (training dataset) that includes missing values. Alternatively, you can declare integer columns as doubles (float64) whenever these columns may have missing values. See `Handling Integers With Missing Values <https://www.mlflow.org/docs/latest/models.html#handling-integers-with-missing-values>`_ for more details.
  warnings.warn(
/databricks/python/lib/python3.11/site-packages/_distutils_hack/__init__.py:33: UserWarning: Setuptools is replacing distutils.
  warnings.warn("Setuptools is replacing distutils.")
Successfully registered model 'wine_quality'.
2025/03/21 15:41:28 INFO mlflow.store.model_registry.abstract_store: Waiting up to 300 seconds for model version to finish creation. Model name: wine_quality, version 1
Created version '1' of model 'wine_quality'.
/root/.ipykernel/1407/command-4055028952959938-4115726697:127: FutureWarning: ``mlflow.tracking.client.MlflowClient.transition_model_version_stage`` is deprecated since 2.9.0. Model registry stages will be removed in a future major release. To learn more about the deprecation of model registry stages, see our migration guide here: https://mlflow.org/docs/2.11.4/model-registry.html#migrating-from-stages
  client.transition_model_version_stage(
/databricks/python/lib/python3.11/site-packages/mlflow/store/artifact/utils/models.py:32: FutureWarning: ``mlflow.tracking.client.MlflowClient.get_latest_versions`` is deprecated since 2.9.0. Model registry stages will be removed in a future major release. To learn more about the deprecation of model registry stages, see our migration guide here: https://mlflow.org/docs/2.11.4/model-registry.html#migrating-from-stages
  latest = client.get_latest_versions(name, None if stage is None else [stage])
AUC: 0.8540300975814177
```
Some highlights to the well-detailed comments:

I trained a Random Forest Classifier using scikit-learn and tracked the experiment with MLflow. The dataset was split into training (60%), validation (20%), and test (20%) sets.
A Random Forest model with n_estimators=10 was trained on the dataset. The AUC (Area Under the ROC Curve) was calculated on the test set, achieving 0.854.
The model was logged in MLflow, along with its parameters, metrics, and feature importances.
The model was registered in the MLflow Model Registry under the name "wine_quality".
The registered model was promoted to the Production stage.
Finally, the production model was loaded and tested, confirming that the AUC remained consistent as you see the last row of the output.

Below are the list of feature importances, which was learned by the model. It shows how the particular input variables(features) effects the decision of the model regarding the forecast od the wines.

![3_importance](https://github.com/user-attachments/assets/53230fd4-a1c1-4fde-baf3-6535571aaa79)

Below you can see the overview of the wine_quality model's run:

![3_exp_1](https://github.com/user-attachments/assets/a2293d32-84a5-4a35-a588-b29a95b4a133)

Here is the Area Under the ROC Curve (AUC) in the Model Metrics tab, which is a time-series plot on the X-axis there are the model runs, on the Y-axis the AUC level, what achieved. Because I had only one run it's a horizontal line.

![3_model_metr](https://github.com/user-attachments/assets/4e3071a0-45a1-4a74-906b-3cf9976772aa)

Below you can see the artifacts, which were created during the model run:

![3_artif](https://github.com/user-attachments/assets/4a2fd901-d76d-4ad2-a949-9c9af62fb51c)



