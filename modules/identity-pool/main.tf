/*************************************************************************************************
  Common module that creates a Workload Identity Pool with one Identity Provider per pool for Terraform Cloud integrarion with GCP
    
  For Workload identity tokens from Terraform Cloud refer to 
      https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/workload-identity-tokens 
  
*************************************************************************************************/
      
resource "google_iam_workload_identity_pool" "identity-pool" {
  workload_identity_pool_id = var.identity_pool_id
  display_name              = var.identity_pool_name
  description               = var.identity_pool_desc
  disabled                  = var.identity_pool_disabled
}
    
resource "google_iam_workload_identity_pool_provider" "pool-provider" {
  workload_identity_pool_id           = google_iam_workload_identity_pool.identity-pool.workload_identity_pool_id
  workload_identity_pool_provider_id  = var.pool_provider_id
  display_name                        = var.pool_provider_name
  description                         = var.pool_provider_desc
  disabled                            = var.pool_provider_disabled

  attribute_mapping                   = {
    "attribute.tfc_organization_id"   = "assertion.terraform_organization_id"
    "attribute.tfc_project_id"        = "assertion.terraform_project_id"
    "attribute.tfc_project_name"      = "assertion.terraform_project_name"
    "google.subject"                  = "assertion.terraform_workspace_id"
    "attribute.tfc_workspace_name"    = "assertion.terraform_workspace_name"
    "attribute.tfc_workspace_env"     = "assertion.terraform_workspace_name.split('-')[assertion.terraform_workspace_name.split('-').size() -1]"
  }
  oidc {
    #allowed_audiences = var.allowed_audiences TODO
    issuer_uri        = "https://app.terraform.io"
  }
  attribute_condition                =  "attribute.tfc_organization_id == '${ var.tfc_organization_id }'  && attribute.tfc_workspace_env ==   '${var.tfc_workspace_env}'"
}
