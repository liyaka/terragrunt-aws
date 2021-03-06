# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


locals {
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  proj    = read_terragrunt_config(find_in_parent_folders("proj.hcl"))

  namespace = "${local.proj.locals.project}-${local.env.locals.environment}"
}



terraform {
}


inputs = {
  tags = {
    Terraform     = "true"
    Environment   = local.namespace
    TerraformPath = path_relative_to_include()
  }
}
