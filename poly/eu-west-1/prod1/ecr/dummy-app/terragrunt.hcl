# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../"
}

dependencies {
  paths = ["../"]
}

locals {
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  proj    = read_terragrunt_config(find_in_parent_folders("proj.hcl"))


  # Extract the variables we need for easy access
  account_name = local.account.locals.account_name
  account_id   = local.account.locals.aws_account_id
  aws_region   = local.region.locals.aws_region

  namespace = "${local.proj.locals.project}-${local.env.locals.environment}"
}

inputs = {
  name            = "dummy-app"
  repository_name = "${local.proj.locals.project}"
  # principals_readonly_access = ["arn:aws:iam::329054710135:user/liya@tikalk.com"]
  principals_readonly_access = ["arn:aws:iam::${local.account_id}:role/liya-ops"]

  # principals_full_access = ["arn:aws:iam::329054710135:group/poly-deploy"]
  principals_full_access = ["arn:aws:iam::${local.account_id}:role/liya-ops"]
}
