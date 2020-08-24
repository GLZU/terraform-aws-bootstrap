import sys
import requests
import time
sys.path.append("../")
import pyterprise
import json

tfe_token = 'Di1Hd0jH2FtPiA.atlasv1.slyWXAxH7116psJqFzfdiNwFJN1L7NPEpQ0an9bbnzLWtxmtAPDIhMj3UQWjCMXWZHI'
github_token = "5c9cc5a8c469609fb9f831eb46aa847eb9f71913"
vcs_oauth_token_id = "ot-HyJSLofrx93mvkyf"
client = pyterprise.Client()
tf_hostname = "terraform.lab.morganstanley.com"
tfe_org = "TFOLZU"
git_org = "GLZU"
#============================


# Supply your token as a parameter and the url for the terraform enterprise server.
# If you are not self hosting, use the one provided by hashicorp.
client.init(token=tfe_token, url='https://{}/'.format(tf_hostname), ssl_verification=False)

org = client.set_organization(id=tfe_org)

# Version Control options dictionary
vcs_options = {
    "identifier": "{}/template-aws-bootstrap".format(git_org),
    "oauth-token-id": vcs_oauth_token_id,
    "branch": "master",
    "default-branch": True
}

account_alias = "account6"
workspace_name = "terraform-aws-{}-bootstrap".format(account_alias)

print(

    org.create_workspace(name=workspace_name,
                         vcs_repo=vcs_options,
                         auto_apply=True,
                         queue_all_runs=False,
                         working_directory='/',
                         trigger_prefixes=['/']))

workspace = org.get_workspace(name=workspace_name)


# Create a variable
vars = [
        {
            'key': 'tfe_token',
            'value': tfe_token,
            'category': 'terraform',
            'sensitive': True
        },
        {
            'key': 'github_token',
            'value': github_token,
            'category': 'terraform',
            'sensitive': True
        },
        {
            'key': 'vcs_oauth_token_id',
            'value': vcs_oauth_token_id,
            'category': 'terraform',
            'sensitive': True
        },
        {
            'key': 'account_alias',
            'value': account_alias,
            'category': 'terraform',
            'sensitive': False
        },
        {
            'key': 'tf_hostname',
            'value': tf_hostname,
            'category': 'terraform',
            'sensitive': False
        },
        {
            'key': 'target_tfe_org',
            'value': tfe_org,
            'category': 'terraform',
            'sensitive': False
        },
        {
            'key': 'target_git_org',
            'value': git_org,
            'category': 'terraform',
            'sensitive': False
        },
        {
            'key': 'source_git_owner',
            'value': git_org,
            'category': 'terraform',
            'sensitive': False
        }
   ]
#print(
for var in vars:
    workspace.create_variable(key=var['key'],
                              value=var['value'],
                              sensitive=var['sensitive'],
                              category=var['category'])
#)

# Get variables for a workspace
variables = workspace.list_variables()

# Update a variable.
for variable in variables:
    print(variable)

# Delete the variable we created.
#for variable in variables:
#    if variable.key == 'foo':
#        variable.delete()
time.sleep(5)
# Create and apply a run in a workspace without auto-apply settings. Logs terraform plan/apply output in console.
workspace.plan_apply(message='just testing.', destroy_flag=False)
time.sleep(5)
# Basic terraform run, easy use on auto-apply workspaces. Enable destroy flag for destruction (Default is False.)
run = workspace.run(destroy_flag=False)

# Get terraform plan output of run.
print(run.get_plan_output())

# If plan output looks ok in run lets apply it
print(run.apply('Plan output look OK.'))

# List general run data, you can apply, cancel and perform other methods on specific runs with the instantiated run object.
for run in workspace.list_runs(page=1, page_size=100):
    print(run)
    print(run.id, run.status, run.status_timestamps)
