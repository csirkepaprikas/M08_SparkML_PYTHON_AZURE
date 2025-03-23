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

The model's storing process to the Model Registry was successful the transition of the model to the Production stage, too. The later ensures, the model is ready for real-world, production use with live data.

![3_reg](https://github.com/user-attachments/assets/2debd36d-9d50-4a16-ac90-08d689838552)

The fourth cell is the Explore the results of the hyperparameter sweep with MLflow. This time I used the xgboost library to train a more accurate model. Run a hyperparameter sweep to train multiple models in parallel, using Hyperopt and SparkTrials. As before, MLflow tracks the performance of each parameter configuration.

```python
# MAGIC %md
# MAGIC ##Experiment with a new model
# MAGIC
# MAGIC The random forest model performed well even without hyperparameter tuning.
# MAGIC
# MAGIC The script trains a classification model using the XGBoost algorithm. Hyperopt and SparkTrials are used for hyperparameter tuning, enabling parallel search. A total of 96 different configurations (Spark jobs) were executed. The goal was to maximize the AUC score, with fmin() selecting the best hyperparameter combination. The search used the Tree-structured Parzen Estimator (TPE) algorithm (tpe.suggest) to optimize the parameters. The SparkTrials(parallelism=10) setting allowed up to 10 Spark jobs to run in parallel. his sped up the tuning process, though it does not guarantee finding the absolute best configuration. Each trial was automatically logged using MLflow.

# COMMAND ----------

# MAGIC %pip install hyperopt
# MAGIC %pip install xgboost

# COMMAND ----------

from hyperopt import fmin, tpe, hp, SparkTrials, Trials, STATUS_OK
from hyperopt.pyll import scope
from math import exp
import mlflow.xgboost
import numpy as np
import xgboost as xgb

search_space = {
  'max_depth': scope.int(hp.quniform('max_depth', 4, 100, 1)),
  'learning_rate': hp.loguniform('learning_rate', -3, 0),
  'reg_alpha': hp.loguniform('reg_alpha', -5, -1),
  'reg_lambda': hp.loguniform('reg_lambda', -6, -1),
  'min_child_weight': hp.loguniform('min_child_weight', -1, 3),
  'objective': 'binary:logistic',
  'seed': 123, # Set a seed for deterministic training
}

def train_model(params):
  # With MLflow autologging, hyperparameters and the trained model are automatically logged to MLflow.
  mlflow.xgboost.autolog()
  with mlflow.start_run(nested=True):
    train = xgb.DMatrix(data=X_train, label=y_train)
    validation = xgb.DMatrix(data=X_val, label=y_val)
    # Pass in the validation set so xgb can track an evaluation metric. XGBoost terminates training when the evaluation metric
    # is no longer improving.
    booster = xgb.train(params=params, dtrain=train, num_boost_round=1000,\
                        evals=[(validation, "validation")], early_stopping_rounds=50)
    validation_predictions = booster.predict(validation)
    auc_score = roc_auc_score(y_val, validation_predictions)
    mlflow.log_metric('auc', auc_score)

    signature = infer_signature(X_train, booster.predict(train))
    mlflow.xgboost.log_model(booster, "model", signature=signature)
    
    # Set the loss to -1*auc_score so fmin maximizes the auc_score
    return {'status': STATUS_OK, 'loss': -1*auc_score, 'booster': booster.attributes()}

# Greater parallelism will lead to speedups, but a less optimal hyperparameter sweep. 
# A reasonable value for parallelism is the square root of max_evals.
spark_trials = SparkTrials(parallelism=10)

# Run fmin within an MLflow run context so that each hyperparameter configuration is logged as a child run of a parent
# run called "xgboost_models" .
with mlflow.start_run(run_name='xgboost_models'):
  best_params = fmin(
    fn=train_model, 
    space=search_space, 
    algo=tpe.suggest, 
    max_evals=96,
    trials=spark_trials,
  )

# COMMAND ----------

# MAGIC %md
# MAGIC #### Use MLflow to view the results
# MAGIC Open up the Experiment Runs sidebar to see the MLflow runs. Click on Date next to the down arrow to display a menu, and select 'auc' to display the runs sorted by the auc metric. The highest auc value is 0.90.
# MAGIC
# MAGIC MLflow tracks the parameters and performance metrics of each run. Click the External Link icon <img src="https://docs.databricks.com/_static/images/icons/external-link.png"/> at the top of the Experiment Runs sidebar to navigate to the MLflow Runs Table. 
# MAGIC
# MAGIC For details about how to use the MLflow runs table to understand how the effect of individual hyperparameters on run metrics, see the  documentation ([AWS](https://docs.databricks.com/mlflow/runs.html#compare-runs) | [Azure](https://docs.microsoft.com/azure/databricks//mlflow/runs#--compare-runs) | [GCP](https://docs.gcp.databricks.com/mlflow/runs.html#compare-runs)). 
```
GUI output:
```python
100%|██████████| 96/96 [04:37<00:00,  2.89s/trial, best loss: -0.8979887932759655]
INFO:hyperopt-spark:Total Trials: 96: 96 succeeded, 0 failed, 0 cancelled.
```
Spark jobs and GUI during the cell running:

![4_spark_ui](https://github.com/user-attachments/assets/f0fb7fc4-13a7-4f31-8fe3-193a6c39d0fa)

Screenshot about the succeeded jobs:

![4_succ_end](https://github.com/user-attachments/assets/c1894dc5-5b38-4775-a99e-aaa4dba8c07b)

And a snapshot about the model runs in the :

![4_runs](https://github.com/user-attachments/assets/6136f3c4-b0bf-4c0a-bd28-48f85d5083bf)

The script trained 96 different XGBoost models using Spark while performing hyperparameter tuning. The best model achieved an AUC score of 0.89799, indicating strong performance. All runs were automatically tracked in MLflow, and no failures or cancellations occurred.

These are the best according their AUC's:

![4_best_aucs](https://github.com/user-attachments/assets/fc5d88ad-c722-4d7e-bff2-ff2b89407512)

THen I headed to the fifth cell, which is the Register the best performing model in MLflow. I saved earlier the baseline model to Model Registry with the name `wine_quality`. Now I updated `wine_quality` to a more accurate model from the hyperparameter sweep.
Because I used MLflow to log the model produced by each hyperparameter configuration, I can use MLflow to identify the best performing run and save the model from that run to the Model Registry.
Here is the related code:
```python
best_run = mlflow.search_runs(order_by=['metrics.auc DESC']).iloc[0]
print(f'AUC of Best Run: {best_run["metrics.auc"]}')

# COMMAND ----------

new_model_version = mlflow.register_model(f"runs:/{best_run.run_id}/model", model_name)

# Registering the model takes a few seconds, so add a small delay
time.sleep(15)

# COMMAND ----------

# MAGIC %md
# MAGIC Click **Models** in the left sidebar to see that the `wine_quality` model now has two versions. 
# MAGIC
# MAGIC Promote the new version to production.

# COMMAND ----------

# Archive the old model version
client.transition_model_version_stage(
  name=model_name,
  version=model_version.version,
  stage="Archived"
)

# Promote the new model version to Production
client.transition_model_version_stage(
  name=model_name,
  version=new_model_version.version,
  stage="Production"
)

# COMMAND ----------

# MAGIC %md
# MAGIC Clients that call load_model now receive the new model.

# COMMAND ----------

# This code is the same as the last block of "Building a Baseline Model". No change is required for clients to get the new model!
model = mlflow.pyfunc.load_model(f"models:/{model_name}/production")
print(f'AUC: {roc_auc_score(y_test, model.predict(X_test))}')

# COMMAND ----------

# MAGIC %md
# MAGIC The new version achieved a better score on the test set.
```

The result of the run:
```python
AUC of Best Run: 0.8995243299826049
Registered model 'wine_quality' already exists. Creating a new version of this model...
2025/03/22 11:25:53 INFO mlflow.store.model_registry.abstract_store: Waiting up to 300 seconds for model version to finish creation. Model name: wine_quality, version 4
Created version '4' of model 'wine_quality'.
/root/.ipykernel/1656/command-1820034450416633-3889142388:28: FutureWarning: ``mlflow.tracking.client.MlflowClient.transition_model_version_stage`` is deprecated since 2.9.0. Model registry stages will be removed in a future major release. To learn more about the deprecation of model registry stages, see our migration guide here: https://mlflow.org/docs/2.11.4/model-registry.html#migrating-from-stages
  client.transition_model_version_stage(
/root/.ipykernel/1656/command-1820034450416633-3889142388:35: FutureWarning: ``mlflow.tracking.client.MlflowClient.transition_model_version_stage`` is deprecated since 2.9.0. Model registry stages will be removed in a future major release. To learn more about the deprecation of model registry stages, see our migration guide here: https://mlflow.org/docs/2.11.4/model-registry.html#migrating-from-stages
  client.transition_model_version_stage(
/databricks/python/lib/python3.11/site-packages/mlflow/store/artifact/utils/models.py:32: FutureWarning: ``mlflow.tracking.client.MlflowClient.get_latest_versions`` is deprecated since 2.9.0. Model registry stages will be removed in a future major release. To learn more about the deprecation of model registry stages, see our migration guide here: https://mlflow.org/docs/2.11.4/model-registry.html#migrating-from-stages
  latest = client.get_latest_versions(name, None if stage is None else [stage])
Downloading artifacts: 100%
 9/9 [00:00<00:00, 21.83it/s]
```

Here are the models, and the new version 4 with the Production stage:

![5_models](https://github.com/user-attachments/assets/a6ae8cb0-3501-423f-b9a2-4c316b25566a)

Then I headed to the sixth cell: Applied the registered model to another dataset using a Spark UDF. This code is used to run batch inference on a new set of data, applying a pre-trained machine learning model to predict outcomes for each row in a dataset. I am simulated new data, deleted existing data if existed in the destination directory. Then loaded model into the Spark UDF, then read the new data from the delta table and applied the model to the new data, finally displayed it.
Here is the code:
```python
spark_df = spark.createDataFrame(X_train)
# Replace <username> with your username before running this cell.
table_path = "dbfs:/mikesb/delta/wine_data"
# Delete the contents of this path in case this cell has already been run
dbutils.fs.rm(table_path, True)
spark_df.write.format("delta").save(table_path)

# COMMAND ----------

# MAGIC %md
# MAGIC Load the model into a Spark UDF, so it can be applied to the Delta table.

# COMMAND ----------

# MAGIC %pip install flask

# COMMAND ----------

import mlflow.pyfunc

apply_model_udf = mlflow.pyfunc.spark_udf(spark, f"models:/{model_name}/production")

# COMMAND ----------

# Read the "new data" from Delta
new_data = spark.read.format("delta").load(table_path)

# COMMAND ----------

display(new_data)

# COMMAND ----------

from pyspark.sql.functions import struct

# Apply the model to the new data
udf_inputs = struct(*(X_train.columns.tolist()))

new_data = new_data.withColumn(
  "prediction",
  apply_model_udf(udf_inputs)
)

# COMMAND ----------

# Each row now has an associated prediction. Note that the xgboost function does not output probabilities by default, so the predictions are not limited to the range [0, 1].
display(new_data)
```

And the results:
```python
/databricks/python/lib/python3.11/site-packages/mlflow/store/artifact/utils/models.py:32: FutureWarning: ``mlflow.tracking.client.MlflowClient.get_latest_versions`` is deprecated since 2.9.0. Model registry stages will be removed in a future major release. To learn more about the deprecation of model registry stages, see our migration guide here: https://mlflow.org/docs/2.11.4/model-registry.html#migrating-from-stages
  latest = client.get_latest_versions(name, None if stage is None else [stage])


2025/03/22 12:05:33 WARNING mlflow.pyfunc: Calling `spark_udf()` with `env_manager="local"` does not recreate the same environment that was used during training, which may lead to errors or inaccurate predictions. We recommend specifying `env_manager="conda"`, which automatically recreates the environment that was used to train the model and performs inference in the recreated environment.

2025/03/22 12:05:33 INFO mlflow.models.flavor_backend_registry: Selected backend for flavor 'python_function'
```
Here you can see the table's before and after state, by the later case you can see the prediction colunm as well, which  task is to predict the quality of the particular wine, if the number is closer to the 0 it's probably a bas quality one, if it's closer to 1 it should be a quality product.

![6_tables](https://github.com/user-attachments/assets/21c39f6e-e94a-4477-b2cb-e04ed383de98)

The seventh cell - Set up model serving for low-latency requests - is splitted into two cells. Their purpose is to deploying the model into a production environment to enable low-latency predictions via an API endpoint.

The first part loads and register the model:
```python
model = mlflow.pyfunc.load_model(f"models:/{model_name}/production")


with mlflow.start_run() as run:
    # Log model
    mlflow.sklearn.log_model(model, "my_model", registered_model_name="MyRegisteredModel")
```
the output:
```python
Successfully registered model 'MyRegisteredModel'.
2025/03/22 12:37:16 INFO mlflow.store.model_registry.abstract_store: Waiting up to 300 seconds for model version to finish creation. Model name: MyRegisteredModel, version 1
Created version '1' of model 'MyRegisteredModel'.
```

![7_reg_mod](https://github.com/user-attachments/assets/08cfb84b-2581-4662-a6ca-d378cc3927dd)

After registering the model, I set up its serving endpoint through the Databricks interface:

![8_ep](https://github.com/user-attachments/assets/a04904ee-bd4a-4a1b-9339-526836f52d08)

I also created a secret-scope and uploaded there the Databricks API token, which was created prior:
```python
c:\data_eng\házi\3\terraform>databricks secrets create-scope --scope my-secret-scope

c:\data_eng\házi\3\terraform>databricks secrets list-scopes
Scope            Backend     KeyVault URL
---------------  ----------  --------------
my-secret-scope  DATABRICKS  N/A

c:\data_eng\házi\3\terraform>databricks secrets put --scope my-secret-scope --key DATABRICKS_TOKEN

c:\data_eng\házi\3\terraform>
```

The second part requests the API token, configure the endpoint URL, converts the parameters to json format, sends the datas to an ML model and requests the predictions. Last but not least it compares the local and the on-the-fly created datas.
```python
token = dbutils.secrets.get(scope="my-secret-scope", key="DATABRICKS_TOKEN")
import os
os.environ["DATABRICKS_TOKEN"] = token

# COMMAND ----------

# MAGIC %md
# MAGIC Go to Serving tab and find created your endpoint. Copy URL

# COMMAND ----------

import os
import requests
import numpy as np
import pandas as pd
import json

def create_tf_serving_json(data):
    return {'inputs': {name: data[name].tolist() for name in data.keys()} if isinstance(data, dict) else data.tolist()}

def score_model(dataset):
    url = 'https://adb-1458450991161077.17.azuredatabricks.net/serving-endpoints/ML_ep/invocations'
    headers = {'Authorization': f'Bearer {os.environ.get("DATABRICKS_TOKEN")}', 'Content-Type': 'application/json'}
    ds_dict = {'dataframe_split': dataset.to_dict(orient='split')} if isinstance(dataset, pd.DataFrame) else create_tf_serving_json(dataset)
    data_json = json.dumps(ds_dict, allow_nan=True)
    response = requests.request(method='POST', headers=headers, url=url, data=data_json)
    if response.status_code != 200:
        raise Exception(f'Request failed with status {response.status_code}, {response.text}')
    return response.json()

# COMMAND ----------

# MAGIC %md
# MAGIC The model predictions from the endpoint should agree with the results from locally evaluating the model.

# COMMAND ----------

# Model serving is designed for low-latency predictions on smaller batches of data
num_predictions = 5
served_predictions = score_model(X_test[:num_predictions])
model_evaluations = model.predict(X_test[:num_predictions])

# Compare the results from the deployed model and the trained model
pd.DataFrame({
  "Model Prediction": model_evaluations,
  "Served Model Prediction": np.array(served_predictions['predictions'], dtype=np.float32),
})
```

The output shows, the live predictions are also as reliable as those, which were computed locally:

```python
	Model Prediction	Served Model Prediction
0	0.000761	0.000140
1	0.008630	0.005238
2	0.027949	0.008637
3	0.080788	0.043080
4	0.047794	0.029655
```
For the CI/CD task I applied terraform method, first I created the tfstate container:

![cicd_cont](https://github.com/user-attachments/assets/e5449d60-2e45-4eaa-b417-4bd99d7d7bb3)

Then modified the terraform and Makefile files.
first the main.tf (deleted the sensitive informations):

```python
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
    resource_group_name  = "rg-m"
    storage_account_name = "dem"
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
  path     = "/Users/bl.com/cicd_ml"
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

```
Then the variables.tf file:
```python
variable "AZURE_SUBSCRIPTION_ID" {}
variable "AZURE_TENANT_ID" {}
variable "AZURE_CLIENT_ID" {}
variable "AZURE_CLIENT_SECRET" {}
variable "DATABRICKS_HOST" {}
variable "DATABRICKS_TOKEN" {}

variable "STORAGE_ACCOUNT_NAME" {}
variable "RESOURCE_GROUP_NAME" {}
```
Also the terraform.tfvars file, where the secrets are stored.

I executed first the terraform init command and got this output:
```python
c:\data_eng\házi\3>terraform init
Initializing the backend...

Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing provider plugins...
- Finding hashicorp/azurerm versions matching ">= 4.0.0"...
- Finding databricks/databricks versions matching ">= 1.0.0"...
- Installing hashicorp/azurerm v4.24.0...
- Installed hashicorp/azurerm v4.24.0 (signed by HashiCorp)
- Installing databricks/databricks v1.70.0...
- Installed databricks/databricks v1.70.0 (self-signed, key ID 9)
Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html
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
```
Then the terraform plan:

```python
c:\data_eng\házi\3>terraform plan
data.databricks_spark_version.latest_lts: Reading...
databricks_notebook.cicd_ml: Refreshing state... [id=/Users/ba.com/cicd_ml]
data.databricks_spark_version.latest_lts: Read complete after 0s [id=15.4.x-scala2.12]
databricks_cluster.cicd1: Refreshing state... [id=03q]
databricks_job.cicd_ml: Refreshing state... [id=880]
azurerm_storage_account.Azure_Spark_ML_storage: Refreshing state... [id=/subscript/resourceGroups/rsm/providers/Microsoft.Storage/storageAccounts/devwesteuropesm]
azurerm_storage_container.data: Refreshing state... [id=https://d.blob.core.windows.net/data]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # databricks_notebook.cicd_ml will be updated in-place
  ~ resource "databricks_notebook" "cicd_ml" {
        id             = "/Users/ba.com/cicd_ml"
      ~ md5            = "80a5544" -> "different"
      ~ source         = "./cicd.dbc" -> "./1by1_ML_1_cop.dbc"
        # (7 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
╷
│ Warning: Argument is deprecated
│
│   with azurerm_storage_container.data,
│   on main.tf line 66, in resource "azurerm_storage_container" "data":
│   66:   storage_account_name  = azurerm_storage_account.Azure_Spark_ML_storage.name
│
│ the `storage_account_name` property has been deprecated in favour of `storage_account_id` and will be removed in version 5.0 of the Provider.
╵

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.

```

And finally the terraform apply command and then started the job manually:


```python
c:\data_eng\házi\3>terraform apply
data.databricks_spark_version.latest_lts: Reading...
databricks_notebook.cicd_ml: Refreshing state... [id=/Users/bom/cicd_ml]
data.databricks_spark_version.latest_lts: Read complete after 1s [id=15.4.x-scala2.12]
databricks_cluster.cicd1: Refreshing state... [id=03q]
databricks_job.cicd_ml: Refreshing state... [id=8880]
azurerm_storage_account.Azure_Spark_ML_storage: Refreshing state... [id=/subscriptions/69d1cd1/resourceGroups/rsm/providers/Microsoft.Storage/storageAccounts/devwesteuropesm]
azurerm_storage_container.data: Refreshing state... [id=https://d.blob.core.windows.net/data]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # databricks_notebook.cicd_ml will be updated in-place
  ~ resource "databricks_notebook" "cicd_ml" {
        id             = "/Users/ba.com/cicd_ml"
      ~ md5            = "80a4" -> "different"
      ~ source         = "./cicd.dbc" -> "./1by1_ML_1_cop.dbc"
        # (7 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
╷
│ Warning: Argument is deprecated
│
│   with azurerm_storage_container.data,
│   on main.tf line 66, in resource "azurerm_storage_container" "data":
│   66:   storage_account_name  = azurerm_storage_account.Azure_Spark_ML_storage.name
│
│ the `storage_account_name` property has been deprecated in favour of `storage_account_id` and will be removed in version 5.0 of the Provider.
╵

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

databricks_notebook.cicd_ml: Modifying... [id=/Users/balm/cicd_ml]
databricks_notebook.cicd_ml: Modifications complete after 2s [id=/Users/baom/cicd_ml]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

job_ids = {
  "cicd_ml" = "880888874189180"
}

c:\data_eng\házi\3>databricks jobs run-now --job-id 880888874189180
WARN: Your CLI is configured to use Jobs API 2.0. In order to use the latest Jobs features please upgrade to 2.1: 'databricks jobs configure --version=2.1'. Future versions of this CLI will default to the new Jobs API. Learn more at https://docs.databricks.com/dev-tools/cli/jobs-cli.html
{
  "run_id": 936887152179528,
  "number_in_job": 936887152179528
}

c:\data_eng\házi\3>
```

Here you can see the created cluster:

![ci_clust](https://github.com/user-attachments/assets/5815f972-b722-4471-9f18-2718b18da3d9)

And the created job:

![ci_job](https://github.com/user-attachments/assets/6fe2645f-3003-4726-a988-94edf49e6c2c)

Here is the outcome of the Seaborn cell:

![ci_1](https://github.com/user-attachments/assets/b22fbede-f4f3-41a9-9a3c-6f938f34d88a)

The result of the matplotlib cell:

![ci_2](https://github.com/user-attachments/assets/71a51fb2-2352-4d9a-b238-03d87807a731)

The outcome of the Parallel hyperparameter cell:

![ci_3](https://github.com/user-attachments/assets/6348375d-8836-4a70-8529-a99c147caa2d)


The result of the hyperparameter sweep cell:

![ci_4](https://github.com/user-attachments/assets/609db3cb-8651-42be-bffa-7bc7e33f26b4)

The outcome of the Register the best model cell:

![ci_5](https://github.com/user-attachments/assets/324103bd-b8c6-46b8-a69e-d7365f3ff963)

The result of the apply the registered cell:

![ci_6](https://github.com/user-attachments/assets/eaa05cab-3a58-42f1-b67e-12203132caaf)

And the outcome of the Setup serving model cell:

![ci_7](https://github.com/user-attachments/assets/5b63d54a-469e-4a92-8dba-c4adaf2c1dd0)

Here you can see the details of the successful job run:

![ci_job_suc](https://github.com/user-attachments/assets/54f4e61f-a3e0-4547-86d8-f4a00cfcf70a)











