# Github Self-Hosted Runners (Terraform) (EC2)

This is a Terraform repository that contains Terraform code to spin up an EC2 Instance acting as the GitHub Self Hosted Runner for a particular GitHub Repository.

In order to use this Repository to construct your GitHub Self Hosted Runners for a given GitHub Repository; you will first require to generate a GitHub "PAT" token for which this token will be used by the GitHub Self Hosted Runners (EC2 Instances) to authenticate on your behalf to the GitHub Repository you wanted the GitHub Self Hosted Runners to run your GitHub Actions Workflows.

This can be easily done by following this guide:
https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token

If you are the owner of the GitHub Repository for which you want to setup GitHub Self Hosted Runners for then no further action on the GitHub side is required.
Otherwise, if you're not the owner of the GitHub Repository you need to be added to the GitHub Repository as an "outside collaborator" with the appropriate priviledges. Instructions can be found here: https://docs.github.com/en/organizations/managing-access-to-your-organizations-repositories/adding-outside-collaborators-to-repositories-in-your-organization

In full, the owner of the PAT token will need to have the appropriate rights to the GitHub Repository you are trying to setup GitHub Self Hosted Runners for using this Repository.

Once you configured the PAT token and connected your GitHub Repository to the PAT token owner (as described above); you can then proceed as follows to continue with setting up this GitHub Self Hosted Runners Repository by executing the standard Terraform workflow to provision the GitHub Self Hosted Runners infrastructure resources on AWS Cloud.


The Terraform code expects arguments to be passed in to the variable parameters as there are no defaults set enabling the user of this particular GitHub Repository to configure it accordingly to their needs.
```
Need to profile
provider "aws" {
  profile = "xxxxx"
  region  = "us-west-2"
}
```

```bash
terraform init
terraform plan -var-file locals.tfvars
terraform apply -var-file locals.tfvars
```
An example `locals.tfvars` is given below:

```hcl
ami                   = "ami-06cffe063efe892ad" # Amazon Linux 2 AMI for us-west-2
vpc_id                = "vpc-xxxxxx"
instance_type         = "t2.micro"
key_name              = # your KeyPair name
github_repo_pat_token = # The GitHub Repository's Pat Token for which you want to register GitHub Runners with to authenticate
github_repo_url       = "https://github.com/{owner}/{repo}"
runner_name           = "gitHub-repo-runner"
subnets_private        = ["subnet-private1","subnet-private2","subnet-private3"]
labels                = ["dev", "infra"]

health_check_grace_period = 600
desired_capacity          = 1
min_size                  = 1
max_size                  = 4
```

where owner is org  and repo represents the GitHub Repository.



