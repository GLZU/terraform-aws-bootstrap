# Module to create workspace
# 1.   Create Git from the template
# 1.1  Create workspace with newly created 
locals {
   account_alias = "Account1-Create"
   
   tf_hostname = "10.1.199.170"  
   
   params = {
      git = {
         target_git_org = "GLZU"
         bootstrap_template = {            
            git_org = "GLZU"
            branch = "master"
            repository = "template-bootstrap-account"
         }
         repo_name = "terraform-aws-${local.account_alias}"
         owner = "GLZU"
      }
      tfe = {
         tf_workspace_name = "terraform-aws-${local.account_alias}"
         tf_org = "TFOLZU"   
         vcs_oauth_token_id = var.vcs_oauth_token_id
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

module create_workspace {
   source = "github.com/GLZU/terraform-aws-modules.git/LandingZone/mod_workspace"
   params = local.params
   providers = {
      github.github1 = github.github1
      tfe.tfe1       = tfe.tfe1
   }
}

/*
# Add a user to the organization
resource "github_repository" "git_repo" {
  name         = local.repo_name
  description  = local.repo_name
  provider     = github.github1
# private = true
# Valid templates would be Accuont Creation, Guard
 template {
    owner = local.bootstrap_template.owner
    repository = local.bootstrap_template.repository
  }
}

resource "tfe_workspace" "ws" {
  name         = local.repo_name
  organization = local.tf_org
  provider     = tfe.tfe1
  vcs_repo {
     identifier     = "${local.git_org}/${local.repo_name}"
#     branch         = local.repo_name
     oauth_token_id = var.vcs_oauth_token_id
  }
  depends_on = [github_repository.git_repo]
}

# Add Variables
resource "tfe_variable" "tfv" {
  key          = "my_key_name"
  value        = "my_value_name"
  category     = "terraform"
  workspace_id = tfe_workspace.ws.id
  description  = "a useful description"
  provider     = tfe.tfe1
}
*/
