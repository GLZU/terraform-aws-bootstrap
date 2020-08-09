# Module to create workspace
# 1.   Create Git from the template
# 1.1  Create workspace with newly created 
locals {
   repo_name = "Account1-Create"
   git_org = "GLZU"
   tf_hostname = "10.1.199.170"
   tf_org = "TFOLZU"
   
   bootstrap_template = {
      owner = "GLZU"
      branch = "master"
      repository = "template-bootstrap-account"
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
  organization = local.git_org  
}

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

