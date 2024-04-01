# Terraform

Resource Management within Azure 

![image](https://github.com/azeezabr/terraform/assets/101916494/3c7c5a51-0f4e-46a1-8584-23e31d309c6d)


**Note:** Creating Sbscription via Terraform is not possible (because subscriptions are managed through the Azure portal or Azure account management services, not through the Azure Resource Manager (ARM) API which Terraform interacts with.)



## Installing Terraform:
  * Windows:
  * [Microsoft resource link](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash?tabs=bash)



## Authenticate Terraform to Azure:
  - Azure CLI
  - Managed Service Identity
  - Service Principal and a Client Certificate
  - Service Principal and a Client Secret
  - OpenID Connect

**Note: ** Terraform recommends using either a Service Principal or Managed Service Identity when running Terraform non-interactively (such as when running Terraform in a CI server) - and authenticating using the Azure CLI when running Terraform locally.

* [Terraform resource link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)


## Data Source and Import in Terraform
* [Useful Link](https://chat.openai.com/share/463fe80e-4f92-4f2f-917e-1ee5ac203857)


## Useful commands:
```terraform
 terraform state list
 terraform state show <resource>
 terraform plan -destroy
 terraform apply -destroy
 terraform apply -auto-approve
ssh -i <C:\Users\..> rootUser@<ip>
```
