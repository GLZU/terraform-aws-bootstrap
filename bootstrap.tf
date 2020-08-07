locals {
   repo_name = "Accoun1-Create"
   git_org = "GLZU"
   lf_hostname = "10.1.199.170"
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
#  template {
#    owner = "github"
#    repository = "terraform-module-template"
#  }
}

resource "tfe_workspace" "test" {
  name         = local.repo_name
  organization = "TFEDemo"
  provider     = tfe.tfe1
  vcs_repo {
     identifier     = "${local.git_org}/${local.repo_name}"
#     branch         = local.repo_name
     oauth_token_id = var.vcs_oauth_token_id
  }
}
