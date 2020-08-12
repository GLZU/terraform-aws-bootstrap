# Module to create workspace
# 1.   Create Git from the template
# 1.1  Create workspace with newly created 
locals {
   account_alias = var.account_alias
   
   tf_hostname = "10.1.199.170"  
   tfe_target_org  = "TFOLZU" 
   params = {
         git = {
            target_git_org = "GLZU"
            target_repo_name = "terraform-aws-${local.account_alias}"
            bootstrap_template = {            
               owner = "GLZU"
               branch = "master"
               repository = "template-bootstrap-account"
            }
         }
         tfe = {
            workspaces = [
               {
                  tf_workspace_name = "terraform-aws-${local.account_alias}-account"
                  tf_org = local.tfe_target_org
                  git_path = "account/"
                  vcs_oauth_token_id = var.vcs_oauth_token_id
               },
               {
                  tf_workspace_name = "terraform-aws-${local.account_alias}-guardrail"
                  tf_org = local.tfe_target_org    
                  git_path = "guardrail/"
                  vcs_oauth_token_id = var.vcs_oauth_token_id
               },
               {
                  tf_workspace_name = "terraform-aws-${local.account_alias}-regional"
                  tf_org = local.tfe_target_org
                  git_path = "regional/"
                  vcs_oauth_token_id = var.vcs_oauth_token_id
               }               
            ]
        }
   }
}

provider "tfe" {
  alias    = "tfe1"
  hostname = local.tf_hostname
  token    = var.tfe_token
  version  = "~> 0.15.0"
}

# Configure the GitHub Provider
provider "github" {
  alias        = "github1"
  token        = var.github_token
  organization = local.params.git.target_git_org  
}

/*
module "modules" {
  source  = "10.1.199.170/TFOLZU/build-account/aws"
  version = "0.1.3"
  params = local.params
  providers = {
     github.github1 = github.github1
     tfe.tfe1       = tfe.tfe1
 }   
}*/

module create_workspace {
   source = "github.com/GLZU/terraform-aws-build-account"
   params = local.params
   providers = {
      github.github1 = github.github1
      tfe.tfe1       = tfe.tfe1
   }
}
